//
//  WeatherForecastPresentable.swift
//  SearchForecast
//
//  Created by Pham Quang Vinh on 8/30/21.
//

import Foundation


public struct WeatherForecastPresentable {
    public let date: String
    public let pressure: String
    public let humidity: String
    public let temperature: String
    public let description: String
    
    public init(date: String, pressure: String, humidity: String, temperature: String, description: String) {
        self.date = date
        self.pressure = pressure
        self.humidity = humidity
        self.temperature = temperature
        self.description = description
    }
}
