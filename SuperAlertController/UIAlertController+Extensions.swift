//
//  SuperAlertController+Extensions.swift
//  SuperAlertController
//
//  Blog  : https://meniny.cn
//  Github: https://github.com/Meniny
//
//  No more shall we pray for peace
//  Never ever ask them why
//  No more shall we stop their visions
//  Of selfdestructing genocide
//  Dogs on leads march to war
//  Go ahead end it all...
//
//  Blow up the world
//  The final silence
//  Blow up the world
//  I don't give a damn!
//
//  Screams of terror, panic spreads
//  Bombs are raining from the sky
//  Bodies burning, all is dead
//  There's no place left to hide
//  Dogs on leads march to war
//  Go ahead end it all...
//
//  Blow up the world
//  The final silence
//  Blow up the world
//  I don't give a damn!
//
//  (A voice was heard from the battle field)
//
//  "Couldn't care less for a last goodbye
//  For as I die, so do all my enemies
//  There's no tomorrow, and no more today
//  So let us all fade away..."
//
//  Upon this ball of dirt we lived
//  Darkened clouds now to dwell
//  Wasted years of man's creation
//  The final silence now can tell
//  Dogs on leads march to war
//  Go ahead end it all...
//
//  Blow up the world
//  The final silence
//  Blow up the world
//  I don't give a damn!
//
//  When I wrote this code, only I and God knew what it was.
//  Now, only God knows!
//
//  So if you're done trying 'optimize' this routine (and failed),
//  please increment the following counter
//  as a warning to the next guy:
//
//  total_hours_wasted_here = 0
//
//  Created by Elias Abel on 2018/1/10.
//  Copyright © 2018 Meniny Lab. All rights reserved.
//

import UIKit
import AudioToolbox

/// Same as `UIAlertController`
public typealias SuperAlertController = UIAlertController

// MARK: - Initializers
extension UIAlertController {
    
    public static var width: CGFloat = 270
	
    /// Create new alert view controller.
    ///
    /// - Parameters:
    ///   - style: alert controller's style.
    ///   - title: alert controller's title.
    ///   - message: alert controller's message (default is nil).
    ///   - defaultActionButtonTitle: default action button title (default is "OK")
    ///   - tintColor: alert controller's tint color (default is nil)
    public convenience init(style: UIAlertControllerStyle, source: UIView? = nil, title: String? = nil, message: String? = nil, tintColor: UIColor? = nil) {
        self.init(title: title, message: message, preferredStyle: style)
        
        // TODO: for iPad or other views
        if style == .actionSheet, let source = source {
            popoverPresentationController?.sourceView = source
            popoverPresentationController?.sourceRect = source.bounds
            //popoverController.barButtonItem = buttonBack
            //popoverController.sourceView = view
            //popoverController.sourceRect = sender.customView?.bounds ?? CGRectMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0, 1.0, 1.0) //view.bounds //CGRectMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0, 1.0, 1.0)
        }
        
        if let color = tintColor {
            self.view.tintColor = color
        }
    }
}

internal let UIAlertControllerSequentialQueue: DispatchQueue = DispatchQueue.init(label: "UIAlertControllerSequentialQueue")
internal let UIAlertControllerSemaphore: DispatchSemaphore = DispatchSemaphore.init(value: 0)

// MARK: - Methods
extension UIAlertController {
    
    /// Present alert view controller in the current view controller.
    ///
    /// - Parameters:
    ///   - animated: set true to animate presentation of alert controller (default is true).
    ///   - vibrate: set true to vibrate the device while presenting the alert (default is false).
    ///   - serial: ‼️ sequential shown, if true, please call `hide(animated:,completion:)` to dismiss this `UIAlertController`
    ///   - completion: an optional completion handler to be called after presenting alert controller (default is nil).
    public func show(animated: Bool = true, vibrate: Bool = false, serial: Bool = false, completion: (() -> Void)? = nil) {
        if serial {
            UIAlertControllerSequentialQueue.async {
                UIAlertControllerSemaphore.wait()
                self.private_show(animated: animated, vibrate: vibrate, completion: completion)
            }
        } else {
            private_show(animated: animated, vibrate: vibrate, completion: completion)
        }
    }
    
    private func private_show(animated: Bool, vibrate: Bool, completion: (() -> Void)?) {
        DispatchQueue.main.async {
            UIApplication.shared.keyWindow?.rootViewController?.present(self, animated: animated, completion: completion)
            if vibrate {
                AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
            }
        }
    }
    
    /// Hide and quit the queue
    ///
    /// - Parameters:
    ///   - animated: If animated
    ///   - completion: Completion action
    public func hide(animated: Bool = true, completion: (() -> Void)?) {
        DispatchQueue.main.async {
            self.dismiss(animated: animated, completion: {
                self.quitQueue()
                completion?()
            })
        }
    }
    
    public func quitQueue() {
        UIAlertControllerSemaphore.signal()
    }
    
    /// Add an action to Alert
    ///
    /// - Parameters:
    ///   - title: action title
    ///   - style: action style (default is UIAlertActionStyle.default)
    ///   - isEnabled: isEnabled status for action (default is true)
    ///   - handler: optional action handler to be called when button is tapped (default is nil)
    public func addAction(image: UIImage? = nil, title: String, color: UIColor? = nil, style: UIAlertActionStyle = .default, isEnabled: Bool = true, handler: ((UIAlertAction) -> Void)? = nil) {
        let action = UIAlertAction(title: title, style: style, handler: handler ?? { _ in
            self.hide(animated: true, completion: nil)
            })
        action.isEnabled = isEnabled
        
        // button image
        if let image = image {
            action.setValue(image, forKey: "image")
        }
        
        // button title color
        if let color = color {
            action.setValue(color, forKey: "titleTextColor")
        }
        
        addAction(action)
    }
    
    /// Set alert's title, font and color
    ///
    /// - Parameters:
    ///   - title: alert title
    ///   - font: alert title font
    ///   - color: alert title color
    internal func set(title: String?, font: UIFont, color: UIColor) {
        if title != nil {
            self.title = title
        }
        setTitle(font: font, color: color)
    }
    
    internal func setTitle(font: UIFont, color: UIColor) {
        guard let title = self.title else { return }
        let attributes: [NSAttributedStringKey: Any] = [.font: font, .foregroundColor: color]
        self.attributedTitle = NSMutableAttributedString(string: title, attributes: attributes)
    }
    
    /// Set alert's title, font and color
    ///
    /// - Parameters:
    ///   - title: alert title
    ///   - font: alert title font
    ///   - color: alert title color
    public func setAttributedTitle(_ title: String?, font: UIFont, color: UIColor) {
        set(title: title, font: font, color: color)
    }
    
    public var attributedTitle: NSAttributedString? {
        get {
            return self.value(forKey: "attributedTitle") as? NSAttributedString
        }
        set {
            self.setValue(newValue, forKey: "attributedTitle")
        }
    }
    
    /// Set alert's message, font and color
    ///
    /// - Parameters:
    ///   - message: alert message
    ///   - font: alert message font
    ///   - color: alert message color
    internal func set(message: String?, font: UIFont, color: UIColor) {
        if message != nil {
            self.message = message
        }
        setMessage(font: font, color: color)
    }
    
    internal func setMessage(font: UIFont, color: UIColor) {
        guard let message = self.message else { return }
        let attributes: [NSAttributedStringKey: Any] = [.font: font, .foregroundColor: color]
        self.attributedMessage = NSMutableAttributedString(string: message, attributes: attributes)
    }
    
    public var attributedMessage: NSAttributedString? {
        get {
            return self.value(forKey: "attributedMessage") as? NSAttributedString
        }
        set {
            self.setValue(newValue, forKey: "attributedMessage")
        }
    }
    
    /// Set alert's message, font and color
    ///
    /// - Parameters:
    ///   - message: alert message
    ///   - font: alert message font
    ///   - color: alert message color
    public func setAttributedMessage(_ message: String?, font: UIFont, color: UIColor) {
        set(message: message, font: font, color: color)
    }
    
    public var contentViewController: UIViewController? {
        get {
            return self.value(forKey: "contentViewController") as? UIViewController
        }
        set {
            self.setValue(newValue, forKey: "contentViewController")
        }
    }
    
    /// Set alert's content viewController
    ///
    /// - Parameters:
    ///   - vc: ViewController
    ///   - width: width of content viewController
    ///   - height: height of content viewController
    internal func set(vc: UIViewController?, width: CGFloat? = nil, height: CGFloat? = nil) {
        guard let vc = vc else { return }
        self.contentViewController = vc
        if let height = height {
            vc.preferredContentSize.height = height
            preferredContentSize.height = height
        }
        if let width = width {
            vc.preferredContentSize.width = width
            preferredContentSize.width = width
        }
    }
    
    /// Set alert's content viewController
    ///
    /// - Parameters:
    ///   - content: Content ViewController
    ///   - width: width of content viewController
    ///   - height: height of content viewController
    public func setContentViewController(_ content: UIViewController?, width: CGFloat? = nil, height: CGFloat? = nil) {
        set(vc: content, width: width, height: height)
    }
}

