//
//  Organic_GamesApp.swift
//  Organic Games
//
//  Created by Chad Wallace on 8/8/24.
//

import SwiftUI
import WallaceAds

@main
struct Organic_GamesApp: App {
    
    @State private var tiles = GameViewModel(gameType: .game1)
    
    init() {
        #if DEBUG
        let useTestAds = true
        #else
        let useTestAds = false
        #endif
        WallaceAds.configure(.init(
            bannerID: "ca-app-pub-5511806561009019/7821042125",
            interstitialID: "ca-app-pub-5511806561009019/1523861549",
            interstitialInterval: 300, // rounds are short, so at most one every 5 minutes
            useTestAds: useTestAds
        ))
    }
    
    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .environment(tiles)
                .onAppear { UIApplication.shared.isIdleTimerDisabled = true } // keep the screen awake during play
        }
    }
}
