//
//  YTPlayerView.swift
//  YouTubePlayer-Swift
//
//  Created by Moayad Al kouz on 7/22/18.
//  Copyright © 2018 Moayad Al kouz. All rights reserved.
//

import UIKit

/** These enums represent the state of the current video in the player. */
public enum YTPlayerState: String{
    case unstarted = "-1"
    case ended = "0"
    case playing = "1"
    case paused = "2"
    case buffering = "3"
    case queued = "5"
    case unknown = "unknown"
}

/** These enums represent the resolution of the currently loaded video. */
public enum YTPlaybackQuality: String {
    case small = "small"
    case medium = "medium"
    case large = "large"
    case hd720 = "hd720"
    case hd1080 = "hd1080"
    case highRes = "highres"
    case auto = "auto" /** Addition for YouTube Live Events. */
    case defaults = "default"
    case unknown = "unknown" /** This should never be returned. It is here for future proofing. */
}

/** These enums represent error codes thrown by the player. */
public enum YTPlayerError: String{
    case invalidParam = "2"
    case html5Error = "5"
    case videoNotFound = "100" // Functionally equivalent error codes 100 and
    // 105 have been collapsed into |kYTPlayerErrorVideoNotFound|.
    case notEmbeddable = "101" // Functionally equivalent error codes 101 and
    // 150 have been collapsed into |kYTPlayerErrorNotEmbeddable|.
    case cannotFindVideo = "105"
    case sameAsNotEmbeddable = "150"
    case unknown
}

public enum YTPlayerCallback: String{
    case onReady = "onReady"
    case onStateChange = "onStateChange"
    case onPlaybackQualityChange = "onPlaybackQualityChange"
    case onError = "onError"
    case onPlayTime = "onPlayTime"
    
    case onYouTubeIframeAPIReady = "onYouTubeIframeAPIReady"
    case onYouTubeIframeAPIFailedToLoad = "onYouTubeIframeAPIFailedToLoad"
}

public enum YTRegexPatterns: String{
    case embedUrl = "^http(s)://(www.)youtube.com/embed/(.*)$"
    case adUrl = "^http(s)://pubads.g.doubleclick.net/pagead/conversion/"
    case oAuth = "^http(s)://accounts.google.com/o/oauth2/(.*)$"
    case staticProxy = "^https://content.googleapis.com/static/proxy.html(.*)$"
    case syndication = "^https://tpc.googlesyndication.com/sodar/(.*).html$"
}

public protocol YTPlayerViewDelegate {
    func playerViewDidBecomeReady(_ playerView: YTPlayerView)
    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState)
    func playerView(_ playerView: YTPlayerView, didChangeTo quality: YTPlaybackQuality)
    func playerView(_ playerView: YTPlayerView, receivedError error: YTPlayerError)
    func playerView(_ playerView: YTPlayerView, didPlayTime playTime: Float)
    func playerViewPreferredWebViewBackgroundColor(_ playerView: YTPlayerView) -> UIColor
    func playerViewPreferredInitialLoadingView(_ playerView: YTPlayerView) -> UIView?
}

public extension YTPlayerViewDelegate{
    func playerViewDidBecomeReady(_ playerView: YTPlayerView){
    }
    
    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState){
    }
    
    func playerView(_ playerView: YTPlayerView, didChangeTo quality: YTPlaybackQuality){
    }
    
    func playerView(_ playerView: YTPlayerView, receivedError error: YTPlayerError) {
    }
    
    func playerView(_ playerView: YTPlayerView, didPlayTime playTime: Float){
    }
    
    func playerViewPreferredWebViewBackgroundColor(_ playerView: YTPlayerView) -> UIColor{
        return UIColor.black
    }
    
    func playerViewPreferredInitialLoadingView(_ playerView: YTPlayerView) -> UIView?{
        return nil
    }
}


open class YTPlayerView: UIView {
    var webView: UIWebView!
    open var delegate: YTPlayerViewDelegate?
    
    var originURL: URL!
    var initialLoadingView: UIView?
    
//    /**
//     * This method loads the player with the given video ID.
//     * This is a convenience method for calling YTPlayerView::loadPlayerWithVideoId:withPlayerVars:
//     * without player variables.
//     *
//     * This method reloads the entire contents of the UIWebView and regenerates its HTML contents.
//     * To change the currently loaded video without reloading the entire UIWebView, use the
//     * YTPlayerView::cueVideoById:startSeconds:suggestedQuality: family of methods.
//     *
//     * @param videoId The YouTube video ID of the video to load in the player view.
//     * @return YES if player has been configured correctly, NO otherwise.
//     */
//    public func load(videoId: String) -> Bool{
//        return self.loadWithVideo(id: id, playerVars: nil)
//    }
//
//    /**
//     * This method loads the player with the given playlist ID.
//     * This is a convenience method for calling YTPlayerView::loadWithPlaylistId:withPlayerVars:
//     * without player variables.
//     *
//     * This method reloads the entire contents of the UIWebView and regenerates its HTML contents.
//     * To change the currently loaded video without reloading the entire UIWebView, use the
//     * YTPlayerView::cuePlaylistByPlaylistId:index:startSeconds:suggestedQuality:
//     * family of methods.
//     *
//     * @param playlistId The YouTube playlist ID of the playlist to load in the player view.
//     * @return YES if player has been configured correctly, NO otherwise.
//     */
//    public func load(playlistId: String) -> Bool{
//        return self.loadWithPlaylist(playlistId: playlistId, playerVars: nil)
//    }
    
    /**
     * This method loads the player with the given video ID and player variables. Player variables
     * specify optional parameters for video playback. For instance, to play a YouTube
     * video inline, the following playerVars dictionary would be used:
     *
     * @code
     * @{ @"playsinline" : @1 };
     * @endcode
     *
     * Note that when the documentation specifies a valid value as a number (typically 0, 1 or 2),
     * both strings and integers are valid values. The full list of parameters is defined at:
     *   https://developers.google.com/youtube/player_parameters?playerVersion=HTML5.
     *
     * This method reloads the entire contents of the UIWebView and regenerates its HTML contents.
     * To change the currently loaded video without reloading the entire UIWebView, use the
     * YTPlayerView::cueVideoById:startSeconds:suggestedQuality: family of methods.
     *
     * @param videoId The YouTube video ID of the video to load in the player view.
     * @param playerVars An NSDictionary of player parameters.
     * @return YES if player has been configured correctly, NO otherwise.
     */
    public func load(videoId: String, playerVars:[String: Any]? = nil) -> Bool{
        var newPlayerVars = [String : Any]()
        if let vars = playerVars {
            newPlayerVars = vars
        }
        let playerParams: [String : Any] = [ "videoId" : videoId, "playerVars": newPlayerVars ]
        return self.loadWithPlayerParams(additionalPlayerParams: playerParams)
        
    }
    
    /**
     * This method loads the player with the given playlist ID and player variables. Player variables
     * specify optional parameters for video playback. For instance, to play a YouTube
     * video inline, the following playerVars dictionary would be used:
     *
     * @code
     * @{ @"playsinline" : @1 };
     * @endcode
     *
     * Note that when the documentation specifies a valid value as a number (typically 0, 1 or 2),
     * both strings and integers are valid values. The full list of parameters is defined at:
     *   https://developers.google.com/youtube/player_parameters?playerVersion=HTML5.
     *
     * This method reloads the entire contents of the UIWebView and regenerates its HTML contents.
     * To change the currently loaded video without reloading the entire UIWebView, use the
     * YTPlayerView::cuePlaylistByPlaylistId:index:startSeconds:suggestedQuality:
     * family of methods.
     *
     * @param playlistId The YouTube playlist ID of the playlist to load in the player view.
     * @param playerVars An NSDictionary of player parameters.
     * @return YES if player has been configured correctly, NO otherwise.
     */
    
    
    public func load(playlistId: String, playerVars:[String: Any]? = nil) -> Bool{
        var newPlayerVars = [String : Any]()
        newPlayerVars["listType"] = "playlist"
        newPlayerVars["list"] = playlistId
        if let vars = playerVars {
            for (key,value) in vars {
                newPlayerVars.updateValue(value, forKey:key)
            }
        }
        
        let playerParams: [String : Any] = [ "playerVars": newPlayerVars ]
        return self.loadWithPlayerParams(additionalPlayerParams: playerParams)
    }
    
    //MARK:- Player controls
    
    // These methods correspond to their JavaScript equivalents as documented here:
    //   https://developers.google.com/youtube/iframe_api_reference#Playback_controls
    
    /**
     * Starts or resumes playback on the loaded video. Corresponds to this method from
     * the JavaScript API:
     *   https://developers.google.com/youtube/iframe_api_reference#playVideo
     */
    public func playVideo(){
        _ = self.stringFromEvaluatingJavaScript(jsToExecute: "player.playVideo();")
    }
    
    /**
     * Pauses playback on a playing video. Corresponds to this method from
     * the JavaScript API:
     *   https://developers.google.com/youtube/iframe_api_reference#pauseVideo
     */
    public func pauseVideo(){
        if let url = URL(string: String(format: "ytplayer://onStateChange?data=%@", YTPlayerState.paused.rawValue)){
            self.notifyDelegateOfYouTubeCallbackUrl(url: url)
        }
        _ = self.stringFromEvaluatingJavaScript(jsToExecute: "player.pauseVideo();")
    }
    
    /**
     * Stops playback on a playing video. Corresponds to this method from
     * the JavaScript API:
     *   https://developers.google.com/youtube/iframe_api_reference#stopVideo
     */
    public func stopVideo(){
        _ = self.stringFromEvaluatingJavaScript(jsToExecute: "player.stopVideo();")
    }
    
    /**
     * Seek to a given time on a playing video. Corresponds to this method from
     * the JavaScript API:
     *   https://developers.google.com/youtube/iframe_api_reference#seekTo
     *
     * @param seekToSeconds The time in seconds to seek to in the loaded video.
     * @param allowSeekAhead Whether to make a new request to the server if the time is
     *                       outside what is currently buffered. Recommended to set to YES.
     */
    public func seek(seekToSeconds: Float, allowSeekAhead: Bool){
        let secondsValue = NSNumber(value: seekToSeconds).stringValue
        let allowSeekAheadValue = self.stringForJSBoolean(boolValue: allowSeekAhead)
        let command = String(format: "player.seekTo(%@, %@);", secondsValue, allowSeekAheadValue)
        _ = self.stringFromEvaluatingJavaScript(jsToExecute: command)
    }
    
    //MARK:- Queuing videos
    
    // Queueing functions for videos. These methods correspond to their JavaScript
    // equivalents as documented here:
    //   https://developers.google.com/youtube/iframe_api_reference#Queueing_Functions
    
    /**
     * Cues a given video by its video ID for playback starting at the given time and with the
     * suggested quality. Cueing loads a video, but does not start video playback. This method
     * corresponds with its JavaScript API equivalent as documented here:
     *    https://developers.google.com/youtube/iframe_api_reference#cueVideoById
     *
     * @param videoId A video ID to cue.
     * @param startSeconds Time in seconds to start the video when YTPlayerView::playVideo is called.
     * @param suggestedQuality YTPlaybackQuality value suggesting a playback quality.
     */
    public func cue(videoId: String, startSeconds: Float, suggestedQuality: YTPlaybackQuality){
        let startSecondsValue = NSNumber(value: startSeconds).stringValue
        let qualityValue = suggestedQuality.rawValue
        let command = String(format: "player.cueVideoById('%@', %@, '%@');", videoId, startSecondsValue, qualityValue)
        _ = self.stringFromEvaluatingJavaScript(jsToExecute: command)
    }

    /**
     * Cues a given video by its video ID for playback starting and ending at the given times
     * with the suggested quality. Cueing loads a video, but does not start video playback. This
     * method corresponds with its JavaScript API equivalent as documented here:
     *    https://developers.google.com/youtube/iframe_api_reference#cueVideoById
     *
     * @param videoId A video ID to cue.
     * @param startSeconds Time in seconds to start the video when playVideo() is called.
     * @param endSeconds Time in seconds to end the video after it begins playing.
     * @param suggestedQuality YTPlaybackQuality value suggesting a playback quality.
     */
    public func cue(videoId: String, startSeconds: Float, endSeconds: Float, suggestedQuality: YTPlaybackQuality){
        let startSecondsValue = NSNumber(value: startSeconds).stringValue
        let endSecondsValue = NSNumber(value: endSeconds).stringValue
        let qualityValue = suggestedQuality.rawValue
        let command = String(format: "player.cueVideoById({'videoId': '%@', 'startSeconds': %@, 'endSeconds': %@, 'suggestedQuality': '%@'});", videoId, startSecondsValue, endSecondsValue, qualityValue)
        _ = self.stringFromEvaluatingJavaScript(jsToExecute: command)
    }
    
    /**
     * Loads a given video by its video ID for playback starting at the given time and with the
     * suggested quality. Loading a video both loads it and begins playback. This method
     * corresponds with its JavaScript API equivalent as documented here:
     *    https://developers.google.com/youtube/iframe_api_reference#loadVideoById
     *
     * @param videoId A video ID to load and begin playing.
     * @param startSeconds Time in seconds to start the video when it has loaded.
     * @param suggestedQuality YTPlaybackQuality value suggesting a playback quality.
     */
    public func load(videoId: String, startSeconds: Float, suggestedQuality: YTPlaybackQuality){
        let startSecondsValue = NSNumber(value: startSeconds).stringValue
        let qualityValue = suggestedQuality.rawValue
        let command = String(format: "player.loadVideoById('%@', %@, '%@');", videoId, startSecondsValue, qualityValue)
        _ = self.stringFromEvaluatingJavaScript(jsToExecute: command)
    }
   
    /**
     * Loads a given video by its video ID for playback starting and ending at the given times
     * with the suggested quality. Loading a video both loads it and begins playback. This method
     * corresponds with its JavaScript API equivalent as documented here:
     *    https://developers.google.com/youtube/iframe_api_reference#loadVideoById
     *
     * @param videoId A video ID to load and begin playing.
     * @param startSeconds Time in seconds to start the video when it has loaded.
     * @param endSeconds Time in seconds to end the video after it begins playing.
     * @param suggestedQuality YTPlaybackQuality value suggesting a playback quality.
     */
    public func load(videoId: String, startSeconds: Float, endSeconds: Float, suggestedQuality: YTPlaybackQuality){
        let startSecondsValue = NSNumber(value: startSeconds).stringValue
        let endSecondsValue = NSNumber(value: endSeconds).stringValue
        let qualityValue = suggestedQuality.rawValue
        let command = String(format: "player.loadVideoById({'videoId': '%@', 'startSeconds': %@, 'endSeconds': %@, 'suggestedQuality': '%@'});", videoId, startSecondsValue, endSecondsValue, qualityValue)
        _ = self.stringFromEvaluatingJavaScript(jsToExecute: command)
    }
   
    /**
     * Cues a given video by its URL on YouTube.com for playback starting at the given time
     * and with the suggested quality. Cueing loads a video, but does not start video playback.
     * This method corresponds with its JavaScript API equivalent as documented here:
     *    https://developers.google.com/youtube/iframe_api_reference#cueVideoByUrl
     *
     * @param videoURL URL of a YouTube video to cue for playback.
     * @param startSeconds Time in seconds to start the video when YTPlayerView::playVideo is called.
     * @param suggestedQuality YTPlaybackQuality value suggesting a playback quality.
     */
    public func cue(videoUrl: String, startSeconds: Float, suggestedQuality: YTPlaybackQuality){
        let startSecondsValue = NSNumber(value: startSeconds).stringValue
        let qualityValue = suggestedQuality.rawValue
        let command = String(format: "player.cueVideoByUrl('%@', %@, '%@');", videoUrl, startSecondsValue, qualityValue)
        _ = self.stringFromEvaluatingJavaScript(jsToExecute: command)
    }
   
    /**
     * Cues a given video by its URL on YouTube.com for playback starting at the given time
     * and with the suggested quality. Cueing loads a video, but does not start video playback.
     * This method corresponds with its JavaScript API equivalent as documented here:
     *    https://developers.google.com/youtube/iframe_api_reference#cueVideoByUrl
     *
     * @param videoURL URL of a YouTube video to cue for playback.
     * @param startSeconds Time in seconds to start the video when YTPlayerView::playVideo is called.
     * @param endSeconds Time in seconds to end the video after it begins playing.
     * @param suggestedQuality YTPlaybackQuality value suggesting a playback quality.
     */
    public func cue(videoUrl: String, startSeconds: Float, endSeconds: Float, suggestedQuality: YTPlaybackQuality){
        let startSecondsValue = NSNumber(value: startSeconds).stringValue
        let endSecondsValue = NSNumber(value: endSeconds).stringValue
        let qualityValue = suggestedQuality.rawValue
        let command = String(format: "player.cueVideoByUrl('%@', %@, %@, '%@');", videoUrl, startSecondsValue, endSecondsValue, qualityValue)
        _ = self.stringFromEvaluatingJavaScript(jsToExecute: command)
    }
   
    /**
     * Loads a given video by its video ID for playback starting at the given time
     * with the suggested quality. Loading a video both loads it and begins playback. This method
     * corresponds with its JavaScript API equivalent as documented here:
     *    https://developers.google.com/youtube/iframe_api_reference#loadVideoByUrl
     *
     * @param videoURL URL of a YouTube video to load and play.
     * @param startSeconds Time in seconds to start the video when it has loaded.
     * @param suggestedQuality YTPlaybackQuality value suggesting a playback quality.
     */
    public func load(videoUrl: String, startSeconds: Float, suggestedQuality: YTPlaybackQuality){
        let startSecondsValue = NSNumber(value: startSeconds).stringValue
        let qualityValue = suggestedQuality.rawValue
        let command = String(format: "player.loadVideoByUrl('%@', %@, '%@');", videoUrl, startSecondsValue, qualityValue)
        _ = self.stringFromEvaluatingJavaScript(jsToExecute: command)
    }
   
    /**
     * Loads a given video by its video ID for playback starting and ending at the given times
     * with the suggested quality. Loading a video both loads it and begins playback. This method
     * corresponds with its JavaScript API equivalent as documented here:
     *    https://developers.google.com/youtube/iframe_api_reference#loadVideoByUrl
     *
     * @param videoURL URL of a YouTube video to load and play.
     * @param startSeconds Time in seconds to start the video when it has loaded.
     * @param endSeconds Time in seconds to end the video after it begins playing.
     * @param suggestedQuality YTPlaybackQuality value suggesting a playback quality.
     */
    public func load(videoUrl: String, startSeconds: Float, endSeconds: Float, suggestedQuality: YTPlaybackQuality){
        let startSecondsValue = NSNumber(value: startSeconds).stringValue
        let endSecondsValue = NSNumber(value: endSeconds).stringValue
        let qualityValue = suggestedQuality.rawValue
        let command = String(format: "player.loadVideoByUrl('%@', %@, %@, '%@');", videoUrl, startSecondsValue, endSecondsValue, qualityValue)
        _ = self.stringFromEvaluatingJavaScript(jsToExecute: command)
    }
    
    //MARK:- Queuing functions for playlists
    
    // Queueing functions for playlists. These methods correspond to
    // the JavaScript methods defined here:
    //    https://developers.google.com/youtube/js_api_reference#Playlist_Queueing_Functions
    
    /**
     * Cues a given playlist with the given ID. The |index| parameter specifies the 0-indexed
     * position of the first video to play, starting at the given time and with the
     * suggested quality. Cueing loads a playlist, but does not start video playback. This method
     * corresponds with its JavaScript API equivalent as documented here:
     *    https://developers.google.com/youtube/iframe_api_reference#cuePlaylist
     *
     * @param playlistId Playlist ID of a YouTube playlist to cue.
     * @param index A 0-indexed position specifying the first video to play.
     * @param startSeconds Time in seconds to start the video when YTPlayerView::playVideo is called.
     * @param suggestedQuality YTPlaybackQuality value suggesting a playback quality.
     */
    public func cue(playlistId: String, index: Int, startSeconds: Float, suggestedQuality: YTPlaybackQuality){
        let playlistIdString = String(format: "'%@'", playlistId)
        self.cuePlaylist(cueingString: playlistIdString, index: index, startSeconds: startSeconds, suggestedQuality: suggestedQuality)
    }
    
  
    /**
     * Cues a playlist of videos with the given video IDs. The |index| parameter specifies the
     * 0-indexed position of the first video to play, starting at the given time and with the
     * suggested quality. Cueing loads a playlist, but does not start video playback. This method
     * corresponds with its JavaScript API equivalent as documented here:
     *    https://developers.google.com/youtube/iframe_api_reference#cuePlaylist
     *
     * @param videoIds An NSArray of video IDs to compose the playlist of.
     * @param index A 0-indexed position specifying the first video to play.
     * @param startSeconds Time in seconds to start the video when YTPlayerView::playVideo is called.
     * @param suggestedQuality YTPlaybackQuality value suggesting a playback quality.
     */
    public func cue(videoIds: [String], index: Int, startSeconds: Float, suggestedQuality: YTPlaybackQuality){
        self.cuePlaylist(cueingString: self.stringFromVideoIdArray(videoIds: videoIds), index: index, startSeconds: startSeconds, suggestedQuality: suggestedQuality)
    }

    /**
     * Loads a given playlist with the given ID. The |index| parameter specifies the 0-indexed
     * position of the first video to play, starting at the given time and with the
     * suggested quality. Loading a playlist starts video playback. This method
     * corresponds with its JavaScript API equivalent as documented here:
     *    https://developers.google.com/youtube/iframe_api_reference#loadPlaylist
     *
     * @param playlistId Playlist ID of a YouTube playlist to cue.
     * @param index A 0-indexed position specifying the first video to play.
     * @param startSeconds Time in seconds to start the video when YTPlayerView::playVideo is called.
     * @param suggestedQuality YTPlaybackQuality value suggesting a playback quality.
     */
    public func load(playlistId: String, index: Int, startSeconds: Float, suggestedQuality: YTPlaybackQuality){
        let playlistIdString = String(format: "'%@'", playlistId)
        self.loadPlaylist(cueingString: playlistIdString, index: index, startSeconds: startSeconds, suggestedQuality: suggestedQuality)
    }
   
    /**
     * Loads a playlist of videos with the given video IDs. The |index| parameter specifies the
     * 0-indexed position of the first video to play, starting at the given time and with the
     * suggested quality. Loading a playlist starts video playback. This method
     * corresponds with its JavaScript API equivalent as documented here:
     *    https://developers.google.com/youtube/iframe_api_reference#loadPlaylist
     *
     * @param videoIds An NSArray of video IDs to compose the playlist of.
     * @param index A 0-indexed position specifying the first video to play.
     * @param startSeconds Time in seconds to start the video when YTPlayerView::playVideo is called.
     * @param suggestedQuality YTPlaybackQuality value suggesting a playback quality.
     */
    public func load(videoIds: [String], index: Int, startSeconds: Float, suggestedQuality: YTPlaybackQuality){
        self.loadPlaylist(cueingString: self.stringFromVideoIdArray(videoIds: videoIds), index: index, startSeconds: startSeconds, suggestedQuality: suggestedQuality)
    }
  
    //MARK:- Playing a video in a playlist
    
    // These methods correspond to the JavaScript API as defined under the
    // "Playing a video in a playlist" section here:
    //    https://developers.google.com/youtube/iframe_api_reference#Playback_status
    
    /**
     * Loads and plays the next video in the playlist. Corresponds to this method from
     * the JavaScript API:
     *   https://developers.google.com/youtube/iframe_api_reference#nextVideo
     */
    public func nextVideo(){
        _ = self.stringFromEvaluatingJavaScript(jsToExecute: "player.nextVideo();")
    }
    
    /**
     * Loads and plays the previous video in the playlist. Corresponds to this method from
     * the JavaScript API:
     *   https://developers.google.com/youtube/iframe_api_reference#previousVideo
     */
    public func previousVideo(){
        _ = self.stringFromEvaluatingJavaScript(jsToExecute: "player.previousVideo();")
    }
    
    /**
     * Loads and plays the video at the given 0-indexed position in the playlist.
     * Corresponds to this method from the JavaScript API:
     *   https://developers.google.com/youtube/iframe_api_reference#playVideoAt
     *
     * @param index The 0-indexed position of the video in the playlist to load and play.
     */
    public func playVideo(at index: Int){
        let command = String(format: "player.playVideoAt(%@);", NSNumber(integerLiteral: index))
        _ = self.stringFromEvaluatingJavaScript(jsToExecute: command)
    }
    
    //MARK:- Setting the playback rate
    /**
     * Sets/Gets the playback rate. The default value is 1.0, which represents a video
     * playing at normal speed. Other values may include 0.25 or 0.5 for slower
     * speeds, and 1.5 or 2.0 for faster speeds. To fetch a list of valid values for
     * this method, call YTPlayerView::getAvailablePlaybackRates. This method does not
     * guarantee that the playback rate will change.
     * This method corresponds to the JavaScript API defined here:
     *   https://developers.google.com/youtube/iframe_api_reference#setPlaybackRate
     *
     * @param suggestedRate A playback rate to suggest for the player.
     */
    public var playbackRate: Float{
        set{
            let command = String(format: "player.setPlaybackRate(%f);", playbackRate)
            _ = self.stringFromEvaluatingJavaScript(jsToExecute: command)
        }
        get{
            if let result = Float(self.stringFromEvaluatingJavaScript(jsToExecute: "player.getPlaybackRate();")){
                return result
            }
            return 0
        }
    }
    
    
    /**
     * Gets a list of the valid playback rates, useful in conjunction with
     * YTPlayerView::setPlaybackRate. This method corresponds to the
     * JavaScript API defined here:
     *   https://developers.google.com/youtube/iframe_api_reference#getPlaybackRate
     *
     * @return An NSArray containing available playback rates. nil if there is an error.
     */
    public func availablePlaybackRates() -> [Float]?{
        let returnValue = self.stringFromEvaluatingJavaScript(jsToExecute: "player.getAvailablePlaybackRates();")
        
        do {
            guard let playbackRateData = returnValue.data(using: .utf8) else{
                return nil
            }
            
            let playbackRates = try JSONSerialization.jsonObject(with: playbackRateData, options: [])
            
            return playbackRates as? [Float]
        } catch  {
            return nil
        }
    }
    
    //MARK:-  Setting playback behavior for playlists
    
    /**
     * Sets whether the player should loop back to the first video in the playlist
     * after it has finished playing the last video. This method corresponds to the
     * JavaScript API defined here:
     *   https://developers.google.com/youtube/iframe_api_reference#loopPlaylist
     *
     * @param loop A boolean representing whether the player should loop.
     */
    public func set(loop: Bool){
        let loopPlayListValue = self.stringForJSBoolean(boolValue: loop)
        let command = String(format: "player.setLoop(%@);", loopPlayListValue)
        _ = self.stringFromEvaluatingJavaScript(jsToExecute: command)
    }
    
    /**
     * Sets whether the player should shuffle through the playlist. This method
     * corresponds to the JavaScript API defined here:
     *   https://developers.google.com/youtube/iframe_api_reference#shufflePlaylist
     *
     * @param shuffle A boolean representing whether the player should
     *                shuffle through the playlist.
     */
    public func set(shuffle: Bool){
        let shuffleValue = self.stringForJSBoolean(boolValue: shuffle)
        let command = String(format: "player.setShuffle(%@);", shuffleValue)
        _ = self.stringFromEvaluatingJavaScript(jsToExecute: command)
    }
    
    //MARK:- Playback status
    // These methods correspond to the JavaScript methods defined here:
    //    https://developers.google.com/youtube/js_api_reference#Playback_status
    
    /**
     * Returns a number between 0 and 1 that specifies the percentage of the video
     * that the player shows as buffered. This method corresponds to the
     * JavaScript API defined here:
     *   https://developers.google.com/youtube/iframe_api_reference#getVideoLoadedFraction
     *
     * @return A float value between 0 and 1 representing the percentage of the video
     *         already loaded.
     */
    public func videoLoadedFraction() -> Float{
        guard let result = Float(self.stringFromEvaluatingJavaScript(jsToExecute: "player.getVideoLoadedFraction();")) else {
            return 0
        }
        return result
    }
 
    /**
     * Returns the state of the player. This method corresponds to the
     * JavaScript API defined here:
     *   https://developers.google.com/youtube/iframe_api_reference#getPlayerState
     *
     * @return |YTPlayerState| representing the state of the player.
     */
    public var playerState: YTPlayerState{
        guard let state = YTPlayerState(rawValue: self.stringFromEvaluatingJavaScript(jsToExecute: "player.getPlayerState();")) else{
            return .unknown
        }
        return state
    }
   
    
    /**
     * Returns the elapsed time in seconds since the video started playing. This
     * method corresponds to the JavaScript API defined here:
     *   https://developers.google.com/youtube/iframe_api_reference#getCurrentTime
     *
     * @return Time in seconds since the video started playing.
     */
    public var currentTime: Float{
        guard let result = Float(self.stringFromEvaluatingJavaScript(jsToExecute: "player.getCurrentTime();")) else {
            return 0
        }
        return result
    }
 
    
    //MARK:- Playback quality
    
    // Playback quality. These methods correspond to the JavaScript
    // methods defined here:
    //   https://developers.google.com/youtube/js_api_reference#Playback_quality
    
    /**
     * Set and Returns the playback quality. This method corresponds to the
     * JavaScript API defined here:
     *   https://developers.google.com/youtube/iframe_api_reference#getPlaybackQuality
     *
     * @return YTPlaybackQuality representing the current playback quality.
     */
    public var playbackQuality: YTPlaybackQuality{
        get{
        guard let quality = YTPlaybackQuality(rawValue: self.stringFromEvaluatingJavaScript(jsToExecute: "player.getPlaybackQuality();")) else{
            return .unknown
        }
        return quality
        }
        set{
            let command = String(format: "player.setPlaybackQuality('%@');", playbackQuality.rawValue)
            _ = self.stringFromEvaluatingJavaScript(jsToExecute: command)
        }
    }
    
    
    /**
     * Gets a list of the valid playback quality values, useful in conjunction with
     * YTPlayerView::setPlaybackQuality. This method corresponds to the
     * JavaScript API defined here:
     *   https://developers.google.com/youtube/iframe_api_reference#getAvailableQualityLevels
     *
     * @return An NSArray containing available playback quality levels. Returns nil if there is an error.
     */
    public func availableQualityLevels() -> [YTPlaybackQuality]?{
        let value = self.stringFromEvaluatingJavaScript(jsToExecute: "player.getAvailableQualityLevels().toString();")
        if value.isEmpty{
            return nil
        }
        var levels = [YTPlaybackQuality]()
        let rawQualityValues = value.components(separatedBy: ",")
        for rawQuality in rawQualityValues{
            if let quality = YTPlaybackQuality(rawValue: rawQuality){
                levels.append(quality)
            }
        }
        
        if levels.count > 0{
            return levels
        }else{
            return nil
        }
    }
    
    //MARK:- Retrieving video information
    
    // Retrieving video information. These methods correspond to the JavaScript
    // methods defined here:
    //   https://developers.google.com/youtube/js_api_reference#Retrieving_video_information
    
    /**
     * Returns the duration in seconds since the video of the video. This
     * method corresponds to the JavaScript API defined here:
     *   https://developers.google.com/youtube/iframe_api_reference#getDuration
     *
     * @return Length of the video in seconds.
     */
    public var duration: TimeInterval{
        guard let result = Double(self.stringFromEvaluatingJavaScript(jsToExecute: "player.getDuration();")) else {
            return 0
        }
        return result
    }
    
    
    /**
     * Returns the YouTube.com URL for the video. This method corresponds
     * to the JavaScript API defined here:
     *   https://developers.google.com/youtube/iframe_api_reference#getVideoUrl
     *
     * @return The YouTube.com URL for the video. Returns nil if no video is loaded yet.
     */
    public var videoUrl: URL?{
        guard let url = URL(string: self.stringFromEvaluatingJavaScript(jsToExecute: "player.getVideoUrl();")) else{
            return nil
        }
        return url
    }
    
    /**
     * Returns the embed code for the current video. This method corresponds
     * to the JavaScript API defined here:
     *   https://developers.google.com/youtube/iframe_api_reference#getVideoEmbedCode
     *
     * @return The embed code for the current video. Returns nil if no video is loaded yet.
     */
    public var videoEmbedCode: String{
        return self.stringFromEvaluatingJavaScript(jsToExecute: "player.getVideoEmbedCode();")
    }
    
    //MARK:- Retrieving playlist information
    
    // Retrieving playlist information. These methods correspond to the
    // JavaScript defined here:
    //    https://developers.google.com/youtube/js_api_reference#Retrieving_playlist_information
    
    /**
     * Returns an ordered array of video IDs in the playlist. This method corresponds
     * to the JavaScript API defined here:
     *   https://developers.google.com/youtube/iframe_api_reference#getPlaylist
     *
     * @return An NSArray containing all the video IDs in the current playlist. |nil| on error.
     */
    public func playlist() -> [String]?{
        let returnValue = self.stringFromEvaluatingJavaScript(jsToExecute: "player.getPlaylist();")
        
        do {
            guard let playlistData = returnValue.data(using: .utf8) else{
                return nil
            }
            
            let videoIds = try JSONSerialization.jsonObject(with: playlistData, options: [])
            
            return videoIds as? [String]
        } catch  {
            return nil
        }
    }
    
    /**
     * Returns the 0-based index of the currently playing item in the playlist.
     * This method corresponds to the JavaScript API defined here:
     *   https://developers.google.com/youtube/iframe_api_reference#getPlaylistIndex
     *
     * @return The 0-based index of the currently playing item in the playlist.
     */
    public func playlistIndex() -> Int{
        guard let result = Int(self.stringFromEvaluatingJavaScript(jsToExecute: "player.getPlaylistIndex();")) else {
            return 0
        }
        return result
    }
    
    /**
     * Private method for evaluating JavaScript in the WebView.
     *
     * @param jsToExecute The JavaScript code in string format that we want to execute.
     * @return JavaScript response from evaluating code.
     */
    private func stringFromEvaluatingJavaScript(jsToExecute: String) -> String{
        guard let result = self.webView.stringByEvaluatingJavaScript(from: jsToExecute) else{
            return ""
        }
        return result
    }
    
    /**
     * Private method to convert a Swift BOOL value to JS boolean value.
     *
     * @param boolValue Swift BOOL value.
     * @return JavaScript Boolean value, i.e. "true" or "false".
     */
    private func stringForJSBoolean(boolValue: Bool) -> String{
        return boolValue ? "true" : "false";
    }
    
    //MARK:- private methods
    private func createNewWebView() -> UIWebView{
        let webView = UIWebView(frame: self.bounds)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false
        
        if let delegate = self.delegate{
            webView.backgroundColor = delegate.playerViewPreferredWebViewBackgroundColor(self)
            if webView.backgroundColor == .clear{
                webView.isOpaque = false
            }
        }
        return webView
    }
    
    /**
     * Private method to handle "navigation" to a callback URL of the format
     * ytplayer://action?data=someData
     * This is how the UIWebView communicates with the containing Swift code.
     * Side effects of this method are that it calls methods on this class's delegate.
     *
     * @param url A URL of the format ytplayer://action?data=value.
     */
    func notifyDelegateOfYouTubeCallbackUrl(url: URL){
        let query = url.query
        
        var data: String? = nil
        if let query = query{
            data = query.components(separatedBy: "=")[1]
        }
        
        if let action = url.host, let callback = YTPlayerCallback(rawValue: action){
            switch callback{
            case .onReady:
                if self.initialLoadingView != nil{
                    self.initialLoadingView?.removeFromSuperview()
                }
                self.delegate?.playerViewDidBecomeReady(self)
            case .onStateChange:
                var playerState = YTPlayerState.unknown
                if let data = data, let state = YTPlayerState(rawValue: data){
                    playerState = state
                }
                self.delegate?.playerView(self, didChangeTo: playerState)
            case .onPlaybackQualityChange:
                var playerQuality = YTPlaybackQuality.unknown
                if let data = data, let quality = YTPlaybackQuality(rawValue: data){
                    playerQuality = quality
                }
                self.delegate?.playerView(self, didChangeTo: playerQuality)
            case .onError:
                var playerError = YTPlayerError.unknown
                if let data = data, let error = YTPlayerError(rawValue: data){
                    playerError = error
                }
                self.delegate?.playerView(self, receivedError: playerError)
            case .onPlayTime:
                if let data = data, let time = Float(data){
                    self.delegate?.playerView(self, didPlayTime: time)
                }
            case .onYouTubeIframeAPIFailedToLoad:
                self.initialLoadingView?.removeFromSuperview()
            default:
                break
                
            }
        }
    }
    
    func handleHttpNavigationToUrl(url: URL) -> Bool{
        // Usually this means the user has clicked on the YouTube logo or an error message in the
        // player. Most URLs should open in the browser. The only http(s) URL that should open in this
        // UIWebView is the URL for the embed, which is of the format:
        //     http(s)://www.youtube.com/embed/[VIDEO ID]?[PARAMETERS]
        
        let absoluteString = url.absoluteString
        
        
        do {
            let ytRegex = try NSRegularExpression(pattern: YTRegexPatterns.embedUrl.rawValue, options: .caseInsensitive)
            let ytMatch  = ytRegex.firstMatch(in: absoluteString, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, absoluteString.count))
            
            let adRegex = try NSRegularExpression(pattern: YTRegexPatterns.adUrl.rawValue, options: .caseInsensitive)
            let adMatch  = adRegex.firstMatch(in: absoluteString, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, absoluteString.count))
            
            let syndicationRegex = try NSRegularExpression(pattern: YTRegexPatterns.syndication.rawValue, options: .caseInsensitive)
            let syndicationMatch  = syndicationRegex.firstMatch(in: absoluteString, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, absoluteString.count))
            
            let oauthRegex = try NSRegularExpression(pattern: YTRegexPatterns.oAuth.rawValue, options: .caseInsensitive)
            let oauthMatch  = oauthRegex.firstMatch(in: absoluteString, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, absoluteString.count))
            
            let staticProxyRegex = try NSRegularExpression(pattern: YTRegexPatterns.staticProxy.rawValue, options: .caseInsensitive)
            let staticProxyMatch  = staticProxyRegex.firstMatch(in: absoluteString, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, absoluteString.count))
            
            
            if ytMatch != nil || adMatch != nil || oauthMatch != nil || staticProxyMatch != nil || syndicationMatch != nil {
                return true
            }else{
                return false
            }
           
        } catch {
            // regex was bad!
            return false
        }
    }
    
    /**
     * Private helper method to load an iframe player with the given player parameters.
     *
     * @param additionalPlayerParams An NSDictionary of parameters in addition to required parameters
     *                               to instantiate the HTML5 player with. This differs depending on
     *                               whether a single video or playlist is being loaded.
     * @return YES if successful, NO if not.
     */
    private func loadWithPlayerParams(additionalPlayerParams:[String: Any]? = nil) -> Bool{
        let playerCallbacks = [
            "onReady" : "onReady",
            "onStateChange" : "onStateChange",
            "onPlaybackQualityChange" : "onPlaybackQualityChange",
            "onError" : "onPlayerError"
        ]
        
        var playerParams = [String : Any]()
        if let vars = additionalPlayerParams {
            playerParams = vars
        }
        
        if playerParams["height"] == nil{
            playerParams["height"] = "100%"
        }
        
        if playerParams["width"] == nil{
            playerParams["width"] = "100%"
        }
        playerParams["events"] = playerCallbacks
        
        if let vars = playerParams["playerVars"]{
            var playerVars = [String: Any]()
            playerVars["playerVars"] = vars
            
            if let origin = playerVars["origin"] as? String{
                self.originURL = URL(string: origin)
            }else{
                self.originURL = URL(string: "about:blank")
            }
        }else{
            playerParams["playerVars"] = [String: Any]()
        }
        
        self.webView?.removeFromSuperview()
        self.webView = createNewWebView()
        self.addSubview(self.webView)
        self.webView.scalesPageToFit = true
        let path: String!
        
        if UI_USER_INTERFACE_IDIOM() == .pad{
            path = Bundle.frameworkBundle()?.path(forResource: "YTPlayerView-iframe-playerIPAD", ofType: "html")
        }else{
            path = Bundle.frameworkBundle()?.path(forResource: "YTPlayerView-iframe-player", ofType: "html")
        }
        
        let embedHTMLTemplate: String!
        if let filepath = path {
            do {
                embedHTMLTemplate = try String(contentsOfFile: filepath)
            } catch(let err) {
                print("Received error rendering template: ", err)
                return false
                // contents could not be loaded
            }
        } else {
            // example.txt not found!
            print("File is not exist on path")
            return false
        }
        
        let jsonData:Data!
        
        do {
            try jsonData = JSONSerialization.data(withJSONObject: playerParams, options: .prettyPrinted)
        } catch(let err) {
            print("Attempted configuration of player with invalid playerVars: ", playerParams, " \tError: ", err)
            return false
            // contents could not be loaded
        }
        
        guard let playerVarsJsonString = String(data: jsonData, encoding: .utf8) else{
            print("Attempted configuration of player with invalid playerVars: ", playerParams)
            return false
        }
        let embedHTML = String(format: embedHTMLTemplate, playerVarsJsonString)
        self.webView.loadHTMLString(embedHTML, baseURL: self.originURL)
        self.webView.delegate = self
        self.webView.allowsInlineMediaPlayback = true
        self.webView.mediaPlaybackRequiresUserAction = false
        
        if let delegate = self.delegate{
            if let loadingView = delegate.playerViewPreferredInitialLoadingView(self){
                loadingView.frame = self.bounds
                loadingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                self.addSubview(loadingView)
                self.initialLoadingView = loadingView
            }
        }
        return true
    }
    
    /**
    * Private method for cueing both cases of playlist ID and array of video IDs. Cueing
    * a playlist does not start playback.
    *
    * @param cueingString A JavaScript string representing an array, playlist ID or list of
    *                     video IDs to play with the playlist player.
    * @param index 0-index position of video to start playback on.
    * @param startSeconds Seconds after start of video to begin playback.
    * @param suggestedQuality Suggested YTPlaybackQuality to play the videos.
    * @return The result of cueing the playlist.
    */
    private func cuePlaylist(cueingString: String, index: Int, startSeconds: Float, suggestedQuality: YTPlaybackQuality ){
        let indexValue = NSNumber(integerLiteral: index).stringValue
        let startSecondsValue = NSNumber(value: startSeconds).stringValue
        let qualityValue = suggestedQuality.rawValue
        let command = String(format: "player.cuePlaylist(%@, %@, %@, '%@');", cueingString, indexValue, startSecondsValue, qualityValue)
        
        _ = self.stringFromEvaluatingJavaScript(jsToExecute: command)
    }

    /**
     * Private method for loading both cases of playlist ID and array of video IDs. Loading
     * a playlist automatically starts playback.
     *
     * @param cueingString A JavaScript string representing an array, playlist ID or list of
     *                     video IDs to play with the playlist player.
     * @param index 0-index position of video to start playback on.
     * @param startSeconds Seconds after start of video to begin playback.
     * @param suggestedQuality Suggested YTPlaybackQuality to play the videos.
     * @return The result of cueing the playlist.
     */
    private func loadPlaylist(cueingString: String, index: Int, startSeconds: Float, suggestedQuality: YTPlaybackQuality ){
        let indexValue = NSNumber(integerLiteral: index).stringValue
        let startSecondsValue = NSNumber(value: startSeconds).stringValue
        let qualityValue = suggestedQuality.rawValue
        let command = String(format: "player.loadPlaylist(%@, %@, %@, '%@');", cueingString, indexValue, startSecondsValue, qualityValue)
        
        _ = self.stringFromEvaluatingJavaScript(jsToExecute: command)
    }
    
    /**
     * Private helper method for converting an NSArray of video IDs into its JavaScript equivalent.
     *
     * @param videoIds An array of video ID strings to convert into JavaScript format.
     * @return A JavaScript array in String format containing video IDs.
     */
    private func stringFromVideoIdArray(videoIds: [String]) -> String{
        var formattedVideoIds = [String]()
        for vidId in videoIds{
            formattedVideoIds.append(String(format: "'%@'", vidId))
        }
        
        return String(format: "[%@]", formattedVideoIds.joined(separator: ", "))
    }
    
}

extension YTPlayerView: UIWebViewDelegate{
    public func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool{
        guard  let url = request.url else {
            return true
        }
        
        if url.host == self.originURL.host{
            return true
        }else if url.scheme == "ytplayer"{
            self.notifyDelegateOfYouTubeCallbackUrl(url: url)
            return false
        }else if url.scheme == "http" || url.scheme == "https"{
            return self.handleHttpNavigationToUrl(url: url)
        }
        return true
    }
    
    public func webView(_ webView: UIWebView, didFailLoadWithError error: Error){
        self.initialLoadingView?.removeFromSuperview()
    }
}

extension Bundle{
    class func frameworkBundle() -> Bundle?{
        guard let mainBundlePath = Bundle(for: YTPlayerView.self).resourcePath else {
            return nil
        }
        let frameworkBundlePath = mainBundlePath.appending("/youtube-ios-player-helper-swift.bundle")
        return Bundle(path: frameworkBundlePath)
    }
}


















