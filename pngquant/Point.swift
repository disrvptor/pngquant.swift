//
//  Point.swift
//  pngquant
//
//  Created by Guy Pascarella on 1/19/20.
//  Copyright © 2020 Jenever, LLC. All rights reserved.
//

import Foundation
import UIKit

struct Point : Equatable {
    let x : CGFloat
    let y : CGFloat
    let z : CGFloat

    init(_ x: CGFloat, _ y : CGFloat, _ z : CGFloat) {
        self.x = x
        self.y = y
        self.z = z
    }

    init(from color : UIColor) {
        var r : CGFloat = 0
        var g : CGFloat = 0
        var b : CGFloat = 0
        var a : CGFloat = 0
        if color.getRed(&r, green: &g, blue: &b, alpha: &a) {
            x = r
            y = g
            z = b
        } else {
            x = 0
            y = 0
            z = 0
        }
    }

    func toUIColor() -> UIColor {
        return UIColor(red: x, green: y, blue: z, alpha: 1)
    }

    func distanceSquared(to p : Point) -> CGFloat {
        return (self.x - p.x) * (self.x - p.x)
            + (self.y - p.y) * (self.y - p.y)
            + (self.z - p.z) * (self.z - p.z)
    }

    static func == (lhs: Point, rhs: Point) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
    }

    static let zero = Point(0, 0, 0)

    static func +(lhs : Point, rhs : Point) -> Point {
        return Point(lhs.x + rhs.x, lhs.y + rhs.y, lhs.z + rhs.z)
    }

    static func /(lhs : Point, rhs : CGFloat) -> Point {
        return Point(lhs.x / rhs, lhs.y / rhs, lhs.z / rhs)
    }

}
