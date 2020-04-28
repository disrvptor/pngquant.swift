//
//  Cluster.swift
//  pngquant
//
//  Created by Guy Pascarella on 1/19/20.
//  Copyright © 2020 Jenever, LLC. All rights reserved.
//

import Foundation
import UIKit

class Cluster {
    var points = [Point]()
    var center : Point

    init(center : Point) {
        self.center = center
    }

    func calculateCurrentCenter() -> Point {
        if points.isEmpty {
            return Point.zero
        }
        return points.reduce(Point.zero, +) / CGFloat(points.count)
    }

    func updateCenter() {
        if points.isEmpty {
            return
        }
        let currentCenter = calculateCurrentCenter()
        center = points.min(by: {$0.distanceSquared(to: currentCenter) < $1.distanceSquared(to: currentCenter)})!
    }

}
