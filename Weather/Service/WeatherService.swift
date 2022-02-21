//
//  WeatherService.swift
//  Weather
//
//  Created by Nikita Somenkov on 21.02.2022.
//

import Foundation

final class WeatherService {

    // MARK: - Private Static Properties

    private static let apiKey: String = "b88b66e74f0e38b26476e65be6b09b2d"
    private static let baseURL = URL(string: "http://api.openweathermap.org/data/2.5/")!

    // MARK: - Requests

    struct WeatherRequest {

        let latitude: Double
        let lontidude: Double

    }

    struct WeatherCityRequest {

    }

    // MARK: - Decodable

    struct WeatherResult: Decodable {

        let weather: [WeatherResultDetails]
        let main: WeatherResultMain
        let name: String

    }

    struct WeatherResultDetails: Decodable {

        let id: Int
        let main: String
        let description: String
        let icon: String

    }

    struct WeatherResultMain: Decodable {

        let temp: Double
        let feels_like: Double
        let temp_min: Double
        let temp_max: Double
        let pressure: Double
        let humidity: Double

    }

    struct WeatherCityResult: Decodable {

    }

    func weather(for request: WeatherRequest, completionHandler: @escaping (Result<WeatherResult, Error>) -> Void) {
        var urlComponents = URLComponents(
            url: Self.baseURL.appendingPathComponent("/weather"),
            resolvingAgainstBaseURL: true
        )
        let numberFormatter = NumberFormatter()

        urlComponents?.queryItems = [
            URLQueryItem(name: "lat", value: numberFormatter.string(from: NSNumber(value: request.latitude))),
            URLQueryItem(name: "lon", value: numberFormatter.string(from: NSNumber(value: request.lontidude))),
            URLQueryItem(name: "appid", value: Self.apiKey),
            URLQueryItem(name: "units", value: "metric"),
        ]


        guard let url = urlComponents?.url else {
            fatalError("developer error: cannot url")
        }

        let urlRequest = URLRequest(url: url)

        let dataTask = URLSession.shared.dataTask(
            with: urlRequest,
            completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
                if let error = error {
                    completionHandler(.failure(error))
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    completionHandler(.failure(URLError(.badServerResponse)))
                    return
                }

                guard httpResponse.statusCode == 200 else {
                    completionHandler(.failure(URLError(.badServerResponse)))
                    return
                }

                guard let data = data else {
                    completionHandler(.failure(URLError(.badServerResponse)))
                    return
                }

                do {
                    let weatherResult = try JSONDecoder().decode(WeatherResult.self, from: data)
                    completionHandler(.success(weatherResult))
                } catch {
                    completionHandler(.failure(error))
                }
            }
        )
        dataTask.resume()
    }

    func cities(for request: WeatherCityRequest,
                completionHandler: @escaping (Result<WeatherCityResult, Error>) -> Void) {
        
    }

}
