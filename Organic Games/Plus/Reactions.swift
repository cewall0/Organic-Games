//
//  Reactions.swift
//  Organic Games
//
//  The Ch. 11 reaction summary (organicchemistryguide.com 11.25): starting material, reagents and product
//  drawings cut from the textbook's own figures (Assets.xcassets/Reactions). Two-step acetylide sequences are
//  split into their single steps. Reactions with the same product share a productKey, so a question never
//  offers two right answers.
//

import SwiftUI

enum ReactionGroup: String, CaseIterable {
    case alkene, propyne, butyne, acetylide, metathesis

    /// Groups whose products make fair distractors for each other
    var family: Int {
        switch self {
        case .alkene: return 0
        case .propyne, .butyne, .acetylide: return 1
        case .metathesis: return 2
        }
    }
}

struct OrgReaction: Identifiable, Hashable {
    let id: String
    let group: ReactionGroup
    let name: String
    let note: String            // why, shown after answering
    let reagents: String        // spoken by VoiceOver
    let productName: String     // also the duplicate key: same name, same product
    let smImage: String
    let reagentsImage: String
    let productImage: String
    var reversible = false

    static let chapterURL = URL(string: "https://organicchemistryguide.com/alkene-alkyne-reaction-summary/")!

    static func byID(_ id: String) -> OrgReaction? { all.first { $0.id == id } }

    /// Up to `count` other products for a multiple-choice question: same group first, then the same family,
    /// never one that is the same compound as the answer.
    func distractors(_ count: Int) -> [OrgReaction] {
        var seen: Set<String> = [productName]
        return pick(count) { r in seen.insert(r.productName).inserted }
    }

    /// Up to `count` other reagent sets: never one that also makes this product, and never the same reagents twice.
    func reagentDistractors(_ count: Int) -> [OrgReaction] {
        var seen: Set<String> = [reagents]
        return pick(count) { r in r.productName != productName && seen.insert(r.reagents).inserted }
    }

    /// The reactions students confuse with each one (Markovnikov vs anti-Markovnikov, syn vs anti, cold vs hot
    /// KMnO₄...). They always come first among the wrong answers.
    private static let rivals: [String: [String]] = [
        "r01": ["r02"], "r02": ["r01", "r07"],
        "r03": ["r07", "r01"], "r04": ["r07"], "r05": ["r07", "r06"], "r06": ["r05", "r07"], "r07": ["r05", "r02"],
        "r08": ["r09"], "r09": ["r08"],
        "r10": ["r11", "r16"], "r11": ["r16", "r10"], "r16": ["r11", "r18"], "r17": ["r11", "r18"],
        "r12": ["r14"], "r13": ["r14"], "r14": ["r12"],
        "r18": ["r19", "r17"], "r19": ["r18"],
        "r24": ["r25", "r29"], "r25": ["r24", "r27"], "r26": ["r27"], "r27": ["r26", "r25"], "r29": ["r24"],
        "r30": ["r31"], "r31": ["r30"], "r32": ["r33"], "r33": ["r32"], "r34": ["r33"],
        "r35a": ["r36a", "r37a"], "r36a": ["r37a", "r35a"], "r37a": ["r36a", "r35a"],
        "r35b": ["r36b"], "r36b": ["r35b"], "r37b": ["r35b"],
    ]

    private func pick(_ count: Int, _ keep: (OrgReaction) -> Bool) -> [OrgReaction] {
        var picks: [OrgReaction] = []
        let pools = [(Self.rivals[id] ?? []).compactMap(Self.byID),
                     Self.all.filter { $0.group == group }.shuffled(),
                     Self.all.filter { $0.group != group && $0.group.family == group.family }.shuffled()]
        for pool in pools {
            for r in pool where picks.count < count && keep(r) { picks.append(r) }
        }
        return picks
    }

    // MARK: Data

    private static func alkene(_ id: String, _ name: String, _ reagents: String, _ product: String, _ note: String) -> OrgReaction {
        OrgReaction(id: id, group: .alkene, name: name, note: note, reagents: reagents, productName: product,
                    smImage: "rxn-alkene-sm", reagentsImage: "rxn-\(id)-reagents", productImage: "rxn-\(id)-product")
    }

    private static func alkyne(_ id: String, _ group: ReactionGroup, _ name: String, _ reagents: String, _ product: String, _ note: String) -> OrgReaction {
        OrgReaction(id: id, group: group, name: name, note: note, reagents: reagents, productName: product,
                    smImage: group == .propyne ? "rxn-propyne-sm" : "rxn-butyne-sm",
                    reagentsImage: "rxn-\(id)-reagents", productImage: "rxn-\(id)-product")
    }

    private static func metathesis(_ id: String, _ name: String, _ reagents: String, _ product: String, _ note: String, reversible: Bool = true) -> OrgReaction {
        OrgReaction(id: id, group: .metathesis, name: name, note: note, reagents: reagents, productName: product,
                    smImage: "rxn-\(id)-sm", reagentsImage: "rxn-\(id)-reagents", productImage: "rxn-\(id)-product", reversible: reversible)
    }

    /// Step 1 (propyne to the acetylide) or step 2 (the acetylide on to the product) of a two-step sequence
    private static func step(_ seq: String, _ n: Int, _ name: String, _ reagents: String, _ product: String, _ note: String) -> OrgReaction {
        OrgReaction(id: "\(seq)\(n == 1 ? "a" : "b")", group: n == 1 ? .propyne : .acetylide, name: name, note: note,
                    reagents: reagents, productName: product,
                    smImage: n == 1 ? "rxn-propyne-sm" : "rxn-\(seq)-intermediate",
                    reagentsImage: "rxn-\(seq)-step\(n)",
                    productImage: n == 1 ? "rxn-\(seq)-intermediate" : "rxn-\(seq)-product")
    }

    static let all: [OrgReaction] = [
        alkene("r01", "Markovnikov addition of HBr", "HBr", "1-bromo-1-methylcyclopentane",
               "H adds to the less substituted carbon, so Br ends up on the more substituted carbon (the more stable carbocation)."),
        alkene("r02", "Anti-Markovnikov addition of HBr", "HBr, ROOR", "1-bromo-2-methylcyclopentane",
               "Peroxides start a radical chain: Br adds first to the less substituted carbon, so Br ends up there."),
        alkene("r03", "Acid-catalyzed hydration", "H₃O⁺", "1-methylcyclopentanol",
               "Markovnikov: OH goes to the more substituted carbon through the tertiary carbocation."),
        alkene("r04", "Hydration with sulfuric acid", "1) H₂SO₄ 2) H₂O, heat", "1-methylcyclopentanol",
               "H₂SO₄ adds Markovnikov; water then replaces the sulfate, so OH ends up on the more substituted carbon."),
        alkene("r05", "Oxymercuration–demercuration", "1) Hg(OAc)₂, H₂O 2) NaBH₄", "1-methylcyclopentanol",
               "Markovnikov OH without carbocation rearrangements."),
        alkene("r06", "Alkoxymercuration–demercuration", "1) Hg(OAc)₂, ROH 2) NaBH₄", "1-alkoxy-1-methylcyclopentane",
               "Like oxymercuration, but the alcohol (ROH) adds: a Markovnikov ether."),
        alkene("r07", "Hydroboration–oxidation", "1) BH₃·THF 2) H₂O₂, OH⁻", "2-methylcyclopentanol",
               "Anti-Markovnikov, syn addition: OH on the less substituted carbon."),
        alkene("r08", "Bromination", "Br₂, CCl₄", "trans-1,2-dibromo-1-methylcyclopentane",
               "Anti addition through a bromonium ion: the two Br atoms end up trans."),
        alkene("r09", "Halohydrin formation", "Br₂, H₂O", "2-bromo-1-methylcyclopentanol",
               "Water opens the bromonium ion at the more substituted carbon: OH there, Br anti on the other carbon."),
        alkene("r10", "Epoxidation", "MCPBA, CCl₄", "1-methylcyclopentene oxide",
               "A peroxyacid delivers one O to both carbons at once: an epoxide."),
        alkene("r11", "Anti dihydroxylation", "RCO₃H, H₂O", "trans-1-methylcyclopentane-1,2-diol",
               "The epoxide forms, then water opens it from the back: the two OH groups end up trans."),
        alkene("r12", "Cyclopropanation with diazomethane", "CH₂N₂", "1-methylbicyclo[3.1.0]hexane",
               "CH₂N₂ gives a carbene (:CH₂) that adds across the double bond: a cyclopropane."),
        alkene("r13", "Simmons–Smith cyclopropanation", "CH₂I₂, Zn(Cu)", "1-methylbicyclo[3.1.0]hexane",
               "CH₂I₂ and Zn(Cu) form a carbenoid that adds CH₂ across the double bond: a cyclopropane."),
        alkene("r14", "Dichlorocarbene addition", "CHCl₃, NaOH", "6,6-dichloro-1-methylbicyclo[3.1.0]hexane",
               "CHCl₃ and NaOH form :CCl₂, which adds to give a dichlorocyclopropane."),
        alkene("r15", "Catalytic hydrogenation", "H₂, Pt", "methylcyclopentane",
               "Two H atoms add from the same face: the alkane."),
        alkene("r16", "Syn dihydroxylation (OsO₄)", "1) OsO₄ 2) H₂O₂, OH⁻", "cis-1-methylcyclopentane-1,2-diol",
               "OsO₄ adds both oxygens from the same face: a cis diol."),
        alkene("r17", "Syn dihydroxylation (cold KMnO₄)", "KMnO₄, H₂O, neutral, cold", "cis-1-methylcyclopentane-1,2-diol",
               "Cold, neutral KMnO₄ also adds both OH groups from the same face: a cis diol."),
        alkene("r18", "Oxidative cleavage (hot KMnO₄)", "KMnO₄, OH⁻, warm, conc.", "5-oxohexanoic acid",
               "The double bond is cut: the carbon with an H becomes a carboxylic acid, the other a ketone."),
        alkene("r19", "Ozonolysis", "1) O₃ 2) Me₂S", "5-oxohexanal",
               "The double bond is cut; with Me₂S the carbon with an H becomes an aldehyde, the other a ketone."),
        metathesis("r20", "Ring-opening metathesis polymerization (ROMP)", "Grubbs catalyst", "ROMP polymer",
                   "Grubbs catalyst opens the strained ring and links the pieces into a polymer."),
        metathesis("r21", "Cross metathesis", "Grubbs catalyst", "3-ethyl-2-methylpent-2-ene",
                   "Grubbs catalyst swaps the alkene halves: a Me₂C= half joins an =CEt₂ half."),
        metathesis("r22", "Ring-closing metathesis", "Grubbs catalyst", "1-methylcyclopentene",
                   "The two ends of the diene join into a ring, releasing ethylene."),
        metathesis("r23", "Polymerization", "various reagents", "polyalkene",
                   "Alkene monomers add one after another to a growing chain.", reversible: false),
        alkyne("r24", .propyne, "Addition of 2 HBr", "2 HBr", "2,2-dibromopropane",
               "Markovnikov twice: both Br atoms end up on the more substituted carbon."),
        alkyne("r25", .propyne, "Anti-Markovnikov addition of HBr", "HBr, ROOR", "1-bromopropene",
               "Radical addition puts Br on the end carbon, giving a mix of E and Z alkenes."),
        alkyne("r26", .propyne, "Hydration (HgSO₄, H₂SO₄)", "HgSO₄, H₂SO₄", "acetone",
               "Markovnikov addition of water gives an enol, which tautomerizes to a ketone."),
        alkyne("r27", .propyne, "Hydroboration–oxidation", "1) Sia₂BH 2) H₂O₂, OH⁻", "propanal",
               "Anti-Markovnikov: the enol tautomerizes to an aldehyde. The bulky Sia₂BH adds only once."),
        alkyne("r28", .propyne, "Complete hydrogenation", "2 H₂, Pt", "propane",
               "Two H₂ add with Pt: all the way to the alkane."),
        alkyne("r29", .propyne, "Addition of 2 Br₂", "2 Br₂", "1,1,2,2-tetrabromopropane",
               "Two Br₂ add across the triple bond: a tetrabromide."),
        step("r35", 1, "Deprotonation with NaNH₂", "NaNH₂", "sodium propynide",
             "NaNH₂ removes the acidic terminal H: a sodium acetylide."),
        step("r36", 1, "Silver acetylide", "Ag⁺", "silver propynide",
             "Ag⁺ replaces the terminal H, forming a silver acetylide."),
        step("r37", 1, "Copper acetylide", "Cu⁺", "copper propynide",
             "Cu⁺ replaces the terminal H, forming a copper acetylide."),
        step("r35", 2, "Alkylation of an acetylide", "Et–Br", "2-pentyne",
             "The acetylide attacks Et–Br (SN2): a new C–C bond."),
        step("r36", 2, "Protonation", "HCl", "propyne",
             "HCl puts the H back: propyne again."),
        step("r37", 2, "Protonation", "HCl", "propyne",
             "HCl puts the H back: propyne again."),
        alkyne("r30", .butyne, "Lindlar reduction", "H₂, Lindlar catalyst", "cis-2-butene",
               "The poisoned catalyst stops at the alkene: syn addition gives the cis alkene."),
        alkyne("r31", .butyne, "Dissolving-metal reduction", "Na, NH₃", "trans-2-butene",
               "Na in NH₃ adds the H atoms one at a time: the trans alkene."),
        alkyne("r32", .butyne, "Oxidative cleavage (hot KMnO₄)", "KMnO₄, OH⁻, warm, conc.", "acetic acid",
               "The triple bond is cut: each carbon becomes a carboxylic acid."),
        alkyne("r33", .butyne, "Oxidation (neutral KMnO₄)", "KMnO₄, H₂O, neutral", "2,3-butanedione",
               "Under neutral conditions both carbons of the triple bond become C=O: a 1,2-diketone."),
        alkyne("r34", .butyne, "Ozonolysis", "1) O₃ 2) Me₂S", "acetic acid",
               "Ozonolysis cuts an internal alkyne into two carboxylic acids."),
    ]
}

// MARK: Drawing

/// One drawing from the textbook figure, at the same scale as the others (so the text sizes match),
/// shrinking only if it has to fit.
struct StructureImage: View {
    let name: String
    var scale: CGFloat = 1
    var label: String = ""

    var body: some View {
        let size = UIImage(named: name)?.size ?? CGSize(width: 100, height: 50)
        Image(name)
            .resizable()
            .interpolation(.high)
            .scaledToFit()
            .frame(maxWidth: size.width * scale, maxHeight: size.height * scale)
            .accessibilityLabel(label)
    }
}

/// A reaction arrow (or equilibrium arrows) with the reagents drawing above it
struct ReagentArrow: View {
    let reagentsImage: String?      // nil: a "?" for the reagents to name
    var reversible = false
    var scale: CGFloat = 1
    var label: String = ""

    var body: some View {
        VStack(spacing: 3) {
            if let reagentsImage {
                StructureImage(name: reagentsImage, scale: scale, label: label)
            } else {
                Text("?").font(.title.bold()).foregroundStyle(.orange)
            }
            Canvas { context, size in
                let y = size.height / 2
                var path = Path()
                if reversible {
                    path.move(to: CGPoint(x: 0, y: y - 2)); path.addLine(to: CGPoint(x: size.width, y: y - 2))
                    path.move(to: CGPoint(x: size.width - 7, y: y - 6)); path.addLine(to: CGPoint(x: size.width, y: y - 2))
                    path.move(to: CGPoint(x: size.width, y: y + 2)); path.addLine(to: CGPoint(x: 0, y: y + 2))
                    path.addLine(to: CGPoint(x: 7, y: y + 6))
                    context.stroke(path, with: .color(.black), lineWidth: 1.3)
                } else {
                    path.move(to: CGPoint(x: 0, y: y)); path.addLine(to: CGPoint(x: size.width - 2, y: y))
                    context.stroke(path, with: .color(.black), lineWidth: 1.5)
                    var head = Path()
                    head.move(to: CGPoint(x: size.width, y: y))
                    head.addLine(to: CGPoint(x: size.width - 9, y: y - 4))
                    head.addLine(to: CGPoint(x: size.width - 9, y: y + 4))
                    head.closeSubpath()
                    context.fill(head, with: .color(.black))
                }
            }
            .frame(height: 12)
        }
        .frame(minWidth: 56)
        .fixedSize()   // only as wide as the reagents, so the structures get the room
    }
}

/// White "paper" card the drawings sit on, in light and dark mode
struct PaperCard: ViewModifier {
    var highlight: Color? = nil
    func body(content: Content) -> some View {
        content
            .padding(8)
            .background(RoundedRectangle(cornerRadius: 12).fill(.white))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(highlight ?? .black.opacity(0.12), lineWidth: highlight == nil ? 1 : 3))
    }
}

extension View {
    func paperCard(highlight: Color? = nil) -> some View { modifier(PaperCard(highlight: highlight)) }
}
