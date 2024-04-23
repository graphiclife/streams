//
//  PortTuple.swift
//  streams
//
//  Created by @graphiclife on April 17, 2024.
//

import Foundation

public struct PortTuple: Codable {
    public let rtp: Int
    public let rtcp: Int

    public init(rtp: Int, rtcp: Int) {
        self.rtp = rtp
        self.rtcp = rtcp
    }
}
