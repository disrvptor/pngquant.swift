//
//  KMeans.swift
//  pngquant
//
//  Created by Guy Pascarella on 1/19/20.
//  Copyright © 2020 Jenever, LLC. All rights reserved.
//

import Foundation
import UIKit

class KMeans {

    private static let debug = true;
    private static func log(_ msg:String) {
        if debug {
            print(msg);
        }
    }

    private static func findClosest(for p : Point, from clusters: [Cluster]) -> Cluster {
        return clusters.min(by: {$0.center.distanceSquared(to: p) < $1.center.distanceSquared(to: p)})!
    }

    public static func cluster(points : [Point], into k : Int, distance : CGFloat = 0.001) -> [Cluster] {
        var clusters = [Cluster]()
        log("Generating \(k) clusters");
        for _ in 0 ..< k {
            var p = points.randomElement()
            while p == nil || clusters.contains(where: {$0.center == p}) {
                p = points.randomElement()
            }
            clusters.append(Cluster(center: p!))
        }

        for p in points {
            let closest = findClosest(for: p, from: clusters)
            closest.points.append(p)
        }

        clusters.forEach {
            $0.updateCenter()
        }

        var totalConvergenceTime = TimeInterval(0);
        for i in 0 ..< 10 {
            let methodStart = Date()
            log("Performing iteration \(i) of convergence");
            clusters.forEach {
                $0.points.removeAll()
            }
            for p in points {
                let closest = findClosest(for: p, from: clusters)
                closest.points.append(p)
            }
            var converged = true
            clusters.forEach {
                let oldCenter = $0.center
                $0.updateCenter()
                if oldCenter.distanceSquared(to: $0.center) > distance {
                    converged = false
                }
            }
            let methodFinish = Date()
            let executionTime = methodFinish.timeIntervalSince(methodStart)
            totalConvergenceTime += executionTime;
            log("Execution time of iteration \(i): \(executionTime) s")
            if converged {
                log("Converged. Took \(i+1) iterations in \(totalConvergenceTime) s")
                break;
            }
        }

        return clusters;
    }

}
