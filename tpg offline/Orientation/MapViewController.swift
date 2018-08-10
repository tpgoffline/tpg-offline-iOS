//
//  MapViewController.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 21/10/2017.
//  Copyright © 2018 Rémy Da Costa Faro. All rights reserved.
//

import UIKit
import Crashlytics

class MapViewController: UIViewController {

  var mapImage: UIImage!
  @IBOutlet weak var scrollView: UIScrollView!
  var imageView: UIImageView!

  override func viewDidLoad() {
    super.viewDidLoad()
    App.log("Show map \(title ?? "?")")
    App.logEvent("Show map",
                 attributes: ["map": (title ?? "?")])
    imageView = UIImageView(image: mapImage)

    scrollView.delegate = self
    scrollView.backgroundColor = .white
    scrollView.contentSize = imageView.bounds.size
    scrollView.autoresizingMask = [UIViewAutoresizing.flexibleWidth,
                                   UIViewAutoresizing.flexibleHeight]
    setZoomScale()

    let point = CGPoint(x: (scrollView.contentSize.width -
                          scrollView.bounds.size.width) / 2,
                        y: (scrollView.contentSize.height -
                          scrollView.bounds.size.height) / 2)
    scrollView.setContentOffset(point, animated: false)

    scrollView.addSubview(imageView)

    ColorModeManager.shared.addColorModeDelegate(self)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  deinit {
    ColorModeManager.shared.removeColorModeDelegate(self)
  }
}

extension MapViewController: UIScrollViewDelegate {
  func viewForZooming(in scrollView: UIScrollView) -> UIView? {
    return imageView
  }

  func setZoomScale() {
    let imageViewSize = imageView.bounds.size
    let scrollViewSize = scrollView.bounds.size
    let widthScale = scrollViewSize.width / imageViewSize.width
    let heightScale = scrollViewSize.height / imageViewSize.height

    scrollView.minimumZoomScale = min(widthScale, heightScale)
    scrollView.maximumZoomScale = 10.0
    scrollView.zoomScale = 1.0
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
