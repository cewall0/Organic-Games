//
//  SynthesisView.swift
//  Organic Games
//
//  Organic Games Plus: Synthesis Steps. Multistep routes from the book's Ch. 11 problems (11.40, 11.47):
//  the start and target are Chad's drawings, the intermediates are left out, and one step's reagents are
//  missing. Wrong answers are the rival reagents (Lindlar vs Na/NH₃, OsO₄ vs MCPBA/H₃O⁺, HgSO₄ vs Sia₂BH,
//  NaNH₂ vs NaOH, the wrong-length alkyl halide...), each checked to be wrong for that route, never a second
//  way to the same target. Rounds of 10, weakest first. Without Plus, the first round is free.
//

import SwiftUI

struct SynthesisRoute {
    struct Step {
        let reagents: String        // sub-steps on separate lines: "1) O₃\n2) Me₂S"
        var traps: [String] = []    // wrong reagents for this gap (only needed for steps that are asked)
        var why = ""
    }

    let id: String          // "11.40a"
    let problem: String     // shown after answering
    let start: String       // image names
    let target: String
    let targetName: String
    let steps: [Step]
    let gaps: [Int]         // which steps are asked

    // Steps used by several routes
    private static func e2(_ halide: String) -> Step {
        Step(reagents: "t-BuOK", traps: ["NaI, acetone", "HBr", "PBr₃"],
             why: "A strong, bulky base does E2 on the \(halide): H–X leaves and cyclohexene forms. NaI only swaps the halogen, and HBr and PBr₃ don't react with an alkyl halide.")
    }
    private static func alkylate(_ halide: String, traps: [String], why: String) -> Step {
        Step(reagents: "1) NaNH₂\n2) \(halide)", traps: traps.map { $0.hasPrefix("1)") ? $0 : "1) NaNH₂\n2) \($0)" }, why: why)
    }
    private static let naOH = "1) NaOH\n2) "

    static let all: [SynthesisRoute] = [
        SynthesisRoute(id: "11.40a", problem: "Problem 11.40a", start: "syn-s40a-sm", target: "syn-s40a-tg",
                       targetName: "trans-2-bromocyclohexanol", steps: [
                        e2("alkyl chloride"),
                        Step(reagents: "Br₂, H₂O", traps: ["Br₂, CCl₄", "HBr", "OsO₄, H₂O₂"],
                             why: "Br₂ forms a bromonium ion and water opens it from the back side, so Br and OH end up trans (a bromohydrin). In CCl₄ you'd get the dibromide; OsO₄ gives a diol."),
                       ], gaps: [0, 1]),
        SynthesisRoute(id: "11.40b", problem: "Problem 11.40b", start: "syn-s40b-sm", target: "syn-s40b-tg",
                       targetName: "hexanedial", steps: [
                        Step(reagents: "Br₂, light", traps: ["Br₂, CCl₄", "HBr", "PBr₃"],
                             why: "An alkane has no C=C or OH, so only free-radical bromination (light) works: bromocyclohexane."),
                        e2("alkyl bromide"),
                        Step(reagents: "1) O₃\n2) Me₂S", traps: ["KMnO₄, OH⁻, warm, conc.", "OsO₄, H₂O₂", "MCPBA"],
                             why: "Ozonolysis cuts the C=C and, with Me₂S, each =CH– becomes a CHO. Warm, concentrated KMnO₄ would go on to the carboxylic acids."),
                       ], gaps: [0, 1, 2]),
        SynthesisRoute(id: "11.40c", problem: "Problem 11.40c", start: "syn-s40c-sm", target: "syn-s40c-tg",
                       targetName: "1,3-dimethylcyclopentanol", steps: [
                        Step(reagents: "H₂SO₄, heat", traps: ["t-BuOK", "PBr₃", "NaOH"],
                             why: "OH⁻ is a poor leaving group, so a base can't do E2 on an alcohol. Acid protonates the OH, water leaves, and E1 gives the more substituted alkene, with the C=C on the carbon that has the methyl."),
                        Step(reagents: "1) Hg(OAc)₂, H₂O\n2) NaBH₄", traps: ["1) BH₃·THF\n2) H₂O₂, OH⁻", "OsO₄, H₂O₂", "H₂, Pt"],
                             why: "Oxymercuration adds OH Markovnikov, to the 3° carbon with the methyl. Hydroboration–oxidation (anti-Markovnikov) would put the OH back on the 2° carbon."),
                       ], gaps: [0, 1]),
        SynthesisRoute(id: "11.40d", problem: "Problem 11.40d", start: "syn-s40d-sm", target: "syn-s40d-tg",
                       targetName: "cis-1,2-cyclohexanediol", steps: [
                        e2("alkyl bromide"),
                        Step(reagents: "OsO₄, H₂O₂", traps: ["1) MCPBA\n2) H₃O⁺", "Br₂, H₂O", "1) O₃\n2) Me₂S"],
                             why: "OsO₄ adds both OH from the same face (through a cyclic osmate ester): the cis diol. An epoxide opened by water (MCPBA, then H₃O⁺) gives the trans diol."),
                       ], gaps: [1]),
        SynthesisRoute(id: "11.40e", problem: "Problem 11.40e", start: "syn-s40e-sm", target: "syn-s40e-tg",
                       targetName: "the epoxide", steps: [
                        Step(reagents: "H₂SO₄, heat", traps: ["t-BuOK", "PBr₃", "MCPBA"],
                             why: "E1: the protonated OH leaves as water and the C=C forms toward the ring-fusion carbon, the more substituted alkene (Saytzeff)."),
                        Step(reagents: "MCPBA", traps: ["OsO₄, H₂O₂", "Br₂, H₂O", "1) O₃\n2) Me₂S"],
                             why: "A peroxyacid hands one O atom to the C=C: an epoxide. OsO₄ gives a diol, Br₂/H₂O a bromohydrin, and ozone cuts the ring open."),
                       ], gaps: [0, 1]),
        SynthesisRoute(id: "11.40f", problem: "Problem 11.40f", start: "syn-s40f-sm", target: "syn-s40f-tg",
                       targetName: "bicyclo[4.1.0]heptane", steps: [
                        e2("alkyl chloride"),
                        Step(reagents: "CH₂I₂, Zn(Cu)", traps: ["CHCl₃, NaOH, H₂O", "MCPBA", "H₂, Pt"],
                             why: "The Simmons–Smith reagent adds a CH₂ across the C=C: a cyclopropane. CHCl₃ and NaOH would add CCl₂ instead (a dichlorocyclopropane)."),
                       ], gaps: [1]),
        SynthesisRoute(id: "11.47b", problem: "Problem 11.47b", start: "syn-acetylene", target: "syn-s47b-tg",
                       targetName: "(hex-3-yn-1-yl)benzene", steps: [
                        alkylate("CH₃CH₂Br", traps: [naOH + "CH₃CH₂Br", "CH₃Br", "CH₃CH₂CH₂Br"],
                                 why: "NaNH₂ removes the alkyne H; the acetylide attacks CH₃CH₂Br (SN2), adding the ethyl group. NaOH is too weak a base to make an acetylide."),
                        alkylate("PhCH₂CH₂Br", traps: [naOH + "PhCH₂CH₂Br", "PhCH₂Br", "PhBr"],
                                 why: "A second deprotonation and SN2 add the CH₂CH₂Ph group. Count carbons: PhCH₂Br is one short, and SN2 can't happen at a benzene carbon (PhBr)."),
                       ], gaps: [0, 1]),
        SynthesisRoute(id: "11.47c", problem: "Problem 11.47c", start: "syn-acetylene", target: "syn-s47c-tg",
                       targetName: "1-phenylhex-3-yn-2-ol", steps: [
                        Step(reagents: "1) NaNH₂\n2) CH₃CH₂Br"),
                        Step(reagents: "1) NaNH₂\n2) PhCH₂CHO\n3) H₃O⁺",
                             traps: ["1) NaNH₂\n2) PhCH₂CH₂Br", "1) NaNH₂\n2) PhCHO\n3) H₃O⁺", naOH + "PhCH₂CHO\n3) H₃O⁺"],
                             why: "The acetylide adds to the aldehyde's C=O, and acid workup gives the alcohol. An alkyl halide gives no OH, and PhCHO is one carbon short. The alkylation has to come first: the OH would use up the next NaNH₂."),
                       ], gaps: [1]),
        SynthesisRoute(id: "11.47d", problem: "Problem 11.47d", start: "syn-acetylene", target: "syn-s47d-tg",
                       targetName: "3-ethylhex-4-yn-3-ol", steps: [
                        alkylate("CH₃Br", traps: [naOH + "CH₃Br", "CH₃CH₂Br", "(CH₃)₃CBr"],
                                 why: "NaNH₂, then CH₃Br (SN2), puts the methyl on: propyne. A 3° halide like (CH₃)₃CBr only does E2 with an acetylide."),
                        Step(reagents: "1) NaNH₂\n2) (CH₃CH₂)₂C=O\n3) H₃O⁺",
                             traps: ["1) NaNH₂\n2) CH₃CH₂COCH₃\n3) H₃O⁺", "1) NaNH₂\n2) (CH₃CH₂)₂CHBr", naOH + "(CH₃CH₂)₂C=O\n3) H₃O⁺"],
                             why: "The acetylide adds to the ketone's C=O, making the 3° alcohol. 2-Butanone is one carbon short, and a 2° halide gives E2, not an alcohol."),
                       ], gaps: [0, 1]),
        SynthesisRoute(id: "11.47j-cis", problem: "Problem 11.47j, by way of cis-2-butene", start: "syn-acetylene", target: "syn-s47j-tg",
                       targetName: "meso-2,3-butanediol", steps: [
                        Step(reagents: "1) NaNH₂\n2) CH₃Br"),
                        Step(reagents: "1) NaNH₂\n2) CH₃Br"),
                        Step(reagents: "H₂, Lindlar catalyst", traps: ["Na, NH₃", "H₂, Pt", "HgSO₄, H₂SO₄"],
                             why: "Lindlar's catalyst stops at cis-2-butene, and syn addition (OsO₄) to a cis alkene gives the meso diol. Na/NH₃ would give trans-2-butene, which OsO₄ turns into the racemic pair."),
                        Step(reagents: "OsO₄, H₂O₂", traps: ["1) MCPBA\n2) H₃O⁺", "Br₂, H₂O", "KMnO₄, OH⁻, warm, conc."],
                             why: "Syn addition to cis-2-butene gives meso-2,3-butanediol, which has a mirror plane. Anti addition (epoxide, then water) would give the racemic pair; warm KMnO₄ cuts the C=C."),
                       ], gaps: [2, 3]),
        SynthesisRoute(id: "11.47j-trans", problem: "Problem 11.47j, by way of trans-2-butene", start: "syn-acetylene", target: "syn-s47j-tg",
                       targetName: "meso-2,3-butanediol", steps: [
                        Step(reagents: "1) NaNH₂\n2) CH₃Br"),
                        Step(reagents: "1) NaNH₂\n2) CH₃Br"),
                        Step(reagents: "Na, NH₃", traps: ["H₂, Lindlar catalyst", "H₂, Pt", "HgSO₄, H₂SO₄"],
                             why: "Na in NH₃ gives trans-2-butene, and anti addition (epoxide, then water) to a trans alkene gives the meso diol. Lindlar would give cis-2-butene, which anti addition turns into the racemic pair."),
                        Step(reagents: "1) MCPBA\n2) H₃O⁺", traps: ["OsO₄, H₂O₂", "Br₂, H₂O", "KMnO₄, OH⁻, warm, conc."],
                             why: "Anti addition to trans-2-butene gives meso-2,3-butanediol. Syn addition (OsO₄) to the trans alkene would give the racemic pair."),
                       ], gaps: [2, 3]),
        SynthesisRoute(id: "11.47l", problem: "Problem 11.47l", start: "syn-acetylene", target: "syn-s47l-tg",
                       targetName: "heptane-3,4-dione", steps: [
                        alkylate("CH₃CH₂Br", traps: [naOH + "CH₃CH₂Br", "CH₃Br", "CH₃CH₂CH₂CH₂Br"],
                                 why: "NaNH₂, then CH₃CH₂Br, adds the ethyl group; the propyl group comes next, giving 3-heptyne."),
                        Step(reagents: "1) NaNH₂\n2) CH₃CH₂CH₂Br"),
                        Step(reagents: "KMnO₄, H₂O, neutral", traps: ["KMnO₄, OH⁻, warm, conc.", "HgSO₄, H₂SO₄", "1) O₃\n2) Me₂S"],
                             why: "Neutral KMnO₄ oxidizes the C≡C to a 1,2-diketone. Warm, basic KMnO₄ or ozone cuts it into two carboxylic acids, and HgSO₄ gives just one ketone."),
                       ], gaps: [0, 2]),
        SynthesisRoute(id: "11.47m", problem: "Problem 11.47m", start: "syn-acetylene", target: "syn-s47m-tg",
                       targetName: "2-pentanone", steps: [
                        alkylate("CH₃CH₂CH₂Br", traps: [naOH + "CH₃CH₂CH₂Br", "CH₃CH₂Br", "CH₃CH₂CH₂CH₂Br"],
                                 why: "NaNH₂, then CH₃CH₂CH₂Br, makes 1-pentyne. With an ethyl group you'd end at 2-butanone; with a butyl group, 2-hexanone."),
                        Step(reagents: "HgSO₄, H₂SO₄", traps: ["1) Sia₂BH\n2) H₂O₂, OH⁻", "H₂, Lindlar catalyst", "KMnO₄, OH⁻, warm, conc."],
                             why: "Markovnikov hydration: the enol tautomerizes to the methyl ketone. Hydroboration with Sia₂BH would give the aldehyde, pentanal."),
                       ], gaps: [0, 1]),
        SynthesisRoute(id: "11.47n", problem: "Problem 11.47n", start: "syn-acetylene", target: "syn-s47n-tg",
                       targetName: "hex-2-yn-1-ol", steps: [
                        alkylate("CH₃CH₂CH₂Br", traps: [naOH + "CH₃CH₂CH₂Br", "CH₃CH₂Br", "CH₃CH₂CH₂CH₂Br"],
                                 why: "NaNH₂, then CH₃CH₂CH₂Br, adds the propyl group. Alkylate first; the OH made later would use up the NaNH₂."),
                        Step(reagents: "1) NaNH₂\n2) H₂C=O\n3) H₃O⁺", traps: ["1) NaNH₂\n2) CH₃CHO\n3) H₃O⁺", "1) Sia₂BH\n2) H₂O₂, OH⁻", "1) NaNH₂\n2) CH₃OH"],
                             why: "The acetylide adds to formaldehyde, adding CH₂OH: a 1° alcohol. Acetaldehyde would give a 2° alcohol, and methanol just protonates the acetylide."),
                       ], gaps: [0, 1]),
        SynthesisRoute(id: "11.47o", problem: "Problem 11.47o", start: "syn-acetylene", target: "syn-s47o-tg",
                       targetName: "2,2-dibromohexane", steps: [
                        alkylate("CH₃CH₂CH₂CH₂Br", traps: [naOH + "CH₃CH₂CH₂CH₂Br", "CH₃CH₂CH₂Br", "(CH₃)₃CBr"],
                                 why: "NaNH₂, then 1-bromobutane, makes 1-hexyne. A 3° halide only does E2."),
                        Step(reagents: "2 HBr", traps: ["HBr, ROOR", "2 Br₂", "Br₂, CCl₄"],
                             why: "Two Markovnikov additions put both Br on C2, the more substituted carbon. With peroxide, Br goes to C1; 2 Br₂ gives a tetrabromide, and one Br₂ a dibromoalkene."),
                       ], gaps: [0, 1]),
    ]
}

/// One question: a route with one step missing
struct SynthesisGap: Identifiable {
    let route: SynthesisRoute
    let gap: Int
    var id: String { "\(route.id)-\(gap + 1)" }
    var step: SynthesisRoute.Step { route.steps[gap] }

    static let all: [SynthesisGap] = SynthesisRoute.all.flatMap { r in r.gaps.map { SynthesisGap(route: r, gap: $0) } }
    static func byID(_ id: String) -> SynthesisGap? { all.first { $0.id == id } }

    func choices() -> [String] { ([step.reagents] + step.traps.prefix(3)).shuffled() }
}

struct SynthesisView: View {
    static let setID = "synthesis"
    private let roundLength = 10

    @Environment(\.dismiss) private var dismiss
    @AppStorage("freeRounds.synthesis") private var freeRoundsUsed = 0
    private let plus = PlusStore.shared
    private let mastery = MasteryStore.shared

    @State private var round: [SynthesisGap] = []
    @State private var choices: [String] = []
    @State private var index = 0
    @State private var picked: String?
    @State private var correctCount = 0
    @State private var showPaywall = false

    private var keys: [String] { SynthesisGap.all.map(\.id) }
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
        .navigationTitle("Synthesis Steps")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showPaywall) { NavigationStack { PlusPaywall() } }
        .onAppear { if round.isEmpty && !locked { startRound() } }
        .onChange(of: plus.isPlus) { _, isPlus in if isPlus && round.isEmpty { startRound() } }
    }

    // MARK: Question

    private func question(_ q: SynthesisGap) -> some View {
        VStack(spacing: 14) {
            HStack {
                Text("\(index + 1) of \(round.count)").font(.subheadline.bold()).foregroundStyle(.secondary)
                Spacer()
                Label("\(correctCount)", systemImage: "checkmark.circle.fill")
                    .font(.subheadline.bold()).foregroundStyle(.green)
                    .accessibilityLabel("\(correctCount) correct")
            }
            route(q)
                .frame(maxWidth: .infinity)
                .paperCard()
                .shadow(color: .black.opacity(0.08), radius: 4, y: 2)

            Text("Which reagents fill the gap?").font(.headline)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(choices, id: \.self) { c in
                    Button { answer(c, for: q) } label: {
                        Text(c).font(.body.weight(.semibold)).multilineTextAlignment(.center).foregroundStyle(.black)
                            .minimumScaleFactor(0.8)
                            .frame(maxWidth: .infinity, minHeight: 72)
                            .paperCard(highlight: highlight(c, answer: q.step.reagents))
                    }
                    .buttonStyle(.plain)   // taps after answering are ignored in answer()
                }
            }
            if let picked {
                let right = picked == q.step.reagents
                VStack(alignment: .leading, spacing: 6) {
                    Label(right ? "Correct!" : q.step.reagents.replacingOccurrences(of: "\n", with: " "),
                          systemImage: right ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.headline)
                        .foregroundStyle(right ? .green : .red)
                    Text(q.step.why).font(.subheadline)
                    Text("\(q.route.problem) · target: \(q.route.targetName)").font(.caption).foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemGroupedBackground)))
                wideButton(index + 1 < round.count ? "Next" : "Finish round") { next() }
            }
        }
    }

    /// Start, one down arrow per step with its reagents beside it (the gap is a "?"), then the target
    private func route(_ q: SynthesisGap) -> some View {
        VStack(spacing: 6) {
            StructureImage(name: q.route.start, label: "Starting material").frame(maxHeight: 80)
            ForEach(Array(q.route.steps.enumerated()), id: \.offset) { i, step in
                HStack(spacing: 10) {
                    Color.clear.frame(maxWidth: .infinity, maxHeight: 1)
                    Image(systemName: "arrow.down").font(.title3.weight(.semibold))
                    Group {
                        if i == q.gap {
                            Text("?").font(.title2.bold()).foregroundStyle(.orange)
                        } else {
                            Text(step.reagents).font(.callout)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .foregroundStyle(.black)
                .accessibilityElement(children: .combine)
                .accessibilityLabel(i == q.gap ? "Step \(i + 1): missing" : "Step \(i + 1): \(step.reagents)")
            }
            StructureImage(name: q.route.target, label: q.route.targetName).frame(maxHeight: 90)
        }
    }

    private func highlight(_ c: String, answer: String) -> Color? {
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
            Text("Mastered \(done) of \(keys.count) steps").font(.headline).foregroundStyle(.secondary)
            ProgressView(value: Double(done), total: Double(keys.count)).tint(.orange)
            if plus.isPlus {
                wideButton("Next round") { startRound() }
            } else {
                Text("That was your free round. Organic Games Plus keeps the practice going and focuses on the steps you miss.")
                    .multilineTextAlignment(.center).font(.subheadline)
                wideButton("See Plus plans") { showPaywall = true }
            }
            Link("Review the Ch. 11 summary in the free textbook", destination: ReactionChapter.ch11.url).font(.subheadline)
            Button("Back to games") { dismiss() }.font(.subheadline)
        }
        .padding(.top, 30)
    }

    private var lockedCard: some View {
        VStack(spacing: 16) {
            Image(systemName: "lock.circle.fill").font(.system(size: 56)).foregroundStyle(.orange)
            Text("Keep practicing with Plus").font(.title2.bold())
            Text("You've used your free round of Synthesis Steps. Plus unlocks every round, tracks what you've mastered and drills the steps you miss.")
                .multilineTextAlignment(.center).font(.subheadline)
            wideButton("See Plus plans") { showPaywall = true }
            Link("Review the Ch. 11 summary in the free textbook", destination: ReactionChapter.ch11.url).font(.subheadline)
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

    /// Ten gaps, weakest first, in random order
    private func startRound() {
        let order = mastery.practiceOrder(setID: Self.setID, keys: keys).compactMap(SynthesisGap.byID)
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

    private func answer(_ c: String, for q: SynthesisGap) {
        guard picked == nil else { return }
        picked = c
        let right = c == q.step.reagents
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
