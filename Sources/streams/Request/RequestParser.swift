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

    public typealias ErrorHandler = (Error) -> Void

    typealias Decoder = (Data) throws -> Void

    public unowned let application: Application

    private var requestHandlers = [String: Decoder]()
    private var requestDataBuffer = Data()
    private var errorHandlers = [ErrorHandler]()

    public required init(application: Application) {
        self.application = application
    }

    public func registerRequestHandler<T: Request>(_ handler: RequestHandler<T>) {
        requestHandlers[T.name] = handler.decoder
    }

    public func registerErrorHandler(_ handler: @escaping ErrorHandler) {
        errorHandlers.append(handler)
    }

    func readFromFile(_ fileno: Int32) {
        var bytesRead = 0

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

            do {
                let base = try JSONDecoder().decode(RequestBaseData.self, from: data)

                guard let handler = requestHandlers[base.name] else {
                    throw RequestParserError.badRequest
                }
                
                try handler(data)
            } catch {
                errorHandlers.forEach { handler in
                    handler(error)
                }
            }

            requestDataBuffer.removeSubrange(..<range.upperBound)
        }
    }
}
