//
//  RGBA32.swift
//  pngquant
//
//  Created by Guy Pascarella on 1/20/20.
//  Copyright © 2020 Jenever, LLC. All rights reserved.
//

// Pulled from https://gist.github.com/ha1f/bd7ffc9153007e94391ef88d4297e051

import Foundation
import UIKit

struct RGBA32 : Equatable {
    
//    // MARK: Properties
//    let red: CGFloat
//    let green: CGFloat
//    let blue: CGFloat
//    let alpha: CGFloat
//
//    // MARK: Getter
//    var colorHex: UInt32 {
//        let iRed = UInt32(red * 255.0)
//        let iGreen = UInt32(green * 255.0)
//        let iBlue = UInt32(blue * 255.0)
//
//        return (iRed << 16) + (iGreen << 8) + iBlue
//    }
//
//    var uiColor: UIColor {
//        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
//    }
//
//    // I don't know if this is correct
//    static let bitmapInfo = CGBitmapInfo.byteOrder32Little.rawValue + CGImageAlphaInfo.premultipliedLast.rawValue;
//
//    // MARK: Initializer
//    init(hex: UInt32, alpha: CGFloat = 1.0) {
//        self.red = CGFloat((hex & 0xFF0000) >> 16) / 255.0
//        self.green = CGFloat((hex & 0x00FF00) >> 8) / 255.0
//        self.blue = CGFloat(hex & 0x0000FF) / 255.0
//        self.alpha = alpha
//    }
//
//    init?(color: UIColor) {
//        var fRed: CGFloat = 0
//        var fGreen: CGFloat = 0
//        var fBlue: CGFloat = 0
//        var fAlpha: CGFloat = 0
//        guard color.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) else {
//            return nil
//        }
//        self.red = fRed
//        self.green = fGreen
//        self.blue = fBlue
//        self.alpha = fAlpha
//    }

    private var rgba: UInt32

    var red: UInt8 {
        return UInt8((rgba >> 24) & 255)
    }

    var green: UInt8 {
        return UInt8((rgba >> 16) & 255)
    }

    var blue: UInt8 {
        return UInt8((rgba >> 8) & 255)
    }

    var alpha: UInt8 {
        return UInt8((rgba >> 0) & 255)
    }

    init(red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8) {
        rgba = (UInt32(red) << 24) | (UInt32(green) << 16) | (UInt32(blue) << 8) | (UInt32(alpha) << 0)
    }

    init(color: UIColor) {
        var fRed : CGFloat = 0
        var fGreen : CGFloat = 0
        var fBlue : CGFloat = 0
        var fAlpha: CGFloat = 0
        if color.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
            let iRed = UInt32(fRed * 255.0)
            let iGreen = UInt32(fGreen * 255.0)
            let iBlue = UInt32(fBlue * 255.0)
            let iAlpha = UInt32(fAlpha * 255.0)

            //  (Bits 24-31 are alpha, 16-23 are red, 8-15 are green, 0-7 are blue).
            self.rgba = (iAlpha << 24) + (iRed << 16) + (iGreen << 8) + iBlue
        } else {
            // Could not extract RGBA components:
            self.rgba = 0;
        }
    }

    static let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Little.rawValue

    static func ==(lhs: RGBA32, rhs: RGBA32) -> Bool {
        return lhs.rgba == rhs.rgba
    }

}
