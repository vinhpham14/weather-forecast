//
//  WeatherForecastItem.swift
//  SearchForecast
//
//  Created by Pham Quang Vinh on 8/29/21.
//

import Foundation


public struct WeatherForecastItem {
    public let date: Date
    public let pressure: Double
    public let humidity: Double
    public let temperature: Double
    public let description: String
    
    public init(date: Date, pressure: Double, humidity: Double, temperature: Double, description: String) {
        self.date = date
        self.pressure = pressure
        self.humidity = humidity
        self.temperature = temperature
        self.description = description
    }
}

extension WeatherForecastItem: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.date == rhs.date
        && lhs.pressure == rhs.pressure
        && lhs.humidity == rhs.humidity
        && lhs.temperature == rhs.temperature
        && lhs.description == rhs.description
    }
}
