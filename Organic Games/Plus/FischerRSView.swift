//
//  FischerRSView.swift
//  Organic Games
//
//  Organic Games Plus: Fischer R and S (Ch. 7). Fischer projections from the book; each stereocenter is circled
//  in turn, top to bottom, and is answered R or S. The answer is worked out the book's way (Fig. 7.5): number
//  the groups by priority, follow 1 → 2 → 3, and reverse it when 4 (H) is on a horizontal bond, toward you.
//  Sources: 7.5 and 7.6 (D-glucose), 7.7, 7.16 e and h, 7.19 k and mm, and Fig. 7.6 (labeled in the book).
//  Rounds of 6 molecules, weakest first. Without Plus, the first round is free.
//

import SwiftUI

struct FischerCenter {
    let top: String, right: String, bottom: String, left: String
    let ranks: [Int]            // CIP priority of top, right, bottom, left (1 highest)
    var note: String? = nil     // how a tie between two carbons was broken

    private var groups: [String] { [top, right, bottom, left] }
    /// Top, right, bottom, left as points (y up)
    private static let spots = [CGPoint(x: 0, y: 1), CGPoint(x: 1, y: 0), CGPoint(x: 0, y: -1), CGPoint(x: -1, y: 0)]

    private func spot(_ rank: Int) -> CGPoint { Self.spots[ranks.firstIndex(of: rank)!] }
    private var turnsClockwise: Bool {
        let a = spot(1), b = spot(2), c = spot(3)
        return (b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x) < 0
    }
    /// 4 on a horizontal bond points toward you, so the arrow reads backward
    private var lowestHorizontal: Bool { [1, 3].contains(ranks.firstIndex(of: 4)!) }

    var isR: Bool { turnsClockwise != lowestHorizontal }

    var explanation: String {
        let order = (1...4).map { "\($0) \(groups[ranks.firstIndex(of: $0)!])" }.joined(separator: ", ")
        let arrow = turnsClockwise ? "clockwise (R)" : "counterclockwise (S)"
        let lowest = groups[ranks.firstIndex(of: 4)!]
        let reading = lowestHorizontal
            ? "\(lowest) is on a horizontal bond, toward you, so reverse it: \(isR ? "R" : "S")."
            : "\(lowest) is on a vertical bond, away from you, so it reads as drawn: \(isR ? "R" : "S")."
        return "\(order). 1 → 2 → 3 turns \(arrow). \(reading)" + (note.map { " \($0)" } ?? "")
    }
}

struct FischerMolecule: Identifiable {
    let id: String
    let source: String
    let image: String
    let centers: [FischerCenter]

    /// Where each stereocenter is in the drawing, top to bottom
    var positions: [CGPoint] {
        let atoms = StereoCenters.atoms[image] ?? []
        return (StereoCenters.centers[image] ?? []).map { atoms[$0] }.sorted { $0.y < $1.y }
    }

    static func byID(_ id: String) -> FischerMolecule? { all.first { $0.id == id } }

    private static func c(_ top: String, _ right: String, _ bottom: String, _ left: String, _ ranks: [Int], _ note: String? = nil) -> FischerCenter {
        FischerCenter(top: top, right: right, bottom: bottom, left: left, ranks: ranks, note: note)
    }
    private static let above = "the carbon above", below = "the carbon below"

    // 7.6 and Fig. 7.6 are labeled in the book; the rest are Claude's key
    static let all: [FischerMolecule] = [
        FischerMolecule(id: "7.6", source: "Problem 7.6 (D-glucose)", image: "stereo-5a", centers: [
            c("CHO", "OH", below, "H", [2, 1, 3, 4]),
            c(above, "H", below, "OH", [2, 4, 3, 1], "Above and below both hold O, C and H; above wins because it leads to the CHO."),
            c(above, "OH", below, "H", [2, 1, 3, 4], "Above and below both hold O, C and H; above wins because it leads to a carbon with O, C, H, and below to CH₂OH (O, H, H)."),
            c(above, "OH", "CH₂OH", "H", [2, 1, 3, 4]),
        ]),
        FischerMolecule(id: "F7.6a", source: "Figure 7.6", image: "isomer-f6a", centers: [
            c("CH₃", "Br", below, "H", [3, 1, 2, 4]), c(above, "Cl", "CH₂CH₃", "H", [2, 1, 3, 4]),
        ]),
        FischerMolecule(id: "F7.6b", source: "Figure 7.6", image: "isomer-f6b", centers: [
            c("CH₃", "H", below, "Br", [3, 4, 2, 1]), c(above, "H", "CH₂CH₃", "Cl", [2, 4, 3, 1]),
        ]),
        FischerMolecule(id: "F7.6c", source: "Figure 7.6", image: "isomer-f6c", centers: [
            c("CH₃", "H", below, "Br", [3, 4, 2, 1]), c(above, "Cl", "CH₂CH₃", "H", [2, 1, 3, 4]),
        ]),
        FischerMolecule(id: "F7.6d", source: "Figure 7.6", image: "isomer-f6d", centers: [
            c("CH₃", "Br", below, "H", [3, 1, 2, 4]), c(above, "H", "CH₂CH₃", "Cl", [2, 4, 3, 1]),
        ]),
        FischerMolecule(id: "7.19k", source: "Problem 7.19k", image: "stereo-19k", centers: [
            c("CH₂OH", "OH", below, "H", [3, 1, 2, 4]),
            c(above, "H", below, "OH", [3, 4, 2, 1], "Above and below both hold O, C and H; below wins because it leads to a carbon with O, C, H, and above to CH₂OH."),
            c(above, "H", below, "OH", [2, 4, 3, 1], "Above and below both hold O, C and H; above wins because it leads to a carbon with O, C, H, and below to CH₂OH."),
            c(above, "OH", "CH₂OH", "H", [2, 1, 3, 4]),
        ]),
        FischerMolecule(id: "7.19mm", source: "Problem 7.19mm", image: "stereo-19mm", centers: [
            c("CHO", "OH", below, "H", [2, 1, 3, 4]),
            c(above, "OH", below, "H", [2, 1, 3, 4], "Above and below both hold O, C and H; above wins because it leads to the CHO."),
            c(above, "OH", "CH₂OH", "H", [2, 1, 3, 4]),
        ]),
        FischerMolecule(id: "7.5b", source: "Problem 7.5b", image: "stereo-5b", centers: [
            c("OH", "Cl", below, "H", [2, 1, 3, 4]), c(above, "Cl", "OH", "H", [3, 1, 2, 4]),
        ]),
        FischerMolecule(id: "7.5c", source: "Problem 7.5c", image: "stereo-5c", centers: [
            c("OH", "Cl", "CH₂OH", "H", [2, 1, 3, 4]),
        ]),
        FischerMolecule(id: "7.5d", source: "Problem 7.5d", image: "stereo-5d", centers: [
            c("OH", "Cl", below, "H", [2, 1, 3, 4]), c(above, "H", "OH", "Cl", [3, 4, 2, 1]),
        ]),
        FischerMolecule(id: "7.7b", source: "Problem 7.7b", image: "isomer-7b1", centers: [
            c("OH", "H", below, "Cl", [2, 4, 3, 1]), c(above, "Cl", "OH", "H", [3, 1, 2, 4]),
        ]),
        FischerMolecule(id: "7.7d1", source: "Problem 7.7d", image: "isomer-7d1", centers: [
            c("CHO", "H", below, "Cl", [3, 4, 2, 1], "The carbon below holds Cl, O and H, so it beats CHO (O, O, H) at the first difference."),
            c(above, "Cl", "OH", "H", [3, 1, 2, 4]),
        ]),
        FischerMolecule(id: "7.7d2", source: "Problem 7.7d", image: "isomer-7d2", centers: [
            c("CHO", "Cl", below, "H", [3, 1, 2, 4], "The carbon below holds Cl, O and H, so it beats CHO (O, O, H) at the first difference."),
            c(above, "H", "OH", "Cl", [3, 4, 2, 1]),
        ]),
        FischerMolecule(id: "7.16e", source: "Problem 7.16e", image: "fischer-16e", centers: [
            c("CHO", "Cl", "OH", "H", [3, 1, 2, 4]),
        ]),
        FischerMolecule(id: "7.16h", source: "Problem 7.16h", image: "fischer-16h", centers: [
            c("CH₃", "H", "CH₂CH₃", "Br", [3, 4, 2, 1]),
        ]),
    ]
}

struct FischerRSView: View {
    static let setID = "fischer-rs"
    static var keys: [String] { FischerMolecule.all.map(\.id) }
    static let chapterURL = URL(string: "https://organicchemistryguide.com/fischer-projections/")!
    private let chapterLabel = "Review Fischer projections (Ch. 7) in the free textbook"
    private let roundLength = 6

    @Environment(\.dismiss) private var dismiss
    @AppStorage("freeRounds.fischer-rs") private var freeRoundsUsed = 0
    private let plus = PlusStore.shared
    private let mastery = MasteryStore.shared

    @State private var round: [FischerMolecule] = []
    @State private var index = 0
    @State private var answers: [Bool] = []      // R picked, for the centers answered so far
    @State private var showing = false           // the last answer's explanation is up
    @State private var correctCount = 0
    @State private var showPaywall = false

    private var roundDone: Bool { !round.isEmpty && index >= round.count }
    private var locked: Bool { !plus.isPlus && freeRoundsUsed >= 1 }

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                if round.isEmpty && locked {
                    PlusLockedCard(title: "Fischer R and S", things: "molecules", chapterLabel: chapterLabel,
                                   chapterURL: Self.chapterURL) { showPaywall = true }
                } else if roundDone {
                    PlusRoundSummary(correct: correctCount, total: round.count, setID: Self.setID, keys: Self.keys, things: "molecules",
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
        .navigationTitle("Fischer R and S")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showPaywall) { NavigationStack { PlusPaywall() } }
        .onAppear { if round.isEmpty && !locked { startRound() } }
        .onChange(of: plus.isPlus) { _, isPlus in if isPlus && round.isEmpty { startRound() } }
    }

    private func question(_ m: FischerMolecule) -> some View {
        // The circled center: the last answered while its explanation shows, else the next one
        let current = showing ? answers.count - 1 : answers.count
        let answered = showing
        let center = m.centers[current]
        return VStack(spacing: 14) {
            HStack {
                Text("\(index + 1) of \(round.count)").font(.subheadline.bold()).foregroundStyle(.secondary)
                Spacer()
                Label("\(correctCount)", systemImage: "checkmark.circle.fill")
                    .font(.subheadline.bold()).foregroundStyle(.green)
                    .accessibilityLabel("\(correctCount) correct")
            }
            Text(m.centers.count == 1 ? "Is the circled stereocenter R or S?" : "Stereocenter \(current + 1) of \(m.centers.count): R or S?")
                .font(.headline)
            FischerDrawing(molecule: m, current: current, answers: answers)
                .padding(12)
                .frame(maxWidth: .infinity)
                .paperCard()
                .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
            HStack(spacing: 10) {
                ForEach([true, false], id: \.self) { r in
                    Button { pick(r, m: m) } label: {
                        Text(r ? "R" : "S").font(.title.weight(.bold)).foregroundStyle(.black)
                            .frame(maxWidth: .infinity, minHeight: 60)
                            .paperCard(highlight: answered ? highlight(r, picked: answers[current], answer: center.isR) : nil)
                    }
                    .buttonStyle(.plain)
                }
            }
            if answered {
                let right = answers[current] == center.isR
                VStack(alignment: .leading, spacing: 6) {
                    Label(right ? "Correct!" : "It's \(center.isR ? "R" : "S")", systemImage: right ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.headline).foregroundStyle(right ? .green : .red)
                    Text(center.explanation).font(.subheadline)
                    Text(m.source).font(.caption).foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemGroupedBackground)))
                PlusWideButton(title: current + 1 < m.centers.count ? "Next stereocenter"
                               : index + 1 < round.count ? "Next" : "Finish round") { next(m) }
            }
        }
    }

    private func highlight(_ r: Bool, picked: Bool, answer: Bool) -> Color? {
        if r == answer { return .green }
        if r == picked { return .red }
        return nil
    }

    private func startRound() {
        let order = mastery.practiceOrder(setID: Self.setID, keys: Self.keys).compactMap(FischerMolecule.byID)
        round = Array(order.prefix(roundLength)).shuffled()
        index = 0
        correctCount = 0
        answers = []
        showing = false
    }

    private func pick(_ r: Bool, m: FischerMolecule) {
        guard !showing, answers.count < m.centers.count else { return }
        answers.append(r)
        showing = true
        if answers.count == m.centers.count {   // the molecule counts when every center is right
            let right = zip(answers, m.centers).allSatisfy { $0 == $1.isR }
            if right { correctCount += 1 }
            mastery.record(m.id, setID: Self.setID, firstTry: right)
        }
    }

    /// The button under an explanation: the next center of this molecule, or the next molecule
    private func next(_ m: FischerMolecule) {
        showing = false
        if answers.count < m.centers.count { return }
        answers = []
        index += 1
        if index >= round.count, !plus.isPlus { freeRoundsUsed += 1 }
    }
}

/// The Fischer projection with the current stereocenter circled and the answered ones labeled
private struct FischerDrawing: View {
    let molecule: FischerMolecule
    let current: Int
    let answers: [Bool]

    var body: some View {
        let size = UIImage(named: molecule.image)?.size ?? CGSize(width: 100, height: 100)
        let zoom = min(2.2, 280 / size.height)
        let points = molecule.positions
        Image(molecule.image)
            .resizable()
            .interpolation(.high)
            .scaledToFit()
            .overlay {
                GeometryReader { geo in
                    ForEach(Array(points.enumerated()), id: \.offset) { i, p in
                        let at = CGPoint(x: p.x * geo.size.width, y: p.y * geo.size.height)
                        if i == current {
                            Circle().stroke(Color.purple, lineWidth: 3).frame(width: 28, height: 28).position(at)
                        }
                        if i < answers.count, i < molecule.centers.count {
                            let right = answers[i] == molecule.centers[i].isR
                            Text(molecule.centers[i].isR ? "R" : "S")
                                .font(.subheadline.bold()).foregroundStyle(right ? .green : .red)
                                .padding(.horizontal, 2)
                                .background(Color.white)
                                .position(x: at.x + 16, y: at.y - 16)
                        }
                    }
                }
            }
            .frame(maxWidth: size.width * zoom, maxHeight: size.height * zoom)
            .accessibilityLabel("Fischer projection")
    }
}
