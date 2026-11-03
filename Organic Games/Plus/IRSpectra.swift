//
//  IRSpectra.swift
//  Organic Games
//
//  Generic IR spectra (from Problem 5 of section 3.2 on organicchemistryguide.com), described as peaks
//  and drawn by SpectrumView in the same style as the textbook's drawings.
//

import Foundation

struct IRPeak: Hashable {
    let center: Double        // cm⁻¹
    let halfWidth: Double     // half-width where the peak meets the top of the frame (cm⁻¹)
    let depth: Double         // 0 = top of the frame, 1 = bottom
    var rightHalfWidth: Double? = nil   // for a lopsided peak (carboxylic acid O–H)
    var group: String? = nil  // peaks in the same group overlap into one shape (the NH₂ humps)
}

/// A shallow feature drawn from a baseline at the top of the frame (N–H shoulder, aromatic overtones).
struct IRSoftPeak: Hashable {
    let center: Double
    let sigma: Double
    let depth: Double
}

struct IRSpectrum: Identifiable, Hashable {
    let id: String              // the answer, e.g. "alcohol"
    let peaks: [IRPeak]
    var soft: [IRSoftPeak] = []
    let hint: String            // what gives it away, in the textbook's words
    let highlight: [ClosedRange<Double>]   // the giveaway regions, cm⁻¹

    private static let ch = IRPeak(center: 2925, halfWidth: 62, depth: 0.75)   // sp³ C–H, in almost every spectrum
    private static let nhShoulder = [IRSoftPeak(center: 3560, sigma: 90, depth: 0.15), IRSoftPeak(center: 3420, sigma: 110, depth: 0.20),
                                     IRSoftPeak(center: 3250, sigma: 95, depth: 0.17), IRSoftPeak(center: 3380, sigma: 12, depth: 0.08)]

    static let all: [IRSpectrum] = [
        IRSpectrum(id: "alcohol",
                   peaks: [IRPeak(center: 3390, halfWidth: 300, depth: 0.72), ch, IRPeak(center: 1115, halfWidth: 55, depth: 0.72)],
                   hint: "O–H near 3300 is very broad and strong, with a C–O near 1100 and no C=O.",
                   highlight: [3050...3700, 1050...1180]),
        IRSpectrum(id: "aldehyde",
                   peaks: [IRPeak(center: 2925, halfWidth: 55, depth: 0.75), IRPeak(center: 2812, halfWidth: 30, depth: 0.45),
                           IRPeak(center: 2722, halfWidth: 30, depth: 0.45), IRPeak(center: 1725, halfWidth: 52, depth: 0.97)],
                   hint: "C=O in the 1720s plus two C–H peaks near 2700 and 2800 – they must come with the C=O.",
                   highlight: [2680...2850, 1670...1780]),
        IRSpectrum(id: "primary amine (NH₂)",
                   peaks: [IRPeak(center: 3492, halfWidth: 100, depth: 0.62, group: "nh2"),
                           IRPeak(center: 3272, halfWidth: 95, depth: 0.58, group: "nh2"), ch],
                   hint: "One spike per N–H: two humps near 3300 means NH₂.",
                   highlight: [3150...3620]),
        IRSpectrum(id: "aromatic nitrile",
                   peaks: [IRPeak(center: 3070, halfWidth: 62, depth: 0.55), IRPeak(center: 2920, halfWidth: 62, depth: 0.75),
                           IRPeak(center: 2285, halfWidth: 58, depth: 0.60)],
                   soft: [2030, 1975, 1920, 1865].map { IRSoftPeak(center: $0, sigma: 14, depth: 0.05) },
                   hint: "C≡N just above 2200 is sharp; sp² C–H above 3000 and overtones below 2000 point to an aromatic ring.",
                   highlight: [2220...2350, 3010...3130, 1840...2060]),
        IRSpectrum(id: "alkene",
                   peaks: [IRPeak(center: 3062, halfWidth: 40, depth: 0.27), IRPeak(center: 2925, halfWidth: 65, depth: 0.75),
                           IRPeak(center: 1655, halfWidth: 24, depth: 0.64)],
                   hint: "C=C near 1650, weaker than a C=O, with sp² C–H just above 3000.",
                   highlight: [1620...1690, 3020...3110]),
        IRSpectrum(id: "terminal alkyne",
                   peaks: [IRPeak(center: 3300, halfWidth: 45, depth: 0.72), ch, IRPeak(center: 2155, halfWidth: 32, depth: 0.42)],
                   hint: "Sharp ≡C–H near 3300 that only appears together with the C≡C just below 2200.",
                   highlight: [3250...3350, 2120...2190]),
        IRSpectrum(id: "carboxylic acid",
                   peaks: [IRPeak(center: 2995, halfWidth: 300, depth: 0.45, rightHalfWidth: 590), IRPeak(center: 1712, halfWidth: 52, depth: 0.97)],
                   hint: "A very broad O–H centered near 3000 together with a strong C=O near 1700–1720.",
                   highlight: [2400...3300, 1660...1760]),
        IRSpectrum(id: "secondary amine (–NH)",
                   peaks: [ch], soft: nhShoulder,
                   hint: "A single N–H spike near 3300 (one spike per N–H) and no C=O.",
                   highlight: [3150...3650]),
        IRSpectrum(id: "ketone",
                   peaks: [ch, IRPeak(center: 1717, halfWidth: 55, depth: 0.97)],
                   hint: "A strong C=O at 1700–1720 and nothing else: no O–H, no aldehyde C–H, no C–O.",
                   highlight: [1660...1770]),
        IRSpectrum(id: "ether",
                   peaks: [ch, IRPeak(center: 1078, halfWidth: 60, depth: 0.85)],
                   hint: "A strong C–O near 1100 with no O–H and no C=O.",
                   highlight: [1010...1150]),
        IRSpectrum(id: "amide (CONH)",
                   peaks: [ch, IRPeak(center: 1672, halfWidth: 58, depth: 0.97)], soft: nhShoulder,
                   hint: "C=O in the 1660s (lower than a ketone) plus an N–H near 3300.",
                   highlight: [1610...1730, 3150...3650]),
        IRSpectrum(id: "ester",
                   peaks: [ch, IRPeak(center: 1742, halfWidth: 55, depth: 0.97),
                           IRPeak(center: 1245, halfWidth: 58, depth: 0.70), IRPeak(center: 1062, halfWidth: 50, depth: 0.70)],
                   hint: "C=O in the 1730s plus two C–O peaks near 1250 and 1050.",
                   highlight: [1690...1800, 1000...1310]),
    ]

    /// Height of the curve at a wavenumber: 0 = top of the frame, 1 = bottom. Same math as the prototype that
    /// was matched against the textbook drawings: the baseline sits above the frame, so peaks have steep sides.
    func absorbance(at wn: Double) -> Double {
        let offset = 0.6
        var groups: [String: Double] = [:]
        for (i, p) in peaks.enumerated() {
            let hw = (p.rightHalfWidth != nil && wn < p.center) ? p.rightHalfWidth! : p.halfWidth
            let a = (p.depth + offset) / (1 + offset)
            let sigma = hw / log(a * (1 + offset) / offset).squareRoot()
            let key = p.group ?? "\(i)"
            groups[key, default: 1] *= 1 - a * exp(-pow((wn - p.center) / sigma, 2))
        }
        let walls = groups.values.map { (1 - $0) * (1 + offset) - offset }.max() ?? 0
        let shallow = soft.reduce(0) { $0 + $1.depth * exp(-pow((wn - $1.center) / $1.sigma, 2)) }
        return min(1, max(0, max(walls, shallow)))
    }
}
