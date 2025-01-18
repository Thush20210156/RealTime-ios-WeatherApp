//
//  GeocordingViewModel.swift
//  ios_CW
//
//  Created by Thushini Abeysuriya on 2025-01-15.
//

import Foundation
import Combine

class GeocodingViewModel: ObservableObject {
    private let apiKey = "2edeae3a641c9a2da8aa488d09c54af1"
    @Published var geoLocations: [GeoLocation] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private var cancellables = Set<AnyCancellable>()

    func fetchCoordinates(for cityName: String) {
        guard !cityName.isEmpty else {
            errorMessage = "City name cannot be empty."
            print("ERROR: \(errorMessage!)")
            return
        }
        
        // Encode the city name
        let encodedCityName = cityName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://api.openweathermap.org/geo/1.0/direct?q=\(encodedCityName)&limit=5&appid=\(apiKey)"
        print("DEBUG: Constructed Geocoding URL: \(urlString)")

        // Check if the URL is valid
        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid URL."
            print("ERROR: \(errorMessage!)")
            return
        }

        isLoading = true
        errorMessage = nil

        print("DEBUG: Starting API request for city: \(cityName)")

        // Make the API request
        URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { data, response -> Data in
                if let httpResponse = response as? HTTPURLResponse {
                    print("DEBUG: HTTP status code: \(httpResponse.statusCode)")
                    guard httpResponse.statusCode == 200 else {
                        throw URLError(.badServerResponse)
                    }
                }
                print("DEBUG: Raw data received: \(data.count) bytes")
                return data
            }
            .decode(type: [GeoLocation].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self = self else { return }
                    self.isLoading = false
                    switch completion {
                    case .finished:
                        print("DEBUG: Successfully completed the API request.")
                    case .failure(let error):
                        self.errorMessage = "Failed to fetch data: \(error.localizedDescription)"
                        print("ERROR: \(self.errorMessage!)")
                    }
                },
                receiveValue: { [weak self] locations in
                    guard let self = self else { return }
                    self.geoLocations = locations
                    print("DEBUG: Fetched \(locations.count) locations:")
                    for location in locations {
                        print("DEBUG: Location - Name: \(location.name), Latitude: \(location.lat), Longitude: \(location.lon), Country: \(location.country), State: \(location.state ?? "N/A")")
                    }
                }
            )
            .store(in: &cancellables)
    }
}
