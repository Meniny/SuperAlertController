import UIKit

// MARK: - Properties

extension UITextField {
    
    public typealias TextFieldConfig = (UITextField) -> Swift.Void
    
    public func config(textField configurate: TextFieldConfig?) {
        configurate?(self)
    }
    
    internal func left(image: UIImage?, color: UIColor = .black) {
        if let image = image {
            leftViewMode = UITextFieldViewMode.always
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
            imageView.contentMode = .scaleAspectFit
            imageView.image = image
            imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)
            imageView.tintColor = color
            leftView = imageView
        } else {
            leftViewMode = UITextFieldViewMode.never
            leftView = nil
        }
    }
    
    public enum ImagePosition {
        case left, right
    }
    
    internal func right(image: UIImage?, color: UIColor = .black) {
        if let image = image {
            rightViewMode = UITextFieldViewMode.always
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
            imageView.contentMode = .scaleAspectFit
            imageView.image = image
            imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)
            imageView.tintColor = color
            rightView = imageView
        } else {
            rightViewMode = UITextFieldViewMode.never
            rightView = nil
        }
    }
    
    /// Set image to UITextField
    ///
    /// - Parameters:
    ///   - image: The image
    ///   - position: Position, left or right
    ///   - color: Image color
    public func setImage(_ image: UIImage?, at position: UITextField.ImagePosition = .left, color: UIColor = .black) {
        switch position {
        case .left:
            left(image: image, color: color)
            break
        default:
            right(image: image, color: color)
            break
        }
    }
}

// MARK: - Methods

internal extension UITextField {
    
    /// Set placeholder text color.
    ///
    /// - Parameter color: placeholder text color.
    internal func setPlaceHolderTextColor(_ color: UIColor) {
        self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedStringKey.foregroundColor: color])
    }
    
    /// Set placeholder text and its color
    internal func placeholder(text value: String, color: UIColor = .red) {
        self.attributedPlaceholder = NSAttributedString(string: value, attributes: [ NSAttributedStringKey.foregroundColor : color])
    }
}
