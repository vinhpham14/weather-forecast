//
//  WeatherForecastItem.swift
//  SearchForecast
//
//  Created by Pham Quang Vinh on 8/29/21.
//

import Foundation


public struct WeatherForecastItem {
    public let id: UUID
    public let date: Date
    public let pressure: Double
    public let humidity: Double
    public let temperature: Double
    public let description: String
    
    public init( id: UUID, date: Date, pressure: Double, humidity: Double, temperature: Double, description: String) {
        self.id = id
        self.date = date
        self.pressure = pressure
        self.humidity = humidity
        self.temperature = temperature
        self.description = description
    }
}

extension WeatherForecastItem: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
}
