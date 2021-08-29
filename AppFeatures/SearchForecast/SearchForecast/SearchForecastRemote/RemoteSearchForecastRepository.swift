//
//  RemoteSearchForecastRepository.swift
//  SearchForecast
//
//  Created by Pham Quang Vinh on 8/29/21.
//

import Foundation


public final class RemoteSearchForecastRepository: SearchForecastRepository {
    private let endpoint: ForecastEndpoint
    private let apiClient: APIClient
    
    public enum Error: Swift.Error {
        case invalidJSON
        case unexpected
    }
    
    public init(endpoint: ForecastEndpoint, apiClient: APIClient) {
        self.endpoint = endpoint
        self.apiClient = apiClient
    }
    
    public func searchForecast(_ parameters: SearchParameters, completion: @escaping (RemoteSearchForecastRepository.Result) -> Void) {
        let url = endpoint.search(
            keyword: parameters.cityName,
            maximumForcastDay: parameters.maximumForecastDay,
            unit: parameters.unit.description
        
        )
        apiClient.get(from: url, completion: { [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case let .success((data, response)):
                completion(Self.map(data, from: response))
                
            case .failure(_):
                completion(.failure(Error.unexpected))
            }
        })
    }
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> SearchForecastResult {
        do {
            let items = try WeatherForecastItemMapper.map(data, from: response)
            return .success(items.toDomainItems())
        } catch {
            return .failure(error)
        }
    }
}


private extension Array where Element == RemoteWeatherForecastItem {
    func toDomainItems() -> [WeatherForecastItem] {
        return map { WeatherForecastItem(id: $0.id, date: $0.date, pressure: $0.pressure, humidity: $0.humidity, temperature: $0.temperature, description: $0.description) }
    }
}
