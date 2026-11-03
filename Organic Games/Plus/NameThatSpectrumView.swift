//
//  NameThatSpectrumView.swift
//  Organic Games
//
//  Organic Games Plus: identify the functional group from a generic IR spectrum (4 choices).
//  A miss shows the answer, highlights the giveaway peaks and explains them. Rounds of 10, weakest first.
//  Without Plus, the first round is a free preview.
//

import SwiftUI

struct NameThatSpectrumView: View {
    static let setID = "ir-spectra"
    static let chapterURL = URL(string: "https://organicchemistryguide.com/infrared-spectroscopy/")!
    private let roundLength = 10

    @Environment(\.dismiss) private var dismiss
    @AppStorage("freeRounds.ir-spectra") private var freeRoundsUsed = 0
    private let plus = PlusStore.shared
    private let mastery = MasteryStore.shared

    @State private var round: [IRSpectrum] = []
    @State private var index = 0
    @State private var spectrum: IRSpectrum?
    @State private var choices: [String] = []
    @State private var picked: String?
    @State private var correctCount = 0
    @State private var showPaywall = false

    private var keys: [String] { IRSpectrum.all.map(\.id) }
    private var roundDone: Bool { !round.isEmpty && index >= round.count }
    private var locked: Bool { !plus.isPlus && freeRoundsUsed >= 1 }

    var body: some View {
        VStack(spacing: 14) {
            if round.isEmpty && locked {   // came back after using the free round
                lockedCard
            } else if roundDone {
                summary
            } else if let spectrum {
                question(spectrum)
            }
        }
        .padding()
        .frame(maxWidth: 700, maxHeight: .infinity, alignment: .top)
        .frame(maxWidth: .infinity)
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Name That Spectrum")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showPaywall) { NavigationStack { PlusPaywall() } }
        .onAppear { if round.isEmpty && !locked { startRound() } }
        .onChange(of: plus.isPlus) { _, isPlus in if isPlus && round.isEmpty { startRound() } }
    }

    // MARK: Question

    private func question(_ s: IRSpectrum) -> some View {
        VStack(spacing: 14) {
            HStack {
                Text("\(index + 1) of \(round.count)").font(.subheadline.bold()).foregroundStyle(.secondary)
                Spacer()
                Label("\(correctCount)", systemImage: "checkmark.circle.fill")
                    .font(.subheadline.bold()).foregroundStyle(.green)
                    .accessibilityLabel("\(correctCount) correct")
            }
            SpectrumView(spectrum: s, showHighlight: picked != nil && picked != s.id)
                .frame(height: 230)
                .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
            Text("Which functional group?")
                .font(.headline)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(choices, id: \.self) { choice in
                    Button { answer(choice) } label: {
                        Text(choice)
                            .font(.body.weight(.semibold))
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, minHeight: 56)
                            .padding(.horizontal, 6)
                            .foregroundStyle(foreground(for: choice, answer: s.id))
                            .background(RoundedRectangle(cornerRadius: 12).fill(background(for: choice, answer: s.id)))
                    }
                    .buttonStyle(.plain)   // taps after answering are ignored in answer(), so colours stay full strength
                }
            }
            if let picked {
                feedback(picked: picked, answer: s)
                Button {
                    next()
                } label: {
                    Text(index + 1 < round.count ? "Next" : "Finish round")
                        .font(.headline).frame(maxWidth: .infinity, minHeight: 48)
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
            }
            Spacer(minLength: 0)
        }
    }

    private func feedback(picked: String, answer s: IRSpectrum) -> some View {
        let right = picked == s.id
        return VStack(alignment: .leading, spacing: 6) {
            Label(right ? "Correct!" : "It's \(s.id).", systemImage: right ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.headline)
                .foregroundStyle(right ? .green : .red)
            Text(s.hint).font(.subheadline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemGroupedBackground)))
    }

    private func background(for choice: String, answer: String) -> Color {
        guard let picked else { return Color(.secondarySystemGroupedBackground) }
        if choice == answer { return .green }
        if choice == picked { return .red }
        return Color(.secondarySystemGroupedBackground)
    }

    private func foreground(for choice: String, answer: String) -> Color {
        guard picked != nil, choice == answer || choice == picked else { return .primary }
        return .white
    }

    // MARK: Summary and locked states

    private var summary: some View {
        VStack(spacing: 16) {
            Image(systemName: correctCount >= round.count - 2 ? "star.circle.fill" : "checkmark.seal.fill")
                .font(.system(size: 56)).foregroundStyle(.orange)
            Text("\(correctCount) of \(round.count) right").font(.title.bold())
            Text("Mastered \(mastery.masteredCount(setID: Self.setID, keys: keys)) of \(keys.count) spectra")
                .font(.headline).foregroundStyle(.secondary)
            ProgressView(value: Double(mastery.masteredCount(setID: Self.setID, keys: keys)), total: Double(keys.count))
                .tint(.orange)
            if plus.isPlus {
                wideButton("Next round") { startRound() }
            } else {
                Text("That was your free round. Organic Games Plus keeps the practice going and focuses on the spectra you miss.")
                    .multilineTextAlignment(.center).font(.subheadline)
                wideButton("Try Plus free") { showPaywall = true }
            }
            Link("Review IR on organicchemistryguide.com", destination: Self.chapterURL)
                .font(.subheadline)
            Button("Back to games") { dismiss() }
                .font(.subheadline)
            Spacer(minLength: 0)
        }
        .padding(.top, 30)
    }

    private var lockedCard: some View {
        VStack(spacing: 16) {
            Image(systemName: "lock.circle.fill").font(.system(size: 56)).foregroundStyle(.orange)
            Text("Keep practicing with Plus").font(.title2.bold())
            Text("You've used your free round of Name That Spectrum. Plus unlocks every round, tracks what you've mastered and drills the spectra you miss.")
                .multilineTextAlignment(.center).font(.subheadline)
            wideButton("Try Plus free") { showPaywall = true }
            Link("Review IR on organicchemistryguide.com", destination: Self.chapterURL).font(.subheadline)
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

    private func startRound() {
        let order = mastery.practiceOrder(setID: Self.setID, keys: keys)
        let byID = Dictionary(uniqueKeysWithValues: IRSpectrum.all.map { ($0.id, $0) })
        // Ten questions, weakest first; with only 12 spectra there are no repeats in a round
        round = order.prefix(roundLength).compactMap { byID[$0] }.shuffled()
        index = 0
        correctCount = 0
        show(0)
    }

    private func show(_ i: Int) {
        picked = nil
        guard i < round.count else { spectrum = nil; return }
        let s = round[i].varied()
        spectrum = s
        let others = keys.filter { $0 != s.id }.shuffled().prefix(3)
        choices = (Array(others) + [s.id]).shuffled()
    }

    private func answer(_ choice: String) {
        guard let s = spectrum, picked == nil else { return }
        picked = choice
        let right = choice == s.id
        if right { correctCount += 1 }
        mastery.record(s.id, setID: Self.setID, firstTry: right)
    }

    private func next() {
        index += 1
        if index >= round.count {
            spectrum = nil
            if !plus.isPlus { freeRoundsUsed += 1 }
        } else {
            show(index)
        }
    }
}
