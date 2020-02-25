
//
//  StockList.swift
//  ZipCodeChallenge
//
//  Created by Robert Bernardini on 21/2/20.
//  Copyright © 2020 Robert Bernardini. All rights reserved.
//

import Foundation

struct StockList {
    struct Stock {
        let symbol: String
        let name: String?
        let price: Double
        let exchange: String?
    }
    
    let stocks: [Stock]
}

extension StockList: Decodable {
    enum CodingKeys: String, CodingKey {
        case stocks = "symbolsList"
    }
}

extension StockList.Stock: Decodable {}
