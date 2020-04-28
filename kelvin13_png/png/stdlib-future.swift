//
//  stdlib-future.swift
//  pngquant
//
//  Created by Guy Pascarella on 4/27/20.
//  Copyright © 2020 Jenever, LLC. All rights reserved.
//

// blocked by this: https://github.com/apple/swift/pull/22289
extension Sequence
{
    @inlinable
    func count(where predicate:(Element) throws -> Bool) rethrows -> Int
    {
        var count:Int = 0
        for e:Element in self where try predicate(e)
        {
            count += 1
        }
        return count
    }
}
