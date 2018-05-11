
import UIKit

extension UIAlertController {
    
    public var datePickerController: DatePickerViewController? {
        return self.contentViewController as? DatePickerViewController
    }
    
    /// Add a date picker
    ///
    /// - Parameters:
    ///   - mode: date picker mode
    ///   - date: selected date of date picker
    ///   - minimumDate: minimum date of date picker
    ///   - maximumDate: maximum date of date picker
    ///   - action: an action for datePicker value change
    public func addDatePicker(mode: UIDatePickerMode, date: Date?, minimumDate: Date? = nil, maximumDate: Date? = nil, action: DatePickerViewController.DatePickerAction?) {
        let datePicker = DatePickerViewController(mode: mode, date: date, minimumDate: minimumDate, maximumDate: maximumDate, action: action)
        self.setContentViewController(datePicker, height: 216)
    }
}

public final class DatePickerViewController: UIViewController {
    
    public typealias DatePickerAction = (Date) -> Void
    
    public var action: DatePickerAction?
    
    public lazy var datePicker: UIDatePicker = {
        $0.addTarget(self, action: #selector(DatePickerViewController.actionForDatePicker), for: .valueChanged)
        return $0
    }(UIDatePicker())
    
    public required init(mode: UIDatePickerMode, date: Date? = nil, minimumDate: Date? = nil, maximumDate: Date? = nil, action: DatePickerAction?) {
        super.init(nibName: nil, bundle: nil)
        datePicker.datePickerMode = mode
        datePicker.date = date ?? Date()
        datePicker.minimumDate = minimumDate
        datePicker.maximumDate = maximumDate
        self.action = action
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        
    }
    
    public override func loadView() {
        view = datePicker
    }
    
    @objc func actionForDatePicker() {
        action?(datePicker.date)
    }
    
    public func setDate(_ date: Date) {
        datePicker.setDate(date, animated: true)
    }
}
