//
//  UIAlertController+QuickUsage.swift
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

import Foundation
import UIKit

fileprivate extension String {
    fileprivate var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}

public typealias SuperAlertActionClosure = (_ index: Int, _ action: UIAlertAction, _ controller: SuperAlertController) -> Swift.Void
public typealias SuperAlertConfigurationClosure = (_ controller: inout SuperAlertController) -> Swift.Void
public typealias SuperAlertTextFieldInfo = (title: String?, placeholder: String?)
public typealias SuperAlertControllerStyle = UIAlertControllerStyle

public extension UIViewController {
    
    public struct AlertControllerDefaults {
        public static var cancelActionTitle = "Cancel"
    }
    
    /// Present `UIAlertController`s in queue
    ///
    /// - Parameters:
    ///   - alertContrller: An `UIAlertController` instance
    ///   - animated: If animated
    ///   - completion: Completion closure
    /// - Returns: The controller
    @discardableResult
    public func present(alertContrller: SuperAlertController, animated: Bool = true, completion: (() -> Void)? = nil) -> UIAlertController {
        alertContrller.show(animated: animated, vibrate: false, serial: true, completion: completion)
        return alertContrller
    }
    
    @discardableResult
    public func dismiss(alertContrller: SuperAlertController, animated: Bool = true, completion: (() -> Void)? = nil) -> UIAlertController {
        alertContrller.hide(completion: completion)
        return alertContrller
    }
}

public extension UIViewController {
    /// Show an `UIAlertController`
    ///
    /// - Parameters:
    ///   - style: `UIAlertControllerStyle`
    ///   - alertTitle: Title string
    ///   - message: Content text string
    ///   - alignment: Text alignment of message string
    ///   - textFields: Text fields
    ///   - buttons: An array of dismiss button title strings
    ///   - config: Configuration
    ///   - action: Action closure
    @discardableResult
    public func show(_ style: UIAlertControllerStyle,
                     title alertTitle: String?,
                     message: String?,
                     alignment: NSTextAlignment = .center,
                     textFields: [SuperAlertTextFieldInfo] = [],
                     buttons: [String] = [],
                     cancelable: Bool = false,
                     config configuration: SuperAlertConfigurationClosure? = nil,
                     action: SuperAlertActionClosure? = nil) -> UIAlertController {

        var alertController = UIAlertController.init(title: alertTitle?.localized,
                                                     message: message?.localized,
                                                     preferredStyle: style)
        
        func actionClosure(index: Int) -> ((UIAlertAction) -> Swift.Void) {
            let c: ((UIAlertAction) -> Swift.Void) = { (a) in
                if let act = action {
                    UIAlertControllerSemaphore.signal()
                    act(index, a, alertController)
                } else {
                    alertController.hide(completion: nil)
                }
            }
            return c
        }
        
        if let msg = message {
            let paragraphStyle = NSMutableParagraphStyle.init()
            paragraphStyle.alignment = alignment
            
            let messageText = NSAttributedString.init(
                string: msg.localized,
                attributes: [
                    NSAttributedStringKey.paragraphStyle: paragraphStyle,
                    NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12),
                    NSAttributedStringKey.foregroundColor : UIColor.darkText
                ]
            )
            alertController.setValue(messageText, forKey: "attributedMessage")
        }
        
        if style == .alert {
            for info in textFields {
                alertController.addTextField { (f) in
                    if let t = info.title, !t.isEmpty {
                        f.text = t
                    }
                    if let p = info.placeholder, !p.isEmpty {
                        f.placeholder = p
                    }
                    f.clearButtonMode = .whileEditing
                }
            }
        }
        
        for btn in buttons {
            guard let index = buttons.index(of: btn) else {
                continue
            }
            let button = UIAlertAction.init(title: btn.localized,
                                            style: .default,
                                            handler: actionClosure(index: index))
            alertController.addAction(button)
        }
        
        if alertController.actions.isEmpty || cancelable {
            let index = alertController.actions.isEmpty ? 0 : alertController.actions.count
            let button = UIAlertAction.init(title: AlertControllerDefaults.cancelActionTitle.localized,
                                            style: .cancel,
                                            handler: actionClosure(index: index))
            alertController.addAction(button)
        }
        configuration?(&alertController)
        
        return self.present(alertContrller: alertController, animated: true, completion: nil)
    }
    
    /// Show an `UIAlertController`
    ///
    /// - Parameters:
    ///   - style: `UIAlertControllerStyle`
    ///   - alertTitle: Title string
    ///   - message: Content text string
    ///   - alignment: Text alignment of message string
    ///   - textFields: Text fields
    ///   - buttons: An array of dismiss button title strings
    ///   - config: Configuration
    ///   - action: Action closure
    public func debug(_ style: UIAlertControllerStyle,
                      title alertTitle: String?,
                      message: String?,
                      alignment: NSTextAlignment = .center,
                      textFields: [SuperAlertTextFieldInfo] = [],
                      buttons: [String] = [],
                      config: SuperAlertConfigurationClosure? = nil,
                      action: SuperAlertActionClosure? = nil) {
        #if DEBUG
            self.show(style,
                      title: alertTitle,
                      message: message,
                      alignment: alignment,
                      textFields: textFields,
                      buttons: buttons,
                      config: config,
                      action: action)
        #endif
    }
}

