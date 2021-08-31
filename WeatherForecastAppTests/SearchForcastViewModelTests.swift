//
//  SearchForcastViewModelTests.swift
//  WeatherForecastAppTests
//
//  Created by Pham Quang Vinh on 8/31/21.
//

@testable import WeatherForecastApp
import RxSwift
import RxCocoa
import XCTest
import SearchForecast


class SearchForecastViewModelTests: XCTestCase {
    
    var searchTrigger: BehaviorRelay<String?>!
    var disposeBag: DisposeBag!
    
    override func setUp() {
        searchTrigger = BehaviorRelay<String?>(value: nil)
        disposeBag = DisposeBag()
    }
    
    override func tearDown() {
        searchTrigger = nil
        disposeBag = nil
    }
    
    func test_init_doNotPerformAnySearch() {
        let (_, useCase) = makeSUT()
        
        XCTAssertTrue(useCase.messages.isEmpty)
    }
    
    func test_inputSearchTextChanged_doNotSearchWhileSearchTextCharactersCountIsLowerThanThreshold() {
        let threshold = 3
        let (sut, useCase) = makeSUT(searchKeywordCountThreshold: threshold)
        let (_, output) = makeInputOutput(sut: sut, searchTextChanged: searchTrigger)
        var items: [WeatherForecastViewModel]?
        
        output.weatherForecastItems
            .drive(onNext: { items = $0 })
            .disposed(by: disposeBag)
        
        searchTrigger.accept("ab")
        
        XCTAssertEqual(useCase.messages.count, 0)
        XCTAssertNil(items)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(searchKeywordCountThreshold: Int = 3) -> (sut: SearchForecastViewModel, useCase: MockSearchForecastUseCase) {
        let useCase = MockSearchForecastUseCase()
        let sut = SearchForecastViewModel(searchKeywordCountThreshold: searchKeywordCountThreshold, searchForecastUseCase: useCase)
        return (sut, useCase)
    }
    
    private func makeInputOutput(
        sut: SearchForecastViewModel,
        searchTextChanged: BehaviorRelay<String?> = .init(value: nil)
    ) -> (input: SearchForecastViewModel.Input, output: SearchForecastViewModel.Output) {
        
        let input = SearchForecastViewModel.Input(
            searchTextChanged: searchTextChanged.asDriver()
        )
        
        let output = sut.transfrom(input)
        return (input, output)
    }
}


class MockSearchForecastUseCase: SearchForecastUseCase {
    var messages = [(params: SearchParameters, completion: (SearchForecastUseCaseResult) -> Void)]()
    
    func searchForecast(parameters: SearchParameters, completion: @escaping (SearchForecastUseCaseResult) -> Void) {
        messages.append((parameters, completion))
    }
}
