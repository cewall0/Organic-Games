import SwiftUI
import Foundation
import AVFoundation

struct GameView: View {
    @Environment(GameViewModel.self) private var viewModel
    @Binding var path: NavigationPath
    @State private var showFireworks = false // State to control fireworks animation
    @State private var pulseAnimation = false // State to control pulsing animation for text
    
    var gameType: GameType // GameType to determine the type of game
    
    func resetPath() {
        self.path = NavigationPath()
        viewModel.gameCompleted = false
    }
    
    var body: some View {
        VStack {
            ZStack {
                GeometryReader { geometry in
                    ForEach(viewModel.tiles) { tile in
                        if let position = viewModel.tilePositions[tile.id], let rotation = viewModel.tileRotations[tile.id] {
                            TileView(tile: tile, isSelected: viewModel.selectedTiles.contains(where: { $0.id == tile.id }), gameType: gameType)
                                .rotationEffect(.degrees(rotation))
                                .position(x: position.x, y: min(position.y, geometry.size.height * 0.85)) // Increase tile area height to 85%
                                .onTapGesture {
                                    viewModel.selectTile(tile)
                                }
                        }
                    }
                }
                
                if viewModel.gameCompleted {
                    VStack {
                        Text("Congratulations!")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                            .padding()
                            .scaleEffect(pulseAnimation ? 1.1 : 1.0) // Pulsing effect
                            .animation(Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: pulseAnimation)
                            .onAppear {
                                pulseAnimation = true
                            }
                        
                        Button("Play Again") {
                            viewModel.gameCompleted = false
                            viewModel.resetGame(for: gameType)
                            showFireworks = false
                            pulseAnimation = false
                        }
                        .padding()
                        .background(.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(color: .gray, radius: 4, x: 0, y: 2)
                        
                        Button("Choose different game") {
                            viewModel.gameCompleted = false
                            resetPath()
                            showFireworks = false
                            pulseAnimation = false
                        }
                        .padding()
                        .background(.teal)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(color: .gray, radius: 4, x: 0, y: 2)
                    }
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(20)
                    .shadow(radius: 10)
                    .onAppear {
                        withAnimation {
                            showFireworks = true
                        }
                    }
                }
            }
            
            Spacer(minLength: 10) // Reduce the size of the spacer
            
            HStack {
                Button("Scramble Remaining Tiles") {
                    viewModel.scrambleRemainingTiles()
                }
                .padding()
                .background(.teal)
                .foregroundColor(.white)
                .cornerRadius(10)
                .shadow(color: .gray, radius: 4, x: 0, y: 2)
            }
            .padding(.bottom, 10) // Less padding to bring the button closer
            
            BannerAdView(adFormat: UIDevice.current.userInterfaceIdiom == .pad ? .leaderboard : .standardBanner, onShow: { print("Show Banner") })
                .padding(.bottom, 10) // Adjust the padding to reduce the extra space
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            viewModel.resetGame(for: gameType)
        }
        .onDisappear {
            viewModel.gameCompleted = false
        }
    }
}

struct FireworksView: View {
    @State private var fireworkOffsets: [CGSize] = Array(repeating: .zero, count: 10)
    @State private var fireworkScales: [CGFloat] = Array(repeating: 0.1, count: 10)
    @State private var fireworkOpacities: [Double] = Array(repeating: 1.0, count: 10)
    
    var body: some View {
        ZStack {
            ForEach(0..<10) { i in
                Circle()
                    .fill(fireworkColor(for: i))
                    .frame(width: 50, height: 50)
                    .scaleEffect(fireworkScales[i])
                    .opacity(fireworkOpacities[i])
                    .offset(fireworkOffsets[i])
                    .onAppear {
                        withAnimation(Animation.easeOut(duration: 1.0).delay(Double(i) * 0.1)) {
                            let randomX = CGFloat.random(in: -250...250) // Random X position
                            let randomY = CGFloat.random(in: -400...250) // Random Y position
                            fireworkOffsets[i] = CGSize(width: randomX, height: randomY)
                            fireworkScales[i] = 2.0
                            fireworkOpacities[i] = 0.0
                        }
                    }
            }
        }
    }
    
    private func fireworkColor(for index: Int) -> Color {
        let colors: [Color] = [.red, .yellow, .blue, .green, .orange, .pink, .purple, .cyan, .white, .indigo]
        return colors[index % colors.count] // Return color in rotation
    }
}


struct TileView: View {
    let tile: Tile
    let isSelected: Bool
    let gameType: GameType
    
    var body: some View {
        // Define the base size for non-game6
        let baseSize: CGFloat = (UIDevice.current.userInterfaceIdiom == .pad) ? 200 : 100
        // Increase size by 150% if gameType is .game6
        let tileSize: CGFloat = (gameType == .game6 && tile.imageName.hasSuffix("A")) ? baseSize * 1.5 : baseSize
        
        Image(tile.imageName) // Use imageName to get the correct image
            .resizable()
            .aspectRatio(1, contentMode: .fit)
            .frame(width: tileSize, height: tileSize)
            .background(isSelected ? Color.yellow.opacity(0.3) : Color.clear)
            .cornerRadius(10)
            .shadow(radius: 5)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color.yellow : Color.clear, lineWidth: 3)
            )
    }
}

