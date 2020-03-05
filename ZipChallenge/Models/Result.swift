//
//  Result.swift
//  ZipChallenge
//
//  Created by Robert Bernardini on 4/3/20.
//  Copyright © 2020 Robert Bernardini. All rights reserved.
//

import Foundation

enum Result<T, ResultError: Error> {
    case success(T)
    case failure(ResultError)
}
