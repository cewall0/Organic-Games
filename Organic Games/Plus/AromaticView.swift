//
//  AromaticView.swift
//  Organic Games
//
//  Organic Games Plus, Ch. 21 aromatic reactions.
//  Benzene Roadmap: the book's 21.20 roadmap, one arrow at a time. Chad's start and product drawings with the
//  reagents missing (wrong answers are the rival reagents from the 21.18 summary), and for the product letters
//  (K, L, M, U) where the new group goes: ortho and para, meta, or no reaction.
//  Director Blitz: a substituted benzene from the book; is the group an o,p activator, an o,p deactivator (the
//  halogens) or a meta deactivator? A right answer moves straight on; a wrong one stops to explain.
//  Both: rounds of 10, weakest first. Without Plus, the first round is free.
//

import SwiftUI

// MARK: Benzene Roadmap

struct RoadmapQuestion: Identifiable {
    let id: String          // "21.20A"
    let start: String
    let product: String?    // nil: the question is where the new group goes
    var reagents: String? = nil
    let answer: String
    let traps: [String]
    let why: String

    static let orthoPara = "Ortho and para", meta = "Meta", noReaction = "No reaction"

    var prompt: String { product == nil ? "Where does the new group go?" : "Which reagents?" }
    func choices() -> [String] { ([answer] + traps.prefix(3)).shuffled() }
    static func byID(_ id: String) -> RoadmapQuestion? { all.first { $0.id == id } }

    private static func sandmeyer(_ letter: String, _ product: String, _ answer: String, _ traps: [String], _ why: String) -> RoadmapQuestion {
        RoadmapQuestion(id: "21.20\(letter)", start: "arom-diazonium", product: product, answer: answer, traps: traps, why: why)
    }
    private static func position(_ letter: String, _ start: String, _ reagents: String, _ answer: String, _ why: String) -> RoadmapQuestion {
        RoadmapQuestion(id: "21.20\(letter)", start: start, product: nil, reagents: reagents, answer: answer,
                        traps: [orthoPara, meta, noReaction].filter { $0 != answer }, why: why)
    }

    static let all: [RoadmapQuestion] = [
        RoadmapQuestion(id: "21.20A", start: "arom-benzene", product: "arom-bromo", answer: "Br₂, FeBr₃",
                        traps: ["Br₂, hν", "NBS, hν", "HBr"],
                        why: "FeBr₃ makes Br₂ electrophilic enough (Br⁺) to attack the aromatic ring. Light makes Br radicals, which only brominate side chains, and benzene has none."),
        RoadmapQuestion(id: "21.20B", start: "arom-benzene", product: "arom-chloro", answer: "Cl₂, AlCl₃",
                        traps: ["3 Cl₂, heat or hν", "HCl", "Cl₂, H₂O"],
                        why: "AlCl₃ activates Cl₂ for electrophilic aromatic substitution. With heat or light, three Cl₂ add across the ring instead, giving hexachlorocyclohexane."),
        RoadmapQuestion(id: "21.20C", start: "arom-benzene", product: "arom-nitro", answer: "HNO₃, H₂SO₄",
                        traps: ["SO₃, H₂SO₄", "NaNO₂, HCl", "1) Fe, HCl\n2) OH⁻"],
                        why: "H₂SO₄ protonates HNO₃, which loses water to give the nitronium ion, NO₂⁺, the electrophile."),
        RoadmapQuestion(id: "21.20D", start: "arom-benzene", product: "arom-sulfonic", answer: "SO₃, H₂SO₄",
                        traps: ["HNO₃, H₂SO₄", "H⁺, H₂O, heat", "1) KMnO₄\n2) H⁺"],
                        why: "Fuming sulfuric acid (SO₃ in H₂SO₄) adds SO₃H. The reaction is reversible: H⁺ and water with heat take the SO₃H back off."),
        RoadmapQuestion(id: "21.20E", start: "arom-benzene", product: "arom-ethyl", answer: "CH₃CH₂Cl, AlCl₃",
                        traps: ["CH₃COCl, AlCl₃", "CH₃CH₂Cl", "CH₃CH₂OH"],
                        why: "Friedel–Crafts alkylation: AlCl₃ pulls off Cl⁻ to make the ethyl electrophile. Without the Lewis acid nothing happens; CH₃COCl would give the ketone."),
        RoadmapQuestion(id: "21.20F", start: "arom-benzene", product: "arom-acetophenone", answer: "CH₃COCl, AlCl₃",
                        traps: ["CH₃CH₂Cl, AlCl₃", "CO, HCl,\nAlCl₃, CuCl", "CH₃COCl"],
                        why: "Friedel–Crafts acylation: AlCl₃ turns the acid chloride into an acylium ion. CO/HCl (Gatterman–Koch) would give the aldehyde instead."),
        RoadmapQuestion(id: "21.20G", start: "arom-benzene", product: "arom-benzaldehyde", answer: "CO, HCl,\nAlCl₃, CuCl",
                        traps: ["CH₃COCl, AlCl₃", "CH₃CH₂Cl, AlCl₃", "1) KMnO₄\n2) H⁺"],
                        why: "Gatterman–Koch formylation adds CHO. HCOCl is too unstable to use in a Friedel–Crafts acylation, so CO and HCl make the formyl electrophile in place."),
        RoadmapQuestion(id: "21.20H", start: "arom-acetophenone", product: "arom-ethyl", answer: "Zn(Hg), HCl",
                        traps: ["3 H₂, 1000 psi,\nmetal catalyst", "Na, NH₃, CH₃OH", "1) KMnO₄\n2) H⁺"],
                        why: "The Clemmensen reduction turns the C=O into CH₂. High-pressure hydrogenation would reduce the ring too, and Birch reduction attacks the ring."),
        RoadmapQuestion(id: "21.20I", start: "arom-nitro", product: "arom-aniline", answer: "1) Fe, HCl\n2) OH⁻",
                        traps: ["NaNO₂, HCl", "NH₃", "NaNH₂"],
                        why: "Iron and acid reduce NO₂ to NH₃⁺; base frees the amine, aniline. NaNO₂/HCl is the next step, aniline to the diazonium salt."),
        RoadmapQuestion(id: "21.20J", start: "arom-aniline", product: "arom-diazonium", answer: "NaNO₂, HCl",
                        traps: ["HNO₃, H₂SO₄", "1) Fe, HCl\n2) OH⁻", "CuCl"],
                        why: "Nitrous acid (from NaNO₂ and HCl) turns ArNH₂ into the diazonium salt, ArN₂⁺ Cl⁻, which sets up the Sandmeyer reactions."),
        sandmeyer("N", "arom-arbr", "CuBr", ["CuCl", "CuCN", "HBF₄"],
                  "Sandmeyer: CuBr replaces N₂ with Br. Each copper salt delivers its own group."),
        sandmeyer("O", "arom-arcl", "CuCl", ["CuBr", "CuCN", "KI"],
                  "Sandmeyer: CuCl replaces N₂ with Cl."),
        sandmeyer("S", "arom-arcn", "CuCN", ["CuCl", "CuBr", "KI"],
                  "Sandmeyer: CuCN replaces N₂ with CN, a benzonitrile."),
        sandmeyer("P", "arom-arf", "HBF₄", ["CuCl", "KI", "H₃PO₂"],
                  "Fluoride comes from HBF₄: the diazonium tetrafluoroborate loses N₂ and BF₃ on heating, leaving Ar–F."),
        sandmeyer("Q", "arom-ari", "KI", ["CuCl", "HBF₄", "I₂"],
                  "Iodide is a good enough nucleophile that KI alone replaces N₂; no copper is needed."),
        sandmeyer("R", "arom-aroh", "H₃O⁺", ["NaOH", "H₃PO₂", "HBF₄"],
                  "Warm acidic water replaces N₂ with OH, a phenol."),
        sandmeyer("T", "arom-benzene2", "H₃PO₂", ["H₃O⁺", "KI", "HBF₄"],
                  "Hypophosphorous acid replaces N₂ with H. That makes NH₂ (and NO₂ before it) a temporary directing group that can be removed."),
        RoadmapQuestion(id: "21.20V", start: "arom-benzene2", product: "arom-diene", answer: "Na, NH₃, CH₃OH",
                        traps: ["3 H₂, 1000 psi,\nmetal catalyst", "H₂, Lindlar catalyst", "Zn(Hg), HCl"],
                        why: "The Birch reduction adds two H's to opposite carbons, giving 1,4-cyclohexadiene. High-pressure hydrogenation goes all the way to cyclohexane; Lindlar's catalyst doesn't touch benzene."),
        position("K", "arom-ethyl", "HNO₃\nH₂SO₄", orthoPara,
                 "An ethyl group donates electrons (hyperconjugation), so it activates the ring and directs ortho and para."),
        position("L", "arom-acetophenone", "Cl₂\nAlCl₃", meta,
                 "The carbonyl carbon attached to the ring is δ+, so the acetyl group deactivates the ring and directs meta."),
        position("M", "arom-benzaldehyde", "CH₃CH₂Cl\nAlCl₃", noReaction,
                 "Friedel–Crafts reactions fail on rings with a deactivating group like CHO, so there's no reaction."),
        position("U", "arom-arcl", "HNO₃\nH₂SO₄", orthoPara,
                 "Chlorine deactivates the ring (it pulls electrons inductively) but its lone pairs donate by resonance, so it directs ortho and para."),
    ]
}

struct BenzeneRoadmapView: View {
    static let setID = "aromatic-roadmap"
    static let chapterURL = URL(string: "https://organicchemistryguide.com/aromatic-reaction-summary/")!
    private let roundLength = 10

    @Environment(\.dismiss) private var dismiss
    @AppStorage("freeRounds.aromatic-roadmap") private var freeRoundsUsed = 0
    private let plus = PlusStore.shared
    private let mastery = MasteryStore.shared

    @State private var round: [RoadmapQuestion] = []
    @State private var choices: [String] = []
    @State private var index = 0
    @State private var picked: String?
    @State private var correctCount = 0
    @State private var showPaywall = false

    private var keys: [String] { RoadmapQuestion.all.map(\.id) }
    private var roundDone: Bool { !round.isEmpty && index >= round.count }
    private var locked: Bool { !plus.isPlus && freeRoundsUsed >= 1 }

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                if round.isEmpty && locked {   // came back after using the free round
                    PlusLockedCard(title: "Benzene Roadmap", things: "steps", chapterURL: Self.chapterURL) { showPaywall = true }
                } else if roundDone {
                    PlusRoundSummary(correct: correctCount, total: round.count, setID: Self.setID, keys: keys, things: "steps",
                                     isPlus: plus.isPlus, chapterLabel: "Review the Ch. 21 summary in the free textbook",
                                     chapterURL: Self.chapterURL, next: startRound, paywall: { showPaywall = true }, back: { dismiss() })
                } else if index < round.count {
                    question(round[index])
                }
            }
            .padding()
            .frame(maxWidth: 700)
            .frame(maxWidth: .infinity)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Benzene Roadmap")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showPaywall) { NavigationStack { PlusPaywall() } }
        .onAppear { if round.isEmpty && !locked { startRound() } }
        .onChange(of: plus.isPlus) { _, isPlus in if isPlus && round.isEmpty { startRound() } }
    }

    private func question(_ q: RoadmapQuestion) -> some View {
        VStack(spacing: 14) {
            HStack {
                Text("\(index + 1) of \(round.count)").font(.subheadline.bold()).foregroundStyle(.secondary)
                Spacer()
                Label("\(correctCount)", systemImage: "checkmark.circle.fill")
                    .font(.subheadline.bold()).foregroundStyle(.green)
                    .accessibilityLabel("\(correctCount) correct")
            }
            HStack(spacing: 8) {
                StructureImage(name: q.start, label: "Starting material")
                ReagentArrow(reagentsImage: nil, label: q.reagents ?? "", reagentsText: q.reagents)
                if let product = q.product {
                    StructureImage(name: product, label: "Product")
                } else {
                    Text("?").font(.largeTitle.bold()).foregroundStyle(.orange).frame(minWidth: 50)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 90)
            .paperCard()
            .shadow(color: .black.opacity(0.08), radius: 4, y: 2)

            Text(q.prompt).font(.headline)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(choices, id: \.self) { c in
                    Button { answer(c, for: q) } label: {
                        Text(c).font(.body.weight(.semibold)).multilineTextAlignment(.center).foregroundStyle(.black)
                            .minimumScaleFactor(0.8)
                            .frame(maxWidth: .infinity, minHeight: 64)
                            .paperCard(highlight: highlight(c, answer: q.answer))
                    }
                    .buttonStyle(.plain)
                }
            }
            if let picked {
                let right = picked == q.answer
                VStack(alignment: .leading, spacing: 6) {
                    Label(right ? "Correct!" : q.answer.replacingOccurrences(of: "\n", with: " "),
                          systemImage: right ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.headline).foregroundStyle(right ? .green : .red)
                    Text(q.why).font(.subheadline)
                    Text("Problem 21.20, letter \(q.id.suffix(1))").font(.caption).foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemGroupedBackground)))
                PlusWideButton(title: index + 1 < round.count ? "Next" : "Finish round") { next() }
            }
        }
    }

    private func highlight(_ c: String, answer: String) -> Color? {
        guard let picked else { return nil }
        if c == answer { return .green }
        if c == picked { return .red }
        return nil
    }

    private func startRound() {
        let order = mastery.practiceOrder(setID: Self.setID, keys: keys).compactMap(RoadmapQuestion.byID)
        round = Array(order.prefix(roundLength)).shuffled()
        index = 0
        correctCount = 0
        picked = nil
        choices = round.first?.choices() ?? []
    }

    private func answer(_ c: String, for q: RoadmapQuestion) {
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
        if index < round.count { choices = round[index].choices() }
    }
}

// MARK: Director Blitz

enum DirectorKind: String, CaseIterable {
    case opActivating, opDeactivating, metaDeactivating

    var label: String {
        switch self {
        case .opActivating: return "o,p · activating"
        case .opDeactivating: return "o,p · deactivating"
        case .metaDeactivating: return "meta · deactivating"
        }
    }
}

struct DirectorQuestion: Identifiable {
    let id: String          // image name
    let group: String
    let kind: DirectorKind
    let why: String

    static func byID(_ id: String) -> DirectorQuestion? { all.first { $0.id == id } }

    private static let halogen = "Halogens pull electrons out through the σ bond, so they deactivate the ring, but their lone pairs donate by resonance to the ortho and para positions."
    private static let carbonyl = "The ring is bonded to a δ+ carbonyl carbon, which pulls electrons out of the ring by resonance. Ortho or para attack would put the + charge next to it, so it directs meta."

    static let all: [DirectorQuestion] = [
        DirectorQuestion(id: "arom-bromo", group: "–Br", kind: .opDeactivating, why: halogen),
        DirectorQuestion(id: "arom-chloro", group: "–Cl", kind: .opDeactivating, why: halogen),
        DirectorQuestion(id: "arom-ari", group: "–I", kind: .opDeactivating, why: halogen),
        DirectorQuestion(id: "arom-arf", group: "–F", kind: .opDeactivating, why: halogen),
        DirectorQuestion(id: "arom-nitro", group: "–NO₂", kind: .metaDeactivating,
                         why: "The nitrogen bonded to the ring carries a + charge and pulls electrons out by resonance: a strong deactivator that directs meta."),
        DirectorQuestion(id: "arom-sulfonic", group: "–SO₃H", kind: .metaDeactivating,
                         why: "The sulfur bonded to the ring is strongly δ+ (three S=O/S–O bonds), so it deactivates and directs meta."),
        DirectorQuestion(id: "arom-arcn", group: "–CN", kind: .metaDeactivating,
                         why: "The nitrile carbon is δ+ and pulls electrons out by resonance, so it deactivates and directs meta."),
        DirectorQuestion(id: "arom-acetophenone", group: "–COCH₃", kind: .metaDeactivating, why: carbonyl),
        DirectorQuestion(id: "arom-benzaldehyde", group: "–CHO", kind: .metaDeactivating, why: carbonyl),
        DirectorQuestion(id: "arom-benzoic", group: "–CO₂H", kind: .metaDeactivating, why: carbonyl),
        DirectorQuestion(id: "arom-mebenzoate", group: "–CO₂CH₃", kind: .metaDeactivating,
                         why: carbonyl + " Compare phenyl acetate, where the ring is bonded to the oxygen instead."),
        DirectorQuestion(id: "arom-ethyl", group: "–CH₂CH₃", kind: .opActivating,
                         why: "Alkyl groups donate electrons (hyperconjugation), stabilizing the cation from ortho or para attack: a weak activator."),
        DirectorQuestion(id: "arom-aniline", group: "–NH₂", kind: .opActivating,
                         why: "The nitrogen lone pair donates into the ring by resonance: a strong activator that directs ortho and para."),
        DirectorQuestion(id: "arom-aroh", group: "–OH", kind: .opActivating,
                         why: "An oxygen lone pair donates into the ring by resonance: a strong activator that directs ortho and para."),
        DirectorQuestion(id: "arom-acetanilide", group: "–NHCOCH₃", kind: .opActivating,
                         why: "The nitrogen lone pair still donates into the ring, though it's shared with the C=O, so it's a moderate activator. It stays o,p-directing in acid, where –NH₂ would be protonated."),
        DirectorQuestion(id: "arom-phenylacetate", group: "–OCOCH₃", kind: .opActivating,
                         why: "The ring is bonded to the oxygen, whose lone pair donates by resonance, so it activates and directs ortho and para. Compare methyl benzoate, where the ring is bonded to the carbonyl carbon."),
    ]
}

struct DirectorBlitzView: View {
    static let setID = "aromatic-directors"
    static let chapterURL = URL(string: "https://organicchemistryguide.com/activating-groups/")!
    private let roundLength = 10

    @Environment(\.dismiss) private var dismiss
    @AppStorage("freeRounds.aromatic-directors") private var freeRoundsUsed = 0
    private let plus = PlusStore.shared
    private let mastery = MasteryStore.shared

    @State private var round: [DirectorQuestion] = []
    @State private var index = 0
    @State private var picked: DirectorKind?
    @State private var correctCount = 0
    @State private var showPaywall = false

    private var keys: [String] { DirectorQuestion.all.map(\.id) }
    private var roundDone: Bool { !round.isEmpty && index >= round.count }
    private var locked: Bool { !plus.isPlus && freeRoundsUsed >= 1 }

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                if round.isEmpty && locked {
                    PlusLockedCard(title: "Director Blitz", things: "groups", chapterURL: Self.chapterURL) { showPaywall = true }
                } else if roundDone {
                    PlusRoundSummary(correct: correctCount, total: round.count, setID: Self.setID, keys: keys, things: "groups",
                                     isPlus: plus.isPlus, chapterLabel: "Review activating groups (Ch. 21) in the free textbook",
                                     chapterURL: Self.chapterURL, next: startRound, paywall: { showPaywall = true }, back: { dismiss() })
                } else if index < round.count {
                    question(round[index])
                }
            }
            .padding()
            .frame(maxWidth: 700)
            .frame(maxWidth: .infinity)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Director Blitz")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showPaywall) { NavigationStack { PlusPaywall() } }
        .onAppear { if round.isEmpty && !locked { startRound() } }
        .onChange(of: plus.isPlus) { _, isPlus in if isPlus && round.isEmpty { startRound() } }
    }

    private func question(_ q: DirectorQuestion) -> some View {
        VStack(spacing: 14) {
            HStack {
                Text("\(index + 1) of \(round.count)").font(.subheadline.bold()).foregroundStyle(.secondary)
                Spacer()
                Label("\(correctCount)", systemImage: "checkmark.circle.fill")
                    .font(.subheadline.bold()).foregroundStyle(.green)
                    .accessibilityLabel("\(correctCount) correct")
            }
            StructureImage(name: q.id, scale: 1.3, label: "Benzene with \(q.group)")
                .frame(maxWidth: .infinity, minHeight: 150)
                .paperCard()
                .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
            Text("What does \(q.group) do?").font(.headline)
            VStack(spacing: 10) {
                ForEach(DirectorKind.allCases, id: \.self) { k in
                    Button { answer(k, for: q) } label: {
                        Text(k.label).font(.title3.weight(.semibold)).foregroundStyle(.black)
                            .frame(maxWidth: .infinity, minHeight: 52)
                            .paperCard(highlight: highlight(k, answer: q.kind))
                    }
                    .buttonStyle(.plain)
                }
            }
            // Right answers move on by themselves; a miss stops to explain
            if let picked, picked != q.kind {
                VStack(alignment: .leading, spacing: 6) {
                    Label(q.kind.label, systemImage: "xmark.circle.fill").font(.headline).foregroundStyle(.red)
                    Text(q.why).font(.subheadline)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemGroupedBackground)))
                PlusWideButton(title: index + 1 < round.count ? "Next" : "Finish round") { next() }
            }
        }
    }

    private func highlight(_ k: DirectorKind, answer: DirectorKind) -> Color? {
        guard let picked else { return nil }
        if k == answer { return .green }
        if k == picked { return .red }
        return nil
    }

    private func startRound() {
        let order = mastery.practiceOrder(setID: Self.setID, keys: keys).compactMap(DirectorQuestion.byID)
        round = Array(order.prefix(roundLength)).shuffled()
        index = 0
        correctCount = 0
        picked = nil
    }

    private func answer(_ k: DirectorKind, for q: DirectorQuestion) {
        guard picked == nil else { return }
        picked = k
        let right = k == q.kind
        if right {
            correctCount += 1
            let current = index
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) { if index == current { next() } }
        }
        mastery.record(q.id, setID: Self.setID, firstTry: right)
    }

    private func next() {
        picked = nil
        index += 1
        if index >= round.count, !plus.isPlus { freeRoundsUsed += 1 }
    }
}

// MARK: Shared pieces for these two games

private struct PlusWideButton: View {
    let title: String
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(title).font(.headline).frame(maxWidth: .infinity, minHeight: 48)
        }
        .buttonStyle(.borderedProminent)
        .tint(.orange)
    }
}

private struct PlusRoundSummary: View {
    let correct: Int
    let total: Int
    let setID: String
    let keys: [String]
    let things: String
    let isPlus: Bool
    let chapterLabel: String
    let chapterURL: URL
    let next: () -> Void
    let paywall: () -> Void
    let back: () -> Void

    var body: some View {
        let done = MasteryStore.shared.masteredCount(setID: setID, keys: keys)
        VStack(spacing: 16) {
            Image(systemName: correct >= total - 2 ? "star.circle.fill" : "checkmark.seal.fill")
                .font(.system(size: 56)).foregroundStyle(.orange)
            Text("\(correct) of \(total) right").font(.title.bold())
            Text("Mastered \(done) of \(keys.count) \(things)").font(.headline).foregroundStyle(.secondary)
            ProgressView(value: Double(done), total: Double(keys.count)).tint(.orange)
            if isPlus {
                PlusWideButton(title: "Next round", action: next)
            } else {
                Text("That was your free round. Organic Games Plus keeps the practice going and focuses on the \(things) you miss.")
                    .multilineTextAlignment(.center).font(.subheadline)
                PlusWideButton(title: "Try Plus free", action: paywall)
            }
            Link(chapterLabel, destination: chapterURL).font(.subheadline)
            Button("Back to games", action: back).font(.subheadline)
        }
        .padding(.top, 30)
    }
}

private struct PlusLockedCard: View {
    let title: String
    let things: String
    let chapterURL: URL
    let paywall: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "lock.circle.fill").font(.system(size: 56)).foregroundStyle(.orange)
            Text("Keep practicing with Plus").font(.title2.bold())
            Text("You've used your free round of \(title). Plus unlocks every round, tracks what you've mastered and drills the \(things) you miss.")
                .multilineTextAlignment(.center).font(.subheadline)
            PlusWideButton(title: "Try Plus free", action: paywall)
            Link("Review Ch. 21 in the free textbook", destination: chapterURL).font(.subheadline)
        }
        .padding(.top, 40)
    }
}
