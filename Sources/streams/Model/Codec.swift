//
//  Codec.swift
//  streams
//
//  Created by @graphiclife on April 17, 2024.
//

import Foundation

public enum Codec: String, Codable {
    case opus
    case g722
    case pcmu
    case pcma
    case telephoneEvent

    case h264
    case vp8
    case vp9
    case av1

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
