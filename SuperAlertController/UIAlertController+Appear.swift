//
//  SuperAlertController+Appear.swift
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

public let UIAlertControllerSequentialQueue: DispatchQueue = DispatchQueue.init(label: "UIAlertControllerSequentialQueue")
public let UIAlertControllerSemaphore: DispatchSemaphore = DispatchSemaphore.init(value: 1)

// MARK: - Methods
public extension UIAlertController {
    
    /// Present alert view controller in the current view controller.
    ///
    /// - Parameters:
    ///   - animated: set true to animate presentation of alert controller (default is true).
    ///   - vibrate: set true to vibrate the device while presenting the alert (default is false).
    ///   - serial: ‼️ sequential shown, if true, please call `hide(completion:)` or `continueSerial(completion:)` to dismiss this `UIAlertController`
    ///   - completion: an optional completion handler to be called after presenting alert controller (default is nil).
    public func show(animated: Bool = true,
                     vibrate: Bool = false,
                     serial: Bool = false,
                     completion: (() -> Void)? = nil) {
        if serial {
            UIAlertControllerSequentialQueue.async {
                UIAlertControllerSemaphore.wait()
                DispatchQueue.main.async {
                    self.private_show(animated: animated, vibrate: vibrate, completion: completion)
                }
            }
        } else {
            DispatchQueue.main.async {
                self.private_show(animated: animated, vibrate: vibrate, completion: completion)
            }
        }
    }
    
    private func private_show(animated: Bool,
                              to controller: UIViewController? = nil,
                              vibrate: Bool,
                              completion: (() -> Void)?) {
        (controller ?? UIApplication.shared.keyWindow?.rootViewController)?.present(self, animated: animated, completion: completion)
        if vibrate {
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
        }
    }
    
    /// Hide and quit the queue
    ///
    /// - Parameters:
    ///   - completion: Completion action
    public func hide(completion: (() -> Void)?) {
        self.contentViewController = nil
        self.continueSerial(completion: completion)
    }
    
    /// Quit the serial
    ///
    /// - Parameter completion: Completion action
    public func continueSerial(completion: (() -> Void)?) {
        UIAlertControllerSemaphore.signal()
        completion?()
    }
}

