//
//  StereoView.swift
//  Organic Games
//
//  Organic Games Plus, Ch. 7 chirality, drawn from the book's problems 7.2, 7.3, 7.5, 7.8 and 7.19 (cut by
//  Tools/book_stereo_cut.py; the stereocenter positions are in StereoCenters.swift).
//  Chiral or Achiral?: a blitz. Pick chiral or achiral, then why (no stereocenters, one stereocenter, a mirror
//  plane, or stereocenters with no mirror plane). Both right moves on by itself; a miss stops to explain.
//  Spot the Stereocenters: tap every stereocenter in the drawing (or none), then check. Taps snap to atoms.
//  Rounds of 10, weakest first. Without Plus, the first round of each is free.
//

import SwiftUI

enum ChiralityReason: CaseIterable {
    case noStereocenters, oneStereocenter, mirrorPlane, noMirrorPlane

    var isChiral: Bool { self == .oneStereocenter || self == .noMirrorPlane }
    var label: String {
        switch self {
        case .noStereocenters: return "No stereocenters"
        case .oneStereocenter: return "One stereocenter"
        case .mirrorPlane: return "Stereocenters, but a mirror plane"
        case .noMirrorPlane: return "Stereocenters, no mirror plane"
        }
    }
}

struct StereoMolecule: Identifiable {
    let id: String          // "7.19c"
    let reason: ChiralityReason
    let why: String

    var image: String { "stereo-" + id.dropFirst(2).replacingOccurrences(of: ".", with: "") }
    var isChiral: Bool { reason.isChiral }
    /// In Spot the Stereocenters (its stereocenters were picked)
    var canSpot: Bool { StereoCenters.centers[image] != nil }

    static func byID(_ id: String) -> StereoMolecule? { all.first { $0.id == id } }

    private static func m(_ id: String, _ reason: ChiralityReason, _ why: String) -> StereoMolecule {
        StereoMolecule(id: id, reason: reason, why: why)
    }

    // 7.2, 7.3, 7.5 and 7.8 are answered in the book; 7.19 is not (Claude's key, for Chad to check)
    static let all: [StereoMolecule] = [
        m("7.2a", .oneStereocenter, "The OH carbon holds H, OH, CH₃ and CH₂CH₃: four different groups. One stereocenter makes it chiral."),
        m("7.2b", .oneStereocenter, "The ring carbon with one CH₃ (and a hidden H) is the stereocenter: going around the ring one way reaches the C(CH₃)₂ sooner than the other way. The carbon with two CH₃s isn't one."),
        m("7.2c", .oneStereocenter, "The bottom carbon holds CH₃ and a hidden H, and going around the ring one way reaches the C=C sooner than the other way. One stereocenter: chiral."),
        m("7.2d", .oneStereocenter, "The CH carbon holds NH₂, CO₂H, CH₂Ph and H. One stereocenter: chiral."),
        m("7.3a", .noStereocenters, "The Cl carbon's two ring paths are the same, so it isn't a stereocenter. Achiral."),
        m("7.3b", .mirrorPlane, "Both Cl carbons are stereocenters, but the Cls are cis, so a mirror plane runs between them (meso). Achiral."),
        m("7.3c", .noMirrorPlane, "Both carbons are stereocenters, and Cl and CH₃ differ, so no mirror plane fits. Chiral."),
        m("7.3d", .noStereocenters, "Cl and Br share a carbon whose two ring paths are the same. No stereocenters: achiral."),
        m("7.3e", .oneStereocenter, "The carbon holds H, Br, CH₃ and CH₂CH₃. One stereocenter: chiral."),
        m("7.3f", .noStereocenters, "The carbon holds two CH₃ groups. No stereocenters: achiral."),
        m("7.3g", .mirrorPlane, "Both carbons are stereocenters, and each has Cl back and Br forward, so a mirror plane cuts the C–C bond (meso). Achiral."),
        m("7.3h", .noMirrorPlane, "Both carbons are stereocenters, but Br and Cl swap wedge and dash from one to the other, so there's no mirror plane. Chiral."),
        m("7.5a", .noMirrorPlane, "Four stereocenters, and the OHs aren't symmetric top to bottom (CHO at one end, CH₂OH at the other). Chiral."),
        m("7.5b", .mirrorPlane, "Two stereocenters with both Cls on the right and OH at both ends, so a mirror plane runs between them (meso). Achiral."),
        m("7.5c", .oneStereocenter, "Only the top carbon is a stereocenter: the bottom one holds two H's. One stereocenter: chiral."),
        m("7.5d", .noMirrorPlane, "Two stereocenters with Cl on the right at the top and on the left at the bottom: no mirror plane. Chiral."),
        m("7.8a", .mirrorPlane, "Both carbons are stereocenters, and the two halves mirror each other across the C–C bond (meso). Achiral."),
        m("7.8b", .noMirrorPlane, "Two stereocenters, but Br and CH₃ swap wedge and dash on the left carbon, so the halves don't mirror each other. Chiral."),
        m("7.8c", .noStereocenters, "Br and CH₃ share a carbon whose two ring paths are identical, so a mirror plane runs through it. No stereocenters: achiral."),
        m("7.8d", .oneStereocenter, "Going around the ring one way reaches the C=C sooner than the other way, so the Br/CH₃ carbon is a stereocenter. One stereocenter: chiral."),
        m("7.19a", .noStereocenters, "No carbon holds four different groups. Achiral."),
        m("7.19b", .noStereocenters, "A flat aromatic ring with no stereocenters. Achiral."),
        m("7.19c", .noMirrorPlane, "Two stereocenters with the CH₃s trans (one wedge, one dash), so no mirror plane fits. Chiral."),
        m("7.19d", .noStereocenters, "The carbon holds two H's. No stereocenters: achiral."),
        m("7.19e", .oneStereocenter, "The carbon holds H, Br, Cl and CH₃. One stereocenter: chiral."),
        m("7.19g", .oneStereocenter, "Only the CH holding CH₃ and CO₂H is a stereocenter; the CH in the isobutyl group holds two CH₃s. One stereocenter: chiral."),
        m("7.19h", .mirrorPlane, "Both carbons are stereocenters, and each has NH₂ back and CH₃ forward, so a mirror plane cuts the middle bond (meso). Achiral."),
        m("7.19i", .noMirrorPlane, "Two stereocenters, but NH₂ and CH₃ swap wedge and dash from left to right. No mirror plane: chiral."),
        m("7.19j", .noMirrorPlane, "Four stereocenters, and the OHs aren't symmetric top to bottom. Chiral."),
        m("7.19k", .mirrorPlane, "Four stereocenters, but CH₂OH is at both ends and the OHs go right, left, left, right, so the top half mirrors the bottom (meso). Achiral."),
        m("7.19l", .noStereocenters, "Each bridgehead holds three identical bridges. No stereocenters: achiral."),
        m("7.19m", .noMirrorPlane, "Three stereocenters (the OH, CH₃ and isopropyl carbons) and no mirror plane. The isopropyl CH holds two CH₃s. Chiral."),
        m("7.19n", .noStereocenters, "No sp³ carbons at all. Achiral."),
        m("7.19o", .noStereocenters, "The carbon holds three F's. No stereocenters: achiral."),
        m("7.19p", .noStereocenters, "Each carbon holds two H's. No stereocenters: achiral."),
        m("7.19q", .mirrorPlane, "The two neighboring CH₃ carbons are stereocenters, and all three CH₃s are on the same side, so a mirror plane runs through the ring. Achiral."),
        m("7.19r", .noMirrorPlane, "Five ring stereocenters and no mirror plane. Chiral."),
        m("7.19s", .oneStereocenter, "Only the carbon joining the two rings is a stereocenter (the N inverts too fast to count). One stereocenter: chiral."),
        m("7.19t", .noStereocenters, "Each bridgehead holds three identical bridges. No stereocenters: achiral."),
        m("7.19u", .noMirrorPlane, "Two stereocenters with the OHs trans: no mirror plane. Chiral."),
        m("7.19v", .mirrorPlane, "Two stereocenters with the OHs cis, so a mirror plane runs between them (meso). Achiral."),
        m("7.19w", .noMirrorPlane, "Both bridgeheads are stereocenters (one is next to the C=O, the other next to the CEt₂), and nothing mirrors them. The CEt₂ carbon holds two ethyls. Chiral."),
        m("7.19x", .noStereocenters, "The carbon holds two CO₂H groups. No stereocenters: achiral."),
        m("7.19y", .noStereocenters, "Flat aromatic rings with no stereocenters. Achiral."),
        m("7.19z", .oneStereocenter, "The stereocenter is phosphorus: it holds =O, OEt, CH₃ and S. The N holds two identical isopropyl groups. One stereocenter: chiral."),
        m("7.19aa", .noStereocenters, "Each substituted ring carbon has two identical ring paths, so neither is a stereocenter, and a mirror plane runs through both. Achiral."),
        m("7.19bb", .noStereocenters, "Every ring atom has two identical ring paths. No stereocenters: achiral."),
        m("7.19cc", .noMirrorPlane, "Four stereocenters: both bridgeheads, the CO₂Me carbon and the ester carbon, with no mirror plane. Chiral."),
        m("7.19dd", .noStereocenters, "The Cl carbon's two ring paths are identical. No stereocenters: achiral."),
        m("7.19ee", .noMirrorPlane, "Both bridgeheads are stereocenters because the C=O sits on one side only. No mirror plane: chiral."),
        m("7.19ff", .mirrorPlane, "Both bridgeheads are stereocenters (each touches the C=C on one side and a CH₂ on the other), but a mirror plane runs through the top CH₂. Achiral."),
        m("7.19gg", .noStereocenters, "No sp³ carbons at all. Achiral."),
        m("7.19hh", .mirrorPlane, "Both Cls point up (cis), so the two stereocenters mirror each other across a plane between them (meso). Achiral."),
        m("7.19ii", .noMirrorPlane, "One Cl up and one down (trans): two stereocenters and no mirror plane. Chiral."),
        m("7.19jj", .oneStereocenter, "The C–Br carbon holds Br, H, the C=O and a CH₂. One stereocenter: chiral."),
        m("7.19kk", .oneStereocenter, "The carbon holds OH, Br, CH₂O and CH₂CH₂O. One stereocenter: chiral."),
        m("7.19ll", .oneStereocenter, "The carbon holds NH₂, CO₂H, CH₂SH and H. One stereocenter: chiral."),
        m("7.19mm", .noMirrorPlane, "Three stereocenters with every OH on the right, but CHO and CH₂OH at the ends differ, so there's no mirror plane. Chiral."),
        m("7.19nn", .mirrorPlane, "Two stereocenters with both Cls on the right and OH at both ends, so a mirror plane runs between them (meso). Achiral."),
        m("7.19oo", .mirrorPlane, "Both Cls point down (cis): two stereocenters with a mirror plane between them (meso). Achiral."),
        m("7.19pp", .noMirrorPlane, "One Cl up and one down (trans): two stereocenters and no mirror plane. Chiral."),
        m("7.19qq", .noStereocenters, "No sp³ carbons at all. Achiral."),
        m("7.19rr", .noStereocenters, "A flat aromatic ring. Achiral."),
        m("7.19ss", .noStereocenters, "The only sp³ carbon is a CH₂. Achiral."),
        m("7.19tt", .noStereocenters, "No carbon holds four different groups. Achiral."),
        m("7.19uu", .noStereocenters, "Each carbon holds at least two identical groups. No stereocenters: achiral."),
    ]
}

private let chiralityURL = URL(string: "https://organicchemistryguide.com/stereochemistry-introduction/")!
private let chiralityLinkLabel = "Review chirality (Ch. 7) in the free textbook"

// MARK: Chiral or Achiral?

struct ChiralBlitzView: View {
    static let setID = "chiral-blitz"
    static var keys: [String] { StereoMolecule.all.map(\.id) }
    private let roundLength = 10

    @Environment(\.dismiss) private var dismiss
    @AppStorage("freeRounds.chiral-blitz") private var freeRoundsUsed = 0
    private let plus = PlusStore.shared
    private let mastery = MasteryStore.shared

    @State private var round: [StereoMolecule] = []
    @State private var index = 0
    @State private var pickedChiral: Bool?
    @State private var pickedReason: ChiralityReason?
    @State private var correctCount = 0
    @State private var showPaywall = false

    private var roundDone: Bool { !round.isEmpty && index >= round.count }
    private var locked: Bool { !plus.isPlus && freeRoundsUsed >= 1 }

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                if round.isEmpty && locked {
                    PlusLockedCard(title: "Chiral or Achiral?", things: "molecules", chapterLabel: chiralityLinkLabel,
                                   chapterURL: chiralityURL) { showPaywall = true }
                } else if roundDone {
                    PlusRoundSummary(correct: correctCount, total: round.count, setID: Self.setID, keys: Self.keys, things: "molecules",
                                     isPlus: plus.isPlus, chapterLabel: chiralityLinkLabel, chapterURL: chiralityURL,
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
        .navigationTitle("Chiral or Achiral?")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showPaywall) { NavigationStack { PlusPaywall() } }
        .onAppear { if round.isEmpty && !locked { startRound() } }
        .onChange(of: plus.isPlus) { _, isPlus in if isPlus && round.isEmpty { startRound() } }
    }

    private func question(_ q: StereoMolecule) -> some View {
        VStack(spacing: 14) {
            HStack {
                Text("\(index + 1) of \(round.count)").font(.subheadline.bold()).foregroundStyle(.secondary)
                Spacer()
                Label("\(correctCount)", systemImage: "checkmark.circle.fill")
                    .font(.subheadline.bold()).foregroundStyle(.green)
                    .accessibilityLabel("\(correctCount) correct")
            }
            StructureImage(name: q.image, scale: zoom(q.image), label: "Problem \(q.id) molecule")
                .frame(maxWidth: .infinity, minHeight: 150)
                .paperCard()
                .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
            HStack(spacing: 10) {
                ForEach([true, false], id: \.self) { chiral in
                    Button { pickChiral(chiral) } label: {
                        Text(chiral ? "Chiral" : "Achiral").font(.title3.weight(.bold)).foregroundStyle(.black)
                            .frame(maxWidth: .infinity, minHeight: 56)
                            .paperCard(highlight: chiralHighlight(chiral, q: q))
                    }
                    .buttonStyle(.plain)
                }
            }
            if pickedChiral != nil {
                Text("Why?").font(.headline)
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    ForEach(ChiralityReason.allCases, id: \.self) { r in
                        Button { pickReason(r, for: q) } label: {
                            Text(r.label).font(.subheadline.weight(.semibold)).multilineTextAlignment(.center).foregroundStyle(.black)
                                .frame(maxWidth: .infinity, minHeight: 52)
                                .paperCard(highlight: reasonHighlight(r, q: q))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            // Both right moves on by itself; a miss stops to explain
            if let pickedReason, pickedReason != q.reason || pickedChiral != q.isChiral {
                VStack(alignment: .leading, spacing: 6) {
                    Label(q.isChiral ? "Chiral" : "Achiral", systemImage: "xmark.circle.fill").font(.headline).foregroundStyle(.red)
                    Text(q.why).font(.subheadline)
                    Text("Problem \(q.id)").font(.caption).foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemGroupedBackground)))
                PlusWideButton(title: index + 1 < round.count ? "Next" : "Finish round") { next() }
            }
        }
    }

    /// The 7.19 drawings are small in the book; grow each to about 150 pt tall
    private func zoom(_ image: String) -> CGFloat {
        min(2.2, 150 / (UIImage(named: image)?.size.height ?? 150))
    }

    private func chiralHighlight(_ chiral: Bool, q: StereoMolecule) -> Color? {
        guard let pickedChiral else { return nil }
        if chiral == q.isChiral { return .green }
        if chiral == pickedChiral { return .red }
        return nil
    }

    private func reasonHighlight(_ r: ChiralityReason, q: StereoMolecule) -> Color? {
        guard let pickedReason else { return nil }
        if r == q.reason { return .green }
        if r == pickedReason { return .red }
        return nil
    }

    private func startRound() {
        let order = mastery.practiceOrder(setID: Self.setID, keys: Self.keys).compactMap(StereoMolecule.byID)
        round = Array(order.prefix(roundLength)).shuffled()
        index = 0
        correctCount = 0
        pickedChiral = nil
        pickedReason = nil
    }

    private func pickChiral(_ chiral: Bool) {
        guard pickedChiral == nil else { return }
        pickedChiral = chiral
    }

    /// Mastery needs both answers right
    private func pickReason(_ r: ChiralityReason, for q: StereoMolecule) {
        guard pickedReason == nil else { return }
        pickedReason = r
        let right = r == q.reason && pickedChiral == q.isChiral
        if right {
            correctCount += 1
            let current = index
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) { if index == current { next() } }
        }
        mastery.record(q.id, setID: Self.setID, firstTry: right)
    }

    private func next() {
        pickedChiral = nil
        pickedReason = nil
        index += 1
        if index >= round.count, !plus.isPlus { freeRoundsUsed += 1 }
    }
}

// MARK: Spot the Stereocenters

struct SpotStereocentersView: View {
    static let setID = "spot-stereocenters"
    static var keys: [String] { StereoMolecule.all.filter(\.canSpot).map(\.id) }
    private let roundLength = 10

    @Environment(\.dismiss) private var dismiss
    @AppStorage("freeRounds.spot-stereocenters") private var freeRoundsUsed = 0
    private let plus = PlusStore.shared
    private let mastery = MasteryStore.shared

    @State private var round: [StereoMolecule] = []
    @State private var index = 0
    @State private var marked: Set<Int> = []     // atom indices
    @State private var checked = false
    @State private var correctCount = 0
    @State private var showPaywall = false

    private var roundDone: Bool { !round.isEmpty && index >= round.count }
    private var locked: Bool { !plus.isPlus && freeRoundsUsed >= 1 }

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                if round.isEmpty && locked {
                    PlusLockedCard(title: "Spot the Stereocenters", things: "molecules", chapterLabel: chiralityLinkLabel,
                                   chapterURL: chiralityURL) { showPaywall = true }
                } else if roundDone {
                    PlusRoundSummary(correct: correctCount, total: round.count, setID: Self.setID, keys: Self.keys, things: "molecules",
                                     isPlus: plus.isPlus, chapterLabel: chiralityLinkLabel, chapterURL: chiralityURL,
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
        .navigationTitle("Spot the Stereocenters")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showPaywall) { NavigationStack { PlusPaywall() } }
        .onAppear { if round.isEmpty && !locked { startRound() } }
        .onChange(of: plus.isPlus) { _, isPlus in if isPlus && round.isEmpty { startRound() } }
    }

    private func question(_ q: StereoMolecule) -> some View {
        let atoms = StereoCenters.atoms[q.image] ?? []
        let centers = StereoCenters.centers[q.image] ?? []
        let perfect = marked == centers
        return VStack(spacing: 14) {
            HStack {
                Text("\(index + 1) of \(round.count)").font(.subheadline.bold()).foregroundStyle(.secondary)
                Spacer()
                Label("\(correctCount)", systemImage: "checkmark.circle.fill")
                    .font(.subheadline.bold()).foregroundStyle(.green)
                    .accessibilityLabel("\(correctCount) correct")
            }
            Text("Tap every stereocenter").font(.headline)
            TappableMolecule(image: q.image, atoms: atoms, centers: centers, marked: $marked, checked: checked)
                .padding(12)
                .frame(maxWidth: .infinity)
                .paperCard()
                .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
            if !checked {
                PlusWideButton(title: marked.isEmpty ? "None here" : "Check") { check(q, centers: centers) }
            } else {
                VStack(alignment: .leading, spacing: 6) {
                    Label(perfect ? "Correct!" : verdict(marked: marked, centers: centers),
                          systemImage: perfect ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.headline).foregroundStyle(perfect ? .green : .red)
                    Text(q.why).font(.subheadline)
                    Text("Problem \(q.id)").font(.caption).foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemGroupedBackground)))
                PlusWideButton(title: index + 1 < round.count ? "Next" : "Finish round") { next() }
            }
        }
    }

    private func verdict(marked: Set<Int>, centers: Set<Int>) -> String {
        let missed = centers.subtracting(marked).count, extra = marked.subtracting(centers).count
        switch (missed, extra) {
        case (0, _): return "\(extra) isn't a stereocenter"
        case (_, 0): return "Missed \(missed)"
        default: return "Missed \(missed), \(extra) wrong"
        }
    }

    private func startRound() {
        let order = mastery.practiceOrder(setID: Self.setID, keys: Self.keys).compactMap(StereoMolecule.byID)
        round = Array(order.prefix(roundLength)).shuffled()
        index = 0
        correctCount = 0
        marked = []
        checked = false
    }

    private func check(_ q: StereoMolecule, centers: Set<Int>) {
        checked = true
        let right = marked == centers
        if right { correctCount += 1 }
        mastery.record(q.id, setID: Self.setID, firstTry: right)
    }

    private func next() {
        marked = []
        checked = false
        index += 1
        if index >= round.count, !plus.isPlus { freeRoundsUsed += 1 }
    }
}

/// The drawing with tap targets on its atoms. Before checking, a tap toggles the nearest atom; after, stereocenters
/// tapped are green, wrong taps red, and missed stereocenters dashed orange.
private struct TappableMolecule: View {
    let image: String
    let atoms: [CGPoint]
    let centers: Set<Int>
    @Binding var marked: Set<Int>
    let checked: Bool

    var body: some View {
        let size = UIImage(named: image)?.size ?? CGSize(width: 100, height: 100)
        let zoom = min(2.2, 260 / size.height)    // small drawings grow for fingers
        Image(image)
            .resizable()
            .interpolation(.high)
            .scaledToFit()
            .overlay {
                GeometryReader { geo in
                    ZStack {
                        Color.clear.contentShape(Rectangle())
                            .onTapGesture(coordinateSpace: .local) { p in tap(p, in: geo.size) }
                        ForEach(Array(atoms.enumerated()), id: \.offset) { i, a in
                            marker(i).position(x: a.x * geo.size.width, y: a.y * geo.size.height)
                        }
                    }
                }
            }
            .frame(maxWidth: size.width * zoom, maxHeight: size.height * zoom)
            .accessibilityLabel("Molecule drawing")
    }

    @ViewBuilder private func marker(_ i: Int) -> some View {
        let on = marked.contains(i), center = centers.contains(i)
        if checked && on {
            Circle().stroke(center ? Color.green : Color.red, lineWidth: 3).frame(width: 26, height: 26)
                .overlay { if !center { Image(systemName: "xmark").font(.caption.bold()).foregroundStyle(.red) } }
                .allowsHitTesting(false)
        } else if checked && center {
            Circle().stroke(Color.orange, style: StrokeStyle(lineWidth: 3, dash: [4, 3])).frame(width: 26, height: 26)
                .allowsHitTesting(false)
        } else if on {
            Circle().fill(Color.purple.opacity(0.25)).overlay(Circle().stroke(Color.purple, lineWidth: 2.5))
                .frame(width: 26, height: 26)
                .allowsHitTesting(false)
        }
    }

    private func tap(_ p: CGPoint, in size: CGSize) {
        guard !checked else { return }
        let nearest = atoms.indices.min { d(atoms[$0], p, size) < d(atoms[$1], p, size) }
        guard let i = nearest, d(atoms[i], p, size) < 30 else { return }
        if marked.contains(i) { marked.remove(i) } else { marked.insert(i) }
    }

    private func d(_ a: CGPoint, _ p: CGPoint, _ size: CGSize) -> CGFloat {
        hypot(a.x * size.width - p.x, a.y * size.height - p.y)
    }
}
