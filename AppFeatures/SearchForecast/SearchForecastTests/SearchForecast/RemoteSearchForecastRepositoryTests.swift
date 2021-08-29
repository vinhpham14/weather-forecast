//
//  RemoteSearchForecastRepositoryTests.swift
//  SearchForecastTests
//
//  Created by Pham Quang Vinh on 8/29/21.
//


import XCTest
import SearchForecast


final class RemoteSearchForecastRepositoryTests: XCTestCase {
    
    private let kRootKey = "items"
    
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
    
    func test_doSearch_receiveErrorByAPIClient() {
        let url = anyURL
        let (sut, api) = makeSUT(url: url)
        
        expectSearch(by: sut, toCompleteWith: failure(.unexpected)) {
            let err = anyError
            api.completeWith(error: err)
        }
    }
    
    func test_doSearch_receiveErrorOn200HTTPResponseWithInvalidDataJSON() {
        let (sut, api) = makeSUT()
        
        expectSearch(by: sut, toCompleteWith: failure(.invalidJSON)) {
            api.completeWith(statusCode: 200, data: Data("invalid data".utf8))
        }
    }
    
    func test_doSearch_receiveEmptyListOn200HTTPResponseWithEmptyJSON() {
        let (sut, api) = makeSUT()
        
        expectSearch(by: sut, toCompleteWith: .success([])) {
            api.completeWith(statusCode: 200, data: makeItemJson([]))
        }
    }
    
    func test_doSearch_receiveEmptyListItemsOn200HTTPResponseWithJSONItems() {
        let (sut, api) = makeSUT()
        let expectedItems = (0..<10).map({ _ in makeRandomItem() })

        expectSearch(by: sut, toCompleteWith: .success(expectedItems.map({ $0.model }))) {
            api.completeWith(statusCode: 200, data: makeItemJson(expectedItems.map({ $0.json })))
        }
    }
    
    // MARK: - Helpers
    
    private typealias SearchParameters = RemoteSearchForecastRepository.SearchParameters
    
    private func makeSUT(url: URL? = nil) -> (sut: RemoteSearchForecastRepository, api: APIClientSpy) {
        let api = APIClientSpy()
        let sut = RemoteSearchForecastRepository(url: url ?? anyURL, apiClient: api)
        return (sut, api)
    }
    
    private func expectSearch(_ parameters: SearchParameters? = nil, by sut: RemoteSearchForecastRepository, toCompleteWith expectedResult: RemoteSearchForecastRepository.Result, withAction action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let params = parameters ?? makeSearchParameters()
        let exp = expectation(description: "Wait for searching completion")
        
        sut.searchForecast(params) { result in
            switch (expectedResult, result) {
            case let (.failure(err1 as RemoteSearchForecastRepository.Error),
                      .failure(err2 as RemoteSearchForecastRepository.Error)):
                XCTAssertEqual(err1, err2, file: file, line: line)
                
            case let (.success(arr1), .success(arr2)):
                XCTAssertEqual(arr1, arr2, file: file, line: line)
                
            default:
                XCTFail("Failed to match expected result.", file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 5.0)
    }
    
    private func failure(_ error: RemoteSearchForecastRepository.Error) -> RemoteSearchForecastRepository.Result {
        return .failure(error)
    }
    
    private func makeRandomItem() -> (model: WeatherForecastItem, json: [String: Any]) {
        let model = WeatherForecastItem.random()
        let dateFormatter = ISO8601DateFormatter()
        let json: [String: Any] = [
            "id": model.id.uuidString,
            "date": dateFormatter.string(from: model.date),
            "pressure": model.pressure,
            "humidity": model.humidity,
            "temperature": model.temperature,
            "description": model.description,
        ]
        return (model, json)
    }
    
    private func makeItemJson(_ items: [[String: Any]]? = nil) -> Data {
        let itemJson = items ?? (0...10).map({ _ in makeRandomItem() }).map({ $0.json })
        let json = [kRootKey: itemJson]
        return try! JSONSerialization.data(withJSONObject: json)
    }
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
    
    func completeWith(statusCode: Int, data: Data, at index: Int = 0) {
        let response = HTTPURLResponse(
            url: requestedURLs[index],
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )!
        completions[index](.success((data, response)))
    }
}
