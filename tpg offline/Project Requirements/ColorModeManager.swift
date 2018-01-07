//
//  ColorModeManager.swift
//  tpg offline
//
//  Created by Rémy DA COSTA FARO on 06/01/2018.
//  Copyright © 2018 Remy. All rights reserved.
//

import Foundation

class ColorModeManager: NSObject {
    fileprivate override init() {
        super.init()
    }

    static let shared = ColorModeManager()

    private var colorModeDelegates = [ColorModeDelegate]()

    func addColorModeDelegate<T>(_ delegate: T) where T: ColorModeDelegate, T: Equatable {
        colorModeDelegates.append(delegate)
    }

    func removeColorModeDelegate<T>(_ delegate: T) where T: ColorModeDelegate, T: Equatable {
        for (index, colorModeDelegate) in colorModeDelegates.enumerated() {
            if let colorModeDelegate = colorModeDelegate as? T, colorModeDelegate == delegate {
                colorModeDelegates.remove(at: index)
                break
            }
        }
    }

    func updateColorMode() {
        DispatchQueue.main.async {
            self.colorModeDelegates.forEach { $0.colorModeDidUpdated() }
        }
    }
}

protocol ColorModeDelegate: class {
    func colorModeDidUpdated()
}
