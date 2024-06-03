//
//  RTPSender.swift
//  streams
//
//  Created by @graphiclife on April 17, 2024.
//

import Foundation
import gstreamer
import gstreamer_swift

public final class RTPSender {
    public static func create(in pipeline: Pipeline, transport: Transport, payloads: [PayloadInfo], bindPort: PortTuple) throws -> RTPSender {
        let rtpBin = Element("rtpbin").add(to: pipeline)
        let rtpUDPSink = Element("udpsink")
            .set("host", to: "127.0.0.1")
            .set("port", to: Int32(transport.port.rtp))
            .set("bind-port", to: Int32(bindPort.rtp))
            .add(to: pipeline)

        let rtcpUDPSink = Element("udpsink")
            .set("host", to: "127.0.0.1")
            .set("port", to: Int32(transport.port.rtcp))
            .set("bind-port", to: Int32(bindPort.rtcp))
            .add(to: pipeline)

        let queue = Element("queue")
            .set("max-size-bytes", to: UInt32(0))
            .set("max-size-buffers", to: UInt32(0))
            .add(to: pipeline)

        try rtpBin.connect(signal: "request-pt-map") { (element: Element, session: UInt32, pt: UInt32) -> Caps in
            guard let payload = payloads.first(where: { $0.type == pt }) else {
                return .empty(mediaType: "application/x-rtp")
            }

            return payload.caps
        }

        try rtpBin.connect(signal: "pad-added") { (element: Element, pad: Pad) in
            guard let name = pad.name, name == "send_rtp_src_0" else {
                return
            }

            do {
                try pad.link(to: queue.pad(static: "sink"))
            } catch {
                _ = fputs("Error linking \(error)\n", stderr)
            }
        }

        let rtcpSrcPad = try rtpBin.pad(request: "send_rtcp_src_0")
        let rtpSinkPad = try rtpBin.pad(request: "send_rtp_sink_0")

        try rtcpSrcPad.link(to: rtcpUDPSink.pad(static: "sink"))
        try queue.link(to: rtpUDPSink)

        return .init(rtpSinkPad: rtpSinkPad, rtpUDPSink: rtpUDPSink, rtcpUDPSink: rtcpUDPSink)
    }

    public let rtpSinkPad: Pad

    private let rtpUDPSink: Element
    private let rtcpUDPSink: Element

    private init(rtpSinkPad: Pad, rtpUDPSink: Element, rtcpUDPSink: Element) {
        self.rtpSinkPad = rtpSinkPad
        self.rtpUDPSink = rtpUDPSink
        self.rtcpUDPSink = rtcpUDPSink
    }

    public func updateRTPTransport(_ transport: Transport) {
        rtpUDPSink
            .set("host", to: transport.host)
            .set("port", to: transport.port.rtp)
    }

    public func updateRTCPTransport(_ transport: Transport) {
        rtcpUDPSink
            .set("host", to: transport.host)
            .set("port", to: transport.port.rtcp)
    }
}
