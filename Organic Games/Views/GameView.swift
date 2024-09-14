import SwiftUI

struct GameView: View {
    @Environment(GameViewModel.self) private var viewModel
    @Binding var path: NavigationPath
    
    var gameType: GameType // GameType to determine the type of game

    func resetPath() {
        self.path = NavigationPath()
        viewModel.gameCompleted = false
    }

    var body: some View {
        ZStack {
            ForEach(viewModel.tiles) { tile in
                if let position = viewModel.tilePositions[tile.id], let rotation = viewModel.tileRotations[tile.id] {
                    TileView(tile: tile, isSelected: viewModel.selectedTiles.contains(where: { $0.id == tile.id }), gameType: gameType)
                        .rotationEffect(.degrees(rotation))
                        .position(position)
                        .onTapGesture {
                            viewModel.selectTile(tile)
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
                    
                    Text(" ")
                    Button("Play Again") {
                        
                        viewModel.gameCompleted = false
                        viewModel.resetGame(for: gameType)
                        
                    }
                    .padding()
                    .background(.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    
                    Text(" ")
                    
                    Button("Choose different game") {
                        
                        viewModel.gameCompleted = false
                        resetPath()
                        
                    }
                    .padding()
                    .background(.brown)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    
                    Text(" ")
                    Text(" ")
                }
                .background(Color.white.opacity(0.8))
                .cornerRadius(20)
                .shadow(radius: 10)
                
            } else {
                VStack {
                    Spacer()
                    HStack {
                        
                        Button("Scramble Remaining Tiles") {
                            viewModel.scrambleRemainingTiles()
                        }
                        .padding()
                        .background(.brown)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .padding()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            viewModel.resetGame(for: gameType) // Pass gameType to initialize the game
        }
        .onDisappear {
            viewModel.gameCompleted = false
        }
    }
}

struct TileView: View {
    let tile: Tile
    let isSelected: Bool
    let gameType: GameType
    
    var body: some View {
        // Define the base size for non-game6
        let baseSize: CGFloat = (UIDevice.current.userInterfaceIdiom == .pad) ? 200 : 100
        // Increase size by 200% if gameType is .game6
        let tileSize: CGFloat = gameType == .game6 ? baseSize * 1.5 : baseSize
        
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

