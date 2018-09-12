//
//  AddToSiriTableViewCell.swift
//  tpg offline
//
//  Created by Rémy on 30/08/2018.
//  Copyright © 2018 Remy. All rights reserved.
//

import UIKit
import IntentsUI

@available(iOS 12.0, *)
class AddToSiriTableViewCell: UITableViewCell,
                              INUIAddVoiceShortcutViewControllerDelegate {
  // swiftlint:disable:next line_length
  func addVoiceShortcutViewController(_ controller: INUIAddVoiceShortcutViewController,
                                      didFinishWith voiceShortcut: INVoiceShortcut?,
                                      error: Error?) {
    controller.dismiss(animated: true, completion: nil)
  }

  func addVoiceShortcutViewControllerDidCancel(_ controller: INUIAddVoiceShortcutViewController) {
    // swiftlint:disable:previous line_length
    controller.dismiss(animated: true, completion: nil)
  }

  @IBOutlet weak var stackView: UIStackView!

  override func awakeFromNib() {
    super.awakeFromNib()
  }

  var shortcut: INShortcut?
  var parent: UIViewController? = nil {
    didSet {
      for x in stackView.subviews {
        x.removeFromSuperview()
      }
      let textLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
      textLabel.textColor = App.textColor
      textLabel.text =
        "Do you want to see the departures of this stop at a glance?".localized
      textLabel.numberOfLines = 0
      textLabel.textAlignment = .center
      self.stackView.addArrangedSubview(textLabel)
      self.backgroundColor = App.cellBackgroundColor
      let selectedBackgroundView = UIView()
      selectedBackgroundView.backgroundColor = App.cellBackgroundColor
      self.selectedBackgroundView = selectedBackgroundView
      if INPreferences.siriAuthorizationStatus() != .authorized {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        button.setTitle("Enable Siri in the settings".localized, for: .normal)
        self.stackView.addArrangedSubview(button)
      } else {
        let button = INUIAddVoiceShortcutButton(style:
          App.darkMode ? .blackOutline : .whiteOutline)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 150).isActive = true
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.addTarget(self, action: #selector(addToSiri), for: .touchUpInside)
        stackView.addArrangedSubview(button)
      }
    }
  }

  @objc func addToSiri() {
    if let shortcut = self.shortcut, let parent = self.parent {
      let viewController = INUIAddVoiceShortcutViewController(shortcut: shortcut)
      viewController.modalPresentationStyle = .formSheet
      viewController.delegate = self
      parent.present(viewController, animated: true, completion: nil)
    }
  }
}
