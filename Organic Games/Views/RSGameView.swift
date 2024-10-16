//
//  MoleculeGameView.swift
//  RandS
//
//  Created by Chad Wallace on 9/24/24.
//

//  MoleculeGameView.swift
//  RandS
//
//  Created by Chad Wallace on 9/24/24.
//

import SwiftUI
import UIKit

struct RSGameView: View {
    
    @Binding var path: NavigationPath // Binding to allow navigation
    
    let allMoleculeImages = (1...8).flatMap { ["G7_\($0)_R", "G7_\($0)_S"] }

    @State private var currentImage = ""
    @State private var score = 0
    @State private var highScore = 0
    @State private var timeRemaining = 30
    @State private var gameOver = false
    @State private var countdown = 3
    @State private var incorrectGuesses: [(image: String, correctAnswer: String)] = []
    @State private var usedMoleculeImages: [String] = []
    @State private var unusedMoleculeImages: [String] = []
    @State private var showResults = false
    @State private var timer: DispatchSourceTimer?
    @State private var showCountdown = true

    // Relaxed Mode state
    @State private var isRelaxedMode = false

    // States for button animations
    @State private var sButtonTapped = false
    @State private var rButtonTapped = false

    // States for feedback indicators
    @State private var showFeedback: Bool = false
    @State private var feedbackType: FeedbackType? = nil

    enum FeedbackType {
        case correct
        case incorrect
    }

    var body: some View {
        ZStack {
            // Main game view
            VStack {
                if showResults {
                    RSResultsView(incorrectGuesses: incorrectGuesses, roundScore: score, highScore: highScore) {
                        resetGame()
                    }
                } else {
                    VStack {
                        // Relaxed Mode Toggle
                        HStack {
                            Spacer()
                            
                            Text("Relaxed Mode")
                            Toggle("", isOn: $isRelaxedMode)
                                .labelsHidden()
                        }
                        .padding()
                        .onChange(of: isRelaxedMode) { _, newValue in
                            toggleRelaxedMode()
                        }

                        HStack {
                            // Conditionally show Timer Box
                            if !isRelaxedMode {
                                VStack {
                                    Text("Timer")
                                        .font(.title2)
                                        .foregroundColor(.black)
                                    Text("\(timeRemaining)")
                                        .font(.largeTitle)
                                        .frame(width: 100, height: 100)
                                        .background(
                                            RoundedRectangle(cornerRadius: 20)
                                                .fill(Color.black)
                                                .shadow(color: .gray, radius: 10, x: 5, y: 5)
                                        )
                                        .foregroundColor(.green)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(Color.white, lineWidth: 5)
                                        )
                                }
                                .padding(.leading)
                            }

                            Spacer()

                            // Score Box
                            VStack {
                                Text("Score")
                                    .font(.title2)
                                    .foregroundColor(.black)
                                Text("\(score)")
                                    .font(.largeTitle)
                                    .frame(width: 100, height: 100)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(Color.red)
                                            .shadow(color: .black, radius: 10, x: 5, y: 5)
                                    )
                                    .foregroundColor(.yellow)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.white, lineWidth: 5)
                                    )
                            }
                            .padding(.trailing)
                        }
                        .padding(.top)

                        GeometryReader { geometry in
                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()

                                    // S button
                                    Button(action: {
                                        sButtonTapped = true
                                        handleAnswer(selectedAnswer: "S")
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                            sButtonTapped = false
                                        }
                                    }) {
                                        Text("S")
                                            .font(.title)
                                            .frame(width: 50, height: 50)
                                            .background(Color.green)
                                            .foregroundColor(.white)
                                            .cornerRadius(10)
                                            .shadow(radius: 5)
                                            .scaleEffect(sButtonTapped ? 1.2 : 1.0)
                                    }

                                    Spacer()

                                    // Molecule image with feedback indicators
                                    ZStack {
                                        if let image = UIImage(named: currentImage) {
                                            Image(uiImage: image)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: geometry.size.width * 0.5, height: geometry.size.width * 0.5)
                                                .padding()
                                        }

                                        // Feedback indicators
                                        if showFeedback {
                                            Image(systemName: feedbackType == .correct ? "checkmark.circle.fill" : "xmark.circle.fill")
                                                .resizable()
                                                .frame(width: geometry.size.width * 0.5 * 0.5, height: geometry.size.width * 0.5 * 0.5)
                                                .foregroundColor(.white)
                                                .background(Circle()
                                                    .fill(feedbackType == .correct ? Color.green : Color.red)
                                                    .frame(width: geometry.size.width * 0.5 * 0.6, height: geometry.size.width * 0.5 * 0.6)
                                                )
                                                .transition(.opacity)
                                        }
                                    }

                                    Spacer()

                                    // R button
                                    Button(action: {
                                        rButtonTapped = true
                                        handleAnswer(selectedAnswer: "R")
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                            rButtonTapped = false
                                        }
                                    }) {
                                        Text("R")
                                            .font(.title)
                                            .frame(width: 50, height: 50)
                                            .background(Color.blue)
                                            .foregroundColor(.white)
                                            .cornerRadius(10)
                                            .shadow(radius: 5)
                                            .scaleEffect(rButtonTapped ? 1.2 : 1.0)
                                    }

                                    Spacer()
                                }
                                .padding(.horizontal)
                                Spacer()
                            }
                        }
                        .padding()
                    }
                    .onAppear(perform: startCountdown)
                    .alert(isPresented: $gameOver) {
                        Alert(
                            title: Text("Time's Up!")
                                .font(.system(size: 50, weight: .bold)),
                            message: Text("Your final score is \(score).")
                                .font(.system(size: 40)),
                            dismissButton: .default(Text("View Incorrect Guesses").font(.system(size: 30))) {
                                showResults = true
                                timer?.cancel()
                            }
                        )
                    }
                }
                BannerAdView(adFormat: UIDevice.current.userInterfaceIdiom == .pad ? .leaderboard : .standardBanner, onShow: { print("Show Banner") })
                    .padding(.bottom, 10) 
            }

            // Countdown overlay
            if showCountdown {
                Color.white
                    .edgesIgnoringSafeArea(.all)
                    .overlay(
                        Text("\(countdown)")
                            .font(.system(size: 100, weight: .bold))
                            .foregroundColor(.black)
                            .opacity(showCountdown ? 1.0 : 0.0)
                    )
            }
        }
    }

    private func handleAnswer(selectedAnswer: String) {
        // Reset feedback before processing new answer
        showFeedback = false
        
        // Check if the answer is correct
        if currentImage.hasSuffix("_\(selectedAnswer)") {
            score += 1
            feedbackType = .correct
        } else {
            let correctAnswer = currentImage.hasSuffix("_R") ? "R" : "S"
            incorrectGuesses.append((image: currentImage, correctAnswer: correctAnswer))
            score -= 1
            feedbackType = .incorrect
            
            // Trigger vibration for an incorrect guess
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        }
        
        // Show feedback indicator
        showFeedback = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            showFeedback = false // Hide feedback indicator after 0.2 seconds
        }
        
        showNextMolecule()
    }

    private func showNextMolecule() {
        if unusedMoleculeImages.isEmpty {
            unusedMoleculeImages = allMoleculeImages.shuffled()
        }
        
        if let nextImage = unusedMoleculeImages.popLast() {
            currentImage = nextImage
            usedMoleculeImages.append(nextImage)
        }
    }

    private func startCountdown() {
        score = 0
        timeRemaining = 30
        incorrectGuesses.removeAll()
        gameOver = false
        showResults = false
        showCountdown = true

        unusedMoleculeImages = allMoleculeImages.shuffled()
        usedMoleculeImages.removeAll()

        countdown = 3

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.timer?.cancel()
            self.timer = DispatchSource.makeTimerSource(queue: DispatchQueue.main)
            self.timer?.schedule(deadline: .now(), repeating: 1.0)
            self.timer?.setEventHandler {
                if self.countdown > 1 {
                    self.countdown -= 1
                } else {
                    self.timer?.cancel()
                    self.showCountdown = false
                    self.startGameTimer()
                }
            }
            self.timer?.resume()
        }
    }

    private func startGameTimer() {
        self.timer?.cancel()
        self.timer = DispatchSource.makeTimerSource(queue: DispatchQueue.main)
        self.timer?.schedule(deadline: .now(), repeating: 1.0)
        self.timer?.setEventHandler {
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.timer?.cancel()
                self.gameOver = true
                
                // Update high score if needed
                if score > highScore {
                    highScore = score // Update high score if current score is higher
                }
            }
        }
        self.timer?.resume()
        
        // Start with the first molecule image
        showNextMolecule()
    }

    private func resetGame() {
        // Resetting the game state for a new round
        score = 0
        timeRemaining = 30
        incorrectGuesses.removeAll()
        usedMoleculeImages.removeAll()
        unusedMoleculeImages.removeAll()
        currentImage = ""
        showResults = false
        gameOver = false
        countdown = 3
        isRelaxedMode = false // Reset relaxed mode
        showCountdown = true

        // Reset timer and start a new game
        timer?.cancel()
        startCountdown()
    }

    private func toggleRelaxedMode() {
        if isRelaxedMode {
            // Enter relaxed mode without countdown or timer
            timer?.cancel() // Stop any ongoing timers
            showCountdown = false // Hide countdown immediately
            timeRemaining = 0 // Set time remaining to 0 since timer is not needed
            showNextMolecule() // Continue the game without timers
        } else {
            // Exit relaxed mode and reset the game with the timer
            startCountdown() // Restart the countdown and timer if relaxed mode is turned off
        }
    }
}
