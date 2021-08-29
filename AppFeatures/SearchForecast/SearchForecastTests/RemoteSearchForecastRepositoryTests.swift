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
    private let url: URL
    private let apiClient: APIClient
    
    init(url: URL, apiClient: APIClient) {
        self.url = url
        self.apiClient = apiClient
    }
    
    func searchForecast(cityName: String, completion: @escaping (SearchForecastResult) -> Void) {
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
        let url = randomURL
        let (sut, api) = makeSUT(url: url)
        
        sut.searchForecast(cityName: randomCityName, completion: { _ in })
        sut.searchForecast(cityName: randomCityName, completion: { _ in })
        
        XCTAssertEqual(api.requestedURLs, [url, url])
    }
    
    func test_doSearch_receiveErrorOnAPIClient() {
        let url = randomURL
        let (sut, api) = makeSUT(url: url)
        let err = anyError
        var capturedErr: NSError?
        
        let exp = expectation(description: "Wait for searching completion.")
        sut.searchForecast(cityName: randomCityName, completion: { result in
            if case let .failure(err) = result {
                capturedErr = err as NSError
            }
            exp.fulfill()
        })
        
        api.completeWith(error: err)
        
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(api.requestedURLs, [url])
        XCTAssertEqual(capturedErr, err as NSError)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://any-url.com")!) -> (sut: RemoteSearchForecastRepository, api: APIClientSpy) {
        let api = APIClientSpy()
        let sut = RemoteSearchForecastRepository(url: url, apiClient: api)
        return (sut, api)
    }
    
    private var randomCityName: String { "city \(randomNumber)" }
    private var randomURL: URL { URL(string: "https://any-url.com/(\(randomNumber)")! }
    private var randomNumber: Int { Int.random(in: 1...100) }
    private var anyError: Error { NSError(domain: "error", code: 0, userInfo: nil) }
}
