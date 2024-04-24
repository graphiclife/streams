//
//  RTPNetworkProbe.swift
//  streams
//
//  Created by @graphiclife on April 17, 2024.
//

import Foundation
import gstreamer
import gstreamer_net
import gstreamer_swift

public class RTPNetworkProbe: Probe {
    public struct Sender {
        let host: String
        let port: Int
    }

    public init(handler: @escaping (Sender) -> Void) {
        super.init(type: GST_PAD_PROBE_TYPE_BUFFER, handler: { probeInfo in
            let isBufferProbe = (gst_pad_probe_info_type(probeInfo).rawValue & GST_PAD_PROBE_TYPE_BUFFER.rawValue) != 0

            guard isBufferProbe else {
                return GST_PAD_PROBE_PASS
            }

            guard let data = gst_pad_probe_info_data(probeInfo) else {
                return GST_PAD_PROBE_PASS
            }

            return data.withMemoryRebound(to: GstBuffer.self, capacity: 1) { buffer in
                guard let meta = gst_buffer_get_net_address_meta(buffer) else {
                    return GST_PAD_PROBE_PASS
                }

                guard let socketAddress = meta.pointee.addr else {
                    return GST_PAD_PROBE_PASS
                }

                return socketAddress.withMemoryRebound(to: GInetSocketAddress.self, capacity: 1) { inetSocketAddress in
                    guard let address = g_inet_socket_address_get_address(inetSocketAddress) else {
                        return GST_PAD_PROBE_PASS
                    }

                    guard let host = g_inet_address_to_string(address) else {
                        return GST_PAD_PROBE_PASS
                    }

                    handler(.init(host: String(cString: host), port: Int(g_inet_socket_address_get_port(inetSocketAddress))))

                    return GST_PAD_PROBE_REMOVE
                }
            }
        })
    }
}
