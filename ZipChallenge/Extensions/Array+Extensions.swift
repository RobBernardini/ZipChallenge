//
//  Array+Extensions.swift
//  ZipChallenge
//
//  Created by Robert Bernardini on 27/2/20.
//  Copyright © 2020 Robert Bernardini. All rights reserved.
//

import Foundation

extension Array {
    // Spearates an array into an array of arrays of size element.
    func toChunks(of size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
