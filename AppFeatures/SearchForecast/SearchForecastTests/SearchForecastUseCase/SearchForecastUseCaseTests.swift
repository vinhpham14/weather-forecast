//
//  SearchForecastUseCaseTests.swift
//  SearchForecastTests
//
//  Created by Pham Quang Vinh on 8/30/21.
//

import XCTest
import SearchForecast

class SearchForecastUseCaseTests: XCTestCase {
    
    func test_init_doesNotHaveAnyMessages() {
        let (_, repo) = makeSUT()
        
        XCTAssertTrue(repo.messages.isEmpty)
    }
    
    func test_doSearch_receiveErrorByReposity() {
        let (sut, repo) = makeSUT()
        let params = makeSearchParameters().toUseCaseParams()
        let err = anyNSError
        var capturedError: NSError?
        let exp = expectation(description: "Wait for search completion.")
            
        sut.searchForecast(parameters: params) { result in
            if case let .failure(err) = result {
                capturedError = err as NSError?
            }
            exp.fulfill()
        }
        repo.completeWith(error: err)
        
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(err, capturedError)
        XCTAssertEqual(repo.messages.count, 1)
    }
    
    func test_doSearch_receiveEmptyListItems() {
        let (sut, repo) = makeSUT()
        
        expectSearch(by: sut, toCompleteWith: .success(items: []), with: {
            repo.completeWith(items: [])
        })
        
        XCTAssertEqual(repo.messages.count, 1)
    }
    
    func test_doSearch_receiveListItems() {
        let (sut, repo) = makeSUT()
        let items = [WeatherForecastItem.random(), WeatherForecastItem.random(), WeatherForecastItem.random()]
        
        expectSearch(by: sut, toCompleteWith: .success(items: items), with: {
            repo.completeWith(items: items)
        })
        
        XCTAssertEqual(repo.messages.count, 1)
    }
    
    // MARK: - MARKS
    
    private func makeSUT() -> (sut: DefaultSearchForecastUseCase, repo: MockSearchForecastRepository) {
        let repo = MockSearchForecastRepository()
        let sut = DefaultSearchForecastUseCase(searchRepository: repo)
        return (sut, repo)
    }
    
    private func expectSearch(by sut: SearchForecastUseCase, toCompleteWith expectedResult: SearchForecastUseCase.Result, with action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let params = makeSearchParameters().toUseCaseParams()
        let exp = expectation(description: "Wait for search completion.")
            
        sut.searchForecast(parameters: params) { result in
            switch (expectedResult, result) {
            case let (.success(arr1), .success(arr2)):
                XCTAssertEqual(arr1, arr2, file: file, line: line)
            case let (.failure(err1 as NSError), .failure(err2 as NSError)):
                XCTAssertEqual(err1, err2, file: file, line: line)
            default:
                XCTFail("Unexpected matching patterns.", file: file, line: line)
            }
            exp.fulfill()
        }
    
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
}

fileprivate extension SearchForecastParameters {
    func toUseCaseParams() -> SearchForecastUseCase.SearchParameters {
        return (cityName, maximumForecastDay, unit)
    }
}

class MockSearchForecastRepository: SearchForecastRepository {
    
    var messages = [(params: SearchParameters, completion: (SearchForecastResult) -> Void)]()
    
    func searchForecast(_ parameters: SearchParameters, completion: @escaping (SearchForecastResult) -> Void) {
        messages.append((params: parameters, completion: completion))
    }
    
    func completeWith(error: NSError, at index: Int = 0) {
        messages[index].completion(.failure(error))
    }
    
    func completeWith(items: [WeatherForecastItem], at index: Int = 0) {
        messages[index].completion(.success(items))
    }
}
