//
//  TileGameView.swift
//  Organic Games
//
//  Organic Games Plus: the lazy tile-clearing game, with text tiles (a bond and its IR peak) or drawings
//  (reagents and the product they make, with the starting material shown above the pile, or, for Ch. 9–10,
//  a whole transformation and the reagents that do it).
//  Like the picture games, the whole set is piled up, overlapping, and drawn pair by pair, so the top
//  two tiles always match and can be cleared. A slight tilt keeps the tiles readable. A pair is mastered
//  after three first-try matches in a row. Without Plus, the first round is a free preview.
//

import SwiftUI
import WallaceAds

/// What one tile game piles up
struct TilePile {
    enum Face: Equatable {
        case text(String)
        case image(String, label: String)
        case captioned(String, image: String, label: String)    // "1° alcohol" above the reagents
        case reaction(sm: String, product: String, label: String)   // starting material → product, no reagents

        var label: String {
            switch self {
            case .text(let text): return text
            case .image(_, let label): return label
            case .captioned(let caption, _, let label): return "\(caption), \(label)"
            case .reaction(_, _, let label): return label
            }
        }

        var isText: Bool { if case .text = self { return true } else { return false } }
        var isReaction: Bool { if case .reaction = self { return true } else { return false } }
    }

    struct Pair {
        let key: String         // mastery key
        let a: Face             // the prompt side (bond, reagents)
        let b: Face
        var answerKey: String   // pairs with the same answer (the same product) never share a pile
        var promptKey: String? = nil    // nor do pairs with the same prompt (the same transformation)
    }

    let id: String
    let title: String
    let chapter: String
    let chapterURL: URL
    let pairs: [Pair]
    var header: Face? = nil     // shown above the pile (the starting material)

    var keys: [String] { pairs.map(\.key) }
}

extension TilePile {
    init(set: StudySet) {
        self.init(id: set.id, title: set.title, chapter: set.chapter, chapterURL: set.chapterURL,
                  pairs: (set.pairs ?? []).map { Pair(key: $0.a, a: .text($0.a), b: .text($0.b), answerKey: $0.b) })
    }

    /// Reagents ↔ product for every reaction of one starting material in the Ch. 11 summary
    init(reactions group: ReactionGroup) {
        let reactions = OrgReaction.all.filter { $0.group == group }
        let name: String
        switch group {
        case .alkene: name = "Alkenes"
        case .propyne: name = "Propyne"
        case .butyne: name = "2-Butyne"
        case .acetylide: name = "Acetylides"
        case .metathesis: name = "Metathesis"
        case .allylic: name = "Allylic Bromination"
        case .alcoholToHalide: name = "Alcohols to Alkyl Halides"
        case .dihalide: name = "Dihalides & Dehydration"
        }
        self.init(id: "rxn-tiles-\(group.rawValue)", title: "Reaction Tiles: \(name)", chapter: "Ch. 11",
                  chapterURL: ReactionChapter.ch11.url,
                  pairs: reactions.map { Pair(key: $0.id, a: .image($0.reagentsImage, label: $0.reagents),
                                              b: .image($0.productImage, label: $0.productName), answerKey: $0.productName) },
                  header: reactions.first.map { .image($0.smImage, label: "Starting material") })
    }

    /// Ch. 9–10: each transformation (starting material → product) ↔ the reagents that do it. A pile has each
    /// reagent set once (SOCl₂ for the 1° or the 2° alcohol), so SOCl₂ sits next to HCl, PBr₃ next to HBr...
    init(chapter: ReactionChapter) {
        let reactions = chapter.reactions
        self.init(id: "rxn-tiles-ch\(chapter.rawValue)", title: "Reaction Tiles: Ch. \(chapter == .ch9 ? "9–10" : chapter.rawValue)",
                  chapter: chapter == .ch9 ? "Ch. 9–10" : "Ch. \(chapter.rawValue)", chapterURL: chapter.url,
                  pairs: reactions.map { r in
                      Pair(key: r.id, a: .reaction(sm: r.smImage, product: r.productImage, label: "\(r.caption ?? "") to \(r.productName)"),
                           b: .image(r.reagentsImage, label: r.reagents), answerKey: r.reagents, promptKey: r.productName) })
    }
}

struct TileGameView: View {
    let pile: TilePile

    @Environment(\.dismiss) private var dismiss
    @AppStorage private var freeRoundsUsed: Int
    private let plus = PlusStore.shared
    private let mastery = MasteryStore.shared

    struct Tile: Identifiable, Equatable {
        let id = UUID()
        let face: TilePile.Face
        let pairKey: String     // both tiles of a pair share it
        let isPrompt: Bool      // the "a" side (e.g. the bond)
    }

    @State private var tiles: [Tile] = []
    @State private var spots: [UUID: CGPoint] = [:]      // tile centre, as a fraction of the board
    @State private var tilts: [UUID: Double] = [:]
    @State private var selected: [Tile] = []
    @State private var wrongFlash: Set<UUID> = []
    @State private var missed: Set<String> = []
    @State private var started = false
    @State private var roundDone = false
    @State private var showPaywall = false

    init(pile: TilePile) {
        self.pile = pile
        _freeRoundsUsed = AppStorage(wrappedValue: 0, "freeRounds.\(pile.id)")
    }

    private var locked: Bool { !plus.isPlus && freeRoundsUsed >= 1 }

    var body: some View {
        VStack(spacing: 8) {
            if !started && locked {
                lockedCard.padding()
            } else if roundDone {
                summary.padding()
            } else {
                if case .image(let name, let label) = pile.header {
                    VStack(spacing: 2) {
                        Text("Starting material").font(.caption).foregroundStyle(.gray)
                        StructureImage(name: name, label: label).frame(maxHeight: 64)
                    }
                    .frame(maxWidth: .infinity)
                    .paperCard()
                    .padding(.horizontal)
                }
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
        .navigationTitle(pile.title)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showPaywall) { NavigationStack { PlusPaywall() } }
        .onAppear { if !started && !locked { startRound() } }
        .onChange(of: plus.isPlus) { _, isPlus in if isPlus && !started { startRound() } }
    }

    // MARK: Board

    private func board(in size: CGSize) -> some View {
        let big = size.width > 600
        let drawings = pile.pairs.contains { !$0.a.isText }
        let reactions = pile.pairs.contains { $0.a.isReaction }
        let tileSize = reactions ? CGSize(width: big ? 280 : 184, height: big ? 128 : 96)
                     : drawings ? CGSize(width: big ? 210 : 150, height: big ? 112 : 84)
                                : CGSize(width: big ? 170 : 118, height: big ? 92 : 68)
        // Keep whole tiles on the board
        let usable = CGSize(width: max(1, size.width - tileSize.width - 8), height: max(1, size.height - tileSize.height - 8))
        return ZStack {
            // Drawn in pair order: the last pair is on top, so there is always a matching pair showing
            ForEach(tiles) { tile in
                if let spot = spots[tile.id] {
                    tileView(tile, size: tileSize)
                        .rotationEffect(.degrees(tilts[tile.id] ?? 0))
                        .position(x: tileSize.width / 2 + 4 + spot.x * usable.width,
                                  y: tileSize.height / 2 + 4 + spot.y * usable.height)
                        .onTapGesture { tap(tile) }
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .frame(width: size.width, height: size.height)
        .animation(.easeInOut(duration: 0.3), value: tiles)
    }

    private func tileView(_ tile: Tile, size: CGSize) -> some View {
        let isSelected = selected.contains(tile)
        let isWrong = wrongFlash.contains(tile.id)
        return Group {
            switch tile.face {
            case .text(let text):
                Text(text)
                    .font(.system(size: 15, weight: tile.isPrompt ? .bold : .semibold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.6)
            case .image(let name, let label):
                StructureImage(name: name, label: label)
            case .captioned(let caption, let name, let label):
                VStack(spacing: 2) {
                    Text(caption).font(.system(size: 12, weight: .semibold, design: .rounded)).foregroundStyle(.secondary)
                    StructureImage(name: name, label: label)
                }
            case .reaction(let sm, let product, let label):
                TransformationImage(sm: sm, product: product).accessibilityLabel(label)
            }
        }
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
        .accessibilityLabel(tile.face.label)
        .accessibilityAddTraits(.isButton)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    // MARK: Summary and locked

    private var summary: some View {
        let keys = pile.keys
        let done = mastery.masteredCount(setID: pile.id, keys: keys)
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
                wideButton("See Plus plans") { showPaywall = true }
            }
            Link("Review \(pile.chapter) in the free textbook", destination: pile.chapterURL).font(.subheadline)
            Button("Choose different game") { dismiss() }.font(.subheadline)
            Spacer(minLength: 0)
        }
        .padding(.top, 30)
    }

    private var lockedCard: some View {
        VStack(spacing: 16) {
            Image(systemName: "lock.circle.fill").font(.system(size: 56)).foregroundStyle(.orange)
            Text("Keep practicing with Plus").font(.title2.bold())
            Text("You've used your free round of \(pile.title). Plus unlocks every round, tracks what you've mastered and brings back the pairs you miss.")
                .multilineTextAlignment(.center).font(.subheadline)
            wideButton("See Plus plans") { showPaywall = true }
            Link("Review \(pile.chapter) in the free textbook", destination: pile.chapterURL).font(.subheadline)
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
        // The whole set in one pile, like the picture games; weakest pairs end up nearest the top.
        // Of pairs with the same answer (e.g. three ways to the same alcohol), only the weakest goes in.
        let byKey = Dictionary(uniqueKeysWithValues: pile.pairs.map { ($0.key, $0) })
        var answers: Set<String> = [], prompts: Set<String> = []
        let weakestFirst = mastery.practiceOrder(setID: pile.id, keys: pile.keys).compactMap { byKey[$0] }
            .filter { answers.insert($0.answerKey).inserted }
            .filter { $0.promptKey.map { prompts.insert($0).inserted } ?? true }
        tiles = weakestFirst.reversed().flatMap { [Tile(face: $0.a, pairKey: $0.key, isPrompt: true),
                                                   Tile(face: $0.b, pairKey: $0.key, isPrompt: false)] }
        selected = []
        missed = []
        pairsCleared = 0
        roundDone = false
        started = true
        scatter()
    }

    /// Spreads the remaining tiles over a zone grid (as the picture games do), keeping the two tiles of a pair
    /// apart, with a slight random tilt and offset. Pair order, and so the top pair, stays the same.
    private func scatter() {
        let cols = 5, rows = 8
        var free = Set(0..<(cols * rows))
        func spot(in zone: Int) -> CGPoint {
            CGPoint(x: (Double(zone % cols) + .random(in: 0.15...0.85)) / Double(cols),
                    y: (Double(zone / cols) + .random(in: 0.15...0.85)) / Double(rows))
        }
        func apart(_ a: Int, _ b: Int) -> Bool { abs(a / cols - b / cols) >= 2 || abs(a % cols - b % cols) >= 2 }
        var newSpots: [UUID: CGPoint] = [:]
        for i in stride(from: 0, to: tiles.count - 1, by: 2) {
            if free.count < 2 { free = Set(0..<(cols * rows)) }     // more tiles than zones: start overlapping more
            let shuffled = free.shuffled()
            let z1 = shuffled[0]
            let z2 = shuffled.dropFirst().first(where: { apart(z1, $0) }) ?? shuffled[1]
            free.remove(z1); free.remove(z2)
            newSpots[tiles[i].id] = spot(in: z1)
            newSpots[tiles[i + 1].id] = spot(in: z2)
        }
        spots = newSpots
        tilts = Dictionary(uniqueKeysWithValues: tiles.map { ($0.id, Double.random(in: -10...10)) })
    }

    private func tap(_ tile: Tile) {
        guard selected.count < 2, !selected.contains(tile) else {
            if selected.contains(tile) { selected.removeAll { $0 == tile } }   // tap again to deselect
            return
        }
        selected.append(tile)
        guard selected.count == 2 else { return }
        let (t1, t2) = (selected[0], selected[1])
        if t1.pairKey == t2.pairKey {
            mastery.record(t1.pairKey, setID: pile.id, firstTry: !missed.contains(t1.pairKey))
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

/// Starting material → product at one shared scale, so the two drawings stay in proportion as the tile shrinks them
struct TransformationImage: View {
    let sm: String
    let product: String
    private let arrow: CGFloat = 18

    var body: some View {
        let a = UIImage(named: sm)?.size ?? CGSize(width: 80, height: 50)
        let b = UIImage(named: product)?.size ?? CGSize(width: 80, height: 50)
        GeometryReader { geo in
            let k = min(1, (geo.size.width - arrow - 8) / (a.width + b.width), geo.size.height / max(a.height, b.height))
            HStack(spacing: 4) {
                Image(sm).resizable().interpolation(.high).frame(width: a.width * k, height: a.height * k)
                Image(systemName: "arrow.right").font(.system(size: 12, weight: .semibold)).frame(width: arrow)
                Image(product).resizable().interpolation(.high).frame(width: b.width * k, height: b.height * k)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}

/// The three Reaction Tiles piles, one per starting material
struct ReactionTilesMenu: View {
    private let plus = PlusStore.shared

    var body: some View {
        VStack(spacing: 16) {
            Text("Match each set of reagents to the product it makes from the starting material.")
                .multilineTextAlignment(.center).font(.subheadline).foregroundStyle(.secondary)
            ForEach([(GameType.rxnTilesAlkene, ReactionGroup.alkene, "Alkenes"),
                     (.rxnTilesPropyne, .propyne, "Propyne"),
                     (.rxnTilesButyne, .butyne, "2-Butyne")], id: \.2) { type, group, title in
                NavigationLink(value: type) {
                    VStack(spacing: 6) {
                        Text(title).font(.headline)
                        if let first = OrgReaction.all.first(where: { $0.group == group }) {
                            StructureImage(name: first.smImage, label: title).frame(maxHeight: 56)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.black)
                    .paperCard()
                }
            }
            Spacer()
        }
        .padding()
        .frame(maxWidth: 500)
        .frame(maxWidth: .infinity)
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Reaction Tiles")
        .navigationBarTitleDisplayMode(.inline)
    }
}
