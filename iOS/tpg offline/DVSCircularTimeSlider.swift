//
//  DVSCircularTimeSlider.swift
//  
//
//  Created by Dries Van Schevensteen on 19/06/15.
//
//

import UIKit

@IBDesignable
class DVSCircularTimeSlider: UIControl {
    
    @IBInspectable
    var primaryCircleColor: UIColor = UIColor(red: 47/255, green: 213/255, blue: 100/255, alpha: 1.0) {
        didSet {
            circleLayer.fillColor = primaryCircleColor.colorWithAlphaComponent(0.1).CGColor
            setNeedsDisplay()
        }
    }
    @IBInspectable
    var primaryCircleStrokeSize: CGFloat = 7 {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable
    var primaryCircleHandleRadius: CGFloat = 15 {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable
    var shadowCircleColor: UIColor = UIColor(red: 231/255, green: 231/255, blue: 231/255, alpha: 1.0) {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable
    var shadowCircleStrokeSize: CGFloat = 1 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    private var shouldDrawHelperCircle = false
    var time: NSDate {
        get {
            return _time
        }
        set (newValue) {
            if getRadiansFromTimeInDate(newValue) > RadianValuesInCircle.FullCircle {
                shouldDrawHelperCircle = true
                isSecondCircle = true
            } else {
                shouldDrawHelperCircle = false
                isSecondCircle = false
            }
            _time = newValue
        }
    }
    private var _time = NSDate() {
        didSet {
            timeLabel.text = timeString
            setNeedsDisplay()
        }
    }
    var timeString: String {
        let formatter = NSDateFormatter()
        formatter.timeStyle = NSDateFormatterStyle.ShortStyle
        return formatter.stringFromDate(_time)
    }
    
    private lazy var timeLabel: UILabel = {
        [unowned self] in
        let label = UILabel()
        label.textAlignment = NSTextAlignment.Center
        label.font = UIFont(name: self.fontName, size: self.fontSize)
        label.adjustsFontSizeToFitWidth = true
        self.addSubview(label)
        // Time label constraints
        var leading = NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 0)
        var trailing = NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 0)
        var top = NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0)
        var bottom = NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)
        self.addConstraints([leading, trailing, top, bottom])
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var fontSize: CGFloat = 30 {
        didSet {
            timeLabel.font = timeLabel.font.fontWithSize(fontSize)
        }
    }
    var fontName = "HelveticaNeue-Light" {
        didSet {
            timeLabel.font = UIFont(name: fontName, size: fontSize)
        }
    }
    var timeLabelColor: UIColor = UIColor.blackColor() {
        didSet {
            timeLabel.textColor = timeLabelColor
        }
    }
    
    private var isTracking = false {
        didSet {
            setNeedsDisplay()
        }
    }
    
    private var isSecondCircle = false {
        didSet {
            if !shouldDrawHelperCircle {
                animateSecondCircle(isSecondCircle)
            }
            setNeedsDisplay()
        }
    }
    
    private struct RadianValuesInCircle {
        static let Quarter = M_PI / 2
        static let Half = M_PI
        static let ThreeQuarters = 3 * M_PI / 2
        static let FullCircle = 2 * M_PI
        static let DoubleCircle = 4 * M_PI
    }

    // MARK: - Initializers
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.contentMode = UIViewContentMode.Redraw
        
        time = NSDate()
        timeLabel.text = self.timeString
        
        circleLayer.fillColor = primaryCircleColor.colorWithAlphaComponent(0.1).CGColor
        self.layer.addSublayer(circleLayer)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    // MARK: - Time
    
    func setTimeWithHours(h: Int, andMinutes m: Int) {
        let cal = NSCalendar(identifier: NSCalendarIdentifierGregorian)
        let components = NSDateComponents()
        components.hour = Int(h)
        components.minute = Int(m)
        if let date = cal?.dateFromComponents(components) {
            _time = date
        }
    }
    
    private func getTimeInHoursFromAngle(a: Double) -> Double {
        return a / (RadianValuesInCircle.FullCircle / 12)
    }
    
    private func getRadiansFromTimeInDate(t: NSDate) -> Double {
        let calender: NSCalendar = NSCalendar.currentCalendar()
        let flags: NSCalendarUnit = [NSCalendarUnit.Hour, NSCalendarUnit.Minute]
        let components = calender.components(flags, fromDate: t)
        
        let numberFromTime: Double = Double(components.hour) + Double(components.minute) / 60
        let timeInRadians: Double = numberFromTime / 24 * RadianValuesInCircle.DoubleCircle
        
        return timeInRadians
    }
    
    // MARK: - Animation
    
    private let circleLayer = CAShapeLayer()
    private func animateSecondCircle(moveIn: Bool) {
        let center = CGPoint(x: bounds.width/2, y: bounds.height/2)
        let radius: CGFloat = min(bounds.width, bounds.height)/2 - max(primaryCircleStrokeSize, shadowCircleStrokeSize)/2 - primaryCircleHandleRadius
        let shadowCircleRect = CGRect(
            x: center.x - radius,
            y: center.y - radius,
            width: radius * 2,
            height: radius * 2)
        let circlePath = UIBezierPath(roundedRect: shadowCircleRect, cornerRadius: radius).CGPath
        let pointPath = UIBezierPath(roundedRect: CGRect(origin: center, size: CGSize(width: 0.1, height: 0.1)), cornerRadius: 1).CGPath
        
        let anim = CABasicAnimation(keyPath: "path")
        anim.toValue = (moveIn) ? circlePath : pointPath
        anim.duration = 0.2
        anim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        anim.fillMode = kCAFillModeBoth
        anim.removedOnCompletion = false
        
        circleLayer.path = (moveIn) ? pointPath : circlePath
        circleLayer.addAnimation(anim, forKey: anim.keyPath)
    }
    
    // MARK: - Touch handlers
    
    private var canHandleMoveLeft = true
    private var canHandleMoveRight = true
    private var didStopOnLeftSide = false {
        didSet {
            if didStopOnLeftSide {
                setTimeWithHours(0, andMinutes: 0)
            }
        }
    }
    private var didStopOnRightSide = false {
        didSet {
            if didStopOnRightSide {
                setTimeWithHours(23, andMinutes: 59)
            }
        }
    }
    
    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        isTracking = true
        return true
    }
    
    override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        let angle = getAngleFromPoint(touch.locationInView(self))
        let previousAngle = getAngleFromPoint(touch.previousLocationInView(self))
        if angle > RadianValuesInCircle.ThreeQuarters && previousAngle < RadianValuesInCircle.Quarter  {
            if isSecondCircle {
                if !didStopOnRightSide {
                    isSecondCircle = false
                    shouldDrawHelperCircle = false
                }
            } else {
                canHandleMoveLeft = false
                didStopOnLeftSide = true
            }
            if didStopOnRightSide {
                didStopOnRightSide = false
            }
        } else if angle < RadianValuesInCircle.Quarter && previousAngle > RadianValuesInCircle.ThreeQuarters  {
            if isSecondCircle {
                canHandleMoveRight = false
                didStopOnRightSide = true
            } else {
                if !didStopOnLeftSide {
                    isSecondCircle = true
                }
            }
            if didStopOnLeftSide {
                didStopOnLeftSide = false
            }
        } else if (canHandleMoveRight && canHandleMoveLeft) ||
        (!canHandleMoveLeft && angle - previousAngle > 0.0 && angle < RadianValuesInCircle.Quarter) ||
        (!canHandleMoveRight && angle - previousAngle < 0.0 && angle > RadianValuesInCircle.ThreeQuarters) {
            var timeInHours =  getTimeInHoursFromAngle(angle)
            if isSecondCircle {
                timeInHours += 12
            }
            let hours = floor(timeInHours)
            let minutes = (timeInHours - hours) * 60
            setTimeWithHours(Int(hours), andMinutes: Int(minutes))
            
            canHandleMoveLeft = true
            canHandleMoveRight = true
        }
        return true
    }
    
    override func endTrackingWithTouch(touch: UITouch?, withEvent event: UIEvent?) {
        isTracking = false
        canHandleMoveLeft = true
        canHandleMoveRight = true
        didStopOnLeftSide = false
        didStopOnRightSide = false
        sendActionsForControlEvents(UIControlEvents.ValueChanged)
    }
    
    private func getAngleFromPoint(p: CGPoint) -> Double {
        let deltaY = p.y - self.frame.size.height/2
        let deltaX = p.x - self.frame.size.width/2
        let angleEndPoint = Double(atan2(deltaY, deltaX) - radianOffset)
        if angleEndPoint < 0 {
            return angleEndPoint + RadianValuesInCircle.FullCircle
        }
        return angleEndPoint
    }

    // MARK: - Draw UI
    
    private let radianOffset = -CGFloat(RadianValuesInCircle.Quarter)
    override func drawRect(rect: CGRect) {
        let center = CGPoint(x: bounds.width/2, y: bounds.height/2)
        let radius: CGFloat = min(bounds.width, bounds.height)/2 - max(primaryCircleStrokeSize, shadowCircleStrokeSize)/2 - primaryCircleHandleRadius
        
        // Shadow circle
        shadowCircleColor.set()
//        let shadowCircleOffset = primaryCircleHandleRadius*2
        let shadowCircleRect = CGRect(
            x: center.x - radius,
            y: center.y - radius,
            width: radius * 2,
            height: radius * 2)
        let shadowCirclePath = UIBezierPath(ovalInRect: shadowCircleRect)
        shadowCirclePath.lineWidth = shadowCircleStrokeSize
        shadowCirclePath.stroke()
        
        // Primary circle
        primaryCircleColor.set()
        let primaryCircleRounedBeginningRect = CGRect(
            x: center.x - primaryCircleStrokeSize/2,
            y: center.y - radius - primaryCircleStrokeSize/2,
            width: primaryCircleStrokeSize,
            height: primaryCircleStrokeSize)
        let primaryCircleRounedBeginningPath = UIBezierPath(ovalInRect:primaryCircleRounedBeginningRect)
        primaryCircleRounedBeginningPath.fill()
        
        let startAngle = 0 + radianOffset
        let endAngle = CGFloat(getRadiansFromTimeInDate(_time)) + radianOffset
        
        let primaryCircleForTimePath = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: true)
        primaryCircleForTimePath.lineWidth = primaryCircleStrokeSize
        primaryCircleForTimePath.stroke()
        
        // Primary circle handle
        let endAngleForPoint: CGFloat = endAngle - startAngle + radianOffset
        let xYOffset = -primaryCircleHandleRadius
        let endAnglePoint: CGPoint = CGPoint(
            x: bounds.width/2 + cos(endAngleForPoint) * radius + xYOffset,
            y: bounds.height/2 + sin(endAngleForPoint) * radius + xYOffset)
        
        let primaryCircleHandleRect = CGRect(
            x: endAnglePoint.x - xYOffset/2,
            y: endAnglePoint.y - xYOffset/2,
            width: primaryCircleHandleRadius,
            height: primaryCircleHandleRadius)
        let primaryCircleHandlePath = UIBezierPath(ovalInRect: primaryCircleHandleRect)
        primaryCircleHandlePath.fill()
        
        // Second replacement circle background
        if shouldDrawHelperCircle {
            primaryCircleColor.colorWithAlphaComponent(0.1).set()
            let secondCirclePath = UIBezierPath(ovalInRect: shadowCircleRect)
            secondCirclePath.fill()
        }
        
        // Primary circle handle background
        if isTracking {
            primaryCircleColor.colorWithAlphaComponent(0.2).set()
            let primaryCircleHandleBackgroundRect = CGRect(
                origin: endAnglePoint,
                size: CGSizeMake(primaryCircleHandleRadius*2, primaryCircleHandleRadius*2))
            let primaryCircleHandleBackgroundPath = UIBezierPath(ovalInRect: primaryCircleHandleBackgroundRect)
            primaryCircleHandleBackgroundPath.fill()
        }
    }
    
}