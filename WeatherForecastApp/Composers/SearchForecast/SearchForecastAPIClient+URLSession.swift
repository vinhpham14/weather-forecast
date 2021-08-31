//
//  SearchForecastAPIClient+URLSession.swift
//  WeatherForecastApp
//
//  Created by Pham Quang Vinh on 8/31/21.
//

import SearchForecast


class URLSessionSearchForecastAPIClient: SearchForecastAPIClient {
    private let session: URLSession
    
    public init(session: URLSession) {
        self.session = session
    }
    
    private struct UnexpectedValuesRepresentation: Error {}
    
    func get(from url: URL, completion: @escaping APICompletion) -> Cancellable {
        let task = session.dataTask(with: url) { data, response, error in
            completion(Result {
                if let error = error {
                    throw error
                } else if let data = data, let response = response as? HTTPURLResponse {
                    return (data, response)
                } else {
                    throw UnexpectedValuesRepresentation()
                }
            })
        }
        task.resume()
        
        return { task.cancel() }
    }
}
