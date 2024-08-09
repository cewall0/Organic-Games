//
//  Organic_GamesApp.swift
//  Organic Games
//
//  Created by Chad Wallace on 8/8/24.
//

import SwiftUI

@main
struct Organic_GamesApp: App {
    
    @State private var tiles = GameViewModel(gameType: .game1)
    
    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .environment(tiles)
        }
    }
}
