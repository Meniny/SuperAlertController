
import Foundation
import UIKit
import AVFoundation
import CoreGraphics

extension UIAlertController {
    
    public var videoPlayerController: VideoPlayerController? {
        return self.contentViewController as? VideoPlayerController
    }
    
    /// Add a Video Player
    ///
    /// - Parameter url: An URL
    public func addVideoPlayer(url: URL, ratio: CGFloat) {
        let controller = VideoPlayerController.init()
        controller.url = url
        controller.ratio = ratio
        controller.playbackLoops = true
        self.setContentViewController(controller)
    }
}

// MARK: - types

/// Video fill mode options for `VideoPlayerController.fillMode`.
///
/// - resize: Stretch to fill.
/// - resizeAspectFill: Preserve aspect ratio, filling bounds.
/// - resizeAspectFit: Preserve aspect ratio, fill within bounds.
public enum VideoPlayerFillMode {
    case resize
    case resizeAspectFill
    case resizeAspectFit // default
    
    public var avFoundationType: String {
        get {
            switch self {
            case .resize:
                return AVLayerVideoGravity.resize.rawValue
            case .resizeAspectFill:
                return AVLayerVideoGravity.resizeAspectFill.rawValue
            case .resizeAspectFit:
                return AVLayerVideoGravity.resizeAspect.rawValue
            }
        }
    }
}

/// Asset playback states.
public enum PlaybackState: Int, CustomStringConvertible {
    case stopped = 0
    case playing
    case paused
    case failed
    
    public var description: String {
        get {
            switch self {
            case .stopped:
                return "Stopped"
            case .playing:
                return "Playing"
            case .failed:
                return "Failed"
            case .paused:
                return "Paused"
            }
        }
    }
}

/// Asset buffering states.
public enum BufferingState: Int, CustomStringConvertible {
    case unknown = 0
    case ready
    case delayed
    
    public var description: String {
        get {
            switch self {
            case .unknown:
                return "Unknown"
            case .ready:
                return "Ready"
            case .delayed:
                return "Delayed"
            }
        }
    }
}

// MARK: - VideoPlayerDelegate

/// VideoPlayerController delegate protocol
public protocol VideoPlayerDelegate: NSObjectProtocol {
    func playerReady(_ player: VideoPlayerController)
    func playerPlaybackStateDidChange(_ player: VideoPlayerController)
    func playerBufferingStateDidChange(_ player: VideoPlayerController)
    
    // This is the time in seconds that the video has been buffered.
    // If implementing a UIProgressView, user this value / player.maximumDuration to set progress.
    func playerBufferTimeDidChange(_ bufferTime: Double)
}


/// VideoPlayerController playback protocol
public protocol VideoPlayerPlaybackDelegate: NSObjectProtocol {
    func playerCurrentTimeDidChange(_ player: VideoPlayerController)
    func playerPlaybackWillStartFromBeginning(_ player: VideoPlayerController)
    func playerPlaybackDidEnd(_ player: VideoPlayerController)
    func playerPlaybackWillLoop(_ player: VideoPlayerController)
}

// MARK: - VideoPlayerController

/// ▶️ VideoPlayerController, simple way to play and stream media
open class VideoPlayerController: UIViewController {
    
    /// VideoPlayerController delegate.
    open weak var playerDelegate: VideoPlayerDelegate?
    
    /// Playback delegate.
    open weak var playbackDelegate: VideoPlayerPlaybackDelegate?
    
    // configuration
    
    /// Local or remote URL for the file asset to be played.
    ///
    /// - Parameter url: URL of the asset.
    open var url: URL? {
        didSet {
            setup(url: url)
        }
    }
    
    /// Determines if the video should autoplay when a url is set
    ///
    /// - Parameter bool: defaults to true
    open var autoplay: Bool = true
    
    /// For setting up with AVAsset instead of URL
    /// Note: Resets URL (cannot set both)
    open var asset: AVAsset? {
        get { return _asset }
        set { _ = newValue.map { setupAsset($0) } }
    }
    
    /// Mutes audio playback when true.
    open var muted: Bool {
        get {
            return self._avplayer.isMuted
        }
        set {
            self._avplayer.isMuted = newValue
        }
    }
    
    /// Volume for the player, ranging from 0.0 to 1.0 on a linear scale.
    open var volume: Float {
        get {
            return self._avplayer.volume
        }
        set {
            self._avplayer.volume = newValue
        }
    }
    
    /// Specifies how the video is displayed within a player layer’s bounds.
    /// The default value is `AVLayerVideoGravityResizeAspect`. See `FillMode` enum.
    open var fillMode: String {
        get {
            return self._playerView.fillMode
        }
        set {
            self._playerView.fillMode = newValue
        }
    }
    
    /// Pauses playback automatically when resigning active.
    open var playbackPausesWhenResigningActive: Bool = true
    
    /// Pauses playback automatically when backgrounded.
    open var playbackPausesWhenBackgrounded: Bool = true
    
    /// Resumes playback when became active.
    open var playbackResumesWhenBecameActive: Bool = true
    
    /// Resumes playback when entering foreground.
    open var playbackResumesWhenEnteringForeground: Bool = true
    
    // state
    
    /// Playback automatically loops continuously when true.
    open var playbackLoops: Bool {
        get {
            return self._avplayer.actionAtItemEnd == .none
        }
        set {
            if newValue {
                self._avplayer.actionAtItemEnd = .none
            } else {
                self._avplayer.actionAtItemEnd = .pause
            }
        }
    }
    
    /// Playback freezes on last frame frame at end when true.
    open var playbackFreezesAtEnd: Bool = false
    
    /// Current playback state of the VideoPlayerController.
    open var playbackState: PlaybackState = .stopped {
        didSet {
            if playbackState != oldValue || !playbackEdgeTriggered {
                self.playerDelegate?.playerPlaybackStateDidChange(self)
            }
        }
    }
    
    /// Current buffering state of the VideoPlayerController.
    open var bufferingState: BufferingState = .unknown {
        didSet {
            if bufferingState != oldValue || !playbackEdgeTriggered {
                self.playerDelegate?.playerBufferingStateDidChange(self)
            }
        }
    }
    
    /// Playback buffering size in seconds.
    open var bufferSize: Double = 10
    
    /// Playback is not automatically triggered from state changes when true.
    open var playbackEdgeTriggered: Bool = true
    
    /// Maximum duration of playback.
    open var maximumDuration: TimeInterval {
        get {
            if let playerItem = self._playerItem {
                return CMTimeGetSeconds(playerItem.duration)
            } else {
                return CMTimeGetSeconds(kCMTimeIndefinite)
            }
        }
    }
    
    /// Media playback's current time.
    open var currentTime: TimeInterval {
        get {
            if let playerItem = self._playerItem {
                return CMTimeGetSeconds(playerItem.currentTime())
            } else {
                return CMTimeGetSeconds(kCMTimeIndefinite)
            }
        }
    }
    
    /// The natural dimensions of the media.
    open var naturalSize: CGSize {
        get {
            if let playerItem = self._playerItem,
                let track = playerItem.asset.tracks(withMediaType: .video).first {
                
                let size = track.naturalSize.applying(track.preferredTransform)
                return CGSize(width: fabs(size.width), height: fabs(size.height))
            } else {
                return CGSize.zero
            }
        }
    }
    
    /// VideoPlayerController view's initial background color.
    open var layerBackgroundColor: UIColor? {
        get {
            guard let backgroundColor = self._playerView.playerLayer.backgroundColor
                else {
                    return nil
            }
            return UIColor(cgColor: backgroundColor)
        }
        set {
            self._playerView.playerLayer.backgroundColor = newValue?.cgColor
        }
    }
    
    // MARK: - private instance vars
    
    internal var _asset: AVAsset? {
        didSet {
            if let _ = self._asset {
                self.setupPlayerItem(nil)
            }
        }
    }
    internal var _avplayer: AVPlayer
    internal var _playerItem: AVPlayerItem?
    internal var _timeObserver: Any?
    
    internal var _playerView: VideoPlayerView = VideoPlayerView(frame: .zero)
    internal var _seekTimeRequested: CMTime?
    
    internal var _lastBufferTime: Double = 0
    
    //Boolean that determines if the user or calling coded has trigged autoplay manually.
    internal var _hasAutoplayActivated: Bool = true
    
    /// height / width
    open var ratio: CGFloat = 0.5
    
    // MARK: - object lifecycle
    
    public convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        self._avplayer = AVPlayer()
        self._avplayer.actionAtItemEnd = .pause
        self._timeObserver = nil
        
        super.init(coder: aDecoder)
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self._avplayer = AVPlayer()
        self._avplayer.actionAtItemEnd = .pause
        self._timeObserver = nil
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    deinit {
        self.stop()
        self.setupPlayerItem(nil)
        
        self.removePlayerObservers()
        
        self.playerDelegate = nil
        self.removeApplicationObservers()
        
        self.playbackDelegate = nil
        self.removePlayerLayerObservers()
        self._playerView.player = nil
    }
    
    // MARK: - view lifecycle
    
    open override func loadView() {
//        self._playerView.playerLayer.isHidden = true
        self._playerView.backgroundColor = UIColor.black
        self.view = self._playerView
        let size = CGSize.init(width: UIAlertController.width, height: UIAlertController.width * self.ratio)
        self.view.addConstraint(NSLayoutConstraint.init(item: self.view, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: size.width))
        self.view.addConstraint(NSLayoutConstraint.init(item: self.view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: size.height))
        self.view.bounds = CGRect.init(origin: .zero, size: size)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        if let url = url {
            setup(url: url)
        } else if let asset = asset {
            setupAsset(asset)
        }
        
        self.addPlayerLayerObservers()
        self.addPlayerObservers()
        self.addApplicationObservers()
        
        self.playFromBeginning()
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self._playerView.playerLayer.frame = self._playerView.bounds
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if self.playbackState == .playing {
            self.pause()
        }
    }
    
    // MARK: - Playback funcs
    
    /// Begins playback of the media from the beginning.
    open func playFromBeginning() {
        self.playbackDelegate?.playerPlaybackWillStartFromBeginning(self)
        self._avplayer.seek(to: kCMTimeZero)
        self.playFromCurrentTime()
    }
    
    /// Begins playback of the media from the current time.
    open func playFromCurrentTime() {
        if !autoplay {
            //external call to this method with auto play off.  activate it before calling play
            _hasAutoplayActivated = true
        }
        play()
    }
    
    fileprivate func play() {
        if autoplay || _hasAutoplayActivated {
            self.playbackState = .playing
            self._avplayer.play()
        }
    }
    
    /// Pauses playback of the media.
    open func pause() {
        if self.playbackState != .playing {
            return
        }
        
        self._avplayer.pause()
        self.playbackState = .paused
    }
    
    /// Stops playback of the media.
    open func stop() {
        if self.playbackState == .stopped {
            return
        }
        
        self._avplayer.pause()
        self.playbackState = .stopped
        self.playbackDelegate?.playerPlaybackDidEnd(self)
    }
    
    /// Updates playback to the specified time.
    ///
    /// - Parameters:
    ///   - time: The time to switch to move the playback.
    ///   - completionHandler: Call block handler after seeking/
    open func seek(to time: CMTime, completionHandler: ((Bool) -> Swift.Void)? = nil) {
        if let playerItem = self._playerItem {
            return playerItem.seek(to: time, completionHandler: completionHandler)
        } else {
            _seekTimeRequested = time
        }
    }
    
    /// Updates the playback time to the specified time bound.
    ///
    /// - Parameters:
    ///   - time: The time to switch to move the playback.
    ///   - toleranceBefore: The tolerance allowed before time.
    ///   - toleranceAfter: The tolerance allowed after time.
    ///   - completionHandler: call block handler after seeking
    open func seekToTime(to time: CMTime, toleranceBefore: CMTime, toleranceAfter: CMTime, completionHandler: ((Bool) -> Swift.Void)? = nil) {
        if let playerItem = self._playerItem {
            return playerItem.seek(to: time, toleranceBefore: toleranceBefore, toleranceAfter: toleranceAfter, completionHandler: completionHandler)
        }
    }
    
    /// Captures a snapshot of the current VideoPlayerController view.
    ///
    /// - Returns: A UIImage of the player view.
    open func takeSnapshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self._playerView.frame.size, false, UIScreen.main.scale)
        self._playerView.drawHierarchy(in: self._playerView.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    /// Return the av player layer for consumption by
    /// things such as Picture in Picture
    open func playerLayer() -> AVPlayerLayer? {
        return self._playerView.playerLayer
    }
}

// MARK: - loading funcs

extension VideoPlayerController {
    
    fileprivate func setup(url: URL?) {
        guard isViewLoaded else { return }
        
        // ensure everything is reset beforehand
        if self.playbackState == .playing {
            self.pause()
        }
        
        //Reset autoplay flag since a new url is set.
        _hasAutoplayActivated = false
        if autoplay {
            playbackState = .playing
        } else {
            playbackState = .stopped
        }
        
        self.setupPlayerItem(nil)
        
        if let url = url {
            let asset = AVURLAsset(url: url, options: .none)
            self.setupAsset(asset)
        }
    }
    
    fileprivate func setupAsset(_ asset: AVAsset) {
        guard isViewLoaded else { return }
        
        if self.playbackState == .playing {
            self.pause()
        }
        
        self.bufferingState = .unknown
        
        self._asset = asset
        
        let keys = [VideoPlayerTracksKey, VideoPlayerPlayableKey, VideoPlayerDurationKey]
        self._asset?.loadValuesAsynchronously(forKeys: keys, completionHandler: { () -> Void in
            for key in keys {
                var error: NSError? = nil
                let status = self._asset?.statusOfValue(forKey: key, error:&error)
                if status == .failed {
                    self.playbackState = .failed
                    return
                }
            }
            
            if let asset = self._asset {
                if !asset.isPlayable {
                    self.playbackState = .failed
                    return
                }
                
                let playerItem = AVPlayerItem(asset:asset)
                self.setupPlayerItem(playerItem)
            }
        })
    }
    
    fileprivate func setupPlayerItem(_ playerItem: AVPlayerItem?) {
        self._playerItem?.removeObserver(self, forKeyPath: VideoPlayerEmptyBufferKey, context: &VideoPlayerItemObserverContext)
        self._playerItem?.removeObserver(self, forKeyPath: VideoPlayerKeepUpKey, context: &VideoPlayerItemObserverContext)
        self._playerItem?.removeObserver(self, forKeyPath: VideoPlayerStatusKey, context: &VideoPlayerItemObserverContext)
        self._playerItem?.removeObserver(self, forKeyPath: VideoPlayerLoadedTimeRangesKey, context: &VideoPlayerItemObserverContext)
        
        if let currentPlayerItem = self._playerItem {
            NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: currentPlayerItem)
            NotificationCenter.default.removeObserver(self, name: .AVPlayerItemFailedToPlayToEndTime, object: currentPlayerItem)
        }
        
        self._playerItem = playerItem
        
        if let seek = _seekTimeRequested, self._playerItem != nil {
            _seekTimeRequested = nil
            self.seek(to: seek)
        }
        
        self._playerItem?.addObserver(self, forKeyPath: VideoPlayerEmptyBufferKey, options: [.new, .old], context: &VideoPlayerItemObserverContext)
        self._playerItem?.addObserver(self, forKeyPath: VideoPlayerKeepUpKey, options: [.new, .old], context: &VideoPlayerItemObserverContext)
        self._playerItem?.addObserver(self, forKeyPath: VideoPlayerStatusKey, options: [.new, .old], context: &VideoPlayerItemObserverContext)
        self._playerItem?.addObserver(self, forKeyPath: VideoPlayerLoadedTimeRangesKey, options: [.new, .old], context: &VideoPlayerItemObserverContext)
        
        if let updatedPlayerItem = self._playerItem {
            NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidPlayToEndTime(_:)), name: .AVPlayerItemDidPlayToEndTime, object: updatedPlayerItem)
            NotificationCenter.default.addObserver(self, selector: #selector(playerItemFailedToPlayToEndTime(_:)), name: .AVPlayerItemFailedToPlayToEndTime, object: updatedPlayerItem)
        }
        
        self._avplayer.replaceCurrentItem(with: self._playerItem)
        
        // update new playerItem settings
        if self.playbackLoops {
            self._avplayer.actionAtItemEnd = .none
        } else {
            self._avplayer.actionAtItemEnd = .pause
        }
    }
    
}

// MARK: - NSNotifications

extension VideoPlayerController {
    
    // MARK: - AVPlayerItem
    
    @objc internal func playerItemDidPlayToEndTime(_ aNotification: Notification) {
        if self.playbackLoops {
            self.playbackDelegate?.playerPlaybackWillLoop(self)
            self._avplayer.seek(to: kCMTimeZero)
        } else {
            if self.playbackFreezesAtEnd {
                self.stop()
            } else {
                self._avplayer.seek(to: kCMTimeZero, completionHandler: { _ in
                    self.stop()
                })
            }
        }
    }
    
    @objc internal func playerItemFailedToPlayToEndTime(_ aNotification: Notification) {
        self.playbackState = .failed
    }
    
    // MARK: - UIApplication
    
    internal func addApplicationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleApplicationWillResignActive(_:)), name: .UIApplicationWillResignActive, object: UIApplication.shared)
        NotificationCenter.default.addObserver(self, selector: #selector(handleApplicationDidBecomeActive(_:)), name: .UIApplicationDidBecomeActive, object: UIApplication.shared)
        NotificationCenter.default.addObserver(self, selector: #selector(handleApplicationDidEnterBackground(_:)), name: .UIApplicationDidEnterBackground, object: UIApplication.shared)
        NotificationCenter.default.addObserver(self, selector: #selector(handleApplicationWillEnterForeground(_:)), name: .UIApplicationWillEnterForeground, object: UIApplication.shared)
    }
    
    internal func removeApplicationObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - handlers
    
    @objc internal func handleApplicationWillResignActive(_ aNotification: Notification) {
        if self.playbackState == .playing && self.playbackPausesWhenResigningActive {
            self.pause()
        }
    }
    
    @objc internal func handleApplicationDidBecomeActive(_ aNotification: Notification) {
//        if self.playbackState != .playing && self.playbackResumesWhenBecameActive {
//            self.play()
//        }
    }
    
    @objc internal func handleApplicationDidEnterBackground(_ aNotification: Notification) {
        if self.playbackState == .playing && self.playbackPausesWhenBackgrounded {
            self.pause()
        }
    }
    
    @objc internal func handleApplicationWillEnterForeground(_ aNoticiation: Notification) {
//        if self.playbackState != .playing && self.playbackResumesWhenEnteringForeground {
//            self.play()
//        }
    }
    
}

// MARK: - KVO

// KVO contexts

private var VideoPlayerObserverContext = 0
private var VideoPlayerItemObserverContext = 0
private var VideoPlayerLayerObserverContext = 0

// KVO player keys

private let VideoPlayerTracksKey = "tracks"
private let VideoPlayerPlayableKey = "playable"
private let VideoPlayerDurationKey = "duration"
private let VideoPlayerRateKey = "rate"

// KVO player item keys

private let VideoPlayerStatusKey = "status"
private let VideoPlayerEmptyBufferKey = "playbackBufferEmpty"
private let VideoPlayerKeepUpKey = "playbackLikelyToKeepUp"
private let VideoPlayerLoadedTimeRangesKey = "loadedTimeRanges"

// KVO player layer keys

private let VideoPlayerReadyForDisplayKey = "readyForDisplay"

extension VideoPlayerController {
    
    // MARK: - AVPlayerLayerObservers
    
    internal func addPlayerLayerObservers() {
        self._playerView.layer.addObserver(self, forKeyPath: VideoPlayerReadyForDisplayKey, options: [.new, .old], context: &VideoPlayerLayerObserverContext)
    }
    
    internal func removePlayerLayerObservers() {
        self._playerView.layer.removeObserver(self, forKeyPath: VideoPlayerReadyForDisplayKey, context: &VideoPlayerLayerObserverContext)
    }
    
    // MARK: - AVPlayerObservers
    
    internal func addPlayerObservers() {
        self._timeObserver = self._avplayer.addPeriodicTimeObserver(forInterval: CMTimeMake(1, 100), queue: DispatchQueue.main, using: { [weak self] timeInterval in
            guard let strongSelf = self
                else {
                    return
            }
            strongSelf.playbackDelegate?.playerCurrentTimeDidChange(strongSelf)
        })
        self._avplayer.addObserver(self, forKeyPath: VideoPlayerRateKey, options: [.new, .old], context: &VideoPlayerObserverContext)
    }
    
    internal func removePlayerObservers() {
        NotificationCenter.default.removeObserver(self)
        if let observer = self._timeObserver {
            self._avplayer.removeTimeObserver(observer)
        }
        self._avplayer.removeObserver(self, forKeyPath: VideoPlayerRateKey, context: &VideoPlayerObserverContext)
    }
    
    // MARK: -
    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        
        // VideoPlayerRateKey, VideoPlayerObserverContext
        
        if context == &VideoPlayerItemObserverContext {
            
            // VideoPlayerStatusKey
            
            if keyPath == VideoPlayerKeepUpKey {
                
                // VideoPlayerKeepUpKey
                
                if let item = self._playerItem {
                    
                    if item.isPlaybackLikelyToKeepUp {
                        self.bufferingState = .ready
                        if self.playbackState == .playing {
                            self.playFromCurrentTime()
                        }
                    }
                }
                
                if let status = change?[NSKeyValueChangeKey.newKey] as? NSNumber {
                    switch status.intValue as AVPlayerStatus.RawValue {
                    case AVPlayerStatus.readyToPlay.rawValue:
                        self._playerView.playerLayer.player = self._avplayer
                        self._playerView.playerLayer.isHidden = false
                    case AVPlayerStatus.failed.rawValue:
                        self.playbackState = PlaybackState.failed
                    default:
                        break
                    }
                }
                
            } else if keyPath == VideoPlayerEmptyBufferKey {
                
                // VideoPlayerEmptyBufferKey
                
                if let item = self._playerItem {
                    if item.isPlaybackBufferEmpty {
                        self.bufferingState = .delayed
                    }
                }
                
                if let status = change?[NSKeyValueChangeKey.newKey] as? NSNumber {
                    switch status.intValue as AVPlayerStatus.RawValue {
                    case AVPlayerStatus.readyToPlay.rawValue:
                        self._playerView.playerLayer.player = self._avplayer
                        self._playerView.playerLayer.isHidden = false
                    case AVPlayerStatus.failed.rawValue:
                        self.playbackState = PlaybackState.failed
                    default:
                        break
                    }
                }
                
            } else if keyPath == VideoPlayerLoadedTimeRangesKey {
                
                // VideoPlayerLoadedTimeRangesKey
                
                if let item = self._playerItem {
                    self.bufferingState = .ready
                    
                    let timeRanges = item.loadedTimeRanges
                    if let timeRange = timeRanges.first?.timeRangeValue {
                        let bufferedTime = CMTimeGetSeconds(CMTimeAdd(timeRange.start, timeRange.duration))
                        if _lastBufferTime != bufferedTime {
                            self.executeClosureOnMainQueueIfNecessary {
                                self.playerDelegate?.playerBufferTimeDidChange(bufferedTime)
                            }
                            _lastBufferTime = bufferedTime
                        }
                    }
                    
                    let currentTime = CMTimeGetSeconds(item.currentTime())
                    if ((_lastBufferTime - currentTime) >= self.bufferSize ||
                        _lastBufferTime == maximumDuration ||
                        timeRanges.first == nil)
                        && self.playbackState == .playing
                    {
                        self.play()
                    }
                    
                }
                
            }
            
        } else if context == &VideoPlayerLayerObserverContext {
            if self._playerView.playerLayer.isReadyForDisplay {
                self.executeClosureOnMainQueueIfNecessary {
                    self.playerDelegate?.playerReady(self)
                }
            }
        }
        
    }
    
}

// MARK: - queues

extension VideoPlayerController {
    
    internal func executeClosureOnMainQueueIfNecessary(withClosure closure: @escaping () -> Void) {
        if Thread.isMainThread {
            closure()
        } else {
            DispatchQueue.main.async(execute: closure)
        }
    }
    
}

// MARK: - VideoPlayerView

internal class VideoPlayerView: UIView {
    
    // MARK: - properties
    
    override class var layerClass: AnyClass {
        get {
            return AVPlayerLayer.self
        }
    }
    
    var playerLayer: AVPlayerLayer {
        get {
            return self.layer as! AVPlayerLayer
        }
    }
    
    var player: AVPlayer? {
        get {
            return self.playerLayer.player
        }
        set {
            self.playerLayer.player = newValue
        }
    }
    
    var fillMode: String {
        get {
            return self.playerLayer.videoGravity.rawValue
        }
        set {
            self.playerLayer.videoGravity = AVLayerVideoGravity(rawValue: newValue)
        }
    }
    
    // MARK: - object lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.playerLayer.backgroundColor = UIColor.black.cgColor
        self.playerLayer.fillMode = VideoPlayerFillMode.resizeAspectFit.avFoundationType
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.playerLayer.backgroundColor = UIColor.black.cgColor
        self.playerLayer.fillMode = VideoPlayerFillMode.resizeAspectFit.avFoundationType
    }
    
    deinit {
        self.player?.pause()
        self.player = nil
    }
    
}
