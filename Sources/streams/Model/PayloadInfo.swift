//
//  PayloadInfo.swift
//  streams
//
//  Created by @graphiclife on April 17, 2024.
//

import Foundation
import gstreamer_swift

public struct PayloadInfo: Codable {
    public let type: Int
    public let clockRate: Int
    public let channels: Int
    public let codec: Codec
    public let capabilities: [String: String]?

    public init(type: Int, clockRate: Int, channels: Int, codec: Codec, capabilities: [String : String]? = nil) {
        self.type = type
        self.clockRate = clockRate
        self.channels = channels
        self.codec = codec
        self.capabilities = capabilities
    }

    public var caps: Caps {
        return Caps.Builder()
            .begin(mediaType: "application/x-rtp")
            .set("payload", to: UInt32(type))
            .set("clock-rate", to: Int32(clockRate))
            .set("media", to: codec.media)
            .set("encoding-name", to: codec.encodingName)
            .build()
    }

    public func elementsForDecodingRTP() -> (depay: Element, decoder: Element) {
        let depay: Element
        let decoder: Element

        switch codec {
        case .opus:
            depay = Element("rtpopusdepay")
            decoder = Element("opusdec")

        case .g722:
            depay = Element("rtpg722depay")
            decoder = Element("avdec_g722")

        case .pcmu:
            depay = Element("rtppcmudepay")
            decoder = Element("mulawdec")

        case .pcma:
            depay = Element("rtppcmadepay")
            decoder = Element("alawdec")

        case .telephoneEvent:
            depay = Element("rtpdtmfdepay")
            decoder = Element("fakesink")

        case .h264, .vp8, .vp9, .av1:
            fatalError("not implemented")
        }

        return (depay, decoder)
    }
}

