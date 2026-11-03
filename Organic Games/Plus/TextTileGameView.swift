//
//  TextTileGameView.swift
//  Organic Games
//
//  Organic Games Plus: the lazy tile-clearing game with text tiles (e.g. a bond and its IR peak).
//  Tiles are scattered with a slight tilt so the text stays readable. Rounds of 9 pairs, weakest first;
//  a pair is mastered after three first-try matches in a row. Without Plus, the first round is a free preview.
//

import SwiftUI
import WallaceAds

struct TextTileGameView: View {
    let set: StudySet
    private let pairsPerRound = 9

    @Environment(\.dismiss) private var dismiss
    @AppStorage private var freeRoundsUsed: Int
    private let plus = PlusStore.shared
    private let mastery = MasteryStore.shared

    struct TextTile: Identifiable, Equatable {
        let id = UUID()
        let text: String
        let pairKey: String     // the pair's "a" text; both tiles of a pair share it
        let isPrompt: Bool      // the "a" side (e.g. the bond)
    }

    @State private var tiles: [TextTile] = []
    @State private var slots: [UUID: Int] = [:]          // tile → grid cell
    @State private var gridCells = 0                     // cells in this round's grid (fixed while tiles clear)
    @State private var tilts: [UUID: Double] = [:]
    @State private var jitter: [UUID: CGSize] = [:]
    @State private var selected: [TextTile] = []
    @State private var wrongFlash: Set<UUID> = []
    @State private var missed: Set<String> = []
    @State private var started = false
    @State private var roundDone = false
    @State private var showPaywall = false

    init(set: StudySet) {
        self.set = set
        _freeRoundsUsed = AppStorage(wrappedValue: 0, "freeRounds.\(set.id)")
    }

    private var locked: Bool { !plus.isPlus && freeRoundsUsed >= 1 }

    var body: some View {
        VStack(spacing: 8) {
            if !started && locked {
                lockedCard.padding()
            } else if roundDone {
                summary.padding()
            } else {
                GeometryReader { geo in board(in: geo.size) }
                Button("Scramble Remaining Tiles") { scatter() }
                    .padding()
                    .background(.teal)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .shadow(color: .gray, radius: 4, x: 0, y: 2)
                    .padding(.bottom, 6)
            }
            if !plus.isPlus {
                BannerAdView()
            }
        }
        .background(Color(.systemBackground))
        .navigationTitle(set.title)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showPaywall) { NavigationStack { PlusPaywall() } }
        .onAppear { if !started && !locked { startRound() } }
        .onChange(of: plus.isPlus) { _, isPlus in if isPlus && !started { startRound() } }
    }

    // MARK: Board

    private func board(in size: CGSize) -> some View {
        let cols = size.width > 600 ? 4 : 3
        // The grid keeps its size for the whole round, so tiles never move when others are cleared
        let rows = Int(ceil(Double(max(gridCells, 1)) / Double(cols)))
        let cell = CGSize(width: size.width / CGFloat(cols), height: size.height / CGFloat(max(rows, 1)))
        let tileSize = CGSize(width: min(cell.width - 14, 200), height: min(cell.height - 12, 86))
        return ZStack {
            ForEach(tiles) { tile in
                if let slot = slots[tile.id] {
                    let base = CGPoint(x: (CGFloat(slot % cols) + 0.5) * cell.width,
                                       y: (CGFloat(slot / cols) + 0.5) * cell.height)
                    let j = jitter[tile.id] ?? .zero
                    tileView(tile, size: tileSize)
                        .rotationEffect(.degrees(tilts[tile.id] ?? 0))
                        .position(x: base.x + j.width * max(0, cell.width - tileSize.width) / 2,
                                  y: base.y + j.height * max(0, cell.height - tileSize.height) / 2)
                        .onTapGesture { tap(tile) }
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .frame(width: size.width, height: size.height)
        .animation(.easeInOut(duration: 0.3), value: tiles)
    }

    private func tileView(_ tile: TextTile, size: CGSize) -> some View {
        let isSelected = selected.contains(tile)
        let isWrong = wrongFlash.contains(tile.id)
        return Text(tile.text)
            .font(.system(size: 15, weight: tile.isPrompt ? .bold : .semibold, design: .rounded))
            .multilineTextAlignment(.center)
            .minimumScaleFactor(0.6)
            .padding(6)
            .frame(width: size.width, height: size.height)
            .foregroundStyle(.black)
            .background(RoundedRectangle(cornerRadius: 10)
                .fill(tile.isPrompt ? Color(red: 1.0, green: 0.95, blue: 0.86) : Color(red: 0.88, green: 0.95, blue: 1.0)))
            .overlay(RoundedRectangle(cornerRadius: 10)
                .stroke(isWrong ? Color.red : (isSelected ? Color.yellow : Color.black.opacity(0.15)),
                        lineWidth: isSelected || isWrong ? 3 : 1))
            .shadow(radius: 4)
            .accessibilityElement()
            .accessibilityLabel(tile.text)
            .accessibilityAddTraits(.isButton)
            .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    // MARK: Summary and locked

    private var summary: some View {
        let keys = set.keys
        let done = mastery.masteredCount(setID: set.id, keys: keys)
        return VStack(spacing: 16) {
            Text("Congratulations!")
                .font(.largeTitle).fontWeight(.bold).foregroundColor(.blue)
            Text("\(pairsCleared - missed.count) of \(pairsCleared) matched on the first try")
                .font(.headline)
            Text("Mastered \(done) of \(keys.count)").foregroundStyle(.secondary)
            ProgressView(value: Double(done), total: Double(keys.count)).tint(.orange)
            if plus.isPlus {
                wideButton("Next round") { startRound() }
            } else {
                Text("That was your free round. Organic Games Plus keeps the practice going and brings back the pairs you miss.")
                    .multilineTextAlignment(.center).font(.subheadline)
                wideButton("Try Plus free") { showPaywall = true }
            }
            Link("Review \(set.chapter) on organicchemistryguide.com", destination: set.chapterURL).font(.subheadline)
            Button("Choose different game") { dismiss() }.font(.subheadline)
            Spacer(minLength: 0)
        }
        .padding(.top, 30)
    }

    private var lockedCard: some View {
        VStack(spacing: 16) {
            Image(systemName: "lock.circle.fill").font(.system(size: 56)).foregroundStyle(.orange)
            Text("Keep practicing with Plus").font(.title2.bold())
            Text("You've used your free round of \(set.title). Plus unlocks every round, tracks what you've mastered and brings back the pairs you miss.")
                .multilineTextAlignment(.center).font(.subheadline)
            wideButton("Try Plus free") { showPaywall = true }
            Link("Review \(set.chapter) on organicchemistryguide.com", destination: set.chapterURL).font(.subheadline)
            Spacer(minLength: 0)
        }
        .padding(.top, 40)
    }

    private func wideButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title).font(.headline).frame(maxWidth: .infinity, minHeight: 48)
        }
        .buttonStyle(.borderedProminent)
        .tint(.orange)
    }

    // MARK: Flow

    @State private var pairsCleared = 0

    private func startRound() {
        let pairs = Dictionary(uniqueKeysWithValues: (set.pairs ?? []).map { ($0.a, $0) })
        let chosen = mastery.practiceOrder(setID: set.id, keys: set.keys).prefix(pairsPerRound).compactMap { pairs[$0] }
        tiles = chosen.flatMap { [TextTile(text: $0.a, pairKey: $0.a, isPrompt: true),
                                  TextTile(text: $0.b, pairKey: $0.a, isPrompt: false)] }
        selected = []
        missed = []
        pairsCleared = 0
        roundDone = false
        started = true
        gridCells = tiles.count
        scatter()
    }

    /// Random cell, slight tilt and offset for each remaining tile
    private func scatter() {
        let cells = Array(0..<gridCells).shuffled()   // remaining tiles spread over the whole board
        slots = Dictionary(uniqueKeysWithValues: zip(tiles.map(\.id), cells))
        tilts = Dictionary(uniqueKeysWithValues: tiles.map { ($0.id, Double.random(in: -10...10)) })
        jitter = Dictionary(uniqueKeysWithValues: tiles.map { ($0.id, CGSize(width: .random(in: -1...1), height: .random(in: -1...1))) })
    }

    private func tap(_ tile: TextTile) {
        guard selected.count < 2, !selected.contains(tile) else {
            if selected.contains(tile) { selected.removeAll { $0 == tile } }   // tap again to deselect
            return
        }
        selected.append(tile)
        guard selected.count == 2 else { return }
        let (t1, t2) = (selected[0], selected[1])
        if t1.pairKey == t2.pairKey {
            mastery.record(t1.pairKey, setID: set.id, firstTry: !missed.contains(t1.pairKey))
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                tiles.removeAll { $0.pairKey == t1.pairKey }
                selected = []
                pairsCleared += 1
                if tiles.isEmpty {
                    roundDone = true
                    if !plus.isPlus { freeRoundsUsed += 1 }
                }
            }
        } else {
            missed.insert(t1.pairKey)
            missed.insert(t2.pairKey)
            wrongFlash = [t1.id, t2.id]
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                selected = []
                wrongFlash = []
            }
        }
    }
}
