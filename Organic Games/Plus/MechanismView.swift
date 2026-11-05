//
//  MechanismView.swift
//  Organic Games
//
//  Organic Games Plus: Which Mechanism? The book's problems 9.75 a–l (label SN1, SN2, E1 or E2) and 9.23 a–d
//  (E1, E2 or neither), each shown as Chad's whole drawn reaction. Step 1: pick the mechanism. Step 2: which
//  clue decided it (substrate, nucleophile/base, solvent or conditions, product stereochemistry, leaving group).
//  Several clues can decide one reaction; any of them counts, and all are shown after answering. Mastery
//  follows the mechanism answer. Rounds of 10, weakest first. Without Plus, the first round is free.
//

import SwiftUI

enum Mechanism: String, CaseIterable {
    case sn1, sn2, e1, e2, neither

    /// "SN1" with the N as a subscript, as in the book
    var label: Text {
        switch self {
        case .sn1, .sn2: return Text("S") + Text("N").font(.caption.bold()).baselineOffset(-4) + Text(self == .sn1 ? "1" : "2")
        case .e1: return Text("E1")
        case .e2: return Text("E2")
        case .neither: return Text("Neither")
        }
    }
    var spoken: String { self == .neither ? "Neither" : rawValue.uppercased() }
}

enum MechanismClue: String, CaseIterable {
    case substrate, nucleophile, conditions, stereo, leavingGroup

    var label: String {
        switch self {
        case .substrate: return "Substrate (1°, 2°, 3°)"
        case .nucleophile: return "Nucleophile or base"
        case .conditions: return "Solvent or conditions"
        case .stereo: return "Product stereochemistry"
        case .leavingGroup: return "Leaving group"
        }
    }
}

struct MechanismQuestion: Identifiable {
    let id: String          // "9.75a"
    let image: String
    let answer: Mechanism
    let clues: Set<MechanismClue>
    let why: String

    var neitherAllowed: Bool { id.hasPrefix("9.23") }
    var choices: [Mechanism] { neitherAllowed ? [.e1, .e2, .neither] : [.sn1, .sn2, .e1, .e2] }

    static func byID(_ id: String) -> MechanismQuestion? { all.first { $0.id == id } }

    static let all: [MechanismQuestion] = [
        MechanismQuestion(id: "9.75a", image: "mech-m75a", answer: .e2, clues: [.nucleophile, .stereo],
                          why: "NaOEt is a strong base, and only one alkene isomer forms: the one set by the anti-coplanar H and Br. Strong base plus a stereospecific alkene means E2."),
        MechanismQuestion(id: "9.75b", image: "mech-m75b", answer: .sn1, clues: [.substrate, .stereo],
                          why: "The 3° benzylic carbon gives a stable carbocation, and the product is racemic because acetate adds to both faces of the flat cation. That's SN1."),
        MechanismQuestion(id: "9.75c", image: "mech-m75c", answer: .e2, clues: [.nucleophile, .stereo],
                          why: "ᵗBuOK is a strong, bulky base, and only the alkene from the anti-coplanar H and I forms. That's E2."),
        MechanismQuestion(id: "9.75d", image: "mech-m75d", answer: .sn2, clues: [.nucleophile, .conditions, .stereo],
                          why: "Cyanide is a strong nucleophile in a polar aprotic solvent (Me₂SO), tosylate is a great leaving group, and the product is inverted. That's SN2."),
        MechanismQuestion(id: "9.75e", image: "mech-m75e", answer: .e1, clues: [.conditions],
                          why: "H₂SO₄ protonates the OH so it leaves as water, giving a carbocation; losing H⁺ gives the alkene. Acid with no good nucleophile means E1."),
        MechanismQuestion(id: "9.75f", image: "mech-m75f", answer: .e1, clues: [.conditions, .nucleophile],
                          why: "Methanol is only a weak base. With heat the bromide ionizes, and the carbocation loses H⁺ to give the more substituted alkene (Saytzeff). That's E1."),
        MechanismQuestion(id: "9.75g", image: "mech-m75g", answer: .e2, clues: [.nucleophile, .substrate],
                          why: "NaOEt is a strong base, and the 3° bromide is too crowded for SN2. Strong base on a 3° halide means E2."),
        MechanismQuestion(id: "9.75h", image: "mech-m75h", answer: .sn1, clues: [.substrate, .conditions],
                          why: "The 3° bromide ionizes to a stable carbocation, and methanol, the solvent and a weak nucleophile, attacks it. That's SN1."),
        MechanismQuestion(id: "9.75i", image: "mech-m75i", answer: .e1, clues: [.conditions],
                          why: "Acid protonates the OH; water leaves to give an allylic carbocation, which loses H⁺ to form the new C=C. That's E1."),
        MechanismQuestion(id: "9.75j", image: "mech-m75j", answer: .sn2, clues: [.stereo, .nucleophile],
                          why: "Hydroxide attacks from the back side, so the OH ends up on the opposite face from the Br (inversion, the only product). That's SN2."),
        MechanismQuestion(id: "9.75k", image: "mech-m75k", answer: .sn2, clues: [.substrate, .nucleophile],
                          why: "Sulfide is a strong nucleophile and both carbons are 1°. Two SN2 reactions close the ring."),
        MechanismQuestion(id: "9.75l", image: "mech-m75l", answer: .sn1, clues: [.stereo, .conditions],
                          why: "Methanol is a weak nucleophile; the chloride ionizes to a flat carbocation, so the ether forms as a racemate. That's SN1."),
        MechanismQuestion(id: "9.23a", image: "mech-m23a", answer: .e2, clues: [.nucleophile, .substrate],
                          why: "Methoxide is a strong base, and a 3° chloride can't do SN2. That's E2."),
        MechanismQuestion(id: "9.23b", image: "mech-m23b", answer: .e1, clues: [.conditions, .substrate],
                          why: "Water is only a weak base, so the 3° bromide must ionize to a carbocation first. That's E1 (with SN1 competing)."),
        MechanismQuestion(id: "9.23c", image: "mech-m23c", answer: .e1, clues: [.leavingGroup, .conditions],
                          why: "The OH is already protonated, so water leaves easily to give a 3° carbocation, and water is only a weak base. That's E1."),
        MechanismQuestion(id: "9.23d", image: "mech-m23d", answer: .neither, clues: [.leavingGroup],
                          why: "Methoxide (CH₃O⁻) is a poor leaving group, and nothing here protonates it, so there's no reaction."),
    ]
}

struct MechanismView: View {
    static let setID = "mechanism"
    static let chapterURL = URL(string: "https://organicchemistryguide.com/comparison-of-sn1-sn2-e1-e2/")!
    private let roundLength = 10

    @Environment(\.dismiss) private var dismiss
    @AppStorage("freeRounds.mechanism") private var freeRoundsUsed = 0
    private let plus = PlusStore.shared
    private let mastery = MasteryStore.shared

    @State private var round: [MechanismQuestion] = []
    @State private var index = 0
    @State private var picked: Mechanism?
    @State private var pickedClue: MechanismClue?
    @State private var correctCount = 0
    @State private var showPaywall = false

    private var keys: [String] { MechanismQuestion.all.map(\.id) }
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
        .navigationTitle("Which Mechanism?")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showPaywall) { NavigationStack { PlusPaywall() } }
        .onAppear { if round.isEmpty && !locked { startRound() } }
        .onChange(of: plus.isPlus) { _, isPlus in if isPlus && round.isEmpty { startRound() } }
    }

    // MARK: Question

    private func question(_ q: MechanismQuestion) -> some View {
        VStack(spacing: 14) {
            HStack {
                Text("\(index + 1) of \(round.count)").font(.subheadline.bold()).foregroundStyle(.secondary)
                Spacer()
                Label("\(correctCount)", systemImage: "checkmark.circle.fill")
                    .font(.subheadline.bold()).foregroundStyle(.green)
                    .accessibilityLabel("\(correctCount) correct")
            }
            StructureImage(name: q.image, label: "Problem \(q.id) reaction")
                .frame(maxWidth: .infinity, minHeight: 80)
                .paperCard()
                .shadow(color: .black.opacity(0.08), radius: 4, y: 2)

            Text("Which mechanism?").font(.headline)
            HStack(spacing: 10) {
                ForEach(q.choices, id: \.self) { m in
                    Button { pick(m, for: q) } label: {
                        m.label.font(.title3.weight(.bold)).foregroundStyle(.black)
                            .frame(maxWidth: .infinity, minHeight: 56)
                            .paperCard(highlight: mechanismHighlight(m, answer: q.answer))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(m.spoken)
                }
            }

            if let picked {
                let right = picked == q.answer
                Label { right ? Text("Correct!") : Text("It's ") + q.answer.label } icon: {
                    Image(systemName: right ? "checkmark.circle.fill" : "xmark.circle.fill")
                }
                .font(.headline).foregroundStyle(right ? .green : .red)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityLabel(right ? "Correct" : "It's \(q.answer.spoken)")

                Text("Which clue decided it?").font(.headline)
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    ForEach(MechanismClue.allCases, id: \.self) { c in
                        Button { if pickedClue == nil { pickedClue = c } } label: {
                            Text(c.label).font(.subheadline.weight(.semibold)).multilineTextAlignment(.center).foregroundStyle(.black)
                                .frame(maxWidth: .infinity, minHeight: 52)
                                .paperCard(highlight: clueHighlight(c, q: q))
                        }
                        .buttonStyle(.plain)
                    }
                }

                if let pickedClue {
                    let good = q.clues.contains(pickedClue)
                    VStack(alignment: .leading, spacing: 6) {
                        Label(good ? "Good clue" : "Not the deciding clue here", systemImage: good ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .font(.headline).foregroundStyle(good ? .green : .orange)
                        Text(q.why).font(.subheadline)
                        Text("Problem \(q.id)").font(.caption).foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemGroupedBackground)))
                    wideButton(index + 1 < round.count ? "Next" : "Finish round") { next() }
                }
            }
        }
    }

    private func mechanismHighlight(_ m: Mechanism, answer: Mechanism) -> Color? {
        guard let picked else { return nil }
        if m == answer { return .green }
        if m == picked { return .red }
        return nil
    }

    /// After a clue is picked, every deciding clue turns green; a wrong pick turns orange
    private func clueHighlight(_ c: MechanismClue, q: MechanismQuestion) -> Color? {
        guard let pickedClue else { return nil }
        if q.clues.contains(c) { return .green }
        if c == pickedClue { return .orange }
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
                wideButton("See Plus plans") { showPaywall = true }
            }
            Link("Review the Ch. 9 comparison in the free textbook", destination: Self.chapterURL).font(.subheadline)
            Button("Back to games") { dismiss() }.font(.subheadline)
        }
        .padding(.top, 30)
    }

    private var lockedCard: some View {
        VStack(spacing: 16) {
            Image(systemName: "lock.circle.fill").font(.system(size: 56)).foregroundStyle(.orange)
            Text("Keep practicing with Plus").font(.title2.bold())
            Text("You've used your free round of Which Mechanism?. Plus unlocks every round, tracks what you've mastered and drills the reactions you miss.")
                .multilineTextAlignment(.center).font(.subheadline)
            wideButton("See Plus plans") { showPaywall = true }
            Link("Review the Ch. 9 comparison in the free textbook", destination: Self.chapterURL).font(.subheadline)
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
        let order = mastery.practiceOrder(setID: Self.setID, keys: keys).compactMap(MechanismQuestion.byID)
        round = Array(order.prefix(roundLength)).shuffled()
        index = 0
        correctCount = 0
        picked = nil
        pickedClue = nil
    }

    private func pick(_ m: Mechanism, for q: MechanismQuestion) {
        guard picked == nil else { return }
        picked = m
        let right = m == q.answer
        if right { correctCount += 1 }
        mastery.record(q.id, setID: Self.setID, firstTry: right)
    }

    private func next() {
        picked = nil
        pickedClue = nil
        index += 1
        if index >= round.count, !plus.isPlus { freeRoundsUsed += 1 }
    }
}
