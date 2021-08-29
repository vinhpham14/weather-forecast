//
//  LocalSearchForecastRepositoryTests.swift
//  SearchForecastTests
//
//  Created by Pham Quang Vinh on 8/29/21.
//


import XCTest
import SearchForecast


public struct LocalWeatherForecastItem {
    public let id: UUID
    public let date: Date
    public let pressure: Double
    public let humidity: Double
    public let temperature: Double
    public let description: String
}

extension LocalWeatherForecastItem: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
}


public enum GetCachedResult {
    case empty
    case found(items: [LocalWeatherForecastItem], timestamp: Date)
    case failure(Error)
}

public protocol ForecastStore {
    typealias SaveCompletion = (Error?) -> Void
    typealias GetCompletion = (GetCachedResult) -> Void
    
    func save(_ items: [LocalWeatherForecastItem], timestamp: Date, for key: String, completion: @escaping SaveCompletion)
    func get(_ items: [LocalWeatherForecastItem], for key: String, completion: @escaping GetCompletion)
}

public class LocalSearchForecastRepository: SearchForecastRepository {
    private let store: ForecastStore
    
    public init(store: ForecastStore) {
        self.store = store
    }
    
    public func save(_ items: [LocalWeatherForecastItem], timestamp: Date, for key: String, completion: @escaping (Error?) -> Void) {
        store.save(items, timestamp: timestamp, for: key, completion: completion)
    }
    
    public func searchForecast(_ parameters: SearchParameters, completion: @escaping (SearchForecastResult) -> Void) {
        
    }
}


final class LocalSearchForecastRepositoryTests: XCTestCase {
    
    func test_init_haveNoMessages() {
        let (_, store) = makeSUT()
        
        XCTAssert(store.receivedMessages.isEmpty)
    }
    
    func test_save_receiveErrorCausedByStoreError() {
        let (sut, store) = makeSUT()
        let error = anyNSError()
        
        expectSave(with: sut, by: store, toCompleteWith: error) {
            store.completeSaveWith(with: error)
        }
    }
    
    func test_save_successfully() {
        let (sut, store) = makeSUT()
        let error = anyNSError()
        
        expectSave(with: sut, by: store, toCompleteWith: nil) {
            store.completeSaveWith(with: nil)
        }
    }
    
    
    
    // MARK: - Helpers
    
    private func makeSUT() -> (sut: LocalSearchForecastRepository, store: ForecastStoreSpy) {
        let store = ForecastStoreSpy()
        let sut = LocalSearchForecastRepository(store: store)
        return (sut, store)
    }
    
    private func uniqueForcasts() -> [LocalWeatherForecastItem] {
        let items: [WeatherForecastItem] = [.random(), .random()]
        let localItems = items.map({ LocalWeatherForecastItem(id: $0.id, date: $0.date, pressure: $0.pressure, humidity: $0.humidity, temperature: $0.temperature, description: $0.description) })
        return localItems
    }
    
    private func expectSave(with sut: LocalSearchForecastRepository, by store: ForecastStoreSpy, toCompleteWith error: NSError?, with action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        
        var capturedError: NSError?
        let items = uniqueForcasts()
        let currentDate = Date()
        let key = anyKey()
        let exp = expectation(description: "Wait for save completion")
        
        sut.save(items, timestamp: currentDate, for: key, completion: {
            capturedError = $0 as NSError?
            exp.fulfill()
        })
        action()
        
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(capturedError, error, file: file, line: line)
        XCTAssertEqual(store.receivedMessages, [.save(items, timestamp: currentDate, key: key)], file: file, line: line)
    }
    
    func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 0)
    }
    
    func anyKey() -> String {
        return "any key"
    }
}


class ForecastStoreSpy: ForecastStore {
    
    enum Message: Equatable {
        case save(_ items: [LocalWeatherForecastItem], timestamp: Date, key: String)
        case get(_ items: [LocalWeatherForecastItem], key: String)
    }
    
    private(set) var receivedMessages: [Message] = []
    private var saveCompletions = [SaveCompletion]()
    private var getCompletions = [GetCompletion]()
    
    func completeSaveWith(with error: Error?, at index: Int = 0) {
        saveCompletions[0](error)
    }
    
    func completeGetWith(with error: Error, at index: Int = 0) {
        getCompletions[0](.failure(error))
    }
    
    func completeGetWithEmptyItems(at index: Int = 0) {
        getCompletions[0](.empty)
    }
    
    func completeGetSuccessfullyWith(with items: [LocalWeatherForecastItem], timestamp: Date, at index: Int = 0) {
        getCompletions[0](.found(items: items, timestamp: timestamp))
    }
    
    func save(_ items: [LocalWeatherForecastItem], timestamp: Date, for key: String, completion: @escaping SaveCompletion) {
        receivedMessages.append(.save(items, timestamp: timestamp, key: key))
        saveCompletions.append(completion)
    }
    
    func get(_ items: [LocalWeatherForecastItem], for key: String, completion: @escaping GetCompletion) {
        receivedMessages.append(.get(items, key: key))
        getCompletions.append(completion)
    }
}
