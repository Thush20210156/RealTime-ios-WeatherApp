//
//  VideoPlayerView.swift
//  ios_CW
//
//  Created by Thushini Abeysuriya on 2025-01-15.
//

import SwiftUI
import AVKit
import UIKit

struct VideoPlayerView: View {
    var videoName: String
   
    
    var body: some View {
        GeometryReader { geometry in
            if let player = createPlayer() {
                CustomVideoPlayer(player: player)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width + 4,
                           height: geometry.size.height + 4)
                    .position(x: geometry.size.width/2,
                              y: geometry.size.height/2)
                    .onAppear {
                        player.play()
                    }
            } else {
                // Fallback view in case video loading fails
                Color.black
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
    
    private func createPlayer() -> AVPlayer? {
        guard let videoURL = Bundle.main.url(forResource: videoName, withExtension: nil) else {
            print("Failed to find video file: \(videoName)")
            return nil
        }
        
        let player = AVPlayer(url: videoURL)
        
        // Loop video
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main
        ) { _ in
            player.seek(to: .zero)
            player.play()
        }
        
        return player
    }
}
