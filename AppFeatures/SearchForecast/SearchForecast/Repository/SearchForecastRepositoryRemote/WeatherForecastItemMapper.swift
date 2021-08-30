//
//  WeatherForecastItemMapper.swift
//  SearchForecast
//
//  Created by Pham Quang Vinh on 8/29/21.
//

import Foundation


public final class WeatherForecastItemMapper {
    private struct Root: Decodable {
        let items: [RemoteWeatherForecastItem]
    }
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteWeatherForecastItem] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard response.statusCode == 200,
            let root = try? decoder.decode(Root.self, from: data) else {
            throw RemoteSearchForecastRepository.Error.invalidJSON
        }
        return root.items
    }
}
