//
//  WeatherSearchView.swift
//  ios_CW
//
//  Created by Thushini Abeysuriya on 2025-01-15.
//

import SwiftUI


struct WeatherSearchView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: WeatherViewModel
    @Binding var selectedLocations: [GeoLocation]
    @Binding var selectedTab: Int
    @State private var showingWeatherView = false
    @State private var selectedLocation: WeatherLocation?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search Bar
                    searchBar
                        .padding()
                    
                    // Content
                    if viewModel.isLoading {
                        ProgressView("Loading...")
                            .padding()
                    } else if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    } else if !viewModel.searchText.isEmpty {
                        // Search Results
                        searchResultsList
                    } else {
                        // Saved Cards
                        savedCardsList
                    }
                }
            }
            .navigationTitle("Weather")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $selectedLocation) { location in
                CombinedWeatherView(
                    viewModel: viewModel,
                    selectedLocation: location,
                    onClose: {
                        selectedLocation = nil
                    }
                )
            }
        }
    }
    
    // Search Bar View
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search for a city or airport", text: $viewModel.searchText)
                .onChange(of: viewModel.searchText) { newValue in
                    if !newValue.isEmpty {
                        viewModel.performSearch()
                    }
                }
                .foregroundColor(.black)
            
            if !viewModel.searchText.isEmpty {
                Button(action: {
                    viewModel.searchText = ""
                    viewModel.searchResults = []
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
    
    // Search Results List
    private var searchResultsList: some View {
        ScrollView {
            if viewModel.searchResults.isEmpty {
                Text("No results found.")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(viewModel.searchResults) { location in
                        Button(action: {
                            let weatherLocation = WeatherLocation(
                                id: UUID(),
                                cityName: location.name,
                                region: location.state,
                                temperature: 0,
                                condition: nil,
                                highTemp: 0,
                                lowTemp: 0,
                                time: nil,
                                isHomeLocation: false,
                                lat: location.lat,
                                lon: location.lon
                            )
                            selectedLocation = weatherLocation
                        }) {
                            VStack(alignment: .leading) {
                                Text(location.name)
                                    .foregroundColor(.white)
                                Text("\(location.state ?? ""), \(location.country)")
                                    .foregroundColor(.gray)
                                    .font(.subheadline)
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    // Saved Cards List
    private var savedCardsList: some View {
        ScrollView(.vertical, showsIndicators: true) {
            if viewModel.weatherLocations.isEmpty {
                Text("No saved locations yet.")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.weatherLocations.indices.dropFirst(), id: \.self) { index in
                        let location = viewModel.weatherLocations[index]
                        Button(action: {
                            selectedLocation = location
                        }) {
                            SwipeableWeatherCard(
                                viewModel: viewModel,
                                location: location,
                                selectedTab: $selectedTab
                            )
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical, 6)
            }
        }
        .background(Color.black)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

