//
//  PayloadInfo.swift
//  streams
//
//  Created by @graphiclife on April 17, 2024.
//

import Foundation
import gstreamer_swift

public struct PayloadInfo: Codable {
    public struct Capability: Codable {
        public enum CapabilityName: String {
            case events = "events"
            case useInbandFec = "useinbandfec"
        }

        public let name: String
        public let value: String

        public init(name: CapabilityName, value: String) {
            self.name = name.rawValue
            self.value = value
        }

        public func `is`(_ capabilityName: CapabilityName) -> Bool {
            return name == capabilityName.rawValue
        }
    }

    public let type: Int
    public let clockRate: Int
    public let channels: Int
    public let codec: Codec
    public let capabilities: [Capability]

    public init(type: Int, clockRate: Int, channels: Int, codec: Codec, capabilities: [Capability] = []) {
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

    public func elementsForDecoding() -> (depay: Element, decoder: Element) {
        let depay: Element
        let decoder: Element

        switch codec {
        case .opus:
            depay = Element("rtpopusdepay")
            decoder = Element("opusdec")

            if let capability = capabilities.first(where: { $0.is(.useInbandFec) }) {
                decoder.set("use-inband-fec", to: capability.value == "1" )
            }

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

    public func elementsForEncoding() -> (encoder: Element, pay: Element) {
        let encoder: Element
        let pay: Element

        switch codec {
        case .opus:
            encoder = Element("opusenc")

            if let capability = capabilities.first(where: { $0.is(.useInbandFec) }) {
                encoder.set("inband-fec", to: capability.value == "1" )
            }

            pay = Element("rtpopuspay")
                .set("pt", to: UInt32(type))

        case .g722:
            encoder = Element("avenc_g722")
            pay = Element("rtpg722pay")
                .set("pt", to: UInt32(type))

        case .pcmu:
            encoder = Element("mulawenc")
            pay = Element("rtppcmupay")
                .set("pt", to: UInt32(type))

        case .pcma:
            encoder = Element("alawenc")
            pay = Element("rtppcmapay")
                .set("pt", to: UInt32(type))

        case .telephoneEvent, .av1, .h264, .vp8, .vp9:
            fatalError("not implemented")
        }

        return (encoder, pay)
    }
}

