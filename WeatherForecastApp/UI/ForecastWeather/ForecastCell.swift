//
//  ForecastCell.swift
//  WeatherForecastApp
//
//  Created by Pham Quang Vinh on 9/1/21.
//

import UIKit


class ForecastCell: UITableViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    
    func configure(with viewModel: WeatherForecastViewModel) {
        dateLabel.text = viewModel.date
        temperatureLabel.text = viewModel.temperature
        pressureLabel.text = viewModel.pressure
        humidityLabel.text = viewModel.humidity
        descLabel.text = viewModel.description   
    }
}

