//
//  StudySet.swift
//  Organic Games
//
//  Organic Games Plus: study sets drawn from organicchemistryguide.com, loaded from StudySets.json.
//

import Foundation
import Observation

struct StudySet: Codable, Identifiable, Hashable {
    enum Mode: String, Codable { case pairs, categories }

    struct Pair: Codable, Hashable { let a: String; let b: String }
    struct Item: Codable, Hashable { let text: String; let category: String }

    let id: String
    let title: String
    let chapter: String
    let chapterURL: URL
    let mode: Mode
    var pairs: [Pair]? = nil
    var categories: [String]? = nil
    var items: [Item]? = nil

    /// Stable key for each thing the student is learning (used for mastery)
    var keys: [String] {
        switch mode {
        case .pairs: return (pairs ?? []).map(\.a)
        case .categories: return (items ?? []).map(\.text)
        }
    }

    static let all: [StudySet] = {
        guard let url = Bundle.main.url(forResource: "StudySets", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let file = try? JSONDecoder().decode(File.self, from: data) else { return [] }
        return file.sets
    }()

    private struct File: Codable { let sets: [StudySet] }
}

/// What the student has learned, per item: mastered after three first-try answers in a row.
@Observable
final class MasteryStore {
    static let shared = MasteryStore()

    struct Record: Codable { var streak = 0; var misses = 0; var seen = 0 }

    private(set) var records: [String: [String: Record]] = [:]   // set id → item key → record
    private let key = "studyMastery"

    private init() {
        if let data = UserDefaults.standard.data(forKey: key),
           let saved = try? JSONDecoder().decode([String: [String: Record]].self, from: data) {
            records = saved
        }
    }

    static let streakToMaster = 3

    /// Each game keeps its own records under a set id (e.g. "ir-spectra"); items are keyed by name.
    func isMastered(_ item: String, setID: String) -> Bool {
        (records[setID]?[item]?.streak ?? 0) >= Self.streakToMaster
    }

    func masteredCount(setID: String, keys: [String]) -> Int { keys.filter { isMastered($0, setID: setID) }.count }

    /// Records one answer: right on the first try builds the streak; a miss resets it.
    func record(_ item: String, setID: String, firstTry: Bool) {
        var r = records[setID]?[item] ?? Record()
        r.seen += 1
        if firstTry { r.streak += 1 } else { r.streak = 0; r.misses += 1 }
        records[setID, default: [:]][item] = r
        save()
    }

    /// Weakest first: not yet mastered, most missed, least seen; shuffled within ties.
    func practiceOrder(setID: String, keys: [String]) -> [String] {
        keys.shuffled().sorted { a, b in
            let ra = records[setID]?[a] ?? Record(), rb = records[setID]?[b] ?? Record()
            let ma = ra.streak >= Self.streakToMaster, mb = rb.streak >= Self.streakToMaster
            if ma != mb { return !ma }
            if ra.misses != rb.misses { return ra.misses > rb.misses }
            return ra.seen < rb.seen
        }
    }

    func reset(setID: String) {
        records[setID] = nil
        save()
    }

    private func save() {
        if let data = try? JSONEncoder().encode(records) { UserDefaults.standard.set(data, forKey: key) }
    }
}
