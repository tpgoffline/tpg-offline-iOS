import Foundation
import UIKit

private extension Selector {
    static let buttonTapped = #selector(DatePickerDialog.buttonTapped)
    static let deviceOrientationDidChange = #selector(DatePickerDialog.deviceOrientationDidChange)
}

open class DatePickerDialog: UIView {
    public typealias DatePickerCallback = ( Bool, Date? ) -> Void
    
    // MARK: - Constants
    private let kDatePickerDialogDefaultButtonHeight:       CGFloat = 50
    private let kDatePickerDialogDefaultButtonSpacerHeight: CGFloat = 1
    private let kDatePickerDialogCornerRadius:              CGFloat = 7
    private let kDatePickerDialogDoneButtonTag:             Int     = 1
    private let kDatePickerDialogNowButtonTag:              Int     = 2
    
    // MARK: - Views
    private var dialogView:   UIView!
    private var titleLabel:   UILabel!
    private var segmentedControl:   UISegmentedControl!
    open var datePicker:    UIDatePicker!
    private var cancelButton: UIButton!
    private var doneButton:   UIButton!
    private var nowButton:   UIButton!
    
    // MARK: - Variables
    private var defaultDate:    Date?
    private var datePickerMode: UIDatePicker.Mode?
    private var callback:       DatePickerCallback?
    var showCancelButton:Bool = false
    var locale: Locale?
    
    private var textColor:      UIColor!
    private var buttonColor:    UIColor!
    private var font:           UIFont!
    
    // MARK: - Dialog initialization
    public init(textColor: UIColor = UIColor.black, buttonColor: UIColor = #colorLiteral(red: 1, green: 0.3411764706, blue: 0.1333333333, alpha: 1), font: UIFont = .boldSystemFont(ofSize: 15), locale: Locale? = nil, showCancelButton:Bool = true) {
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
        self.buttonColor = buttonColor
        self.font = font
        self.showCancelButton = showCancelButton
        self.locale = locale
        
        if App.darkMode {
            self.textColor = .white
        }
        setupView()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setupView() {
        self.dialogView = createContainerView()
        
        self.dialogView!.layer.shouldRasterize = true
        self.dialogView!.layer.rasterizationScale = UIScreen.main.scale
        
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
        
        self.dialogView!.layer.opacity = 0.5
        self.dialogView!.layer.transform = CATransform3DMakeScale(1.3, 1.3, 1)
        
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        
        self.addSubview(self.dialogView!)
    }
    
    /// Handle device orientation changes
    @objc func deviceOrientationDidChange(_ notification: Notification) {
        self.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        let screenSize = countScreenSize()
      let dialogSize = CGSize(width: 350, height: 274
        + (2 * kDatePickerDialogDefaultButtonHeight)
        + (2 * kDatePickerDialogDefaultButtonSpacerHeight))
        dialogView.frame = CGRect(x: (screenSize.width - dialogSize.width) / 2, y: (screenSize.height - dialogSize.height) / 2, width: dialogSize.width, height: dialogSize.height)
    }
    
    /// Create the dialog view, and animate opening the dialog
    open func show(_ title: String, doneButtonTitle: String = "Done", cancelButtonTitle: String = "Cancel", nowButtonTitle: String = "Set to now", defaultDate: Date = Date(), minimumDate: Date? = nil, maximumDate: Date? = nil, datePickerMode: UIDatePicker.Mode = .dateAndTime, arrivalTime: Bool, callback: @escaping DatePickerCallback) {
        self.titleLabel.text = title
        self.doneButton.setTitle(doneButtonTitle, for: .normal)
        self.nowButton.setTitle(nowButtonTitle, for: .normal)
        if showCancelButton {
            self.cancelButton.setTitle(cancelButtonTitle, for: .normal)
        }
        self.datePickerMode = datePickerMode
        self.callback = callback
        self.defaultDate = defaultDate
        self.datePicker.datePickerMode = self.datePickerMode ?? UIDatePicker.Mode.date
        self.datePicker.date = self.defaultDate ?? Date()
        self.datePicker.maximumDate = maximumDate
        self.datePicker.minimumDate = minimumDate
        if let locale = self.locale {
            self.datePicker.locale = locale
        }
        self.segmentedControl.selectedSegmentIndex = arrivalTime ? 1 : 0
        /* Add dialog to main window */
        guard let appDelegate = UIApplication.shared.delegate else { fatalError() }
        guard let window = appDelegate.window else { fatalError() }
        window?.addSubview(self)
        window?.bringSubviewToFront(self)
        window?.endEditing(true)
        
        NotificationCenter.default.addObserver(self, selector: .deviceOrientationDidChange, name: UIDevice.orientationDidChangeNotification, object: nil)
        
        /* Anim */
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            options: .curveEaseInOut,
            animations: {
                self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
                self.dialogView!.layer.opacity = 1
                self.dialogView!.layer.transform = CATransform3DMakeScale(1, 1, 1)
        }
        )
    }
    
    /// Dialog close animation then cleaning and removing the view from the parent
    private func close() {
        NotificationCenter.default.removeObserver(self)
        
        let currentTransform = self.dialogView.layer.transform
        
        let startRotation = (self.value(forKeyPath: "layer.transform.rotation.z") as? NSNumber) as? Double ?? 0.0
        let rotation = CATransform3DMakeRotation((CGFloat)(-startRotation + .pi * 270 / 180), 0, 0, 0)
        
        self.dialogView.layer.transform = CATransform3DConcat(rotation, CATransform3DMakeScale(1, 1, 1))
        self.dialogView.layer.opacity = 1
        
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            options: [],
            animations: {
                self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
                self.dialogView.layer.transform = CATransform3DConcat(currentTransform, CATransform3DMakeScale(0.6, 0.6, 1))
                self.dialogView.layer.opacity = 0
        }) { (finished) in
            for v in self.subviews {
                v.removeFromSuperview()
            }
            
            self.removeFromSuperview()
            self.setupView()
        }
    }
    
    /// Creates the container view here: create the dialog, then add the custom content and buttons
    private func createContainerView() -> UIView {
        let screenSize = countScreenSize()
        let dialogSize = CGSize(
            width: 350,
            height: 274
                + (2 * kDatePickerDialogDefaultButtonHeight)
                + (2 * kDatePickerDialogDefaultButtonSpacerHeight))
        
        // For the black background
        self.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height)
        
        // This is the dialog's container; we attach the custom content and the buttons to this one
        let dialogContainer = UIView(frame: CGRect(x: (screenSize.width - dialogSize.width) / 2, y: (screenSize.height - dialogSize.height) / 2, width: dialogSize.width, height: dialogSize.height))
        
        // First, we style the dialog to match the iOS8 UIAlertView >>>
        let gradient: CAGradientLayer = CAGradientLayer(layer: self.layer)
        gradient.frame = dialogContainer.bounds
        gradient.colors = [UIColor(red: 218/255, green: 218/255, blue: 218/255, alpha: 1).cgColor,
                           UIColor(red: 233/255, green: 233/255, blue: 233/255, alpha: 1).cgColor,
                           UIColor(red: 218/255, green: 218/255, blue: 218/255, alpha: 1).cgColor]
        if App.darkMode {
            gradient.colors = [UIColor(red: 22/255, green: 22/255, blue: 22/255, alpha: 1).cgColor,
                               UIColor(red: 37/255, green: 37/255, blue: 37/255, alpha: 1).cgColor,
                               UIColor(red: 22/255, green: 22/255, blue: 22/255, alpha: 1).cgColor]
        }
        let cornerRadius = kDatePickerDialogCornerRadius
        gradient.cornerRadius = cornerRadius
        dialogContainer.layer.insertSublayer(gradient, at: 0)
        
        dialogContainer.layer.cornerRadius = cornerRadius
        dialogContainer.layer.borderColor = UIColor(red: 198/255, green: 198/255, blue: 198/255, alpha: 1).cgColor
        dialogContainer.layer.borderWidth = 1
        
        // There is a line above the button
        var lineView = UIView(frame: CGRect(x: 0, y: dialogContainer.bounds.size.height - kDatePickerDialogDefaultButtonHeight - kDatePickerDialogDefaultButtonSpacerHeight, width: dialogContainer.bounds.size.width, height: kDatePickerDialogDefaultButtonSpacerHeight))
        lineView.backgroundColor = UIColor(red: 198/255, green: 198/255, blue: 198/255, alpha: 1)
        if App.darkMode {
            dialogContainer.layer.borderColor = UIColor(red: 57/255, green: 57/255, blue: 57/255, alpha: 1).cgColor
            lineView.backgroundColor = UIColor(red: 57/255, green: 57/255, blue: 57/255, alpha: 1)
        }
        dialogContainer.addSubview(lineView)
        
        lineView = UIView(frame: CGRect(x: 0, y: dialogContainer.bounds.size.height - (2 * kDatePickerDialogDefaultButtonHeight) - (2 * kDatePickerDialogDefaultButtonSpacerHeight), width: dialogContainer.bounds.size.width, height: kDatePickerDialogDefaultButtonSpacerHeight))
        lineView.backgroundColor = UIColor(red: 198/255, green: 198/255, blue: 198/255, alpha: 1)
        if App.darkMode {
            dialogContainer.layer.borderColor = UIColor(red: 57/255, green: 57/255, blue: 57/255, alpha: 1).cgColor
            lineView.backgroundColor = UIColor(red: 57/255, green: 57/255, blue: 57/255, alpha: 1)
        }
        dialogContainer.addSubview(lineView)
        
        //Title
        self.titleLabel = UILabel(frame: CGRect(x: 10, y: 10, width: 330, height: 30))
        self.titleLabel.textAlignment = .center
        self.titleLabel.textColor = self.textColor
        self.titleLabel.font = self.font.withSize(17)
        dialogContainer.addSubview(self.titleLabel)
        
        self.segmentedControl = UISegmentedControl(frame: CGRect(x: 10, y: 50, width: 330, height: 28))
        self.segmentedControl.insertSegment(withTitle: "Departure at".localized, at: 0, animated: false)
        self.segmentedControl.insertSegment(withTitle: "Arrival at".localized, at: 1, animated: false)
        self.segmentedControl.selectedSegmentIndex = 0
        self.segmentedControl.tintColor = self.buttonColor
        dialogContainer.addSubview(self.segmentedControl)
        
        self.datePicker = UIDatePicker(frame: CGRect(x: 0, y: 74, width: 0, height: 0))
        self.datePicker.setValue(self.textColor, forKeyPath: "textColor")
        self.datePicker.autoresizingMask = .flexibleRightMargin
        self.datePicker.frame.size.width = 350
        self.datePicker.frame.size.height = 216
        dialogContainer.addSubview(self.datePicker)
        
        // Add the buttons
        addButtonsToView(container: dialogContainer)
        
        return dialogContainer
    }
    
    /// Add buttons to container
    private func addButtonsToView(container: UIView) {
        var buttonWidth = container.bounds.size.width / 2
        
        var leftButtonFrame = CGRect(
            x: 0,
            y: container.bounds.size.height - kDatePickerDialogDefaultButtonHeight,
            width: buttonWidth,
            height: kDatePickerDialogDefaultButtonHeight
        )
        var rightButtonFrame = CGRect(
            x: buttonWidth,
            y: container.bounds.size.height - kDatePickerDialogDefaultButtonHeight,
            width: buttonWidth,
            height: kDatePickerDialogDefaultButtonHeight
        )
        
        if showCancelButton == false {
            buttonWidth = container.bounds.size.width
            leftButtonFrame = CGRect()
            rightButtonFrame = CGRect(
                x: 0,
                y: container.bounds.size.height - kDatePickerDialogDefaultButtonHeight,
                width: buttonWidth,
                height: kDatePickerDialogDefaultButtonHeight
            )
        }
        
        let nowButtonFrame = CGRect(
            x: 0,
            y: container.bounds.size.height - 2 * kDatePickerDialogDefaultButtonHeight,
            width: container.bounds.size.width,
            height: kDatePickerDialogDefaultButtonHeight
        )
        let interfaceLayoutDirection = UIApplication.shared.userInterfaceLayoutDirection
        let isLeftToRightDirection = interfaceLayoutDirection == .leftToRight
        
        if showCancelButton {
            self.cancelButton = UIButton(type: .custom) as UIButton
            self.cancelButton.frame = isLeftToRightDirection ? leftButtonFrame : rightButtonFrame
            self.cancelButton.setTitleColor(self.buttonColor, for: .normal)
            self.cancelButton.setTitleColor(self.buttonColor, for: .highlighted)
            self.cancelButton.titleLabel!.font = self.font.withSize(14)
            self.cancelButton.layer.cornerRadius = kDatePickerDialogCornerRadius
            self.cancelButton.addTarget(self, action: .buttonTapped, for: .touchUpInside)
            container.addSubview(self.cancelButton)
        }
        self.nowButton = UIButton(type: .custom) as UIButton
        self.nowButton.frame = nowButtonFrame
        self.nowButton.tag = kDatePickerDialogNowButtonTag
        self.nowButton.setTitleColor(self.buttonColor, for: .normal)
        self.nowButton.setTitleColor(self.buttonColor, for: .highlighted)
        self.nowButton.titleLabel!.font = self.font.withSize(14)
        self.nowButton.layer.cornerRadius = kDatePickerDialogCornerRadius
        self.nowButton.addTarget(self, action: .buttonTapped, for: .touchUpInside)
        container.addSubview(self.nowButton)
        
        self.doneButton = UIButton(type: .custom) as UIButton
        self.doneButton.frame = isLeftToRightDirection ? rightButtonFrame : leftButtonFrame
        self.doneButton.tag = kDatePickerDialogDoneButtonTag
        self.doneButton.setTitleColor(self.buttonColor, for: .normal)
        self.doneButton.setTitleColor(self.buttonColor, for: .highlighted)
        self.doneButton.titleLabel!.font = self.font.withSize(14)
        self.doneButton.layer.cornerRadius = kDatePickerDialogCornerRadius
        self.doneButton.addTarget(self, action: .buttonTapped, for: .touchUpInside)
        container.addSubview(self.doneButton)
    }
    
    @objc func buttonTapped(sender: UIButton!) {
        if sender.tag == kDatePickerDialogNowButtonTag {
            self.datePicker.date = Date()
        } else if sender.tag == kDatePickerDialogDoneButtonTag {
            self.callback?(self.segmentedControl.selectedSegmentIndex == 1, self.datePicker.date)
            close()
        } else {
            self.callback?(self.segmentedControl.selectedSegmentIndex == 1, nil)
            close()
        }
    }
    
    // MARK: - Helpers
    
    /// Count and return the screen's size
    func countScreenSize() -> CGSize {
        let screenWidth = UIScreen.main.bounds.size.width
        let screenHeight = UIScreen.main.bounds.size.height
        
        return CGSize(width: screenWidth, height: screenHeight)
    }
}
