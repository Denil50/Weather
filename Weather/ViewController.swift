//
//  ViewController.swift
//  Weather
//
//  Created by Apple on 19.02.2022.
//

import UIKit
import NVActivityIndicatorView
import CoreLocation
import Foundation

class ViewController: UIViewController {

    // MARK: - Private Static Propeties

    private static let voronezhCoordinates = CLLocationCoordinate2D(latitude: 51.6720400, longitude:  39.1843000)

    // MARK: - Subviews

    @IBOutlet weak var backgroundImageView: UIImageView!

    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var conditionLabel: UILabel!
    
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var activityIndicator: NVActivityIndicatorView!

    // MARK: - Private Propeties

    private let weatherService = WeatherService()
    private let locationManager = CLLocationManager()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        activityIndicator.backgroundColor = .black

        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startMonitoringSignificantLocationChanges()

        let location = CLLocation(
            latitude: Self.voronezhCoordinates.latitude,
            longitude: Self.voronezhCoordinates.longitude
        )
        startUpdatingWeather(for: location)
    }

}

// MARK: - Private Methods

private extension ViewController {

    func startUpdatingWeather(for location: CLLocation) {
        let request = WeatherService.WeatherRequest(
            latitude: location.coordinate.latitude,
            lontidude: location.coordinate.longitude
        )

        activityIndicator.startAnimating()
        weatherService.weather(for: request, completionHandler: { [weak self] result in
            DispatchQueue.main.async { [weak self] in
                self?.activityIndicator.stopAnimating()
            }

            switch result {
            case .success(let weather):
                DispatchQueue.main.async { [weak self] in
                    self?.updateWeather(weather: weather)
                }
            case .failure(let error):
                print(error)
            }
        })
    }

    func updateWeather(weather: WeatherService.WeatherResult) {
        locationLabel.text = weather.name
        temperatureLabel.text = weather.main.temp.formatted(.number.precision(.fractionLength(0)))

        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        dayLabel.text = dateFormatter.string(from: date)

        guard let firstWeather = weather.weather.first else {
            return
        }

        conditionLabel.text = firstWeather.main
        conditionImageView.image = UIImage(named: firstWeather.icon)

        let suffix = firstWeather.icon.suffix(1)
        if (suffix == "n") {
            backgroundImageView.image = #imageLiteral(resourceName: "b")
        } else {
            backgroundImageView.image = #imageLiteral(resourceName: "w")
        }
    }

}

// MARK: - CLLocationManagerDelegate

extension ViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }

        startUpdatingWeather(for: location)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }

}
