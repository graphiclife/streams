//
//  RequestParser.swift
//  streams
//
//  Created by @graphiclife on April 17, 2024.
//

import Foundation

public class RequestParser: ApplicationService {
    public enum RequestParserError: Error {
        case badRequest
    }

    typealias Decoder = (Data) throws -> Void

    public unowned let application: Application

    private var requestHandlers = [String: Decoder]()
    private var requestDataBuffer = Data()

    public required init(application: Application) {
        self.application = application
    }

    public func registerRequestHandler<T: Request>(_ handler: RequestHandler<T>) {
        requestHandlers[T.name] = handler.decoder
    }

    func readFromFile(_ fileno: Int32) {
        var bytesRead = 0

        fputs("Reading data\n", stderr)

        repeat {
            bytesRead = withUnsafeTemporaryAllocation(of: UInt8.self, capacity: 1024) { buffer in
                guard let baseAddress = buffer.baseAddress else {
                    return 0
                }

                let numberOfBytes = read(fileno, baseAddress, 1024)

                if numberOfBytes > 0 {
                    requestDataBuffer.append(baseAddress, count: numberOfBytes)
                }

                return bytesRead
            }
        } while (bytesRead >= 1024)
        
        parse()
    }

    private func parse() {
        let newline = Data(repeating: 10, count: 1)

        while let range = requestDataBuffer.range(of: newline) {
            let data = requestDataBuffer[..<range.lowerBound]

            data.withUnsafeBytes { (buffer: UnsafeRawBufferPointer) in
                write(STDERR_FILENO, "\n", 1)
                write(STDERR_FILENO, "\n", 1)

                write(STDERR_FILENO, buffer.baseAddress, buffer.count)
                
                write(STDERR_FILENO, "\n", 1)
                write(STDERR_FILENO, "\n", 1)
            }

            do {
                let base = try JSONDecoder().decode(RequestBaseData.self, from: data)

                guard let handler = requestHandlers[base.name] else {
                    throw RequestParserError.badRequest
                }
                
                try handler(data)
            } catch {
                fputs("Error decoding request: \(error)\n", stderr)
            }

            requestDataBuffer.removeSubrange(..<range.upperBound)
        }
    }
}
