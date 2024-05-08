//
//  Application.swift
//  streams
//
//  Created by @graphiclife on April 17, 2024.
//

import Dispatch
import Foundation
import gstreamer
import gstreamer_swift

public protocol ApplicationProvider {
    var application: Application { get }
}

public protocol ApplicationService: ApplicationProvider {
    init(application: Application)
}

public class Application {
    private enum State {
        case idle
        case running(loop: MainLoop)
    }

    public let context = MainContext()

    private let queue = DispatchQueue(label: "application")
    private var signals = [DispatchSourceSignal]()
    private var io = [DispatchSourceRead]()

    private var state: State = .idle

    public init() {
    }

    public func run() {
        setup()
        dispatchMain()
    }

    private func setup() {
        setupSignals()
        setupContext()
        setupIO()
    }

    private func setupSignals() {
        let cleanup = {
            switch self.state {
            case .idle:
                break

            case .running(let loop):
                loop.quit()
            }

            exit(EXIT_SUCCESS)
        }

        for sig in [SIGINT, SIGQUIT, SIGTERM] {
            signal(sig, SIG_IGN)

            let source = DispatchSource.makeSignalSource(signal: sig, queue: queue)
            source.setEventHandler(qos: .background, handler: cleanup)
            source.resume()

            signals.append(source)
        }
    }

    private func setupContext() {
        Task {
            var argc: Int32 = 0
            gst_init(&argc, nil)

            context.pushThreadDefault()
            let loop = context.loop()
            state = .running(loop: loop)
            loop.run()
            context.popThreadDefault()
        }
    }

    private func setupIO() {
        let parser = usingService { (parser: RequestParser) in
            return parser
        }

        let source = DispatchSource.makeReadSource(fileDescriptor: STDIN_FILENO, queue: queue)
        source.setEventHandler(qos: .default) {
            parser.readFile(STDIN_FILENO)
        }
        source.resume()
        io.append(source)
    }

    //
    //  Services
    //

    var services = [String: ApplicationService]()

    func service<T: ApplicationService>() -> T {
        let key = String(describing: T.self)

        if let service = services[key] as? T {
            return service
        }

        let service = T(application: self)
        services[key] = service
        return service
    }

    @discardableResult
    public func usingService<T: ApplicationService, Result>(execute serviceAction: (T) throws -> Result) rethrows -> Result {
        try serviceAction(service())
    }
}
