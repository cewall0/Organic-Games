//
//  GameCatalog.swift
//  Organic Games
//
//  The home page's topics and the games under each, free and Plus side by side. A new game or chapter is
//  one entry here (plus its navigation destination in GameChoiceView).
//

import SwiftUI

struct GameEntry: Identifiable {
    enum Style {
        case tiles, quiz, blitz

        var label: String {
            switch self {
            case .tiles: return "Tile match"
            case .quiz: return "Quiz"
            case .blitz: return "Blitz"
            }
        }
        var icon: String {
            switch self {
            case .tiles: return "square.on.square"
            case .quiz: return "checklist"
            case .blitz: return "bolt.fill"
            }
        }
    }

    let title: String
    let type: GameType
    let style: Style
    var isPlus = false
    var mastery: [(setID: String, keys: [String])] = []   // what "mastered" counts, for Plus games
    var id: GameType { type }

    /// Mastered items and total, or nil for games that don't track mastery
    var progress: (done: Int, total: Int)? {
        guard !mastery.isEmpty else { return nil }
        let store = MasteryStore.shared
        return mastery.reduce((0, 0)) { sum, m in (sum.0 + store.masteredCount(setID: m.setID, keys: m.keys), sum.1 + m.keys.count) }
    }
}

struct GameTopic: Identifiable, Hashable {
    struct Section { let title: String?; let games: [GameEntry] }

    let id: String
    let title: String
    let subtitle: String
    let icon: String
    let tint: Color
    let sections: [Section]

    var games: [GameEntry] { sections.flatMap(\.games) }

    var progress: (done: Int, total: Int)? {
        let parts = games.compactMap(\.progress)
        guard !parts.isEmpty else { return nil }
        return parts.reduce((0, 0)) { ($0.0 + $1.done, $0.1 + $1.total) }
    }

    static func == (a: GameTopic, b: GameTopic) -> Bool { a.id == b.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }

    static func containing(_ type: GameType) -> (GameTopic, GameEntry)? {
        for topic in all { if let game = topic.games.first(where: { $0.type == type }) { return (topic, game) } }
        return nil
    }

    private static func studySetKeys(_ id: String) -> [String] { StudySet.all.first { $0.id == id }?.keys ?? [] }
    private static func reactionKeys(_ group: ReactionGroup) -> [String] { OrgReaction.all.filter { $0.group == group }.map(\.id) }

    static let all: [GameTopic] = [
        GameTopic(id: "basics", title: "Basics", subtitle: "Functional groups, charges, hybridization",
                  icon: "atom", tint: .teal, sections: [
                    Section(title: nil, games: [
                        GameEntry(title: "Functional Groups", type: .game1, style: .tiles),
                        GameEntry(title: "Functional Group Suffixes", type: .game2, style: .tiles),
                        GameEntry(title: "Formal Charges", type: .game3, style: .tiles),
                        GameEntry(title: "Hybridization", type: .game4, style: .tiles),
                        GameEntry(title: "Alkyl Groups", type: .game5, style: .tiles),
                    ]),
                  ]),
        GameTopic(id: "stereo", title: "Stereochemistry", subtitle: "R and S",
                  icon: "arrow.triangle.2.circlepath", tint: .purple, sections: [
                    Section(title: nil, games: [GameEntry(title: "R & S Stereochemistry", type: .game7, style: .blitz)]),
                  ]),
        GameTopic(id: "spectroscopy", title: "Spectroscopy", subtitle: "IR and mass spec",
                  icon: "waveform.path.ecg", tint: .blue, sections: [
                    Section(title: "IR spectroscopy", games: [
                        GameEntry(title: "Name That Spectrum", type: .irSpectra, style: .quiz, isPlus: true,
                                  mastery: [(NameThatSpectrumView.setID, IRSpectrum.all.map(\.id))]),
                        GameEntry(title: "IR Tile Match", type: .irTiles, style: .tiles, isPlus: true,
                                  mastery: [("ir-tiles", studySetKeys("ir-tiles"))]),
                    ]),
                    Section(title: "Mass spectrometry", games: [
                        GameEntry(title: "Name That Pattern", type: .msPatterns, style: .quiz, isPlus: true,
                                  mastery: [(NameThatPatternView.setID, MSAtom.allCases.map(\.rawValue))]),
                        GameEntry(title: "Mass Spec Tile Match", type: .msTiles, style: .tiles, isPlus: true,
                                  mastery: [("ms-tiles", studySetKeys("ms-tiles"))]),
                    ]),
                  ]),
        GameTopic(id: "reactions", title: "Reactions", subtitle: "Alkyl halides, alkenes and alkynes",
                  icon: "arrow.right.circle", tint: .orange, sections: [
                    // No Predict the Product here: the summary's wrong products differ only by halogen or skeleton,
                    // so they were too easy. Product questions for Ch. 9 belong in a mechanism game (SN1/SN2/E1/E2).
                    Section(title: "Ch. 9–10 Alkyl Halides & Eliminations", games: [
                        GameEntry(title: "Name the Reagents", type: .rxn9Reagents, style: .quiz, isPlus: true,
                                  mastery: [(ReactionQuizView.Mode.reagents.setID(.ch9), ReactionQuizView.Mode.reagents.reactions(.ch9).map(\.id))]),
                        GameEntry(title: "Reaction Tiles", type: .rxn9Tiles, style: .tiles, isPlus: true,
                                  mastery: [("rxn-tiles-ch9", ReactionChapter.ch9.reactions.map(\.id))]),
                    ]),
                    Section(title: "Ch. 11 Alkenes & Alkynes", games: [
                        GameEntry(title: "Predict the Product", type: .rxnPredict, style: .quiz, isPlus: true,
                                  mastery: [(ReactionQuizView.Mode.product.setID(.ch11), ReactionQuizView.Mode.product.reactions(.ch11).map(\.id))]),
                        GameEntry(title: "Name the Reagents", type: .rxnReagents, style: .quiz, isPlus: true,
                                  mastery: [(ReactionQuizView.Mode.reagents.setID(.ch11), ReactionQuizView.Mode.reagents.reactions(.ch11).map(\.id))]),
                        GameEntry(title: "Reaction Tiles", type: .rxnTiles, style: .tiles, isPlus: true,
                                  mastery: [ReactionGroup.alkene, .propyne, .butyne].map { ("rxn-tiles-\($0.rawValue)", reactionKeys($0)) }),
                        // Fill the Gap is out until it becomes multistep synthesis chains (Ch. 9–11)
                    ]),
                  ]),
        GameTopic(id: "biochem", title: "Biochemistry", subtitle: "Amino acids",
                  icon: "leaf", tint: .green, sections: [
                    Section(title: nil, games: [GameEntry(title: "Amino Acids", type: .game6, style: .tiles)]),
                  ]),
    ]
}

// MARK: Views

/// A small PLUS or FREE tag
struct PriceTag: View {
    let plus: Bool
    var body: some View {
        Text(plus ? "PLUS" : "FREE")
            .font(.caption2.bold())
            .foregroundStyle(plus ? .orange : .green)
            .padding(.horizontal, 6).padding(.vertical, 2)
            .background(Capsule().fill((plus ? Color.orange : Color.green).opacity(0.15)))
    }
}

/// A home-page card for one topic
struct TopicCard: View {
    let topic: GameTopic
    let isPlus: Bool    // the student has Plus: no tags needed

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: topic.icon).font(.title2).foregroundStyle(topic.tint)
                Spacer()
                if !isPlus {
                    let plusGames = topic.games.filter(\.isPlus).count
                    PriceTag(plus: plusGames == topic.games.count)
                }
            }
            Text(topic.title).font(.headline).foregroundStyle(.primary)
            Text(topic.subtitle).font(.caption).foregroundStyle(.secondary).lineLimit(2, reservesSpace: true)
            HStack {
                Text("\(topic.games.count) game\(topic.games.count == 1 ? "" : "s")").font(.caption.bold()).foregroundStyle(.secondary)
                Spacer()
            }
            if let p = topic.progress {
                ProgressView(value: Double(p.done), total: Double(max(1, p.total))).tint(topic.tint)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 14).fill(Color(.secondarySystemGroupedBackground)))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(topic.tint.opacity(0.35), lineWidth: 1))
        .accessibilityElement(children: .combine)
    }
}

/// One row on a topic page
struct GameRow: View {
    let game: GameEntry
    let tint: Color
    let isPlus: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: game.style.icon)
                .font(.title3).foregroundStyle(tint)
                .frame(width: 40, height: 40)
                .background(RoundedRectangle(cornerRadius: 10).fill(tint.opacity(0.12)))
            VStack(alignment: .leading, spacing: 2) {
                Text(game.title).font(.body.weight(.semibold)).foregroundStyle(.primary)
                HStack(spacing: 6) {
                    Text(game.style.label)
                    if let p = game.progress { Text("· \(p.done) of \(p.total) mastered") }
                }
                .font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            if game.isPlus && !isPlus { PriceTag(plus: true) }
            Image(systemName: "chevron.right").font(.caption.bold()).foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }
}

/// The games in one topic
struct TopicView: View {
    let topic: GameTopic
    let open: (GameType) -> Void
    private let plus = PlusStore.shared

    var body: some View {
        List {
            ForEach(Array(topic.sections.enumerated()), id: \.offset) { _, section in
                Section(section.title ?? "") {
                    ForEach(section.games) { game in
                        Button { open(game.type) } label: { GameRow(game: game, tint: topic.tint, isPlus: plus.isPlus) }
                            .buttonStyle(.plain)   // black titles, not link blue
                    }
                }
            }
        }
        .navigationTitle(topic.title)
    }
}
