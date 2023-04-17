//
//  WeatherManager.swift
//  MeteoApp
//
//  Created by Giulio Aterno on 17/04/23.
//

import Foundation
import CoreLocation


protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailedWithError(error: Error)
}

struct WeatherManager {
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=b897fde960f2b8352f6adc212130b415&units=metric"
    var delegate: WeatherManagerDelegate?
    
    //Richiesta città
    func fetchWeather(cityName: String) {
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(with: urlString)
        
    }
    
    //Richiesta coordinate
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
    }
    
    
    func performRequest(with urlString: String)  {
        
        //1. Create a URL
        if let url = URL(string: urlString) {
            
            //2. Create a URL Session
            let session = URLSession(configuration: .default)
            
            //3. Give a session task
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    self.delegate?.didFailedWithError(error: error!)
                    return
                }
                
                if let safeData = data {
                    if let weather = self.parceJSON(weatherData: safeData) {
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            
            //4. Start the task
            task.resume()
            
        }
    }
    
    func parceJSON(weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            return weather
            
        } catch {
            delegate?.didFailedWithError(error: error)
            return nil
        }
    }
    
    
    
}

