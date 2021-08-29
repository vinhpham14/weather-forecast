//
//  RemoteSearchForecastRepositoryTests.swift
//  SearchForecastTests
//
//  Created by Pham Quang Vinh on 8/29/21.
//


import XCTest
import SearchForecast


public enum SearchForecastResult {
    case success(_ items: [WeatherForecastItem])
    case failure(_ error: Error)
}

public class RemoteSearchForecastRepository {
    typealias SearchParameters = (cityName: String, maximumForecastDay: Int, unit: UnitTemperature)
    private let url: URL
    private let apiClient: APIClient
    
    init(url: URL, apiClient: APIClient) {
        self.url = url
        self.apiClient = apiClient
    }
    
    func searchForecast(_ parameters: SearchParameters, completion: @escaping (SearchForecastResult) -> Void) {
        apiClient.get(from: url, completion: { result in
            switch result {
            case let .failure(err):
                completion(.failure(err))
            default:
                break
            }
        })
    }
}

public protocol APIClient {
    typealias APIResult = Swift.Result<(Data, HTTPURLResponse), Error>
    typealias APICompletion = (APIResult) -> Void
    
    func get(from url: URL, completion: @escaping APICompletion)
}

class APIClientSpy: APIClient {
    var requestedURLs: [URL] = []
    var completions: [APICompletion] = []
    
    func get(from url: URL, completion: @escaping APICompletion) {
        requestedURLs.append(url)
        completions.append(completion)
    }
    
    func completeWith(error: Error, at index: Int = 0) {
        completions[index](.failure(error))
    }
}

class RemoteSearchForecastRepositoryTests: XCTestCase {
    
    func test_init_noRequestHappens() {
        let (_, api) = makeSUT()
        
        XCTAssertTrue(api.requestedURLs.isEmpty)
    }
    
    func test_doSearchTwice_requestHappendsTwice() {
        let url = anyURL
        let (sut, api) = makeSUT(url: url)
        
        sut.searchForecast(makeSearchParameters()) { _ in }
        sut.searchForecast(makeSearchParameters()) { _ in }
        
        XCTAssertEqual(api.requestedURLs, [url, url])
    }
    
    func test_doSearch_receiveErrorOnAPIClient() {
        let url = anyURL
        let (sut, api) = makeSUT(url: url)
        let err = anyError
        
        expectSearch(by: sut, toCompleteWith: .failure(err)) {
            api.completeWith(error: err)
        }
    }
    
    // MARK: - Helpers
    
    private typealias SearchParameters = RemoteSearchForecastRepository.SearchParameters
    
    private func makeSUT(url: URL = URL(string: "https://any-url.com")!) -> (sut: RemoteSearchForecastRepository, api: APIClientSpy) {
        let api = APIClientSpy()
        let sut = RemoteSearchForecastRepository(url: url, apiClient: api)
        return (sut, api)
    }
    
    private func expectSearch(_ parameters: SearchParameters? = nil, by sut: RemoteSearchForecastRepository, toCompleteWith expectedResult: SearchForecastResult, withAction action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        
        let params = parameters ?? makeSearchParameters()
        let exp = expectation(description: "Wait for searching completion")
        
        sut.searchForecast(params) { result in
            switch (expectedResult, result) {
            case let (.failure(err1), .failure(err2)):
                XCTAssertEqual(err1 as NSError, err2 as NSError, file: file, line: line)
            case let (.success(arr1), .success(arr2)):
                XCTAssertEqual(arr1, arr2, file: file, line: line)
            default:
                XCTFail("Failed to match expected result.", file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func makeSearchParameters(cityName: String? = nil, maximumForecastDay: Int? = nil, unit: UnitTemperature? = nil) -> SearchParameters {
        return (cityName ?? anyCityName, maximumForecastDay ?? anyMaximumForecastDay, unit ?? anyUnit)
    }
    
    private var anyUnit: UnitTemperature { .celsius }
    private var anyCityName: String { "city" }
    private var anyURL: URL { URL(string: "https://any-url.com")! }
    private var anyMaximumForecastDay: Int { 7 }
    private var anyError: Error { NSError(domain: "error", code: 0, userInfo: nil) }
}
