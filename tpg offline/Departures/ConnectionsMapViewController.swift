//
//  ConnectionsMapViewController.swift
//  tpg offline
//
//  Created by Rémy DA COSTA FARO on 21/01/2018.
//  Copyright © 2018 Remy. All rights reserved.
//

import UIKit
import Alamofire
import Crashlytics

class ConnectionsMapViewController: UIViewController {

  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var errorLabel: UILabel!
  @IBOutlet weak var loadingView: UIActivityIndicatorView!
  var imageView: UIImageView!

  var stopCode: String = ""
  var downloadData: Data?
  var saved = false

  override func viewDidLoad() {
    super.viewDidLoad()
    App.log("Show connections maps")
    Answers.logCustomEvent(withName: "Show connections maps",
                           customAttributes: ["appCode": stopCode])
    title = "Map".localized

    errorLabel.text = "Error. You're not connected to internet."
    errorLabel.textColor = App.textColor
    errorLabel.isHidden = true

    loadingView.activityIndicatorViewStyle = App.darkMode ? .white : .gray
    loadingView.startAnimating()

    var path: URL
    guard let dirString = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                              .allDomainsMask,
                                                              true).first else {
                                                                return
    }
    let dir = URL(fileURLWithPath: dirString)
    path = dir.appendingPathComponent("\(stopCode).jpg")

    do {
      let data = try Data(contentsOf: path)
      let image = UIImage(data: data)
      self.saved = true
      self.imageView = UIImageView(image: image)
      loadingView.isHidden = true
      self.adjustScrollView()
    } catch {
      Alamofire
        .request(URL.connectionsMap(stopCode: stopCode))
        .responseData(completionHandler: { (response) in
          if let data = response.result.value {
            self.downloadData = data
            let image = UIImage(data: data)
            self.imageView = UIImageView(image: image)
            self.adjustScrollView()
          } else {
            self.errorLabel.isHidden = false
          }
          self.loadingView.isHidden = true
        })
    }

    self.view.backgroundColor = App.cellBackgroundColor
    ColorModeManager.shared.addColorModeDelegate(self)
  }

  @objc func reload() {
    Alamofire
      .request(URL.connectionsMap(stopCode: stopCode))
      .responseData(completionHandler: { (response) in
        if let data = response.result.value {
          self.save()
          self.downloadData = data
          let image = UIImage(data: data)
          self.imageView = UIImageView(image: image)
          self.adjustScrollView()
          self.save()
        } else {
          self.errorLabel.isHidden = false
        }
        self.loadingView.isHidden = true
      })
  }

  func adjustScrollView() {
    navigationItem.rightBarButtonItems =
      [UIBarButtonItem(image: self.saved ? #imageLiteral(resourceName: "trash") : #imageLiteral(resourceName: "download"),
                       style: .plain,
                       target: self,
                       action: #selector(self.save),
                       accessbilityLabel: Text.downloadMap),
       UIBarButtonItem(image: #imageLiteral(resourceName: "reloadNavBar"),
                       style: .plain,
                       target: self,
                       action: #selector(self.reload),
                       accessbilityLabel: Text.reloadMap)]
    scrollView.delegate = self
    scrollView.backgroundColor = .white
    scrollView.contentSize = imageView.bounds.size
    scrollView.autoresizingMask = [UIViewAutoresizing.flexibleWidth,
                                   UIViewAutoresizing.flexibleHeight]
    let point = CGPoint(x: (scrollView.contentSize.width -
                          scrollView.bounds.size.width) / 2,
                        y: (scrollView.contentSize.height -
                          scrollView.bounds.size.height) / 2)
    scrollView.setContentOffset(point,
                                animated: false)

    scrollView.addSubview(imageView)
    setZoomScale()
  }

  deinit {
    ColorModeManager.shared.removeColorModeDelegate(self)
  }

  override func colorModeDidUpdated() {
    super.colorModeDidUpdated()
    self.view.backgroundColor = App.cellBackgroundColor
    errorLabel.textColor = App.textColor
    loadingView.activityIndicatorViewStyle = App.darkMode ? .white : .gray
  }

  @objc func save() {
    if !self.saved {
      guard let downloadData = downloadData else {
        return
      }
      DispatchQueue.global(qos: .utility).async {
        var fileURL = URL(fileURLWithPath:
          NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                              .allDomainsMask,
                                              true)[0])
        fileURL.appendPathComponent("\(self.stopCode).jpg")
        do {
          try downloadData.write(to: fileURL)
          self.saved = true
          DispatchQueue.main.async {
            self.navigationItem.rightBarButtonItems =
              [UIBarButtonItem(image: self.saved ? #imageLiteral(resourceName: "trash") : #imageLiteral(resourceName: "download"),
                               style: .plain,
                               target: self,
                               action: #selector(self.save),
                               accessbilityLabel: Text.downloadMap),
               UIBarButtonItem(image: #imageLiteral(resourceName: "reloadNavBar"),
                               style: .plain,
                               target: self,
                               action: #selector(self.reload),
                               accessbilityLabel: Text.reloadMap)]
          }
        } catch let error {
          print(error)
        }
      }
    } else {
      DispatchQueue.global(qos: .utility).async {
        var fileURL = URL(fileURLWithPath:
          NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                              .allDomainsMask,
                                              true)[0])
        fileURL.appendPathComponent("\(self.stopCode).jpg")
        do {
          try FileManager.default.removeItem(at: fileURL)
          self.saved = false
          DispatchQueue.main.async {
            self.navigationItem.rightBarButtonItems =
              [UIBarButtonItem(image: self.saved ? #imageLiteral(resourceName: "trash") : #imageLiteral(resourceName: "download"),
                               style: .plain,
                               target: self,
                               action: #selector(self.save),
                               accessbilityLabel: Text.downloadMap),
               UIBarButtonItem(image: #imageLiteral(resourceName: "reloadNavBar"),
                               style: .plain,
                               target: self,
                               action: #selector(self.reload),
                               accessbilityLabel: Text.reloadMap)]
          }
        } catch let error {
          print(error)
        }
      }
    }
  }
}

extension ConnectionsMapViewController: UIScrollViewDelegate {
  func viewForZooming(in scrollView: UIScrollView) -> UIView? {
    return imageView
  }
  func setZoomScale() {
    guard let imageView = imageView else { return }
    let imageViewSize = imageView.bounds.size
    let scrollViewSize = scrollView.bounds.size
    let widthScale = scrollViewSize.width / imageViewSize.width
    let heightScale = scrollViewSize.height / imageViewSize.height

    scrollView.minimumZoomScale = min(widthScale, heightScale)
    scrollView.maximumZoomScale = 10.0
    scrollView.zoomScale = scrollView.minimumZoomScale * 2
  }
  override func viewWillLayoutSubviews() {
    setZoomScale()
  }
  func scrollViewDidZoom(_ scrollView: UIScrollView) {
    let imageViewSize = imageView.frame.size
    let scrollViewSize = scrollView.bounds.size

    let verticalPadding = imageViewSize.height < scrollViewSize.height ?
      (scrollViewSize.height - imageViewSize.height) / 2 : 0
    let horizontalPadding = imageViewSize.width < scrollViewSize.width ?
      (scrollViewSize.width - imageViewSize.width) / 2 : 0

    scrollView.contentInset = UIEdgeInsets(top: verticalPadding,
                                           left: horizontalPadding,
                                           bottom: verticalPadding,
                                           right: horizontalPadding)
  }
}
