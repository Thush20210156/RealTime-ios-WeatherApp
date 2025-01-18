//
//  AirQualityViewModel.swift
//  ios_CW
//
//  Created by Thushini Abeysuriya on 2025-01-15.
//
    

import Foundation
import Combine

class AirQualityViewModel: ObservableObject {
    @Published var airQualityData: AirQualityData?
    @Published var errorMessage: String?
    
    private let apiKey = "2edeae3a641c9a2da8aa488d09c54af1"

    func fetchAirQualityData(lat: Double, lon: Double) {
        let urlString = "https://api.openweathermap.org/data/2.5/air_pollution?lat=\(lat)&lon=\(lon)&appid=\(apiKey)"
        
        print("Air Quality API URL: \(urlString)") //Log the URL
        
        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid URL"
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let data = data, error == nil {
                    do {
                        let airQualityData = try JSONDecoder().decode(AirQualityData.self, from: data)
                        print("Air Quality API Response: \(airQualityData)") // Log the response
                        self?.airQualityData = airQualityData
                    } catch {
                        print("Error decoding air quality data: \(error)")
                        self?.errorMessage = "Failed to decode air quality data."
                    }
                } else {
                    print("Error fetching air quality data: \(String(describing: error))")
                    self?.errorMessage = "Failed to fetch air quality data."
                }
            }
        }.resume()
    }
}
