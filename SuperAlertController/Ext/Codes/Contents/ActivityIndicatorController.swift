
import UIKit

extension UIAlertController {
    
    public var activityIndicatorController: ActivityIndicatorController? {
        return self.contentViewController as? ActivityIndicatorController
    }
    
    /// Add an Activity Indicator
    public func addActivityIndicator(style: UIActivityIndicatorViewStyle = .whiteLarge, color: UIColor? = nil) {
        let controller = ActivityIndicatorController.init(style: style, color: color)
        self.setContentViewController(controller)
    }
}

public final class ActivityIndicatorController: UIViewController {
    lazy public private(set) var activityIndicator: UIActivityIndicatorView = {
        let v = UIActivityIndicatorView.init(activityIndicatorStyle: style)
        v.color = color
        v.hidesWhenStopped = false
        return v
    }()
    
    public private(set) var style: UIActivityIndicatorViewStyle
    public private(set) var color: UIColor?
    
    public required init(style: UIActivityIndicatorViewStyle, color: UIColor?) {
        self.style = style
        self.color = color
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func loadView() {
        view = self.activityIndicator
        view.addConstraint(NSLayoutConstraint.init(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 150))
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndicator.startAnimating()
    }
    
    deinit {
        self.activityIndicator.stopAnimating()
    }
}
