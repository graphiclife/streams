//
//  SoundPlayer.swift
//  streams
//
//  Created by @graphiclife on April 17, 2024.
//

import Foundation
import gstreamer_swift

public struct SoundPlayer {
    private let location: String

    public init(location: String, pipeline: Pipeline) {
        self.location = location
    }
}

/*
 let filesrc = Element("filesrc")
     .set("location", to: "sound/\(name).mp3")
     .add(to: pipeline)

 let mpegaudioparse = Element("mpegaudioparse").add(to: pipeline)
 let mpg123audiodec = Element("mpg123audiodec").add(to: pipeline)
 let audioconvert = Element("audioconvert").add(to: pipeline)
 let audiorate = Element("audiorate").add(to: pipeline)

 let audioresample = Element("audioresample")
     .set("quality", to: Int32(10))
     .add(to: pipeline)

 let queue = Element("queue")
     .set("max-size-bytes", to: UInt32(0))
     .set("max-size-buffers", to: UInt32(0))
     .add(to: pipeline)

 try queue.pad(static: "src").offset = Int64(pipeline.clock.interval(since: pipeline.baseTime))

 try filesrc.link(to: mpegaudioparse)
 try mpegaudioparse.link(to: mpg123audiodec)
 try mpg123audiodec.link(to: audioconvert)
 try audioconvert.link(to: audioresample)
 try audioresample.link(to: audiorate)
 try audiorate.link(to: queue)
 try queue.link(to: audiomixer)

 queue.play()
 audiorate.play()
 audioresample.play()
 audioconvert.play()
 mpg123audiodec.play()
 mpegaudioparse.play()
 filesrc.play()
 */
