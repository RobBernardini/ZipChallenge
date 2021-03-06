//
//  StockPriceList.swift
//  ZipCodeChallenge
//
//  Created by Robert Bernardini on 21/2/20.
//  Copyright © 2020 Robert Bernardini. All rights reserved.
//

import Foundation

/*
 Used to parse the Stock Price JSON response.
*/
struct StockPriceList {
    struct StockPrice {
        let symbol: String
        let price: Double
    }

    let prices: [StockPrice]
}

extension StockPriceList: Decodable {
    enum CodingKeys: String, CodingKey {
        case prices = "companiesPriceList"
    }
}

extension StockPriceList.StockPrice: Decodable {}
