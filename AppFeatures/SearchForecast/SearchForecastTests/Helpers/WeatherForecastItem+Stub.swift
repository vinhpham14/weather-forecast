//
//  WeatherForecastItem+Stub.swift
//  SearchForecastTests
//
//  Created by Pham Quang Vinh on 8/30/21.
//

import Foundation
import SearchForecast


extension WeatherForecastItem {
    static func random() -> WeatherForecastItem {
        let date = Int(Date().timeIntervalSince1970)
        return WeatherForecastItem(
            id: UUID(),
            date: Date.init(timeIntervalSince1970: Double(Int.random(in: (date - 1000)...date))),
            pressure: Double.random(in: 0...100),
            humidity: Double.random(in: 0...100),
            temperature: Double.random(in: 0...100),
            description: "\(Double.random(in: 0...100))"
        )
    }
}
