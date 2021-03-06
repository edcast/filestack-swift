//
//  AVTransform.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 21/08/2017.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation

/// Converts a video or audio to a different format, resolution, sample rate, etc.
public class AVTransform: Transform {
    // MARK: - Lifecycle

    /// Initializes an `AVTransform` object.
    public init() {
        super.init(name: "video_convert")
    }
}

// MARK: - Public Functions

public extension AVTransform {
    /// Adds the `preset` option.
    ///
    /// - Parameter value: The format to convert to.
    /// See (File Processing - Video Conversion)[https://www.filestack.com/docs/video-transformations]
    /// for more information about supported presets.
    @discardableResult
    func preset(_ value: String) -> Self {
        return appending(key: "preset", value: value)
    }

    /// Adds the `force` option.
    ///
    /// - Parameter value: Restarts completed or pending video encoding. If a transcoding fails, and you make the same
    /// request again, it will not restart the transcoding process unless this parameter is set to `true`.
    @discardableResult
    func force(_ value: Bool) -> Self {
        return appending(key: "force", value: value)
    }

    /// Adds the `width` option.
    ///
    /// - Parameter value: Set the width in pixels of the video that is generated by the transcoding process.
    @discardableResult
    func width(_ value: Int) -> Self {
        return appending(key: "width", value: value)
    }

    /// Adds the `height` option.
    ///
    /// - Parameter value: Set the height in pixels of the video that is generated by the transcoding process.
    @discardableResult
    func height(_ value: Int) -> Self {
        return appending(key: "height", value: value)
    }

    /// Adds the `title` option.
    ///
    /// - Parameter value: Set the title in the file metadata.
    @discardableResult
    func title(_ value: String) -> Self {
        return appending(key: "title", value: value)
    }

    /// Adds the `extName` option.
    ///
    /// - Parameter value: Set the file extension for the video that is generated by the transcoding process.
    @discardableResult
    func extName(_ value: String) -> Self {
        return appending(key: "extname", value: value)
    }

    /// Adds the `fileName` option.
    ///
    /// - Parameter value: Set the filename of the video that is generated by the transcoding process.
    @discardableResult
    func fileName(_ value: String) -> Self {
        return appending(key: "filename", value: value)
    }

    /// Adds the `location` option.
    ///
    /// - Parameter value: An `StorageLocation` value.
    @discardableResult
    func location(_ value: StorageLocation) -> Self {
        return appending(key: "location", value: value)
    }

    /// Adds the `path` option.
    ///
    /// - Parameter value: The path to store the file at within the specified file store.
    /// For S3, this is the key where the file will be stored at. By default, Filestack stores the file at the root at
    /// a unique id, followed by an underscore, followed by the filename, for example: `3AB239102DB_myvideo.mp4`.
    @discardableResult
    func path(_ value: String) -> Self {
        return appending(key: "path", value: value)
    }

    /// Adds the `access` option.
    ///
    /// - Parameter value: An `StorageAccess` value.
    @discardableResult
    func access(_ value: StorageAccess) -> Self {
        return appending(key: "access", value: value)
    }

    /// Adds the `container` option.
    ///
    /// - Parameter value: The bucket or container in the specified file store where the file
    /// should end up.
    @discardableResult
    func container(_ value: String) -> Self {
        return appending(key: "container", value: value)
    }

    /// Adds the `upscale` option.
    ///
    /// - Parameter value: Upscale the video resolution to match your profile. Defaults to `true`.
    @discardableResult
    func upscale(_ value: Bool) -> Self {
        return appending(key: "upscale", value: value)
    }

    /// Adds the `aspectMode` option.
    ///
    /// - Parameter value: An `TransformAspectMode` value.
    @discardableResult
    func aspectMode(_ value: TransformAspectMode) -> Self {
        return appending(key: "aspect_mode", value: value)
    }

    /// Adds the `twoPass` option.
    ///
    /// - Parameter value: Specify that the transcoding process should do two passes to improve video quality.
    /// Defaults to `false`.
    @discardableResult
    func twoPass(_ value: Bool) -> Self {
        return appending(key: "two_pass", value: value)
    }

    /// Adds the `videoBitRate` option.
    ///
    /// - Parameter value: Specify the video bitrate for the video that is generated by the transcoding process.
    /// Valid range: `1...5000`
    @discardableResult
    func videoBitRate(_ value: Int) -> Self {
        return appending(key: "video_bitrate", value: value)
    }

    /// Adds the `fps` option.
    ///
    /// - Parameter value: Specify the frames per second of the video that is generated by the transcoding process.
    /// Valid range: `1...300`. If ommited, uses the original fps of the source file.
    @discardableResult
    func fps(_ value: Int) -> Self {
        return appending(key: "fps", value: value)
    }

    /// Adds the `keyframeInterval` option.
    ///
    /// - Parameter value: Adds a key frame every `keyframeInterval` frames to the video that is generated by the
    /// transcoding process. Default is `250`.
    @discardableResult
    func keyframeInterval(_ value: Int) -> Self {
        return appending(key: "keyframe_interval", value: value)
    }

    /// Adds the `audioBitRate` option.
    ///
    /// - Parameter value: Sets the audio bitrate for the video that is generated by the transcoding process.
    /// Valid range: `0...999`
    @discardableResult
    func audioBitRate(_ value: Int) -> Self {
        return appending(key: "audio_bitrate", value: value)
    }

    /// Adds the `audioSampleRate` option.
    ///
    /// - Parameter value: Set the audio sample rate for the video that is generated by the transcoding process.
    /// Valid range: `0...99999`. Default is `44100`.
    @discardableResult
    func audioSampleRate(_ value: Int) -> Self {
        return appending(key: "audio_samplerate", value: value)
    }

    /// Adds the `audioChannels` option.
    ///
    /// - Parameter value: Set the number of audio channels for the video that is generated by the transcoding process.
    /// Valid range: `1...12`. Default is same as source video.
    @discardableResult
    func audioChannels(_ value: Int) -> Self {
        return appending(key: "audio_channels", value: value)
    }

    /// Adds the `clipLength` option.
    ///
    /// - Parameter value: Set the length of the video that is generated by the transcoding process. Valid format
    /// should include hours, minutes and seconds.
    @discardableResult
    func clipLength(_ value: String) -> Self {
        return appending(key: "clip_length", value: value)
    }

    /// Adds the `clipOffset` option.
    ///
    /// - Parameter value: Set the point to begin the video clip from. For example, `00:00:10`
    /// will start the video transcode 10 seconds into the source video. Valid format should include hours, minutes
    /// and seconds.
    @discardableResult
    func clipOffset(_ value: String) -> Self {
        return appending(key: "clip_offset", value: value)
    }

    /// Adds the `watermarkURL` option.
    ///
    /// - Parameter value: The Filestack handle or URL of the image file to use as a watermark on the transcoded video.
    @discardableResult
    func watermarkURL(_ value: URL) -> Self {
        return appending(key: "watermark_url", value: value)
    }

    /// Adds the `watermarkTop` option.
    ///
    /// - Parameter value: The distance from the top of the video frame to place the watermark on the video.
    /// Valid range: `0...9999`
    @discardableResult
    func watermarkTop(_ value: Int) -> Self {
        return appending(key: "watermark_top", value: value)
    }

    /// Adds the `watermarkBottom` option.
    ///
    /// - Parameter value: The distance from the bottom of the video frame to place the watermark on the video.
    /// Valid range: `0...9999`
    @discardableResult
    func watermarkBottom(_ value: Int) -> Self {
        return appending(key: "watermark_bottom", value: value)
    }

    /// Adds the `watermarkLeft` option.
    ///
    /// - Parameter value: The distance from the left of the video frame to place the watermark on the video.
    /// Valid range: `0...9999`
    @discardableResult
    func watermarkLeft(_ value: Int) -> Self {
        return appending(key: "watermark_left", value: value)
    }

    /// Adds the `watermarkRight` option.
    ///
    /// - Parameter value: The distance from the right of the video frame to place the watermark on the video.
    /// Valid range: `0...9999`
    @discardableResult
    func watermarkRight(_ value: Int) -> Self {
        return appending(key: "watermark_right", value: value)
    }

    /// Adds the `watermarkWidth` option.
    ///
    /// - Parameter value: Resize the width of the watermark.
    @discardableResult
    func watermarkWidth(_ value: Int) -> Self {
        return appending(key: "watermark_width", value: value)
    }

    /// Adds the `watermarkHeight` option.
    ///
    /// - Parameter value: Resize the height of the watermark.
    @discardableResult
    func watermarkHeight(_ value: Int) -> Self {
        return appending(key: "watermark_height", value: value)
    }
}
