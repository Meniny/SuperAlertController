
import UIKit

extension UIAlertController {
    
    public var pickerViewController: PickerViewViewController? {
        return self.contentViewController as? PickerViewViewController
    }
    
    /// Add a picker view
    ///
    /// - Parameters:
    ///   - values: values for picker view
    ///   - initialSelection: initial selection of picker view
    ///   - action: action for selected value of picker view
    public func addPickerView(values: [PickerViewColumnSet],  initialSelection: PickerViewIndexes? = nil, action: PickerViewViewController.PickerViewAction?) {
        let pickerView = PickerViewViewController(values: values, initialSelection: initialSelection, action: action)
        self.setContentViewController(pickerView, height: 216)
    }
}

public typealias PickerViewColumnSet = Array<String>
public typealias PickerViewIndexes = (column: Int, row: Int)

public final class PickerViewViewController: UIViewController {
    
    public typealias PickerViewAction = (_ vc: UIViewController, _ picker: UIPickerView, _ index: PickerViewIndexes, _ values: [PickerViewColumnSet]) -> ()
    
    fileprivate var action: PickerViewAction?
    fileprivate var values = [PickerViewColumnSet]()
    fileprivate var initialSelection: PickerViewIndexes?
    
    lazy public private(set) var pickerView: UIPickerView = {
        return $0
    }(UIPickerView())
    
    public init(values: [PickerViewColumnSet], initialSelection: PickerViewIndexes? = nil, action: PickerViewAction?) {
        super.init(nibName: nil, bundle: nil)
        self.values = values
        self.initialSelection = initialSelection
        self.action = action
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        
    }
    
    public override func loadView() {
        view = pickerView
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.dataSource = self
        pickerView.delegate = self
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if let initialSelection = initialSelection, values.count > initialSelection.column, values[initialSelection.column].count > initialSelection.row {
            pickerView.selectRow(initialSelection.row, inComponent: initialSelection.column, animated: true)
        }
    }
}

extension PickerViewViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    // returns the number of 'columns' to display.
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return values.count
    }
    
    
    // returns the # of rows in each component..
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return values[component].count
    }
    /*
     // returns width of column and height of row for each component.
     public func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
     
     }
     
     public func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
     
     }
     */
    
    // these methods return either a plain NSString, a NSAttributedString, or a view (e.g UILabel) to display the row for the component.
    // for the view versions, we cache any hidden and thus unused views and pass them back for reuse.
    // If you return back a different object, the old one will be released. the view will be centered in the row rect
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return values[component][row]
    }
    /*
     public func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
     // attributed title is favored if both methods are implemented
     }
     
     
     public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
     
     }
     */
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        action?(self, pickerView, PickerViewIndexes(column: component, row: row), values)
    }
}

