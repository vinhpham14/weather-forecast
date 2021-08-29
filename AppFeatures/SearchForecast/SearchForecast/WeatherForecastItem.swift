//
//  WeatherForecastItem.swift
//  SearchForecast
//
//  Created by Pham Quang Vinh on 8/29/21.
//

import Foundation


struct WeatherForecastItem {
    let date: Date
    let pressure: Double
    let humidity: Double
    let temperature: Double
    let temperatureUnit: UnitTemperature
    let description: String
}
