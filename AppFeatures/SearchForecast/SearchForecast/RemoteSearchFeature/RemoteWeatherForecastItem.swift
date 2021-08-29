//
//  RemoteWeatherForecastItem.swift
//  SearchForecast
//
//  Created by Pham Quang Vinh on 8/29/21.
//

import Foundation


struct RemoteWeatherForecastItem: Decodable {
    public let id: UUID
    public let date: Date
    public let pressure: Double
    public let humidity: Double
    public let temperature: Double
    public let description: String
}
