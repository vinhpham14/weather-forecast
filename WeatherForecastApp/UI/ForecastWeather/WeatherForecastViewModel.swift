//
//  WeatherForecastViewModel.swift
//  WeatherForecastApp
//
//  Created by Pham Quang Vinh on 8/31/21.
//

import SearchForecast


struct WeatherForecastViewModel: Equatable {
    private let presentableItem: WeatherForecastPresentable
    
    var date: String? {
        return "Date: \(presentableItem.date)"
    }
    
    var temperature: String? {
        return "Average Temperature: \(presentableItem.temperature)"
    }
    
    var pressure: String? {
        return "Pressure: \(presentableItem.pressure)"
    }
    
    var humidity: String? {
        return "Humidity: \(presentableItem.humidity)"
    }
    
    var description: String? {
        return "Description: \(presentableItem.description)"
    }
    
    init(_ item: WeatherForecastPresentable) {
        self.presentableItem = item
    }
    
    static func == (lhs: WeatherForecastViewModel, rhs: WeatherForecastViewModel) -> Bool {
        lhs.presentableItem.date == rhs.presentableItem.date
            && lhs.presentableItem.pressure == rhs.presentableItem.pressure
            && lhs.presentableItem.humidity == rhs.presentableItem.humidity
            && lhs.presentableItem.temperature == rhs.presentableItem.temperature
            && lhs.presentableItem.description == rhs.presentableItem.description
    }
}
