//
//  MoonPhaseView.swift
//  ios_CW
//
//  Created by Thushini Abeysuriya on 2025-01-15.
//

import SwiftUI

struct MoonPhaseView: View {
    @ObservedObject var viewModel: WeatherViewModel
    var selectedLocation: WeatherLocation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: "moon.stars")
                    .foregroundColor(.white.opacity(0.7))
                Text(viewModel.moonPhase.isEmpty ? "MOON PHASE" : viewModel.moonPhase.uppercased())
                    .font(.system(size: 14))
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            // Moonset Info
            if let moonsetTimestamp = viewModel.weatherResponses[selectedLocation.id]?.daily?.first?.moonset {
                Text("Moonset: \(viewModel.formatTime(from: Int(moonsetTimestamp)))")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            } else {
                Text("Moonset: N/A")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.black.opacity(0.3))
        .cornerRadius(16)
        .onAppear {
            viewModel.updateMoonPhase(for: selectedLocation)
        }
    }
}

// Preview
struct MoonPhaseView_Previews: PreviewProvider {
    static var mockViewModel: WeatherViewModel = {
        let vm = WeatherViewModel(locationManager: LocationManager())
        let locationId = UUID()
        
        // Create mock weather response
        let mockDaily = Daily(
            dt: 1677000000,
            sunrise: 1676960400,
            sunset: 1677007200,
            moonrise: 1676980000,
            moonset: 1677024000,
            moonPhase: 0.5,
            summary: "Clear sky",
            temp: Temp(day: 25.0, min: 20.0, max: 30.0, night: 22.0, eve: 26.0, morn: 21.0),
            feelsLike: FeelLike(day: 27.0, night: 22.0, eve: 26.0, morn: 21.0),
            pressure: 1012,
            humidity: 65,
            dewPoint: 20.0,
            windSpeed: 15.0,
            windDeg: 270,
            windGust: 25.0,
            weather: [Weather(id: 1, main: "Clear", description: "Clear sky", icon: "01d")],
            clouds: 10,
            pop: 0.0,
            rain: nil,
            snow: nil,
            uvi: 5.0
        )
        
        let mockWeatherResponse = WeatherResponse(
            lat: 0.0,
            lon: 0.0,
            timezone: "UTC",
            timezoneOffset: 0,
            current: Current(
                dt: 1677000000,
                sunrise: 1676960400,
                sunset: 1677007200,
                temp: 25.0,
                feelsLike: 27.0,
                pressure: 1012,
                humidity: 65,
                dewPoint: 20.0,
                uvi: 5.0,
                clouds: 40,
                windSpeed: 15.0,
                windDeg: 270,
                weather: [Weather(id: 1, main: "Clear", description: "Clear sky", icon: "01d")],
                rain: nil
            ),
            minutely: nil,
            hourly: nil,
            daily: [mockDaily],
            alerts: nil
        )
        
        vm.weatherResponses[locationId] = mockWeatherResponse
        vm.moonPhase = "Waxing Gibbous"
        
        return vm
    }()
    
    static var previews: some View {
        MoonPhaseView(
            viewModel: mockViewModel,
            selectedLocation: WeatherLocation(
                id: UUID(),
                cityName: "Test City",
                region: nil,
                temperature: 25,
                condition: "Clear",
                highTemp: 30,
                lowTemp: 20,
                time: nil,
                isHomeLocation: false,
                lat: 0.0,
                lon: 0.0
            )
        )
        .frame(width: 180, height: 180)
        .padding()
        .background(Color.gray)
    }
}
