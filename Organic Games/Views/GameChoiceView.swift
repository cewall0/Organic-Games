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
    @AppStorage("lastGame") private var lastGame = ""

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
                ScrollView {
                    VStack(spacing: 14) {
                        Image("OrganicGamesTitle")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 300)

                        // Pick up where they left off
                        if let (topic, game) = GameType(rawValue: lastGame).flatMap(GameTopic.containing) {
                            Button { open(game.type, fromHome: true) } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: "play.circle.fill").font(.title).foregroundStyle(topic.tint)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Continue").font(.caption.bold()).foregroundStyle(.secondary)
                                        Text(game.title).font(.headline).foregroundStyle(.primary)
                                        if let p = game.progress {
                                            Text("\(p.done) of \(p.total) mastered").font(.caption).foregroundStyle(.secondary)
                                        }
                                    }
                                    Spacer()
                                }
                                .padding(12)
                                .background(RoundedRectangle(cornerRadius: 14).fill(topic.tint.opacity(0.12)))
                            }
                            .buttonStyle(.plain)
                        }

                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                            ForEach(GameTopic.all) { topic in
                                NavigationLink(value: topic) { TopicCard(topic: topic, isPlus: plus.isPlus) }
                                    .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                    .frame(maxWidth: 600)
                    .frame(maxWidth: .infinity)
                }

                Spacer(minLength: 0)

                if !plus.isPlus {
                    BannerAdView()
                }

            }
            .onAppear(perform: {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                WallaceAds.start()
                            }
                        })

            .navigationDestination(for: GameTopic.self) { topic in
                TopicView(topic: topic) { open($0, fromHome: false) }
            }
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
                        TileGameView(pile: TilePile(set: set))
                    }
                case .msPatterns:
                    NameThatPatternView()
                case .msTiles:
                    if let set = StudySet.all.first(where: { $0.id == "ms-tiles" }) {
                        TileGameView(pile: TilePile(set: set))
                    }
                case .rxnPredict:
                    ReactionQuizView(mode: .product)
                case .rxnReagents:
                    ReactionQuizView(mode: .reagents)
                case .rxnTiles:
                    ReactionTilesMenu()
                case .rxnGaps:
                    FillTheGapView()
                case .rxnTilesAlkene:
                    TileGameView(pile: TilePile(reactions: .alkene))
                case .rxnTilesPropyne:
                    TileGameView(pile: TilePile(reactions: .propyne))
                case .rxnTilesButyne:
                    TileGameView(pile: TilePile(reactions: .butyne))
                default:
                    // All other games navigate to GameView as usual
                    GameView(path: $path, gameType: gameType)
                }
            }
        }
    }

    /// Starts a game: from the home page (Continue) the stack starts fresh; from a topic page the game goes on
    /// top, so Back returns to the topic.
    private func open(_ type: GameType, fromHome: Bool) {
        if fromHome { reset() }
        switch type {
        case .game1, .game2, .game3, .game4, .game5:
            viewModel.gameType = type
            viewModel.resetGame(for: type)
        case .game6:
            viewModel.gameType = .game6   // AminoAcidChoiceView picks the amino acids first
        default:
            break
        }
        path.append(type)
        lastGame = type.rawValue
    }
}
