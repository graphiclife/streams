//
//  RTPReceiver.swift
//  streams
//
//  Created by @graphiclife on April 17, 2024.
//

import Foundation
import gstreamer
import gstreamer_swift

public final class RTPReceiver {
    public struct Peer {
        public let ssrc: Int
        public let payload: Payload
        public let pad: Pad
    }

    public typealias PeerHandler = (Peer) -> Void
    public typealias SenderChangeHandler = (RTPNetworkProbe.Sender) -> Void

    public static func create(in pipeline: Pipeline,
                              application: Application,
                                 payloads: [Payload],
                                   onPeer: @escaping PeerHandler,
                        onRTPSenderChange: @escaping SenderChangeHandler,
                       onRTCPSenderChange: @escaping SenderChangeHandler) throws -> RTPReceiver {
        let portTuple = application.usingService { (ports: Ports) in
            return ports.next()
        }

        let rtpBin = Element("rtpbin").add(to: pipeline)
        let rtpSinkPad = try rtpBin.pad(request: "recv_rtp_sink_0")
        let rtcpSinkPad = try rtpBin.pad(request: "recv_rtcp_sink_0")

        let rtpSrc = Element("udpsrc")
            .set("port", to: portTuple.rtp)
            .set("caps", to: Caps.empty(mediaType: "application/x-rtp"))
            .add(to: pipeline)

        try rtpSrc
            .pad(static: "src")
            .addProbe(RTPNetworkProbe(handler: { sender in
                onRTPSenderChange(sender)
            }))
            .link(to: rtpSinkPad)

        let rtcpSrc = Element("udpsrc")
            .set("port", to: portTuple.rtcp)
            .set("caps", to: Caps.empty(mediaType: "application/x-rtcp"))
            .add(to: pipeline)

        try rtcpSrc
            .pad(static: "src")
            .addProbe(RTPNetworkProbe(handler: { sender in
                onRTCPSenderChange(sender)
            }))
            .link(to: rtcpSinkPad)

        try rtpBin.connect(signal: "request-pt-map") { (element: Element, session: UInt32, pt: UInt32) -> Caps in
            guard let payload = payloads.first(where: { $0.type == pt }) else {
                return .empty(mediaType: "application/x-rtp")
            }

            return payload.caps
        }

        try rtpBin.connect(signal: "pad-added") { (element: Element, pad: Pad) in
            guard let name = pad.name else {
                return
            }

            let regex = /^recv_rtp_src_(?<session>\d+)_(?<ssrc>\d+)_(?<pt>\d+)$/

            guard let match = try? regex.wholeMatch(in: name) else {
                return
            }

            guard let ssrc = Int(match.ssrc), let pt = Int(match.pt) else {
                return
            }

            guard let payload = payloads.first(where: { $0.type == pt }) else {
                return
            }

            onPeer(.init(ssrc: ssrc, payload: payload, pad: pad))
        }

        return .init(portTuple: portTuple)
    }

    public let portTuple: PortTuple

    private init(portTuple: PortTuple) {
        self.portTuple = portTuple
    }
}
