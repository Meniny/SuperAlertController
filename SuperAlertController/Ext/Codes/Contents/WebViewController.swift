
import UIKit
import WebKit

extension UIAlertController {
    
    public var webViewController: WebViewController? {
        return self.contentViewController as? WebViewController
    }
    
    /// Add an WebView
    ///
    /// - Parameter image: An URL
    public func addWebView(url: URL) {
        let controller = WebViewController.init(url: url)
        self.setContentViewController(controller)
    }
}

public final class WebViewController: UIViewController {
    lazy public private(set) var webView: WKWebView = {
        let v = WKWebView.init()
        v.backgroundColor = UIColor.clear
        v.clipsToBounds = true
        return v
    }()
    
    public let url: URL
    
    public required init(url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func loadView() {
        view = self.webView
        let constraint = NSLayoutConstraint.init(item: self.webView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: UIAlertController.width)
        self.webView.addConstraint(constraint)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.webView.load(URLRequest.init(url: self.url))
    }
    
    deinit {
        
    }
}
