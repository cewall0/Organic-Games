//
//  IsomerMatchView.swift
//  Organic Games
//
//  Organic Games Plus: Isomer Match (Ch. 7). Two drawings from the book side by side; name how they're related,
//  using the choices of Fig. 7.9 (types of isomers) plus identical and conformers (7.14). After each answer the
//  path down Fig. 7.9's tree is shown. Pairs come from problems 7.7, 7.9 and 7.14 d–j, Figs. 7.6–7.8, and
//  pairs of the chirality games' molecules. Rounds of 10, weakest first. Without Plus, the first round is free.
//

import SwiftUI

enum IsomerKind: CaseIterable {
    case notIsomers, constitutional, conformers, identical, enantiomers, cisTrans, diastereomers

    var label: String {
        switch self {
        case .notIsomers: return "Not isomers"
        case .constitutional: return "Constitutional isomers"
        case .conformers: return "Conformers"
        case .identical: return "Identical"
        case .enantiomers: return "Enantiomers"
        case .cisTrans: return "Cis/trans isomers"
        case .diastereomers: return "Other diastereomers"
        }
    }

    /// The way down Fig. 7.9's tree
    var path: String {
        switch self {
        case .notIsomers: return "Same formula? No → not isomers."
        case .constitutional: return "Same formula, but atoms connected differently → constitutional isomers."
        case .conformers: return "Same connections, and turning a single bond makes one into the other → conformers."
        case .identical: return "Same connections, and turning the whole drawing makes them match → identical."
        case .enantiomers: return "Same connections, can't be superimposed, mirror images → enantiomers."
        case .cisTrans: return "Same connections, not mirror images, differ at a ring or C=C → cis/trans isomers."
        case .diastereomers: return "Same connections, not mirror images, two or more stereocenters → other diastereomers."
        }
    }
}

struct IsomerPair: Identifiable {
    let id: String          // mastery key
    let source: String      // "Problem 7.9a"
    let left: String
    let right: String
    let kind: IsomerKind
    let why: String

    static func byID(_ id: String) -> IsomerPair? { all.first { $0.id == id } }

    /// A pair cut for this game (isomer-…), named by its problem
    private static func book(_ problem: String, _ kind: IsomerKind, _ why: String) -> IsomerPair {
        let key = problem.dropFirst(2)   // "7.9a" → "9a"
        return IsomerPair(id: problem, source: "Problem \(problem)", left: "isomer-\(key)1", right: "isomer-\(key)2",
                          kind: kind, why: why)
    }

    private static func figure(_ id: String, _ figure: String, _ left: String, _ right: String, _ kind: IsomerKind, _ why: String) -> IsomerPair {
        IsomerPair(id: id, source: "Figure \(figure)", left: "isomer-\(left)", right: "isomer-\(right)", kind: kind, why: why)
    }

    /// Two molecules from Chiral or Achiral? (stereo-…)
    private static func pair(_ a: String, _ b: String, _ kind: IsomerKind, _ why: String) -> IsomerPair {
        IsomerPair(id: "\(a)|\(b)", source: "Problems \(a) and \(b)", left: "stereo-" + a.dropFirst(2), right: "stereo-" + b.dropFirst(2),
                   kind: kind, why: why)
    }

    // 7.7, 7.9 and the figures are answered in the book; 7.14 and the paired molecules are Claude's key
    static let all: [IsomerPair] = [
        book("7.7a", .diastereomers, "The top stereocenters match and the bottom ones are opposite, so they aren't mirror images."),
        book("7.7b", .enantiomers, "Both stereocenters are flipped: the two are mirror images."),
        book("7.7c", .notIsomers, "The left one has two Cl's and the right one only one, so their formulas differ."),
        book("7.7d", .enantiomers, "Both stereocenters are flipped: the two are mirror images."),
        book("7.9a", .notIsomers, "C₄H₁₀ vs. C₅H₁₂: one carbon apart."),
        book("7.9b", .constitutional, "Both are C₅H₁₂, but the left has a carbon bonded to four others and the right doesn't."),
        book("7.9c", .enantiomers, "The same carbon holding CH₃, Cl, OH and H, drawn as mirror images."),
        book("7.9d", .cisTrans, "Both are 1,3-dimethylcyclopentane: both CH₃s on one side (cis) vs. opposite sides (trans)."),
        book("7.9e", .diastereomers, "Same connections, but only one CH₃ points the other way, so they aren't mirror images."),
        book("7.9f", .constitutional, "Both are dimethylcyclopentanes, but the CH₃s sit on different carbons."),
        book("7.14d", .cisTrans, "Both are 1,3-dichlorocyclopentane: both Cl's up (cis) vs. one up and one down (trans)."),
        book("7.14e", .identical, "Both are 2,3-dimethylbutane: the left looks down C2–C3 and the right down C1–C2."),
        book("7.14f", .conformers, "Both are butane seen down C2–C3: CH₃s 60° apart (gauche) vs. 180° (anti)."),
        book("7.14g", .constitutional, "The left has both F's on one carbon (1,1-difluoroethene); the right has one on each carbon (1,2)."),
        book("7.14h", .identical, "Both have the F's on the same side (cis); flip the right one over and it matches."),
        book("7.14i", .cisTrans, "cis-1,2-Difluoroethene vs. trans-1,2-difluoroethene."),
        book("7.14j", .constitutional, "The C=C is next to the CH₃ carbon in one and across the ring in the other."),
        figure("F7.6ab", "7.6", "f6a", "f6b", .enantiomers, "(2S,3R) vs. (2R,3S): both stereocenters flipped."),
        figure("F7.6bc", "7.6", "f6b", "f6c", .diastereomers, "(2R,3S) vs. (2R,3R): only the bottom stereocenter is flipped."),
        figure("F7.6cd", "7.6", "f6c", "f6d", .enantiomers, "(2R,3R) vs. (2S,3S): both stereocenters flipped."),
        figure("F7.6ad", "7.6", "f6a", "f6d", .diastereomers, "(2S,3R) vs. (2S,3S): only the bottom stereocenter is flipped."),
        figure("F7.7a", "7.7", "f7a1", "f7a2", .cisTrans, "cis-1,2-Dichloroethene vs. trans-1,2-dichloroethene."),
        figure("F7.7b", "7.7", "f7b1", "f7b2", .cisTrans, "cis-1,3-Dichlorocyclopentane vs. trans."),
        figure("F7.8", "7.8", "f8a1", "f8a2", .enantiomers, "Both are trans-1,3-dichlorocyclopentane, and they're mirror images that can't be superimposed."),
        pair("7.19u", "7.19v", .cisTrans, "Cyclobutane-1,2-diol with the OHs trans vs. cis."),
        pair("7.19oo", "7.19pp", .cisTrans, "1,2-Dichlorocyclopropane with the Cl's cis vs. trans."),
        pair("7.19hh", "7.19ii", .cisTrans, "1,2-Dichlorocyclohexane with the Cl's cis vs. trans."),
        pair("7.19h", "7.19i", .diastereomers, "Same connections, but the left one is meso and the right one is chiral, so they can't be mirror images."),
        pair("7.8a", "7.8b", .diastereomers, "Both are 2,3-dibromobutane: the meso form vs. a chiral one."),
        pair("7.3g", "7.3h", .diastereomers, "Both are 2,3-dibromo-2,3-dichlorobutane: the meso form vs. a chiral one."),
        pair("7.19j", "7.5a", .identical, "Both are the same Fischer projection: OH right, left, right, right."),
        pair("7.19nn", "7.5b", .identical, "Both are the same Fischer projection, with both Cl's on the right."),
        pair("7.19j", "7.19k", .notIsomers, "The left has a CHO end (C₆H₁₂O₆) and the right CH₂OH at both ends (C₆H₁₄O₆)."),
    ]
}

struct IsomerMatchView: View {
    static let setID = "isomer-match"
    static var keys: [String] { IsomerPair.all.map(\.id) }
    static let chapterURL = URL(string: "https://organicchemistryguide.com/types-of-isomers/")!
    private let chapterLabel = "Review types of isomers (Ch. 7) in the free textbook"
    private let roundLength = 10

    @Environment(\.dismiss) private var dismiss
    @AppStorage("freeRounds.isomer-match") private var freeRoundsUsed = 0
    private let plus = PlusStore.shared
    private let mastery = MasteryStore.shared

    @State private var round: [IsomerPair] = []
    @State private var index = 0
    @State private var picked: IsomerKind?
    @State private var correctCount = 0
    @State private var showPaywall = false

    private var roundDone: Bool { !round.isEmpty && index >= round.count }
    private var locked: Bool { !plus.isPlus && freeRoundsUsed >= 1 }

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                if round.isEmpty && locked {
                    PlusLockedCard(title: "Isomer Match", things: "pairs", chapterLabel: chapterLabel,
                                   chapterURL: Self.chapterURL) { showPaywall = true }
                } else if roundDone {
                    PlusRoundSummary(correct: correctCount, total: round.count, setID: Self.setID, keys: Self.keys, things: "pairs",
                                     isPlus: plus.isPlus, chapterLabel: chapterLabel, chapterURL: Self.chapterURL,
                                     next: startRound, paywall: { showPaywall = true }, back: { dismiss() })
                } else if index < round.count {
                    question(round[index])
                }
            }
            .padding()
            .frame(maxWidth: 700)
            .frame(maxWidth: .infinity)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Isomer Match")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showPaywall) { NavigationStack { PlusPaywall() } }
        .onAppear { if round.isEmpty && !locked { startRound() } }
        .onChange(of: plus.isPlus) { _, isPlus in if isPlus && round.isEmpty { startRound() } }
    }

    private func question(_ q: IsomerPair) -> some View {
        VStack(spacing: 14) {
            HStack {
                Text("\(index + 1) of \(round.count)").font(.subheadline.bold()).foregroundStyle(.secondary)
                Spacer()
                Label("\(correctCount)", systemImage: "checkmark.circle.fill")
                    .font(.subheadline.bold()).foregroundStyle(.green)
                    .accessibilityLabel("\(correctCount) correct")
            }
            HStack(spacing: 8) {
                StructureImage(name: q.left, scale: zoom(q.left), label: "First molecule").frame(maxWidth: .infinity)
                Text("vs.").font(.subheadline).foregroundStyle(.secondary)
                StructureImage(name: q.right, scale: zoom(q.right), label: "Second molecule").frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity, minHeight: 140)
            .padding(.horizontal, 8)
            .paperCard()
            .shadow(color: .black.opacity(0.08), radius: 4, y: 2)

            Text("How are they related?").font(.headline)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(IsomerKind.allCases, id: \.self) { k in
                    Button { answer(k, for: q) } label: {
                        Text(k.label).font(.subheadline.weight(.semibold)).multilineTextAlignment(.center).foregroundStyle(.black)
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .paperCard(highlight: highlight(k, answer: q.kind))
                    }
                    .buttonStyle(.plain)
                }
            }

            if let picked {
                let right = picked == q.kind
                VStack(alignment: .leading, spacing: 6) {
                    Label(right ? "Correct!" : q.kind.label, systemImage: right ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.headline).foregroundStyle(right ? .green : .red)
                    Text(q.why).font(.subheadline)
                    Text(q.kind.path).font(.subheadline.italic()).foregroundStyle(.secondary)
                    Text(q.source).font(.caption).foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemGroupedBackground)))
                PlusWideButton(title: index + 1 < round.count ? "Next" : "Finish round") { next() }
            }
        }
    }

    /// Grows each drawing to about 130 pt tall: 7.19 is printed smaller than 7.5, and some pairs mix the two
    private func zoom(_ image: String) -> CGFloat {
        min(1.8, 130 / (UIImage(named: image)?.size.height ?? 130))
    }

    private func highlight(_ k: IsomerKind, answer: IsomerKind) -> Color? {
        guard let picked else { return nil }
        if k == answer { return .green }
        if k == picked { return .red }
        return nil
    }

    private func startRound() {
        let order = mastery.practiceOrder(setID: Self.setID, keys: Self.keys).compactMap(IsomerPair.byID)
        round = Array(order.prefix(roundLength)).shuffled()
        index = 0
        correctCount = 0
        picked = nil
    }

    private func answer(_ k: IsomerKind, for q: IsomerPair) {
        guard picked == nil else { return }
        picked = k
        let right = k == q.kind
        if right { correctCount += 1 }
        mastery.record(q.id, setID: Self.setID, firstTry: right)
    }

    private func next() {
        picked = nil
        index += 1
        if index >= round.count, !plus.isPlus { freeRoundsUsed += 1 }
    }
}
