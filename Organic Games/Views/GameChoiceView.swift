//
//  GameChoiceView.swift
//  Organic Games
//
//  Created by Chad Wallace on 8/8/24.
//

import SwiftUI
import WallaceAds

struct GameChoiceView: View {
    @Environment(GameViewModel.self) private var viewModel
    @State var path = NavigationPath()
    private let plus = PlusStore.shared

    func reset() {
        self.path = NavigationPath()
    }

    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                HStack{
                    if WallaceAds.privacyOptionsRequired {
                        Button {
                            WallaceAds.presentPrivacyOptions()
                        } label: {
                            Image(systemName: "hand.raised.circle")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .padding(.leading)
                                .foregroundColor(.gray)
                        }
                        .accessibilityLabel("Ad privacy settings")
                    }
                    if !plus.isPlus {
                        RemoveAdsLink {
                            Text("Remove Ads")
                                .font(.footnote.bold())
                                .foregroundColor(.gray)
                                .padding(.leading)
                        }
                    }
                    Spacer()
                    Link(destination: URL(string: "https://wallacewaysoftware.com/organic-games/")!) {
                        Image(systemName: "questionmark.circle")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .padding(.trailing)
                            .foregroundColor(.gray)
                    }
                    .accessibilityLabel("Help")
                }
                    Image("OrganicGamesTitle")
                        .resizable()
                        .frame(width: 375, height: 210)

                Text("- Lazy Tile Match Games -")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.orange)
                Text("")
                Button(action: {
                    reset()
                    viewModel.gameType = .game1
                    viewModel.resetGame(for: .game1)
                    path.append(GameType.game1)
                }, label: {
                    Text("Functional Groups")
                })
                Text("")
                Button(action: {
                    reset()
                    viewModel.gameType = .game2
                    viewModel.resetGame(for: .game2)
                    path.append(GameType.game2)
                }, label: {
                    Text("Functional Group Suffixes")
                })
                Text("")
                Button(action: {
                    reset()
                    viewModel.gameType = .game3
                    viewModel.resetGame(for: .game3)
                    path.append(GameType.game3)
                }, label: {
                    Text("Formal Charges")
                })
                Text("")
                Button(action: {
                    reset()
                    viewModel.gameType = .game4
                    viewModel.resetGame(for: .game4)
                    path.append(GameType.game4)
                }, label: {
                    Text("Hybridization")
                })
                Text("")
                Button(action: {
                    reset()
                    viewModel.gameType = .game5
                    viewModel.resetGame(for: .game5)
                    path.append(GameType.game5)
                }, label: {
                    Text("Alkyl groups")
                })
                
                Text("")
                Button(action: {
                    reset() // Reset navigation stack if needed
                    viewModel.gameType = .game6 // Set the game type to game6 (Amino Acids)
                    path.append(GameType.game6) // Navigate to AminoAcidChoiceView
                }, label: {
                    Text("Amino Acids")
                })
                Text("")
                Text("- Blitz Pick Game -")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.orange)
                    .padding(.top)

                Text("")
                Button(action: {
                    reset() // Reset navigation stack if needed
                    path.append(GameType.game7) // Navigate to RSGameView
                }, label: {
                    Text("R & S Stereochemistry")
                })

                Text("- Organic Games Plus -")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.orange)
                    .padding(.top)
                Text("")
                plusGame("IR: Name That Spectrum", .irSpectra)
                Text("")
                plusGame("IR: Tile Match", .irTiles)
                
                Spacer()

                if !plus.isPlus {
                    BannerAdView()
                }

            }
            .onAppear(perform: {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                WallaceAds.start()
                            }
                        })

            .navigationDestination(for: GameType.self) { gameType in
                switch gameType {
                case .game6:
                    // This will navigate to AminoAcidChoiceView to make selections
                    AminoAcidChoiceView(path: $path)
                case .game6Started:
                    // This will navigate to GameView for Game 6 after selections are made
                    GameView(path: $path, gameType: .game6)
                case .game7:
                    // This will navigate to RSGameView
                    RSGameView(path: $path)
                case .irSpectra:
                    NameThatSpectrumView()
                case .irTiles:
                    if let set = StudySet.all.first(where: { $0.id == "ir-tiles" }) {
                        TextTileGameView(set: set)
                    }
                default:
                    // All other games navigate to GameView as usual
                    GameView(path: $path, gameType: gameType)
                }
            }
        }
    }

    /// A menu entry for an Organic Games Plus game (with a PLUS badge for non-subscribers)
    private func plusGame(_ title: String, _ type: GameType) -> some View {
        Button(action: {
            reset()
            path.append(type)
        }, label: {
            HStack(spacing: 6) {
                Text(title)
                if !plus.isPlus {
                    Text("PLUS")
                        .font(.caption2.bold())
                        .padding(.horizontal, 5).padding(.vertical, 2)
                        .background(Capsule().fill(Color.orange.opacity(0.15)))
                }
            }
        })
    }
}
