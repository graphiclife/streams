//
//  Ports.swift
//  streams
//
//  Created by @graphiclife on April 17, 2024.
//

import Foundation

public class Ports: ApplicationService {
    private var port: Int
    private var pool = [PortTuple]()

    public unowned let application: Application

    public required init(application: Application) {
        self.application = application
        self.port = 51050
    }

    public func next() -> PortTuple {
        guard pool.isEmpty else {
            return pool.removeFirst()
        }

        defer {
            port += 2
        }

        return .init(rtp: port, rtcp: port + 1)
    }

    public func reuse(_ tuple: PortTuple) {
        pool.append(tuple)
    }
}
