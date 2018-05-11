//
//  ValueForKeys.swift
//  Pods-Sample
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
//  Created by Elias Abel on 2018/1/22.
//  
//

import Foundation
import UIKit

public extension UIAlertController {
    
    public var attributedTitle: NSAttributedString? {
        get {
            return self.value(forKey: "attributedTitle") as? NSAttributedString
        }
        set {
            self.setValue(newValue, forKey: "attributedTitle")
        }
    }
    
    public var attributedMessage: NSAttributedString? {
        get {
            return self.value(forKey: "attributedMessage") as? NSAttributedString
        }
        set {
            self.setValue(newValue, forKey: "attributedMessage")
        }
    }
    
    public var contentViewController: UIViewController? {
        get {
            return self.value(forKey: "contentViewController") as? UIViewController
        }
        set {
            self.setValue(newValue, forKey: "contentViewController")
        }
    }
    
    internal func setTitleAttribute(font: UIFont, color: UIColor, alignment: NSTextAlignment) {
        guard let title = self.title else { return }
        let paragraphStyle = NSMutableParagraphStyle.init()
        paragraphStyle.alignment = alignment
        let attributes: [NSAttributedStringKey: Any] = [
            .font: font,
            .foregroundColor: color,
            .paragraphStyle: paragraphStyle,
            ]
        self.attributedTitle = NSMutableAttributedString(string: title, attributes: attributes)
    }
    
    /// Set alert's title, font and color
    ///
    /// - Parameters:
    ///   - title: alert title
    ///   - font: alert title font
    ///   - color: alert title color
    public func setAttributedTitle(_ title: String?, font: UIFont, color: UIColor, alignment: NSTextAlignment) {
        if title != nil {
            self.title = title
        }
        setTitleAttribute(font: font, color: color, alignment: alignment)
    }
    
    internal func setMessageAttribute(font: UIFont, color: UIColor, alignment: NSTextAlignment) {
        guard let message = self.message else { return }
        let paragraphStyle = NSMutableParagraphStyle.init()
        paragraphStyle.alignment = alignment
        let attributes: [NSAttributedStringKey: Any] = [
            .font: font,
            .foregroundColor: color,
            .paragraphStyle: paragraphStyle,
            ]
        self.attributedMessage = NSMutableAttributedString(string: message, attributes: attributes)
    }
    
    /// Set alert's message, font and color
    ///
    /// - Parameters:
    ///   - message: alert message
    ///   - font: alert message font
    ///   - color: alert message color
    ///   - alignment: alert message alignment
    public func setAttributedMessage(_ message: String?,
                                     font: UIFont,
                                     color: UIColor,
                                     alignment: NSTextAlignment = .center) {
        if message != nil {
            self.message = message
        }
        setMessageAttribute(font: font, color: color, alignment: alignment)
    }
    
    /// Set alert's content viewController
    ///
    /// - Parameters:
    ///   - content: Content ViewController
    ///   - width: width of content viewController
    ///   - height: height of content viewController
    public func setContentViewController(_ content: UIViewController?, width: CGFloat? = nil, height: CGFloat? = nil) {
        guard let vc = content else { return }
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
}
