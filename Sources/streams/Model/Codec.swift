//
//  Codec.swift
//  streams
//
//  Created by @graphiclife on April 17, 2024.
//

import Foundation

public enum Codec: String, Codable {
    public static func fromMimeType(_ mimeType: String) -> Codec? {
        switch mimeType.lowercased() {
        case "audio/opus":
            return .opus

        case "audio/g722":
            return .g722

        case "audio/pcmu":
            return .pcmu

        case "audio/pcma":
            return .pcma

        case "audio/telephone-event":
            return .telephoneEvent

        case "video/h264":
            return .h264

        case "video/vp8":
            return .vp8

        case "video/vp9":
            return .vp9

        case "video/av1":
            return .av1

        default:
            return nil
        }
    }

    case opus = "opus"
    case g722 = "g722"
    case pcmu = "pcmu"
    case pcma = "pcma"
    case telephoneEvent = "telephone-event"
    case h264 = "h264"
    case vp8 = "vp8"
    case vp9 = "vp9"
    case av1 = "av1"

    public var media: String {
        switch self {
        case .opus, .g722, .pcmu, .pcma, .telephoneEvent:
            return "audio"

        case .h264, .vp8, .vp9, .av1:
            return "video"
        }
    }

    public var encodingName: String {
        switch self {
        case .opus:
            return "OPUS"

        case .g722:
            return "G722"

        case .pcmu:
            return "PCMU"

        case .pcma:
            return "PCMA"

        case .telephoneEvent:
            return "TELEPHONE-EVENT"

        case .h264:
            return "H264"

        case .vp8:
            return "VP8"

        case .vp9:
            return "VP9"

        case .av1:
            return "AV1"
        }
    }
}
