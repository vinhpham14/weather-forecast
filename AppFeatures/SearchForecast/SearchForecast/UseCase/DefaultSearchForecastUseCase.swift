//
//  DefaultSearchForecastUseCase.swift
//  SearchForecast
//
//  Created by Pham Quang Vinh on 8/30/21.
//

import Foundation


public class DefaultSearchForecastUseCase: SearchForecastUseCase {
    private let searchRepository: SearchForecastRepository
    
    public init(searchRepository: SearchForecastRepository) {
        self.searchRepository = searchRepository
    }
    
    public func searchForecast(parameters: SearchParameters, completion: @escaping (SearchForecastUseCaseResult) -> Void) {
        let params = Self.map(useCaseParameters: parameters)
        self.searchRepository.searchForecast(params) { result in
            switch result {
            case let .success(items):
                completion(.success(items: items))
            case let .failure(err):
                completion(.failure(err))
            }
        }
    }
    
    private static func map(useCaseParameters params: SearchParameters) -> SearchForecastParameters {
        return SearchForecastParameters(params.keyword, params.maximumForecastDay, params.unit)
    }
}
