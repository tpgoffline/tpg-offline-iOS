import Mapbox

class CustomCalloutView: UIView, MGLCalloutView {
  var representedObject: MGLAnnotation

  // Allow the callout to remain open during panning.
  let dismissesAutomatically: Bool = false
  let isAnchoredToAnnotation: Bool = true

  // https://github.com/mapbox/mapbox-gl-native/issues/9228
  override var center: CGPoint {
    set {
      var newCenter = newValue
      newCenter.y -= bounds.midY
      super.center = newCenter
    }
    get {
      return super.center
    }
  }

  lazy var leftAccessoryView = UIView() /* unused */
  lazy var rightAccessoryView = UIView() /* unused */

  weak var delegate: MGLCalloutViewDelegate?

  let tipHeight: CGFloat = 10.0
  let tipWidth: CGFloat = 20.0

  let mainBody: UIStackView
  let titleLabel: UILabel
  let subTitleLabel: UILabel

  private lazy var backgroundView: UIView = {
    let view = UIView()
    view.backgroundColor = App.cellBackgroundColor
    view.layer.cornerRadius = 4.0
    return view
  }()

  required init(representedObject: MGLAnnotation) {
    self.representedObject = representedObject
    self.titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 8))
    self.titleLabel.text = representedObject.title ?? ""
    self.titleLabel.numberOfLines = 0
    self.titleLabel.textColor = App.textColor
    self.subTitleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 8))
    self.subTitleLabel.text = representedObject.subtitle ?? ""
    self.subTitleLabel.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
    self.subTitleLabel.numberOfLines = 0
    self.subTitleLabel.textColor = App.textColor
    self.mainBody = UIStackView()
    self.mainBody.alignment = .fill
    self.mainBody.distribution = .fill
    self.mainBody.axis = .vertical
    self.mainBody.translatesAutoresizingMaskIntoConstraints = false
    self.mainBody.widthAnchor.constraint(equalToConstant: 150).isActive = true
    self.mainBody.addArrangedSubview(self.titleLabel)
    self.mainBody.addArrangedSubview(self.subTitleLabel)
    self.mainBody.layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    self.mainBody.isLayoutMarginsRelativeArrangement = true

    super.init(frame: .zero)

    backgroundColor = .clear

    mainBody.backgroundColor = .darkGray
    mainBody.tintColor = .white
    mainBody.layer.cornerRadius = 4.0
    pinBackground(backgroundView, to: mainBody)

    addSubview(mainBody)
  }

  required init?(coder decoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func pinBackground(_ view: UIView, to stackView: UIStackView) {
    view.translatesAutoresizingMaskIntoConstraints = false
    stackView.insertSubview(view, at: 0)
    view.pin(to: stackView)
  }

  // MARK: - MGLCalloutView API

  func presentCallout(from rect: CGRect,
                      in view: UIView,
                      constrainedTo constrainedRect: CGRect,
                      animated: Bool) {
    view.addSubview(self)

    // Prepare title label.
    //mainBody.setTitle(representedObject.title!, for: .normal)

    // Prepare our frame, adding extra space at the bottom for the tip.
    let size = mainBody.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    let frameWidth: CGFloat = size.width
    let frameHeight: CGFloat = size.height + tipHeight
    let frameOriginX = rect.origin.x + (rect.size.width/2.0) - (frameWidth/2.0)
    let frameOriginY = rect.origin.y - frameHeight
    frame = CGRect(x: frameOriginX,
                   y: frameOriginY,
                   width: frameWidth,
                   height: frameHeight)
    mainBody.backgroundColor = .white

    if animated {
      alpha = 0

      UIView.animate(withDuration: 0.2) { [weak self] in
        self?.alpha = 1
      }
    }
  }

  func dismissCallout(animated: Bool) {
    if superview != nil {
      if animated {
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
          self?.alpha = 0
          }, completion: { [weak self] _ in
            self?.removeFromSuperview()
        })
      } else {
        removeFromSuperview()
      }
    }
  }

  // MARK: - Callout interaction handlers

  func isCalloutTappable() -> Bool {
    if let delegate = delegate {
      if delegate.responds(to:
        #selector(MGLCalloutViewDelegate.calloutViewShouldHighlight)) {
        return delegate.calloutViewShouldHighlight!(self)
      }
    }
    return false
  }

  @objc func calloutTapped() {
    if isCalloutTappable(),
      delegate!.responds(to: #selector(MGLCalloutViewDelegate.calloutViewTapped)) {
      delegate!.calloutViewTapped!(self)
    }
  }

  // MARK: - Custom view styling

  override func draw(_ rect: CGRect) {
    // Draw the pointed tip at the bottom.
    let fillColor: UIColor = App.cellBackgroundColor

    let tipLeft = rect.origin.x + (rect.size.width / 2.0) - (tipWidth / 2.0)
    let tipBottom = CGPoint(x: rect.origin.x + (rect.size.width / 2.0),
                            y: rect.origin.y + rect.size.height)
    let heightWithoutTip = rect.size.height - tipHeight - 1

    let currentContext = UIGraphicsGetCurrentContext()!

    let tipPath = CGMutablePath()
    tipPath.move(to: CGPoint(x: tipLeft, y: heightWithoutTip))
    tipPath.addLine(to: CGPoint(x: tipBottom.x, y: tipBottom.y))
    tipPath.addLine(to: CGPoint(x: tipLeft + tipWidth, y: heightWithoutTip))
    tipPath.closeSubpath()

    fillColor.setFill()
    currentContext.addPath(tipPath)
    currentContext.fillPath()
  }
}

public extension UIView {
  public func pin(to view: UIView) {
    NSLayoutConstraint.activate([
      leadingAnchor.constraint(equalTo: view.leadingAnchor),
      trailingAnchor.constraint(equalTo: view.trailingAnchor),
      topAnchor.constraint(equalTo: view.topAnchor),
      bottomAnchor.constraint(equalTo: view.bottomAnchor)
      ])
  }
}
