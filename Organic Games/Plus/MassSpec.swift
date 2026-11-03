//
//  MassSpec.swift
//  Organic Games
//
//  Mass spec isotope patterns (section 3.1 on organicchemistryguide.com): real compounds students meet,
//  drawn as stick spectra. The question is which special atom the pattern shows; the name is never shown.
//

import Foundation

enum MSAtom: String, CaseIterable, Identifiable {
    case bromine = "Br", chlorine = "Cl", iodine = "I", sulfur = "S", nitrogen = "N", choOnly = "Only C, H, O"
    var id: String { rawValue }

    /// Why, in the textbook's words
    var hint: String {
        switch self {
        case .bromine: return "An M⁺ and an M+2 peak with equal heights indicates a bromine atom."
        case .chlorine: return "The M+2 peak is about 1/3 the height of the M⁺ peak: chlorine (75% ³⁵Cl, 25% ³⁷Cl)."
        case .iodine: return "Iodine has only one isotope, so there is no M+2 – look for a peak at 127 and a big M⁺ − 127 peak."
        case .sulfur: return "An M+2 peak that is larger than usual (about 4% of M⁺) indicates sulfur."
        case .nitrogen: return "An odd molecular mass means an odd number of nitrogen atoms."
        case .choOnly: return "Even mass, a small M+1 from carbon-13 and no M+2: only C, H and O."
        }
    }
}

struct MSPeak: Hashable {
    let mz: Int
    let intensity: Double   // relative abundance, base peak = 100
}

struct MSCompound: Hashable {
    let name: String        // for the answer reveal and for reviewing the data; not shown in the question
    let atom: MSAtom
    let mass: Int           // M⁺, most abundant isotopes
    let carbons: Int
    let molecularIon: Double              // M⁺ height relative to the base peak
    let fragments: [MSPeak]               // typical fragment peaks (one of them may be the base peak, 100)

    /// All peaks: fragments plus the M⁺ cluster with isotope peaks from the textbook's abundances.
    var peaks: [MSPeak] {
        let m = molecularIon
        var cluster = [MSPeak(mz: mass, intensity: m)]
        var plusOne = m * 0.011 * Double(carbons)              // ~1% carbon-13 per carbon
        if atom == .sulfur { plusOne += m * 0.008 }
        if atom == .nitrogen { plusOne += m * 0.004 }
        cluster.append(MSPeak(mz: mass + 1, intensity: plusOne))
        switch atom {
        case .bromine: cluster.append(MSPeak(mz: mass + 2, intensity: m * 0.98))   // nearly equal ⁷⁹Br / ⁸¹Br
        case .chlorine: cluster.append(MSPeak(mz: mass + 2, intensity: m * 0.32))  // about 1/3
        case .sulfur: cluster.append(MSPeak(mz: mass + 2, intensity: m * 0.044))   // ³⁴S about 4.2–4.4%
        default: break
        }
        return (fragments + cluster).filter { $0.intensity >= 0.3 }
    }

    /// Where the giveaway is, for the highlight after a miss
    var giveaway: [Int] {
        switch atom {
        case .iodine: return [127, mass - 127, mass]
        case .bromine, .chlorine, .sulfur: return [mass, mass + 2]
        case .nitrogen, .choOnly: return [mass, mass + 1]
        }
    }

    static let all: [MSCompound] = [
        // Bromine: M and M+2 about equal; the base peak is often the alkyl cation after losing Br
        MSCompound(name: "bromomethane", atom: .bromine, mass: 94, carbons: 1, molecularIon: 100, fragments: [MSPeak(mz: 15, intensity: 12), MSPeak(mz: 79, intensity: 9), MSPeak(mz: 81, intensity: 9)]),
        MSCompound(name: "bromoethane", atom: .bromine, mass: 108, carbons: 2, molecularIon: 55, fragments: [MSPeak(mz: 29, intensity: 100), MSPeak(mz: 27, intensity: 45), MSPeak(mz: 28, intensity: 12)]),
        MSCompound(name: "1-bromopropane", atom: .bromine, mass: 122, carbons: 3, molecularIon: 25, fragments: [MSPeak(mz: 43, intensity: 100), MSPeak(mz: 41, intensity: 55), MSPeak(mz: 27, intensity: 40)]),
        MSCompound(name: "bromobenzene", atom: .bromine, mass: 156, carbons: 6, molecularIon: 65, fragments: [MSPeak(mz: 77, intensity: 100), MSPeak(mz: 51, intensity: 35), MSPeak(mz: 50, intensity: 18)]),
        // Chlorine: M+2 about 1/3 of M
        MSCompound(name: "chloromethane", atom: .chlorine, mass: 50, carbons: 1, molecularIon: 100, fragments: [MSPeak(mz: 15, intensity: 25), MSPeak(mz: 35, intensity: 8), MSPeak(mz: 49, intensity: 10)]),
        MSCompound(name: "chloroethane", atom: .chlorine, mass: 64, carbons: 2, molecularIon: 100, fragments: [MSPeak(mz: 29, intensity: 80), MSPeak(mz: 28, intensity: 70), MSPeak(mz: 27, intensity: 60)]),
        MSCompound(name: "1-chlorobutane", atom: .chlorine, mass: 92, carbons: 4, molecularIon: 8, fragments: [MSPeak(mz: 56, intensity: 100), MSPeak(mz: 41, intensity: 55), MSPeak(mz: 43, intensity: 30), MSPeak(mz: 27, intensity: 35)]),
        MSCompound(name: "chlorobenzene", atom: .chlorine, mass: 112, carbons: 6, molecularIon: 100, fragments: [MSPeak(mz: 77, intensity: 60), MSPeak(mz: 51, intensity: 20), MSPeak(mz: 50, intensity: 12)]),
        // Iodine: no M+2; a peak at 127 and a big M - 127
        MSCompound(name: "iodomethane", atom: .iodine, mass: 142, carbons: 1, molecularIon: 100, fragments: [MSPeak(mz: 127, intensity: 40), MSPeak(mz: 15, intensity: 20), MSPeak(mz: 141, intensity: 12)]),
        MSCompound(name: "iodoethane", atom: .iodine, mass: 156, carbons: 2, molecularIon: 85, fragments: [MSPeak(mz: 29, intensity: 100), MSPeak(mz: 127, intensity: 25), MSPeak(mz: 27, intensity: 40)]),
        MSCompound(name: "1-iodopropane", atom: .iodine, mass: 170, carbons: 3, molecularIon: 45, fragments: [MSPeak(mz: 43, intensity: 100), MSPeak(mz: 127, intensity: 18), MSPeak(mz: 41, intensity: 35), MSPeak(mz: 27, intensity: 30)]),
        MSCompound(name: "iodobenzene", atom: .iodine, mass: 204, carbons: 6, molecularIon: 100, fragments: [MSPeak(mz: 77, intensity: 60), MSPeak(mz: 127, intensity: 10), MSPeak(mz: 51, intensity: 25)]),
        // Sulfur: M+2 about 4% of M (larger than usual)
        MSCompound(name: "dimethyl sulfide", atom: .sulfur, mass: 62, carbons: 2, molecularIon: 100, fragments: [MSPeak(mz: 47, intensity: 85), MSPeak(mz: 45, intensity: 40), MSPeak(mz: 46, intensity: 25)]),
        MSCompound(name: "1-propanethiol", atom: .sulfur, mass: 76, carbons: 3, molecularIon: 70, fragments: [MSPeak(mz: 47, intensity: 60), MSPeak(mz: 43, intensity: 45), MSPeak(mz: 42, intensity: 100), MSPeak(mz: 41, intensity: 40)]),
        MSCompound(name: "thiophene", atom: .sulfur, mass: 84, carbons: 4, molecularIon: 100, fragments: [MSPeak(mz: 58, intensity: 60), MSPeak(mz: 45, intensity: 35), MSPeak(mz: 39, intensity: 20)]),
        MSCompound(name: "diethyl sulfide", atom: .sulfur, mass: 90, carbons: 4, molecularIon: 70, fragments: [MSPeak(mz: 75, intensity: 100), MSPeak(mz: 62, intensity: 65), MSPeak(mz: 47, intensity: 60), MSPeak(mz: 29, intensity: 30)]),
        // Nitrogen: odd molecular mass (one N)
        MSCompound(name: "methylamine", atom: .nitrogen, mass: 31, carbons: 1, molecularIon: 70, fragments: [MSPeak(mz: 30, intensity: 100), MSPeak(mz: 28, intensity: 50), MSPeak(mz: 15, intensity: 10)]),
        MSCompound(name: "propylamine", atom: .nitrogen, mass: 59, carbons: 3, molecularIon: 8, fragments: [MSPeak(mz: 30, intensity: 100), MSPeak(mz: 28, intensity: 10), MSPeak(mz: 41, intensity: 8)]),
        MSCompound(name: "pyridine", atom: .nitrogen, mass: 79, carbons: 5, molecularIon: 100, fragments: [MSPeak(mz: 52, intensity: 75), MSPeak(mz: 51, intensity: 35), MSPeak(mz: 50, intensity: 20)]),
        MSCompound(name: "aniline", atom: .nitrogen, mass: 93, carbons: 6, molecularIon: 100, fragments: [MSPeak(mz: 66, intensity: 35), MSPeak(mz: 65, intensity: 18), MSPeak(mz: 39, intensity: 15)]),
        MSCompound(name: "triethylamine", atom: .nitrogen, mass: 101, carbons: 6, molecularIon: 18, fragments: [MSPeak(mz: 86, intensity: 100), MSPeak(mz: 58, intensity: 35), MSPeak(mz: 30, intensity: 30)]),
        // Only C, H, O: even mass, small M+1, no M+2
        MSCompound(name: "ethanol", atom: .choOnly, mass: 46, carbons: 2, molecularIon: 20, fragments: [MSPeak(mz: 31, intensity: 100), MSPeak(mz: 45, intensity: 50), MSPeak(mz: 29, intensity: 25)]),
        MSCompound(name: "acetone", atom: .choOnly, mass: 58, carbons: 3, molecularIon: 60, fragments: [MSPeak(mz: 43, intensity: 100), MSPeak(mz: 15, intensity: 25)]),
        MSCompound(name: "2-butanone", atom: .choOnly, mass: 72, carbons: 4, molecularIon: 25, fragments: [MSPeak(mz: 43, intensity: 100), MSPeak(mz: 29, intensity: 25), MSPeak(mz: 57, intensity: 8)]),
        MSCompound(name: "hexane", atom: .choOnly, mass: 86, carbons: 6, molecularIon: 15, fragments: [MSPeak(mz: 57, intensity: 100), MSPeak(mz: 43, intensity: 80), MSPeak(mz: 41, intensity: 70), MSPeak(mz: 29, intensity: 45)]),
        MSCompound(name: "toluene", atom: .choOnly, mass: 92, carbons: 7, molecularIon: 65, fragments: [MSPeak(mz: 91, intensity: 100), MSPeak(mz: 65, intensity: 12), MSPeak(mz: 39, intensity: 10)]),
    ]
}
