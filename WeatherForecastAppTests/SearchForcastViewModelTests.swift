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
    
    func test_inputSearchTextChanged_doSearchWhileSearchTextCharactersCountIsGreaterThanOrEqualThreshold() {
        let threshold = 3
        let (sut, useCase) = makeSUT(searchKeywordCountThreshold: threshold)
        let (_, output) = makeInputOutput(sut: sut, searchTextChanged: searchTrigger)
        var items: [[WeatherForecastViewModel]] = []
        let set1 = (0...3).map({ _ in WeatherForecastItem.random() })
        let set2 = (0...4).map({ _ in WeatherForecastItem.random() })
        
    
        output.weatherForecastItems
            .drive(onNext: { items.append($0) })
            .disposed(by: disposeBag)
        
        searchTrigger.accept("333")
        useCase.completeWith(items: set1, at: 0)
        
        searchTrigger.accept("55555")
        useCase.completeWith(items: set2, at: 1)
        
        XCTAssertEqual(useCase.messages.count, 2)
        XCTAssertEqual(items.count, 2)
    }
    
    func test_inputSearchTextChanged_receiveOnlyLastestResponseWhenTriggerSearchWhileNotFinishRequesting() {
        let threshold = 3
        let (sut, useCase) = makeSUT(searchKeywordCountThreshold: threshold)
        let (_, output) = makeInputOutput(sut: sut, searchTextChanged: searchTrigger)
        var items: [[WeatherForecastViewModel]] = []
        let set1 = (0...3).map({ _ in WeatherForecastItem.random() })
        let set2 = (0...5).map({ _ in WeatherForecastItem.random() })
        
        output.weatherForecastItems
            .drive(onNext: { items.append($0) })
            .disposed(by: disposeBag)
        
        searchTrigger.accept("333")
        searchTrigger.accept("55555")
        useCase.completeWith(items: set1, at: 0)
        useCase.completeWith(items: set2, at: 1)
        
        XCTAssertEqual(useCase.messages.count, 2)
        XCTAssertEqual(items.count, 1)
        XCTAssertEqual(items.last?.count, set2.count)
    }
    
    func test_inputSearchTextChanged_outputLoadingStatus() {
        let threshold = 3
        let (sut, useCase) = makeSUT(searchKeywordCountThreshold: threshold)
        let (_, output) = makeInputOutput(sut: sut, searchTextChanged: searchTrigger)
        var loading = [Bool]()
        
        disposeBag.insert([
            output.weatherForecastItems.drive(),
            output.loading.drive(onNext: { loading.append($0) })
        ])
        
        searchTrigger.accept("55555")
        useCase.completeWith(items: [], at: 0)
        
        XCTAssertEqual(loading, [false, true, false])
        XCTAssertEqual(useCase.messages.count, 1)
    }
    
    func test_inputSearchTextChanged_receiveErrorByUseCase() {
        let threshold = 3
        let (sut, useCase) = makeSUT(searchKeywordCountThreshold: threshold)
        let (_, output) = makeInputOutput(sut: sut, searchTextChanged: searchTrigger)
        let err = NSError(domain: "any error", code: 0)
        var capturedErrorString: String?
        
        output.weatherForecastItems.drive().disposed(by: disposeBag)
        output.popupErrorMessage.drive(onNext: { capturedErrorString = $0 }).disposed(by: disposeBag)
        searchTrigger.accept("5555")
        useCase.completeWith(error: err, at: 0)
        
        XCTAssertEqual(useCase.messages.count, 1)
        XCTAssertNotNil(capturedErrorString)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(searchKeywordCountThreshold: Int = 3) -> (sut: SearchForecastViewModel, useCase: MockSearchForecastUseCase) {
        let useCase = MockSearchForecastUseCase()
        let sut = SearchForecastViewModel(
            searchKeywordCountThreshold: searchKeywordCountThreshold,
            temperatureUnit: .celsius,
            searchForecastUseCase: useCase)
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
    
    private func randomWeatherForecastViewModel() -> WeatherForecastViewModel {
        return WeatherForecastViewModel(
            WeatherForecastPresentable(
                date: randomString(),
                pressure: randomString(),
                humidity: randomString(),
                temperature: randomString(),
                description: randomString()
            )
        )
    }
    
    private func randomString() -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".map({ String($0) })
        return (0..<10).reduce("") { str, _ in str + String(letters[Int.random(in: (0..<letters.count))]) }
    }
}


class MockSearchForecastUseCase: SearchForecastUseCase {
    var messages = [(params: SearchParameters, completion: (SearchForecastUseCaseResult) -> Void)]()
    
    func searchForecast(parameters: SearchParameters, completion: @escaping (SearchForecastUseCaseResult) -> Void) {
        messages.append((parameters, completion))
    }
    
    func completeWith(items: [WeatherForecastItem], at index: Int) {
        messages[index].completion(.success(items: items))
    }
    
    func completeWith(error: Error, at index: Int) {
        messages[index].completion(.failure(error))
    }
}


extension WeatherForecastItem {
    static func random() -> WeatherForecastItem {
        let date = Int(Date().timeIntervalSince1970)
        return WeatherForecastItem(
            id: UUID(),
            date: Date.init(timeIntervalSince1970: Double(Int.random(in: (date - 1000)...date))),
            pressure: Double.random(in: 0...100),
            humidity: Double.random(in: 0...100),
            temperature: Double.random(in: 0...100),
            description: "\(Double.random(in: 0...100))"
        )
    }
}
