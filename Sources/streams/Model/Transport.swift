//
//  Transport.swift
//  streams
//
//  Created by @graphiclife on April 17, 2024.
//

import Foundation

public struct Transport: Codable {
    public let host: String
    public let port: PortTuple

    public init(host: String, port: PortTuple) {
        self.host = host
        self.port = port
    }
}
