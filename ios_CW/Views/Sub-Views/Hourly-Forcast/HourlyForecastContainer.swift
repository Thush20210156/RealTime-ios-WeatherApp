//
//  HourlyForecastContainer.swift
//  ios_CW
//
//  Created by Thushini Abeysuriya on 2025-01-15.
//

//import SwiftUI

//struct HourlyForecastContainer: View {
//    @ObservedObject var viewModel: WeatherViewModel
//    var selectedLocation: WeatherLocation
//    
//    var body: some View {
//        ZStack {
//            Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)
//            
//            HourlyForecastView(viewModel: viewModel)
//                .padding()
//        }
//        .onAppear {
//            // Fetch hourly data when the view appears if it's not already loaded
////            if viewModel.hourlyWeather.isEmpty {
////                viewModel.updateWeatherData(for: selectedLocation)
////            }
//        }
//    }
//}
//
//#Preview {
//    let mockLocation = WeatherLocation(
//        id: UUID(),
//        cityName: "San Francisco",
//        region: "California",
//        temperature: 22,
//        condition: "Clear",
//        highTemp: 24,
//        lowTemp: 18,
//        time: "10:00 AM",
//        isHomeLocation: false,
//        lat: 37.7749,
//        lon: -122.4194
//    )
//
//    HourlyForecastContainer(viewModel: WeatherViewModel.init(locationManager: LocationManager()), selectedLocation: mockLocation)
//        .background(Color.gray)
//        .previewLayout(.sizeThatFits)
//}


