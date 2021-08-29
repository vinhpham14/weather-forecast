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
    public let temperatureUnit: UnitTemperature
    public let description: String
}
