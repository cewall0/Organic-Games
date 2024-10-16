//
//  CountdownOverlay.swift
//  Organic Games
//
//  Created by Chad Wallace on 10/16/24.
//

// CountdownOverlay.swift
import SwiftUI

struct CountdownOverlay: View {
    var countdown: Int

    var body: some View {
        ZStack {
            Color.black.opacity(0.7).edgesIgnoringSafeArea(.all)
            
            Text("\(countdown)")
                .font(.system(size: 100, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .shadow(radius: 10)
        }
        .transition(.opacity) // Smooth fade-in and fade-out for the overlay
    }
}
