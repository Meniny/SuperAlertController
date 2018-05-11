
import UIKit

extension UIAlertController {
    
    public var oneTextFieldController: OneTextFieldViewController? {
        return self.contentViewController as? OneTextFieldViewController
    }
    
    /// Add a textField
    ///
    /// - Parameters:
    ///   - height: textField height
    ///   - hInset: right and left margins to AlertController border
    ///   - vInset: bottom margin to button
    ///   - configuration: textField
    public func addOneTextField(configuration: TextField.Config?) {
        let textField = OneTextFieldViewController(vInset: preferredStyle == .alert ? 12 : 0, configuration: configuration)
        let height: CGFloat = OneTextFieldViewController.ui.height + OneTextFieldViewController.ui.vInset
        self.setContentViewController(textField, height: height)
    }
}

public final class OneTextFieldViewController: UIViewController {
    
    lazy public private(set) var textField: TextField = TextField()
    
    struct ui {
        static let height: CGFloat = 44
        static let hInset: CGFloat = 12
        static var vInset: CGFloat = 12
    }
    
    
    public init(vInset: CGFloat = 12, configuration: TextField.Config?) {
        super.init(nibName: nil, bundle: nil)
        view.addSubview(textField)
        ui.vInset = vInset
        
        /// have to set textField frame width and height to apply cornerRadius
        textField.height = ui.height
        textField.width = view.width
        
        configuration?(textField)
        
        preferredContentSize.height = ui.height + ui.vInset
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        textField.width = view.width - ui.hInset * 2
        textField.height = ui.height
        textField.center.x = view.center.x
        textField.center.y = view.center.y - ui.vInset / 2
    }
}
