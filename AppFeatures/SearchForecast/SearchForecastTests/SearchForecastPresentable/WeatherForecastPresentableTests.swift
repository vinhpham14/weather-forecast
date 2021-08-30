//
//  WeatherForecastPresentableTests.swift
//  SearchForecastTests
//
//  Created by Pham Quang Vinh on 8/30/21.
//

import XCTest


class WeatherForecastPresentableTests: XCTestCase {
    
    func test_init_getExpectedPublicProperties() {
        let date = randomString()
        let pressure = randomString()
        let humidity = randomString()
        let temperature = randomString()
        let description = randomString()
        let sut = WeatherForecastPresentable(date: date, pressure: pressure, humidity: humidity, temperature: temperature, description: description)
        
        XCTAssertEqual(sut.date, date)
        XCTAssertEqual(sut.pressure, pressure)
        XCTAssertEqual(sut.humidity, humidity)
        XCTAssertEqual(sut.temperature, temperature)
        XCTAssertEqual(sut.description, description)
    }
    
    // MARK: - Helpers
    
    private func randomString() -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".map({ String($0) })
        return (0..<10).reduce("") { str, _ in str + String(letters[Int.random(in: (0..<letters.count))]) }
    }
}
