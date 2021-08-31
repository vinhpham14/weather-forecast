//
//  ViewModelType.swift
//  WeatherForecastApp
//
//  Created by Pham Quang Vinh on 8/31/21.
//


protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    
    func transfrom(_ input: Input) -> Output
}
