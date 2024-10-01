//
//  ResultsView.swift
//  RandS
//
//  Created by Chad Wallace on 9/29/24.
//

import SwiftUI

// Results view to show incorrect guesses
struct RSResultsView: View {
    let incorrectGuesses: [(image: String, correctAnswer: String)]
    let roundScore: Int // Add round score
    let highScore: Int // Add high score
    @State private var currentIndex = 0
    var onPlayAgain: () -> Void

    var body: some View {
        VStack {
            Text("Incorrect Guesses This Round")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .padding()
                .background(Color.blue.opacity(0.2))
                .cornerRadius(10)
                .padding(.horizontal)
                .multilineTextAlignment(.center)

            if incorrectGuesses.isEmpty {
                Text("No incorrect guesses!")
                    .font(.title)
                    .fontWeight(.medium)
                    .foregroundColor(.green) // Green color for positive message
                    .padding()
            } else {
                VStack {
                    // Show current incorrect guess
                    if let image = UIImage(named: incorrectGuesses[currentIndex].image) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                            .padding()
                    }
                    
                    Text("Correct Answer: \(incorrectGuesses[currentIndex].correctAnswer)")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.red) // Red color for the correct answer
                        .padding()

                    // Back and forward arrows
                    HStack {
                        // Back arrow
                        Button(action: {
                            if currentIndex > 0 {
                                currentIndex -= 1
                            }
                        }) {
                            Image(systemName: "arrow.left.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(currentIndex == 0 ? .gray : .blue) // Gray out if at the first tile
                        }
                        .disabled(currentIndex == 0)

                        Spacer()

                        // Forward arrow
                        Button(action: {
                            if currentIndex < incorrectGuesses.count - 1 {
                                currentIndex += 1
                            }
                        }) {
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(currentIndex == incorrectGuesses.count - 1 ? .gray : .blue) // Gray out if at the last tile
                        }
                        .disabled(currentIndex == incorrectGuesses.count - 1)
                    }
                    .padding()
                }
            }

            // Display the round score at the bottom
            Text("Round Score: \(roundScore)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.purple) // Purple color for round score
                .padding(.top)

            // Display the high score directly below the round score
            Text("High Score: \(highScore)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.orange) // Orange color for high score
                .padding(.top)

            // Play again button at the bottom
            Button(action: {
                onPlayAgain()
            }) {
                Text("Play Again")
                    .font(.title)
                    .fontWeight(.semibold)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.top)
            
            Spacer()
            
            BannerAdView(adFormat: UIDevice.current.userInterfaceIdiom == .pad ? .leaderboard : .standardBanner, onShow: { print("Show Banner") })
                .padding(.bottom, 10)
            
        }
        .padding()
    }
}
