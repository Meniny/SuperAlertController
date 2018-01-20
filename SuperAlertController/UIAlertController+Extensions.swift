
import UIKit
import AudioToolbox

// MARK: - Initializers
extension UIAlertController {
	
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

private let UIAlertControllerSequentialQueue: DispatchQueue = DispatchQueue.init(label: "UIAlertControllerSequentialQueue")
private let UIAlertControllerSemaphore: DispatchSemaphore = DispatchSemaphore.init(value: 0)

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
                UIAlertControllerSemaphore.signal()
                completion?()
            })
        }
    }
    
    /// Add an action to Alert
    ///
    /// - Parameters:
    ///   - title: action title
    ///   - style: action style (default is UIAlertActionStyle.default)
    ///   - isEnabled: isEnabled status for action (default is true)
    ///   - handler: optional action handler to be called when button is tapped (default is nil)
    public func addAction(image: UIImage? = nil, title: String, color: UIColor? = nil, style: UIAlertActionStyle = .default, isEnabled: Bool = true, handler: ((UIAlertAction) -> Void)? = nil) {
        let action = UIAlertAction(title: title, style: style, handler: handler)
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
        let attributedTitle = NSMutableAttributedString(string: title, attributes: attributes)
        setValue(attributedTitle, forKey: "attributedTitle")
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
        let attributedMessage = NSMutableAttributedString(string: message, attributes: attributes)
        setValue(attributedMessage, forKey: "attributedMessage")
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
    
    /// Set alert's content viewController
    ///
    /// - Parameters:
    ///   - vc: ViewController
    ///   - height: height of content viewController
    internal func set(vc: UIViewController?, width: CGFloat? = nil, height: CGFloat? = nil) {
        guard let vc = vc else { return }
        setValue(vc, forKey: "contentViewController")
        if let height = height {
            vc.preferredContentSize.height = height
            preferredContentSize.height = height
        }
    }
    
    /// Set alert's content viewController
    ///
    /// - Parameters:
    ///   - contentViewController: ViewController
    ///   - height: height of content viewController
    public func setContentViewController(_ contentViewController: UIViewController?, height: CGFloat? = nil) {
        set(vc: contentViewController, width: nil, height: height)
    }
}

