//
//  Request.swift
//  streams
//
//  Created by @graphiclife on April 17, 2024.
//

import Foundation

public protocol Request: Codable {
    static var name: String { get }
}

public struct RequestHandler<T: Request> {
    public typealias Handler = (T) throws -> Void

    private let handler: Handler

    public init(handler: @escaping Handler) {
        self.handler = handler
    }

    var decoder: (Data) throws -> Void {
        return { data in
            try handler(try JSONDecoder().decode(T.self, from: data))
        }
    }
}

struct RequestBaseData: Codable {
    let name: String
}
