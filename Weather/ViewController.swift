//
//  ViewController.swift
//  Weather
//
//  Created by hyun woo cho on 2023/01/05.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var cityNameTextField: UITextField!
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var weatherDescriptionLabel: UILabel!
    
    @IBOutlet weak var weatherStackView: UIStackView!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var maxTempLabel: UILabel!
    @IBOutlet weak var minTempLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func tapFetchWeatherButton(_ sender: UIButton) {
        if let cityName = self.cityNameTextField.text {
            self.getCurrentWeather(cityName: cityName)
            self.view.endEditing(true)
        }
    }
    
    func showAlert(errorMessage: String) {
        let alert = UIAlertController(title: "error", message: errorMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "confirm", style: .default))
        self.present(alert, animated: true)
    }
    
    func configureView(weatherInformation: WeatherInformation) {
        self.cityNameLabel.text = weatherInformation.name
        if let weather = weatherInformation.weather.first {
            self.weatherDescriptionLabel.text = weather.description
        }
        self.tempLabel.text = "\(Int(weatherInformation.temp.temp - 273.15))°C"
        self.minTempLabel.text = "Min: \(Int(weatherInformation.temp.temp_min - 273.15))°C"
        self.maxTempLabel.text = "Max: \(Int(weatherInformation.temp.temp_max - 273.15))°C"
    }
    
    func getCurrentWeather(cityName: String) {
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(cityName)&appid=") else { return }
        let session = URLSession(configuration: .default)
        session.dataTask(with: url) { [weak self] data, response, error in
            let successRange = (200..<300)
            guard let data = data, error == nil else { return }
            let decoder = JSONDecoder()
            if let response = response as? HTTPURLResponse, successRange.contains(response.statusCode) {
                guard let weatherInformation = try? decoder.decode(WeatherInformation.self, from: data) else { return }
                DispatchQueue.main.async {
                    self?.weatherStackView.isHidden = false
                    self?.configureView(weatherInformation: weatherInformation)
                }
            } else {
                guard let errorMessage = try? decoder.decode(ErrorMessage.self, from: data) else { return }
                DispatchQueue.main.async {
                    self?.showAlert(errorMessage: errorMessage.message)
                }
            }
        }.resume()
    }
}

