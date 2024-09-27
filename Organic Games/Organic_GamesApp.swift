//
//  Organic_GamesApp.swift
//  Organic Games
//
//  Created by Chad Wallace on 8/8/24.
//

import SwiftUI
import AppTrackingTransparency
import GoogleMobileAds

@main
struct Organic_GamesApp: App {
    
    @State private var tiles = GameViewModel(gameType: .game1)
    
    init() {
        if ATTrackingManager.trackingAuthorizationStatus == .notDetermined {
            // The user has not made a choice yet regarding app tracking.
            // This is a good place to show a custom explainer screen or dialog.
            // Toggle any variables or state here if you want to handle this.
        } else {
            // Request the tracking authorization and initialize GADMobileAds
            ATTrackingManager.requestTrackingAuthorization { status in
                // Initialize Google Mobile Ads regardless of the user's choice
                GADMobileAds.sharedInstance().start(completionHandler: nil)
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .environment(tiles)
        }
    }
}
