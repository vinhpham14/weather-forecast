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
    case failure(_ error: Swift.Error)
}

public final class RemoteSearchForecastRepository {
    typealias SearchParameters = (cityName: String, maximumForecastDay: Int, unit: UnitTemperature)
    private let url: URL
    private let apiClient: APIClient
    
    public enum Error: Swift.Error {
        case invalidJSON
        case unexpected
    }
    
    init(url: URL, apiClient: APIClient) {
        self.url = url
        self.apiClient = apiClient
    }
    
    func searchForecast(_ parameters: SearchParameters, completion: @escaping (SearchForecastResult) -> Void) {
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


struct RemoteWeatherForecastItem: Decodable {
    public let id: UUID
    public let date: Date
    public let pressure: Double
    public let humidity: Double
    public let temperature: Double
    public let description: String
}

public final class WeatherForecastItemMapper {
    private struct Root: Decodable {
        let items: [RemoteWeatherForecastItem]
    }
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteWeatherForecastItem] {
        guard response.statusCode == 200,
            let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteSearchForecastRepository.Error.invalidJSON
        }
        return root.items
    }
}

public protocol APIClient {
    typealias APIResult = Swift.Result<(Data, HTTPURLResponse), Error>
    typealias APICompletion = (APIResult) -> Void
    
    func get(from url: URL, completion: @escaping APICompletion)
}

final class RemoteSearchForecastRepositoryTests: XCTestCase {
    
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
    
    func test_doSearch_receiveInvalidDataError() {
        let (sut, api) = makeSUT()
        
        expectSearch(by: sut, toCompleteWith: failure(.invalidJSON)) {
            api.completeWith(statusCode: 200, data: Data("invalid data".utf8))
        }
    }
    
    // MARK: - Helpers
    
    private typealias SearchParameters = RemoteSearchForecastRepository.SearchParameters
    
    private func makeSUT(url: URL? = nil) -> (sut: RemoteSearchForecastRepository, api: APIClientSpy) {
        let api = APIClientSpy()
        let sut = RemoteSearchForecastRepository(url: url ?? anyURL, apiClient: api)
        return (sut, api)
    }
    
    private func expectSearch(_ parameters: SearchParameters? = nil, by sut: RemoteSearchForecastRepository, toCompleteWith expectedResult: SearchForecastResult, withAction action: () -> Void, file: StaticString = #file, line: UInt = #line) {
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
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func failure(_ error: RemoteSearchForecastRepository.Error) -> SearchForecastResult {
        return .failure(error)
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
