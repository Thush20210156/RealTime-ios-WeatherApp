//
//  SwipeableWeatherCard.swift
//  ios_CW
//
//  Created by Thushini Abeysuriya on 2025-01-15.
//

import SwiftUI

struct SwipeableWeatherCard: View {
    @ObservedObject var viewModel: WeatherViewModel
    let location: WeatherLocation
    @Binding var selectedTab: Int
    @State private var offset: CGFloat = 0
    @Environment(\.dismiss) private var dismiss
    @State private var isSwiping = false
    
    private var isCurrentLocation: Bool {
        if let index = viewModel.weatherLocations.firstIndex(where: { $0.id == location.id }) {
            return index == 1
        }
        return false
    }
    
    var body: some View {
        ZStack {
            // Delete background
            Color.red
                .frame(height: 80)
                .cornerRadius(8)
                .opacity(offset < 0 ? 1 : 0)
            
            HStack {
                Spacer()
                Image(systemName: "trash")
                    .foregroundColor(.white)
                    .padding(.trailing)
                    .opacity(offset < 0 ? 1 : 0)
            }
            
            // Weather card
            WeatherCard(viewModel: viewModel, location: location, selectedTab: $selectedTab, onTap: handleTap)
                .background(Color.black)
                .cornerRadius(8)
                .offset(x: offset)
                .simultaneousGesture(
                    DragGesture()
                        .onChanged { gesture in
                            handleDragChange(gesture)
                        }
                        .onEnded { gesture in
                            handleDragEnd(gesture)
                        }
                )
        }
        .frame(height: 100)
        .cornerRadius(15)
        .clipped()
    }
    
    
    private func handleTap() {
        guard !isSwiping else { return }
        
        if let index = viewModel.weatherLocations.firstIndex(where: { $0.id == location.id }) {
            withAnimation {
                viewModel.selectedLocationId = location.id
                selectedTab = index
                dismiss()
            }
        }
    }
    
    private func handleDragChange(_ gesture: DragGesture.Value) {
        guard !isCurrentLocation else { return }
        
        withAnimation {
            isSwiping = true
            if gesture.translation.width < 0 {
                offset = gesture.translation.width
            }
        }
    }
    
    private func handleDragEnd(_ gesture: DragGesture.Value) {
        guard !isCurrentLocation else { return }
        
        withAnimation(.spring()) {
            if gesture.translation.width < -100 {
                viewModel.deleteLocation(location)
            }
            offset = 0
            isSwiping = false
        }
    }
}
