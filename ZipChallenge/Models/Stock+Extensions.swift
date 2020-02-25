//
//  Stock+Extensions.swift
//  ZipChallenge
//
//  Created by Robert Bernardini on 23/2/20.
//  Copyright © 2020 Robert Bernardini. All rights reserved.
//

import Foundation
import CoreData

extension Stock {
    func update(with stock: StockPersistable) {
        companyLogo = stock.companyLogo
        industry = stock.industry
        lastDividend = stock.lastDividend
        name = stock.name
        percentageChange = stock.percentageChange
        changes = stock.changes
        price = stock.price
        sector = stock.sector
        symbol = stock.symbol
        isFavorite = stock.isFavorite
    }
}
