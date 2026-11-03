//
//  FillTheGapView.swift
//  Organic Games
//
//  Organic Games Plus: Ch. 11 puzzles that don't fit "predict the product" or "name the reagents".
//  Two-step acetylide sequences (propyne → acetylide → product) with one piece blanked out: step 1,
//  the intermediate, step 2 or the product. The Ag⁺ and Cu⁺ routes end at the same product, so the
//  intermediate is always shown when a reagent is asked. Rounds of 10, weakest first. Without Plus, the
//  first round is free. (The "which kind of reaction?" metathesis questions are out for now: the reagents and
//  the one fixed drawing per kind gave them away.)
//

import SwiftUI

struct GapQuestion: Identifiable {
    enum Blank: String { case step1, intermediate, step2, product, kind }

    let seq: String            // "r35" (acetylide sequence) or a metathesis reaction id
    let blank: Blank
    var id: String { "\(seq)-\(blank.rawValue)" }

    struct Choice: Identifiable, Equatable {
        let id: String
        var image: String? = nil
        let label: String
    }

    static let sequences = ["r35", "r36", "r37"]
    static let kinds: [(id: String, kind: String)] = [("r20", "Ring-opening metathesis polymerization (ROMP)"),
                                                     ("r21", "Cross metathesis"),
                                                     ("r22", "Ring-closing metathesis"),
                                                     ("r23", "Polymerization")]

    static let all: [GapQuestion] =
        sequences.flatMap { seq in [Blank.step1, .intermediate, .step2, .product].map { GapQuestion(seq: seq, blank: $0) } }

    static func byID(_ id: String) -> GapQuestion? { all.first { $0.id == id } }

    private var step1: OrgReaction { OrgReaction.byID("\(seq)a")! }
    private var step2: OrgReaction { OrgReaction.byID("\(seq)b")! }

    var answer: Choice {
        switch blank {
        case .step1: return Choice(id: step1.reagentsImage, image: step1.reagentsImage, label: step1.reagents)
        case .intermediate: return Choice(id: step1.productImage, image: step1.productImage, label: step1.productName)
        case .step2: return Choice(id: step2.reagents, image: step2.reagentsImage, label: step2.reagents)
        case .product: return Choice(id: step2.productName, image: step2.productImage, label: step2.productName)
        case .kind: return Choice(id: seq, label: Self.kinds.first { $0.id == seq }!.kind)
        }
    }

    /// The answer and three wrong ones: the other acetylide routes first, then other propyne reactions
    func choices() -> [Choice] {
        let others = Self.sequences.filter { $0 != seq }
        let propyne = OrgReaction.all.filter { $0.group == .propyne && !$0.id.hasSuffix("a") }.shuffled()
        var wrong: [Choice]
        switch blank {
        case .step1:
            wrong = others.map { OrgReaction.byID("\($0)a")! }.map { Choice(id: $0.reagentsImage, image: $0.reagentsImage, label: $0.reagents) }
                + propyne.map { Choice(id: $0.reagentsImage, image: $0.reagentsImage, label: $0.reagents) }
        case .intermediate:
            wrong = others.map { OrgReaction.byID("\($0)a")! }.map { Choice(id: $0.productImage, image: $0.productImage, label: $0.productName) }
                + propyne.map { Choice(id: $0.productImage, image: $0.productImage, label: $0.productName) }
        case .step2:
            wrong = others.map { OrgReaction.byID("\($0)b")! }.map { Choice(id: $0.reagents, image: $0.reagentsImage, label: $0.reagents) }
                + propyne.map { Choice(id: $0.reagents, image: $0.reagentsImage, label: $0.reagents) }
        case .product:
            wrong = others.map { OrgReaction.byID("\($0)b")! }.map { Choice(id: $0.productName, image: $0.productImage, label: $0.productName) }
                + propyne.map { Choice(id: $0.productName, image: $0.productImage, label: $0.productName) }
        case .kind:
            wrong = Self.kinds.filter { $0.id != seq }.map { Choice(id: $0.id, label: $0.kind) }
        }
        // Same compound or reagents as the answer (HCl for both Ag⁺ and Cu⁺, propyne for both) is not a wrong answer
        var seen: Set<String> = [answer.id]
        wrong = wrong.filter { seen.insert($0.id).inserted }
        return ([answer] + wrong.prefix(3)).shuffled()
    }

    /// What to show after answering
    var explanation: (title: String, note: String) {
        switch blank {
        case .step1, .intermediate: return (step1.name, step1.note)
        case .step2, .product: return (step2.name, step2.note)
        case .kind:
            let r = OrgReaction.byID(seq)!
            return (r.name, r.note)
        }
    }

    var prompt: String {
        switch blank {
        case .step1: return "Which reagent for step 1?"
        case .intermediate: return "What forms in step 1?"
        case .step2: return "Which reagent for step 2?"
        case .product: return "What's the final product?"
        case .kind: return "What kind of reaction is this?"
        }
    }

    // MARK: Drawing

    @ViewBuilder var card: some View {
        if blank == .kind, let r = OrgReaction.byID(seq) {
            HStack(spacing: 8) {
                StructureImage(name: r.smImage, label: "Starting material")
                ReagentArrow(reagentsImage: r.reagentsImage, reversible: r.reversible, label: r.reagents)
                StructureImage(name: r.productImage, label: r.productName)
            }
        } else {
            // Two rows: propyne → acetylide, then → product
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    StructureImage(name: step1.smImage, label: "propyne")
                    ReagentArrow(reagentsImage: blank == .step1 ? nil : step1.reagentsImage, label: step1.reagents)
                    piece(step1.productImage, label: step1.productName, hidden: blank == .intermediate)
                }
                HStack(spacing: 8) {
                    Spacer(minLength: 0)
                    ReagentArrow(reagentsImage: blank == .step2 ? nil : step2.reagentsImage, label: step2.reagents)
                    piece(step2.productImage, label: step2.productName, hidden: blank == .product)
                }
            }
        }
    }

    @ViewBuilder private func piece(_ image: String, label: String, hidden: Bool) -> some View {
        if hidden {
            Text("?").font(.largeTitle.bold()).foregroundStyle(.orange).frame(minWidth: 60)
        } else {
            StructureImage(name: image, label: label)
        }
    }
}

struct FillTheGapView: View {
    static let setID = "rxn-gaps"
    private let roundLength = 10

    @Environment(\.dismiss) private var dismiss
    @AppStorage("freeRounds.rxn-gaps") private var freeRoundsUsed = 0
    private let plus = PlusStore.shared
    private let mastery = MasteryStore.shared

    @State private var round: [GapQuestion] = []
    @State private var choices: [GapQuestion.Choice] = []
    @State private var index = 0
    @State private var picked: GapQuestion.Choice?
    @State private var correctCount = 0
    @State private var showPaywall = false

    private var keys: [String] { GapQuestion.all.map(\.id) }
    private var roundDone: Bool { !round.isEmpty && index >= round.count }
    private var locked: Bool { !plus.isPlus && freeRoundsUsed >= 1 }

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                if round.isEmpty && locked {   // came back after using the free round
                    lockedCard
                } else if roundDone {
                    summary
                } else if index < round.count {
                    question(round[index])
                }
            }
            .padding()
            .frame(maxWidth: 700)
            .frame(maxWidth: .infinity)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Fill the Gap")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showPaywall) { NavigationStack { PlusPaywall() } }
        .onAppear { if round.isEmpty && !locked { startRound() } }
        .onChange(of: plus.isPlus) { _, isPlus in if isPlus && round.isEmpty { startRound() } }
    }

    // MARK: Question

    private func question(_ q: GapQuestion) -> some View {
        VStack(spacing: 14) {
            HStack {
                Text("\(index + 1) of \(round.count)").font(.subheadline.bold()).foregroundStyle(.secondary)
                Spacer()
                Label("\(correctCount)", systemImage: "checkmark.circle.fill")
                    .font(.subheadline.bold()).foregroundStyle(.green)
                    .accessibilityLabel("\(correctCount) correct")
            }
            q.card
                .frame(maxWidth: .infinity, minHeight: 90)
                .paperCard()
                .shadow(color: .black.opacity(0.08), radius: 4, y: 2)

            Text(q.prompt).font(.headline)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(choices) { c in
                    Button { answer(c, for: q) } label: {
                        Group {
                            if let image = c.image {
                                StructureImage(name: image, scale: 1.1, label: c.label)
                            } else {
                                Text(c.label).font(.body.weight(.semibold)).multilineTextAlignment(.center).foregroundStyle(.black)
                            }
                        }
                        .frame(maxWidth: .infinity, minHeight: 72, maxHeight: 96)
                        .paperCard(highlight: highlight(c, answer: q.answer))
                    }
                    .buttonStyle(.plain)   // taps after answering are ignored in answer()
                }
            }
            if let picked {
                let right = picked == q.answer
                VStack(alignment: .leading, spacing: 6) {
                    Label(right ? "Correct! \(q.explanation.title)" : q.explanation.title,
                          systemImage: right ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.headline)
                        .foregroundStyle(right ? .green : .red)
                    Text(q.explanation.note).font(.subheadline)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemGroupedBackground)))
                wideButton(index + 1 < round.count ? "Next" : "Finish round") { next() }
            }
        }
    }

    private func highlight(_ c: GapQuestion.Choice, answer: GapQuestion.Choice) -> Color? {
        guard let picked else { return nil }
        if c == answer { return .green }
        if c == picked { return .red }
        return nil
    }

    // MARK: Summary and locked

    private var summary: some View {
        let done = mastery.masteredCount(setID: Self.setID, keys: keys)
        return VStack(spacing: 16) {
            Image(systemName: correctCount >= round.count - 2 ? "star.circle.fill" : "checkmark.seal.fill")
                .font(.system(size: 56)).foregroundStyle(.orange)
            Text("\(correctCount) of \(round.count) right").font(.title.bold())
            Text("Mastered \(done) of \(keys.count) puzzles").font(.headline).foregroundStyle(.secondary)
            ProgressView(value: Double(done), total: Double(keys.count)).tint(.orange)
            if plus.isPlus {
                wideButton("Next round") { startRound() }
            } else {
                Text("That was your free round. Organic Games Plus keeps the practice going and focuses on the puzzles you miss.")
                    .multilineTextAlignment(.center).font(.subheadline)
                wideButton("Try Plus free") { showPaywall = true }
            }
            Link("Review the reaction summary on organicchemistryguide.com", destination: ReactionChapter.ch11.url).font(.subheadline)
            Button("Back to games") { dismiss() }.font(.subheadline)
        }
        .padding(.top, 30)
    }

    private var lockedCard: some View {
        VStack(spacing: 16) {
            Image(systemName: "lock.circle.fill").font(.system(size: 56)).foregroundStyle(.orange)
            Text("Keep practicing with Plus").font(.title2.bold())
            Text("You've used your free round of Fill the Gap. Plus unlocks every round, tracks what you've mastered and drills the puzzles you miss.")
                .multilineTextAlignment(.center).font(.subheadline)
            wideButton("Try Plus free") { showPaywall = true }
            Link("Review the reaction summary on organicchemistryguide.com", destination: ReactionChapter.ch11.url).font(.subheadline)
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

    /// Ten puzzles, weakest first, in random order
    private func startRound() {
        let order = mastery.practiceOrder(setID: Self.setID, keys: keys).compactMap(GapQuestion.byID)
        round = Array(order.prefix(roundLength)).shuffled()
        index = 0
        correctCount = 0
        picked = nil
        makeChoices()
    }

    private func makeChoices() {
        guard index < round.count else { return }
        choices = round[index].choices()
    }

    private func answer(_ c: GapQuestion.Choice, for q: GapQuestion) {
        guard picked == nil else { return }
        picked = c
        let right = c == q.answer
        if right { correctCount += 1 }
        mastery.record(q.id, setID: Self.setID, firstTry: right)
    }

    private func next() {
        picked = nil
        index += 1
        if index >= round.count, !plus.isPlus { freeRoundsUsed += 1 }
        makeChoices()
    }
}
