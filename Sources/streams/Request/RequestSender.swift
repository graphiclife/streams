//
//  RequestSender.swift
//  streams
//
//  Created by @graphiclife on April 17, 2024.
//

import Foundation

public class RequestSender: ApplicationService {
    public enum RequestSenderError: Error {
        case badRequest
    }

    public unowned let application: Application

    public required init(application: Application) {
        self.application = application
    }

    public func send<T: Codable>(request: T) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(request)

        data.withUnsafeBytes { (buffer: UnsafeRawBufferPointer) in
            write(STDOUT_FILENO, buffer.baseAddress, buffer.count)
            write(STDOUT_FILENO, "\n", 1)
        }
    }
}
