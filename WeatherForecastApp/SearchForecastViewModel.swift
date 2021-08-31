//
//  SearchForecastViewModel.swift
//  WeatherForecastApp
//
//  Created by Pham Quang Vinh on 8/31/21.
//

import Foundation
import SearchForecast
import RxSwift
import RxCocoa


struct WeatherForecastViewModel {
    private let presentableItem: WeatherForecastPresentable
    
    init(_ item: WeatherForecastPresentable) {
        self.presentableItem = item
    }
}

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    
    func transfrom(_ input: Input) -> Output
}

class SearchForecastViewModel: ViewModelType {
    
    struct Input {
        let searchTextChanged: Driver<String?>
    }
    
    struct Output {
        let weatherForecastItems: Driver<[WeatherForecastViewModel]>
    }
    
    private let searchKeywordCountThreshold: Int
    private let searchForecastUseCase: SearchForecastUseCase
    
    init(searchKeywordCountThreshold: Int, searchForecastUseCase: SearchForecastUseCase) {
        self.searchKeywordCountThreshold = searchKeywordCountThreshold
        self.searchForecastUseCase = searchForecastUseCase
    }
    
    func transfrom(_ input: Input) -> Output {
        
        let items = input.searchTextChanged
            .map({ $0 ?? "" })
            .filter({ [searchKeywordCountThreshold] in $0.count > searchKeywordCountThreshold })
            .flatMapLatest { [searchForecastUseCase] in
                return searchForecastUseCase
                    .searchForecastObservable(keyword: $0, maximumForecastDay: 7, unit: .celsius)
                    .asDriver(onErrorJustReturn: [])
            }
            .map {
                $0
                    .map { WeatherForecastPresentableMapper.map(item: $0) }
                    .map({ WeatherForecastViewModel($0) })
            }
        
        return Output(weatherForecastItems: items)
    }
}


extension SearchForecastUseCase {

    public func searchForecastObservable(keyword: String, maximumForecastDay: Int, unit: UnitTemperature) -> Single<[WeatherForecastItem]> {
        return Single<[WeatherForecastItem]>.create { observer in
            self.searchForecast(parameters: (keyword, maximumForecastDay, unit)) { result in
                switch result {
                case let .success(items):
                    observer(.success(items))
                case let .failure(err):
                    observer(.failure(err))
                }
            }
            return Disposables.create { }
        }
    }
}
