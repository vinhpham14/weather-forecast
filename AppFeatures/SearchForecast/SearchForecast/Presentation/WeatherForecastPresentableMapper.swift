//
//  WeatherForecastPresentableMapper.swift
//  SearchForecast
//
//  Created by Pham Quang Vinh on 8/30/21.
//

import Foundation


public final class DefaultWeatherForecastDateFormatter: DateFormatter {
    private let defaultFormat = "E, dd MMM yyy"
    
    public override init() {
        super.init()
        self.dateFormat = defaultFormat
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

public final class WeatherForecastPresentableMapper {
    
    private init() { }
    
    public static func map(
        item: WeatherForecastItem,
        unit: UnitTemperature,
        dateFormatter: DateFormatter = DefaultWeatherForecastDateFormatter()
    ) -> WeatherForecastPresentable {
        
        let measurement = Measurement(value: item.temperature, unit: unit)
        let formatter = MeasurementFormatter()
        return WeatherForecastPresentable(
            date: dateFormatter.string(from: item.date),
            pressure: "\(Int(item.pressure))",
            humidity: "\(Int(item.humidity))",
            temperature: formatter.string(from: measurement),
            description: item.description
        )
    }
}
