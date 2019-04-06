
import UIKit

extension UIAlertController {
    
    public var activityIndicatorController: ActivityIndicatorController? {
        return self.contentViewController as? ActivityIndicatorController
    }
    
    /// Add an Activity Indicator
    public func addActivityIndicator(style: UIActivityIndicatorView.Style = .whiteLarge, color: UIColor? = nil) {
        let controller = ActivityIndicatorController.init(style: style, color: color)
        self.setContentViewController(controller)
    }
}

public final class ActivityIndicatorController: UIViewController {
    lazy public private(set) var activityIndicator: UIActivityIndicatorView = {
        let v = UIActivityIndicatorView.init(style: style)
        v.color = color
        v.hidesWhenStopped = false
        return v
    }()
    
    public private(set) var style: UIActivityIndicatorView.Style
    public private(set) var color: UIColor?
    
    public required init(style: UIActivityIndicatorView.Style, color: UIColor?) {
        self.style = style
        self.color = color
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func loadView() {
        view = self.activityIndicator
        view.addConstraint(NSLayoutConstraint.init(item: view as Any, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 150))
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndicator.startAnimating()
    }
    
    deinit {
        self.activityIndicator.stopAnimating()
    }
}
