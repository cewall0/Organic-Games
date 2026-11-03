//
//  PredictProductView.swift
//  Organic Games
//
//  Organic Games Plus: starting material and reagents from the Ch. 11 reaction summary; pick the product
//  from four drawings. Distractors come from the same starting material when possible and are never the
//  same compound as the answer. Rounds of 10, weakest reactions first. Without Plus, the first round is free.
//

import SwiftUI

struct PredictProductView: View {
    static let setID = "rxn-predict"
    private let roundLength = 10

    @Environment(\.dismiss) private var dismiss
    @AppStorage("freeRounds.rxn-predict") private var freeRoundsUsed = 0
    private let plus = PlusStore.shared
    private let mastery = MasteryStore.shared

    @State private var round: [OrgReaction] = []
    @State private var choices: [OrgReaction] = []
    @State private var index = 0
    @State private var picked: OrgReaction?
    @State private var correctCount = 0
    @State private var showPaywall = false

    private var keys: [String] { OrgReaction.all.map(\.id) }
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
        .navigationTitle("Predict the Product")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showPaywall) { NavigationStack { PlusPaywall() } }
        .onAppear { if round.isEmpty && !locked { startRound() } }
        .onChange(of: plus.isPlus) { _, isPlus in if isPlus && round.isEmpty { startRound() } }
    }

    // MARK: Question

    private func question(_ r: OrgReaction) -> some View {
        VStack(spacing: 14) {
            HStack {
                Text("\(index + 1) of \(round.count)").font(.subheadline.bold()).foregroundStyle(.secondary)
                Spacer()
                Label("\(correctCount)", systemImage: "checkmark.circle.fill")
                    .font(.subheadline.bold()).foregroundStyle(.green)
                    .accessibilityLabel("\(correctCount) correct")
            }
            HStack(spacing: 8) {
                StructureImage(name: r.smImage, label: "Starting material")
                ReagentArrow(reagentsImage: r.reagentsImage, reversible: r.reversible, label: r.reagents)
                // The answer is marked in the choices below; swapping it in here would squeeze the starting material
                Text("?").font(.largeTitle.bold()).foregroundStyle(.orange).frame(minWidth: 50)
            }
            .frame(maxWidth: .infinity, minHeight: 90)
            .paperCard()
            .shadow(color: .black.opacity(0.08), radius: 4, y: 2)

            Text("What's the product?").font(.headline)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(choices) { c in
                    Button { answer(c, for: r) } label: {
                        StructureImage(name: c.productImage, scale: 1.1, label: c.productName)
                            .frame(maxWidth: .infinity, minHeight: 96, maxHeight: 96)
                            .paperCard(highlight: highlight(c, answer: r))
                    }
                    .buttonStyle(.plain)   // taps after answering are ignored in answer()
                }
            }
            if let picked {
                let right = picked.productName == r.productName
                VStack(alignment: .leading, spacing: 6) {
                    Label(right ? "Correct! \(r.name)" : r.name,
                          systemImage: right ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.headline)
                        .foregroundStyle(right ? .green : .red)
                    Text(r.note).font(.subheadline)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemGroupedBackground)))
                wideButton(index + 1 < round.count ? "Next" : "Finish round") { next() }
            }
        }
    }

    private func highlight(_ c: OrgReaction, answer r: OrgReaction) -> Color? {
        guard let picked else { return nil }
        if c.productName == r.productName { return .green }
        if c.id == picked.id { return .red }
        return nil
    }

    // MARK: Summary and locked

    private var summary: some View {
        let done = mastery.masteredCount(setID: Self.setID, keys: keys)
        return VStack(spacing: 16) {
            Image(systemName: correctCount >= round.count - 2 ? "star.circle.fill" : "checkmark.seal.fill")
                .font(.system(size: 56)).foregroundStyle(.orange)
            Text("\(correctCount) of \(round.count) right").font(.title.bold())
            Text("Mastered \(done) of \(keys.count) reactions").font(.headline).foregroundStyle(.secondary)
            ProgressView(value: Double(done), total: Double(keys.count)).tint(.orange)
            if plus.isPlus {
                wideButton("Next round") { startRound() }
            } else {
                Text("That was your free round. Organic Games Plus keeps the practice going and focuses on the reactions you miss.")
                    .multilineTextAlignment(.center).font(.subheadline)
                wideButton("Try Plus free") { showPaywall = true }
            }
            Link("Review the reaction summary on organicchemistryguide.com", destination: OrgReaction.chapterURL).font(.subheadline)
            Button("Back to games") { dismiss() }.font(.subheadline)
        }
        .padding(.top, 30)
    }

    private var lockedCard: some View {
        VStack(spacing: 16) {
            Image(systemName: "lock.circle.fill").font(.system(size: 56)).foregroundStyle(.orange)
            Text("Keep practicing with Plus").font(.title2.bold())
            Text("You've used your free round of Predict the Product. Plus unlocks every round, tracks what you've mastered and drills the reactions you miss.")
                .multilineTextAlignment(.center).font(.subheadline)
            wideButton("Try Plus free") { showPaywall = true }
            Link("Review the reaction summary on organicchemistryguide.com", destination: OrgReaction.chapterURL).font(.subheadline)
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

    /// Ten reactions, weakest first, in random order
    private func startRound() {
        let order = mastery.practiceOrder(setID: Self.setID, keys: keys).compactMap(OrgReaction.byID)
        round = Array(order.prefix(roundLength)).shuffled()
        index = 0
        correctCount = 0
        picked = nil
        makeChoices()
    }

    private func makeChoices() {
        guard index < round.count else { return }
        let r = round[index]
        choices = ([r] + r.distractors(3)).shuffled()
    }

    private func answer(_ c: OrgReaction, for r: OrgReaction) {
        guard picked == nil else { return }
        picked = c
        let right = c.productName == r.productName
        if right { correctCount += 1 }
        mastery.record(r.id, setID: Self.setID, firstTry: right)
    }

    private func next() {
        picked = nil
        index += 1
        if index >= round.count, !plus.isPlus { freeRoundsUsed += 1 }
        makeChoices()
    }
}
