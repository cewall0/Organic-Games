//
//  NameThatPatternView.swift
//  Organic Games
//
//  Organic Games Plus: which special atom does this mass spectrum show? (Br, Cl, I, S, N or only C, H, O)
//  Real compounds, name hidden until answered. A miss highlights the giveaway peaks and explains them.
//  Rounds of 10, weakest atoms first. Without Plus, the first round is a free preview.
//

import SwiftUI

struct NameThatPatternView: View {
    static let setID = "ms-patterns"
    static let chapterURL = URL(string: "https://organicchemistryguide.com/mass-spectrometry/")!
    private let roundLength = 10

    @Environment(\.dismiss) private var dismiss
    @AppStorage("freeRounds.ms-patterns") private var freeRoundsUsed = 0
    private let plus = PlusStore.shared
    private let mastery = MasteryStore.shared

    @State private var round: [MSCompound] = []
    @State private var index = 0
    @State private var picked: MSAtom?
    @State private var correctCount = 0
    @State private var showPaywall = false

    private var keys: [String] { MSAtom.allCases.map(\.rawValue) }
    private var roundDone: Bool { !round.isEmpty && index >= round.count }
    private var locked: Bool { !plus.isPlus && freeRoundsUsed >= 1 }

    var body: some View {
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
        .frame(maxWidth: 700, maxHeight: .infinity, alignment: .top)
        .frame(maxWidth: .infinity)
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Name That Pattern")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showPaywall) { NavigationStack { PlusPaywall() } }
        .onAppear { if round.isEmpty && !locked { startRound() } }
        .onChange(of: plus.isPlus) { _, isPlus in if isPlus && round.isEmpty { startRound() } }
    }

    // MARK: Question

    private func question(_ c: MSCompound) -> some View {
        VStack(spacing: 14) {
            HStack {
                Text("\(index + 1) of \(round.count)").font(.subheadline.bold()).foregroundStyle(.secondary)
                Spacer()
                Label("\(correctCount)", systemImage: "checkmark.circle.fill")
                    .font(.subheadline.bold()).foregroundStyle(.green)
                    .accessibilityLabel("\(correctCount) correct")
            }
            MassSpectrumView(compound: c, showHighlight: picked != nil && picked != c.atom)
                .frame(height: 240)
                .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
            Text("Which special atom does it contain?")
                .font(.headline)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(MSAtom.allCases) { atom in
                    Button { answer(atom, for: c) } label: {
                        Text(atom.rawValue)
                            .font(.body.weight(.semibold))
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, minHeight: 52)
                            .padding(.horizontal, 4)
                            .foregroundStyle(foreground(atom, answer: c.atom))
                            .background(RoundedRectangle(cornerRadius: 12).fill(background(atom, answer: c.atom)))
                    }
                    .buttonStyle(.plain)   // taps after answering are ignored in answer()
                }
            }
            if let picked {
                VStack(alignment: .leading, spacing: 6) {
                    Label(picked == c.atom ? "Correct! It's \(c.name)." : "It's \(c.atom.rawValue) – \(c.name).",
                          systemImage: picked == c.atom ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.headline)
                        .foregroundStyle(picked == c.atom ? .green : .red)
                    Text(c.atom.hint).font(.subheadline)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemGroupedBackground)))
                Button { next() } label: {
                    Text(index + 1 < round.count ? "Next" : "Finish round")
                        .font(.headline).frame(maxWidth: .infinity, minHeight: 48)
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
            }
            Spacer(minLength: 0)
        }
    }

    private func background(_ atom: MSAtom, answer: MSAtom) -> Color {
        guard let picked else { return Color(.secondarySystemGroupedBackground) }
        if atom == answer { return .green }
        if atom == picked { return .red }
        return Color(.secondarySystemGroupedBackground)
    }

    private func foreground(_ atom: MSAtom, answer: MSAtom) -> Color {
        guard picked != nil, atom == answer || atom == picked else { return .primary }
        return .white
    }

    // MARK: Summary and locked

    private var summary: some View {
        let done = mastery.masteredCount(setID: Self.setID, keys: keys)
        return VStack(spacing: 16) {
            Image(systemName: correctCount >= round.count - 2 ? "star.circle.fill" : "checkmark.seal.fill")
                .font(.system(size: 56)).foregroundStyle(.orange)
            Text("\(correctCount) of \(round.count) right").font(.title.bold())
            Text("Mastered \(done) of \(keys.count) patterns").font(.headline).foregroundStyle(.secondary)
            ProgressView(value: Double(done), total: Double(keys.count)).tint(.orange)
            if plus.isPlus {
                wideButton("Next round") { startRound() }
            } else {
                Text("That was your free round. Organic Games Plus keeps the practice going and focuses on the patterns you miss.")
                    .multilineTextAlignment(.center).font(.subheadline)
                wideButton("Try Plus free") { showPaywall = true }
            }
            Link("Review mass spec on organicchemistryguide.com", destination: Self.chapterURL).font(.subheadline)
            Button("Back to games") { dismiss() }.font(.subheadline)
            Spacer(minLength: 0)
        }
        .padding(.top, 30)
    }

    private var lockedCard: some View {
        VStack(spacing: 16) {
            Image(systemName: "lock.circle.fill").font(.system(size: 56)).foregroundStyle(.orange)
            Text("Keep practicing with Plus").font(.title2.bold())
            Text("You've used your free round of Name That Pattern. Plus unlocks every round, tracks what you've mastered and drills the patterns you miss.")
                .multilineTextAlignment(.center).font(.subheadline)
            wideButton("Try Plus free") { showPaywall = true }
            Link("Review mass spec on organicchemistryguide.com", destination: Self.chapterURL).font(.subheadline)
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

    /// Ten questions: the six atoms weakest first, then again, each with a different real compound.
    private func startRound() {
        let order = mastery.practiceOrder(setID: Self.setID, keys: keys).compactMap(MSAtom.init(rawValue:))
        var pools = Dictionary(grouping: MSCompound.all, by: \.atom).mapValues { $0.shuffled() }
        var picks: [MSCompound] = []
        while picks.count < roundLength {
            for atom in order where picks.count < roundLength {
                if pools[atom]?.isEmpty ?? true { pools[atom] = MSCompound.all.filter { $0.atom == atom }.shuffled() }
                picks.append(pools[atom]!.removeFirst())
            }
        }
        round = picks.shuffled()
        index = 0
        correctCount = 0
        picked = nil
    }

    private func answer(_ atom: MSAtom, for c: MSCompound) {
        guard picked == nil else { return }
        picked = atom
        if atom == c.atom { correctCount += 1 }
        mastery.record(c.atom.rawValue, setID: Self.setID, firstTry: atom == c.atom)
    }

    private func next() {
        picked = nil
        index += 1
        if index >= round.count, !plus.isPlus { freeRoundsUsed += 1 }
    }
}
