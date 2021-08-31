//
//  RemoteWeatherForecastItem.swift
//  SearchForecast
//
//  Created by Pham Quang Vinh on 8/29/21.
//

import Foundation


struct RemoteWeatherForecastItem {
    public let id: UUID
    public let date: Date
    public let pressure: Double
    public let humidity: Double
    public let temperature: Double
    public let description: String
}


extension RemoteWeatherForecastItem: Decodable {
    
    struct Main: Decodable {
        let temp: Double
        let pressure: Double
        let humidity: Double
    }
    
    struct Weather: Decodable {
        let description: String
    }
    
    enum CodingKeys: String, CodingKey {
        case date = "dt"
        case pressure
        case humidity
        case temperature
        case description
        case main = "main"
        case weather = "weather"
    }
    
    private struct UnexpectedError: Error { }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let main = try container.decode(Main.self, forKey: .main)
        let weathers = try container.decode([Weather].self, forKey: .weather)
        
        guard let weather = weathers.first else {
            throw UnexpectedError()
        }
        
        self.id = UUID()
        let timeInterval = try container.decode(Double.self, forKey: .date)
        self.date = Date(timeIntervalSince1970: timeInterval)
        self.pressure = main.pressure
        self.temperature = main.temp
        self.humidity = main.humidity
        self.description = weather.description
    }
}
