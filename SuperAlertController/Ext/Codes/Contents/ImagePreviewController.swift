
import UIKit

extension UIAlertController {
    
    public var imagePreviewController: ImagePreviewController? {
        return self.contentViewController as? ImagePreviewController
    }
    
    /// Add an image prievew
    ///
    /// - Parameter image: An UIImage
    public func addImagePreview(image: UIImage) {
        let imageController = ImagePreviewController.init(image: image)
//        let imageProportion = image.size.width / image.size.height
//        let width = type(of: self).width
//        let height = width / imageProportion
        self.setContentViewController(imageController)//, width: width, height: height)
    }
}

public final class ImagePreviewController: UIViewController {
    lazy public private(set) var imageView: UIImageView = {
        let imgView = UIImageView.init()
        imgView.backgroundColor = UIColor.clear
//        imgView.contentMode = .scaleAspectFit
        imgView.clipsToBounds = true
        return imgView
    }()
    
    public required init(image: UIImage) {
        super.init(nibName: nil, bundle: nil)
        self.imageView.image = image
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func loadView() {
        view = self.imageView
        if let img = self.imageView.image {
            let constraint = NSLayoutConstraint.init(item: self.imageView, attribute: .width, relatedBy: .equal, toItem: self.imageView, attribute: .height, multiplier: img.size.width / img.size.height, constant: 0)
            self.imageView.addConstraint(constraint)
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    deinit {
        
    }
}
