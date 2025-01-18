//
//  WeatherViewModel.swift
//  ios_CW
//
//  Created by Thushini Abeysuriya on 2025-01-15.

import Foundation
import Combine
import SwiftUI
import MapKit

class WeatherViewModel: ObservableObject {
   
    @AppStorage("weatherCardsData") private var weatherCardsData: Data = Data()
    @AppStorage("savedLocationsData") var savedLocationsData: Data = Data()
    @AppStorage("touristAttractionsData") private var touristAttractionsData: Data = Data()
    
    @Published var touristLocations: [MapLocation] = []
    @Published var selectedLocationId: UUID?
    @Published var searchText = ""
    @Published var searchResults: [GeoLocation] = []
    @Published var weatherLocations: [WeatherLocation] = []
    @Published var hourlyWeather: [Hourly] = []
    @Published var dailyWeather: [Daily] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var currentWeatherResponse: WeatherResponse?
    @Published var currentCityName: String?
    @Published var weatherResponses: [UUID: WeatherResponse] = [:]
    @Published var selectedLocations: [GeoLocation] = []
    @Published var airQualityResponses: [UUID: AirQualityData] = [:]
    
    
    
    // Weather data properties
    @Published var uvIndex: Int?
    @Published var uvDescription: String = ""
    @Published var uvAdvice: String = ""
    @Published var sunriseTime: String = ""
    @Published var sunsetTime: String = ""
    @Published var pressure: Int?
    @Published var hourlyPrecipitation: [Double] = []
    @Published var dailyPrecipitation: [Double] = []
    @Published var moonPhase: String = ""
    @Published var humidity: Int?
    @Published var dewPoint: Int?
    @Published var feelsLikeTemperature: Int?
    @Published var dailyHighTemp: Int?
    @Published var averageDailyHigh: Double?
    
    private let apiKey = "2edeae3a641c9a2da8aa488d09c54af1"
    public let geocodingViewModel = GeocodingViewModel()
    public var locationManager: LocationManager
    private var cancellables: Set<AnyCancellable> = []
    private var updateTimer: Timer?
    

    init(locationManager: LocationManager) {
        self.locationManager = locationManager
        
        setupLocationBindings()
        // loadSavedData()
        startPeriodicUpdates()
    }
    
    private func setupLocationBindings() {
        // Bind location updates
        locationManager.$latitude
            .combineLatest(locationManager.$longitude)
            .receive(on: DispatchQueue.main)
            .compactMap { lat, lon -> (Double, Double)? in
                guard let lat = lat, let lon = lon else { return nil }
                return (lat, lon)
            }
            .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
            .sink { [weak self] lat, lon in
                print("DEBUG: Location updated - Lat: \(lat), Lon: \(lon)")
                self?.handleLocationUpdate(latitude: lat, longitude: lon)
            }
            .store(in: &cancellables)
        
        // Bind city name updates
        locationManager.$cityName
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] cityName in
                print("DEBUG: City name updated to: \(cityName)")
                self?.currentCityName = cityName
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    
    func addLocation(_ geoLocation: GeoLocation) {
        
        // Check if this is the current location (first location)
        let isCurrentLocation = weatherLocations.isEmpty
        // Check if the location already exists
        guard !weatherLocations.contains(where: { $0.lat == geoLocation.lat && $0.lon == geoLocation.lon }) else {
            return
        }
        
        // Generate a new UUID for this location
        let locationId = UUID()
        
        // Create a new WeatherLocation with initial values
        let newLocation = WeatherLocation(
            id: locationId,
            cityName: geoLocation.name,
            region: geoLocation.state,
            temperature: 0,
            condition: nil,
            highTemp: 0,
            lowTemp: 0,
            time: nil,
            isHomeLocation: false,
            lat: geoLocation.lat,
            lon: geoLocation.lon
        )
        
        // Add the location
        if isCurrentLocation {
            weatherLocations.insert(newLocation, at: 0)  // Current location always first
        } else {
            weatherLocations.append(newLocation)
        }
        
        // Save the updated locations
                saveWeatherCards()
        
        
        // Add the location first
        //weatherLocations.append(newLocation)
        
        // Then fetch its weather data
        fetchWeather(lat: geoLocation.lat, lon: geoLocation.lon, for: locationId)
    }
    
    
    // To get weather data for a specific location
    func getWeatherData(for locationId: UUID) -> WeatherResponse? {
        return weatherResponses[locationId]
    }
    
    
    
    private func handleLocationUpdate(latitude: Double, longitude: Double) {
        let location = GeoLocation(
            name: currentCityName ?? "Current Location",
            lat: latitude,
            lon: longitude,
            country: "",
            state: nil
        )
        
        // Check if this location already exists
        if let existingLocation = weatherLocations.first(where: { $0.lat == latitude && $0.lon == longitude }) {
            // Update existing location
            fetchWeather(lat: latitude, lon: longitude, for: existingLocation.id)
        } else {
            // Add new location
            addLocation(location)
        }
    }

    
    func fetchWeather(lat: Double, lon: Double, for locationId: UUID?) {
        let urlString = "https://api.openweathermap.org/data/3.0/onecall?lat=\(lat)&lon=\(lon)&units=metric&appid=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            self.errorMessage = "Invalid URL"
            return
        }
        
        isLoading = true
        print("DEBUG: Fetching weather for location ID: \(locationId?.uuidString ?? "current location")")
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: WeatherResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                    print("ERROR: Failed to fetch weather: \(error.localizedDescription)")
                }
            } receiveValue: { [weak self] weather in
                self?.handleWeatherResponse(weather, for: locationId)
                print("DEBUG: Successfully fetched weather for location ID: \(locationId?.uuidString ?? "current location")")
                
                
                
                // After fetching weather, fetch air quality
                self?.fetchAirQuality(lat: lat, lon: lon, for: locationId)
                print("DEBUG: Successfully fetched weather for location ID: \(locationId?.uuidString ?? "current location")")
                
                
            }
            .store(in: &cancellables)
    }
    
    
    
    func fetchAirQuality(lat: Double, lon: Double, for locationId: UUID?) {
        let urlString = "https://api.openweathermap.org/data/2.5/air_pollution?lat=\(lat)&lon=\(lon)&appid=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            self.errorMessage = "Invalid URL for air quality"
            return
        }
        
        print("DEBUG: Fetching air quality for location ID: \(locationId?.uuidString ?? "current location")")
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: AirQualityData.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = "Air quality error: \(error.localizedDescription)"
                    print("ERROR: Failed to fetch air quality: \(error.localizedDescription)")
                }
            } receiveValue: { [weak self] airQualityData in
                if let locationId = locationId {
                    self?.airQualityResponses[locationId] = airQualityData
                    print("DEBUG: Successfully fetched air quality for location ID: \(locationId)")
                }
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    private func handleWeatherResponse(_ weather: WeatherResponse, for locationId: UUID? = nil) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // If we have a locationId, store the response for that specific location
            if let locationId = locationId {
                self.weatherResponses[locationId] = weather
                
                // Update the specific location's weather data
                if let index = self.weatherLocations.firstIndex(where: { $0.id == locationId }) {
                    var updatedLocation = self.weatherLocations[index]
                    updatedLocation.temperature = Int(weather.current.temp)
                    updatedLocation.condition = weather.current.weather.first?.description
                    updatedLocation.highTemp = Int(weather.daily?.first?.temp.max ?? 0)
                    updatedLocation.lowTemp = Int(weather.daily?.first?.temp.min ?? 0)
                    updatedLocation.time = self.formatTime(from: weather.current.dt ?? 0)
                    // Update air quality if available
                    updatedLocation.airQuality = self.airQualityResponses[locationId]?.list.first?.main.aqi
                    self.weatherLocations[index] = updatedLocation
                    
                    self.weatherLocations[index] = updatedLocation
                }
            }
            
            // Update current weather response if this is for the current location
            if locationId == nil {
                self.currentWeatherResponse = weather
                self.updateCurrentConditions(from: weather)
            }
            
            self.objectWillChange.send()
        }
    }
    
    private func updateCurrentConditions(from weather: WeatherResponse) {
        self.feelsLikeTemperature = Int(weather.current.feelsLike)
        self.humidity = weather.current.humidity
        self.pressure = weather.current.pressure
        self.uvIndex = Int(weather.current.uvi)
        self.uvDescription = self.getUVDescription(for: weather.current.uvi)
        self.uvAdvice = self.getUVAdvice(for: weather.current.uvi)
        
        if let sunrise = weather.current.sunrise {
            self.sunriseTime = formatTime(from: sunrise)
        }
        if let sunset = weather.current.sunset {
            self.sunsetTime = formatTime(from: sunset)
        }
        
        if let daily = weather.daily?.first {
            self.dailyHighTemp = Int(daily.temp.max)
            self.moonPhase = getMoonPhase(for: daily.moonPhase)
        }
    }
    
    private func updateWeatherLocation(with weather: WeatherResponse) {
        guard let existingIndex = weatherLocations.firstIndex(where: {
            $0.lat == weather.lat && $0.lon == weather.lon
        }) else { return }
        
        var updatedLocation = weatherLocations[existingIndex]
        updatedLocation.temperature = Int(weather.current.temp)
        updatedLocation.condition = weather.current.weather.first?.description
        updatedLocation.highTemp = Int(weather.daily?.first?.temp.max ?? 0)
        updatedLocation.lowTemp = Int(weather.daily?.first?.temp.min ?? 0)
        updatedLocation.time = formatTime(from: weather.current.dt ?? 0)
        
        weatherLocations[existingIndex] = updatedLocation
        saveWeatherCards()
    }
    
    // Start periodic updates
    private func startPeriodicUpdates() {
        updateTimer?.invalidate()
        updateTimer = Timer.scheduledTimer(withTimeInterval: 900, repeats: true) { [weak self] _ in
            self?.refreshAllLocations()
        }
    }
    
    func refreshAllLocations() {
        for location in weatherLocations {
            fetchWeather(lat: location.lat, lon: location.lon, for: location.id)
        }
    }
    
    
    // Other existing methods remain the same...
    
    
    func loadSavedLocations() {
        do {
            guard !savedLocationsData.isEmpty else { return }
            selectedLocations = try JSONDecoder().decode([GeoLocation].self, from: savedLocationsData)
            print("DEBUG: Restored \(selectedLocations.count) saved locations.")
        } catch {
            print("ERROR: Failed to restore saved locations: \(error.localizedDescription)")
        }
    }
    
    
    private func handleWeatherData(_ weather: WeatherResponse) {
        print("DEBUG: Processing weather data...")
        // Add any additional processing or UI updates here
        // Example:
        print("DEBUG: UV Index: \(weather.current.uvi)")
        print("DEBUG: Humidity: \(weather.current.humidity)%")
        print("DEBUG: Wind Speed: \(weather.current.windSpeed) m/s")
    }
    
    func deleteLocation(_ location: WeatherLocation) {
        weatherLocations.removeAll { $0.id == location.id }
        weatherResponses.removeValue(forKey: location.id) // Remove weather data
        airQualityResponses.removeValue(forKey: location.id) // Remove air quality data
        saveWeatherCards()
    }
    
    private func updateUIComponents(with weather: WeatherResponse) {
        self.dailyHighTemp = Int(weather.daily?.first?.temp.max ?? 0)
        
        let dailyTemps = weather.daily?.compactMap { $0.temp.max } ?? []
        self.averageDailyHigh = dailyTemps.isEmpty ? nil : dailyTemps.reduce(0, +) / Double(dailyTemps.count)
        
        self.feelsLikeTemperature = Int(weather.current.feelsLike)
        self.humidity = weather.current.humidity
        self.dewPoint = Int(weather.current.dewPoint)
        self.pressure = weather.current.pressure
        
        if let sunrise = weather.current.sunrise, let sunset = weather.current.sunset {
            self.sunriseTime = self.formatTime(from: sunrise)
            self.sunsetTime = self.formatTime(from: sunset)
        } else {
            self.sunriseTime = "N/A"
            self.sunsetTime = "N/A"
        }
        
        
        self.hourlyPrecipitation = weather.hourly?.compactMap { $0.rain?.oneHour ?? 0.0 } ?? []
        self.dailyPrecipitation = weather.daily?.compactMap { $0.rain ?? 0.0 } ?? []
        
        if let moonPhase = weather.daily?.first?.moonPhase {
            self.moonPhase = self.getMoonPhase(for: moonPhase)
        }
        
        self.uvIndex = Int(weather.current.uvi)
        self.uvDescription = self.getUVDescription(for: weather.current.uvi)
        self.uvAdvice = self.getUVAdvice(for: weather.current.uvi)
    }
    
    
    // MARK: - Tourist Attractions
    
    //Fetch and store tourist attractions for a given location
    func fetchTouristAttractions(for location: GeoLocation, query: String = "tourist attractions", completion: (() -> Void)? = nil) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: location.lat, longitude: location.lon),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
        
        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching tourist attractions: \(error.localizedDescription)")
                return
            }
            
            guard let response = response else {
                print("No tourist attractions found.")
                return
            }
            
            DispatchQueue.main.async {
                self.touristLocations = response.mapItems.map {
                    let annotation = MKPointAnnotation()
                    annotation.title = $0.name
                    annotation.coordinate = $0.placemark.coordinate
                    return MapLocation(annotation: annotation)
                }
                self.saveTouristAttractions()
                completion?()
            }
        }
    }
    
    func getUVDescription(for uvIndex: Double) -> String {
        switch uvIndex {
        case 0...2: return "Low"
        case 3...5: return "Moderate"
        case 6...7: return "High"
        case 8...10: return "Very High"
        case 11...: return "Extreme"
        default: return "Unknown"
        }
    }
    
    func getUVAdvice(for uvIndex: Double) -> String {
        switch uvIndex {
        case 0...2: return "No protection needed"
        case 3...5: return "Wear sunglasses and apply sunscreen"
        case 6...7: return "Take precautions, wear sunscreen"
        case 8...10: return "Take extra precautions, stay covered"
        case 11...: return "Avoid being outside for prolonged periods"
        default: return "Unknown"
        }
    }
    
    func formatTime(from timestamp: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    
    
    
    
    func loadWeatherCards() {
        do {
            guard !weatherCardsData.isEmpty else {
                print("DEBUG: No data to load.")
                return
            }
            let savedCards = try JSONDecoder().decode([WeatherLocation].self, from: weatherCardsData)
            weatherLocations = savedCards
            print("DEBUG: Loaded \(savedCards.count) weather cards successfully.")
        } catch {
            print("DEBUG: Error loading weather cards: \(error). Resetting stored data.")
            weatherCardsData = Data() // Clear corrupted data
            weatherLocations = []    // Reset to empty state
        }
    }
    
    func saveWeatherCards() {
        do {
            guard !weatherLocations.isEmpty else {
                print("DEBUG: No weather cards to save.")
                return
            }
            let encodedData = try JSONEncoder().encode(weatherLocations)
            weatherCardsData = encodedData
            print("DEBUG: Saved weather cards successfully.")
        } catch {
            print("DEBUG: Error saving weather cards: \(error)")
        }
    }
    
    func setupLocationUpdates() {
        locationManager.$latitude
            .combineLatest(locationManager.$longitude)
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .sink { [weak self] lat, lon in
                guard let lat = lat, let lon = lon else {
                    print("DEBUG: Waiting for valid location coordinates.")
                    return
                }
                let geoLocation = GeoLocation(name: "Current Location", lat: lat, lon: lon, country: "", state: nil)
                self?.addLocation(geoLocation)
            }
            .store(in: &cancellables)
    }
    
    
    
    func getMoonPhase(for moonPhase: Double) -> String {
        switch moonPhase {
        case 0...0.03: return "New Moon"
        case 0.03...0.25: return "Waxing Crescent"
        case 0.25...0.5: return "First Quarter"
        case 0.5...0.75: return "Waxing Gibbous"
        case 0.75...1: return "Full Moon"
        default: return "Unknown"
        }
    }
    
    // Save tourist attractions to persistent storage
    func saveTouristAttractions() {
        do {
            let attractionsData = touristLocations.map {
                TouristAttractionData(
                    name: $0.title ?? "",
                    latitude: $0.latitude,
                    longitude: $0.longitude
                )
            }
            let encodedData = try JSONEncoder().encode(attractionsData)
            touristAttractionsData = encodedData
            print("Saved tourist attractions successfully.")
        } catch {
            print("Error saving tourist attractions: \(error.localizedDescription)")
        }
    }
    
    
    // Load tourist attractions from persistent storage
    func loadTouristAttractions() {
        do {
            let savedAttractions = try JSONDecoder().decode([TouristAttractionData].self, from: touristAttractionsData)
            self.touristLocations = savedAttractions.map {
                let annotation = MKPointAnnotation()
                annotation.title = $0.name
                annotation.coordinate = CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)
                return MapLocation(annotation: annotation)
            }
            print("Loaded tourist attractions successfully.")
        } catch {
            print("Error loading tourist attractions: \(error.localizedDescription)")
        }
    }
    
    // Save and load saved locations
    func saveLocations(locations: [GeoLocation]) {
        do {
            let encodedData = try JSONEncoder().encode(locations)
            savedLocationsData = encodedData
            print("Saved locations successfully.")
        } catch {
            print("Error saving locations: \(error.localizedDescription)")
        }
    }
    
    func loadLocations() -> [GeoLocation] {
        do {
            let savedLocations = try JSONDecoder().decode([GeoLocation].self, from: savedLocationsData)
            print("Loaded saved locations successfully.")
            return savedLocations
        } catch {
            print("Error loading saved locations: \(error.localizedDescription)")
            return []
        }
    }
    
    func updateMoonPhase(for location: WeatherLocation) {
        guard let response = weatherResponses[location.id] else {
            print("No weather response available for this location.")
            return
        }
        
        if let moonPhaseValue = response.daily?.first?.moonPhase {
            self.moonPhase = getMoonPhase(for: moonPhaseValue)
        } else {
            self.moonPhase = "Unknown"
        }
    }
    
    func getPressure(for location: WeatherLocation) -> Int {
        guard let response = weatherResponses[location.id] else {
            return 0 // Default to 0 if no data is available
        }
        return response.current.pressure
    }
    
    func performSearch() {
        guard !searchText.isEmpty else { return }
        isLoading = true
        errorMessage = nil
        searchResults = []
        
        geocodingViewModel.fetchCoordinates(for: searchText)
        
        geocodingViewModel.$geoLocations
            .receive(on: DispatchQueue.main)
            .sink { [weak self] locations in
                self?.isLoading = false
                if locations.isEmpty {
                    self?.errorMessage = "No results found for '\(self?.searchText ?? "")'."
                    print("DEBUG: No results found for \(self?.searchText ?? "").")
                } else {
                    self?.searchResults = locations
                    print("DEBUG: Updated search results: \(locations).")
                }
            }
            .store(in: &cancellables)
        
        geocodingViewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                if let error = error {
                    self?.isLoading = false
                    self?.errorMessage = error
                    print("ERROR: \(error)")
                }
            }
            .store(in: &cancellables)
    }
    
    // Update a single weather location
    func updateLocation(_ location: WeatherLocation) {
        fetchWeather(lat: location.lat, lon: location.lon, for: location.id)
    }
    
    // Update multiple locations from GeoLocation array
    func updateLocations(from newLocations: [GeoLocation]) {
        for location in newLocations {
            if let existingLocation = weatherLocations.first(where: { $0.lat == location.lat && $0.lon == location.lon }) {
                // Update existing location
                updateLocation(existingLocation)
            } else {
                // Add new location
                addLocation(location)
            }
        }
        saveWeatherCards()
    }
    
    // Helper method to update all locations
    func updateAllLocations() {
        for location in weatherLocations {
            updateLocation(location)
        }
        saveWeatherCards()
    }
    
    func getWeatherResponse(for location: WeatherLocation) -> WeatherResponse? {
        return weatherResponses[location.id]
    }
    
    // Update the weather display for a selected location
    func updateDisplayForLocation(_ location: WeatherLocation) {
        if let weatherData = weatherResponses[location.id] {
            updateUIComponents(with: weatherData)
        } else {
            // If we don't have weather data for this location, fetch it
            fetchWeather(lat: location.lat, lon: location.lon, for: location.id)
        }
    }
    
    
    // Check if a location is already saved
        func isLocationSaved(_ location: WeatherLocation) -> Bool {
            return weatherLocations.contains { savedLocation in
                savedLocation.lat == location.lat &&
                savedLocation.lon == location.lon &&
                savedLocation.id != location.id // Exclude comparing with itself
            }
        }
    
    
    
    // Add these helper methods to WeatherViewModel
    func getAirQuality(for locationId: UUID) -> AirQualityData? {
        return airQualityResponses[locationId]
    }
    
    func getAQIDescription(aqi: Int) -> String {
        switch aqi {
        case 1: return "Good"
        case 2: return "Fair"
        case 3: return "Moderate"
        case 4: return "Poor"
        case 5: return "Very Poor"
        default: return "Unknown"
        }
    }
    
    func getAQIColor(aqi: Int) -> Color {
        switch aqi {
        case 1: return .green
        case 2: return .yellow
        case 3: return .orange
        case 4: return .red
        case 5: return .purple
        default: return .gray
        }
    }
}


