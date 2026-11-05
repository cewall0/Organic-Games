//
//  PlusStore.swift
//  Organic Games
//
//  Organic Games Plus: an auto-renewing subscription that unlocks the study sets in full,
//  tracks mastery, and removes ads.
//

import StoreKit
import SwiftUI

@MainActor
@Observable
final class PlusStore {
    static let shared = PlusStore()

    static let productIDs = ["com.Wallace.OrganicGames.plus.semester", "com.Wallace.OrganicGames.plus.yearly",
                                    "com.Wallace.OrganicGames.plus.monthly"]
    static let termsURL = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!
    static let privacyURL = URL(string: "https://wallacewaysoftware.com/organic-games/privacy/")!

    private(set) var isPlus = false
    private var updates: Task<Void, Never>?

    private init() {
        #if DEBUG
        if CommandLine.arguments.contains("-plusDemo") { isPlus = true; return }
        #endif
        updates = Task { [weak self] in
            for await result in Transaction.updates {
                if case .verified(let transaction) = result { await transaction.finish() }
                await self?.refresh()
            }
        }
        Task { await refresh() }
    }

    func refresh() async {
        var active = false
        for await result in Transaction.currentEntitlements {
            if case .verified(let t) = result, Self.productIDs.contains(t.productID), t.revocationDate == nil {
                active = true
            }
        }
        isPlus = active
    }
}

/// The subscription screen. The billed price is the largest text on each plan and on the
/// buy button; the free trial is a smaller line under it (App Review guideline 3.1.2(c)).
struct PlusPaywall: View {
    @Environment(\.dismiss) private var dismiss

    @State private var products: [Product] = []
    @State private var trialEligible: Set<String> = []
    @State private var selectedID = "com.Wallace.OrganicGames.plus.yearly"
    @State private var purchasing = false
    @State private var errorText: String?

    private var selected: Product? { products.first { $0.id == selectedID } }

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                header
                if products.isEmpty {
                    ProgressView().padding(.vertical, 40)
                } else {
                    ForEach(products) { product in
                        PlanRow(product: product, trial: trial(for: product), isSelected: product.id == selectedID)
                            .onTapGesture { selectedID = product.id }
                    }
                }
                if let errorText {
                    Text(errorText).font(.footnote).foregroundStyle(.red)
                }
                if let selected {
                    Button { Task { await buy(selected) } } label: {
                        Text("Subscribe for \(selected.displayPrice)/\(Self.unit(selected))")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 6)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
                    .disabled(purchasing)
                    Text(terms(for: selected))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                Button("Restore Purchases") { Task { await restore() } }
                    .font(.subheadline)
                HStack(spacing: 20) {
                    Link("Terms of Use", destination: PlusStore.termsURL)
                    Link("Privacy Policy", destination: PlusStore.privacyURL)
                }
                .font(.caption)
            }
            .padding()
            .frame(maxWidth: 560)
            .frame(maxWidth: .infinity)
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) { Button("Close") { dismiss() } }
        }
        .task { await load() }
    }

    private var header: some View {
        VStack(spacing: 14) {
            Image(systemName: "graduationcap.fill")
                .font(.system(size: 52))
                .foregroundStyle(.orange)
                .accessibilityHidden(true)
            Text("Organic Games Plus")
                .font(.title.bold())
            VStack(alignment: .leading, spacing: 10) {
                Label("Study sets from the WallaceWay Organic textbook: IR, mass spec, reactions, synthesis", systemImage: "books.vertical.fill")
                Label("Tracks what you've mastered and drills your weak spots", systemImage: "chart.bar.fill")
                Label("New sets added through the semester", systemImage: "sparkles")
                Label("No ads", systemImage: "nosign")
            }
            .font(.subheadline)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    /// "3-day free trial" when this account can still get the product's introductory offer.
    private func trial(for product: Product) -> String? {
        guard trialEligible.contains(product.id),
              let offer = product.subscription?.introductoryOffer, offer.paymentMode == .freeTrial else { return nil }
        let p = offer.period
        let unit = switch p.unit {
        case .day: "day"
        case .week: "week"
        case .month: "month"
        case .year: "year"
        @unknown default: "day"
        }
        return "\(p.value)-\(unit) free trial"
    }

    private func terms(for product: Product) -> String {
        let renew = "\(product.displayPrice)/\(Self.unit(product)), renews automatically until you cancel in Settings at least 24 hours before the period ends."
        guard let trial = trial(for: product) else { return "Billed \(renew)" }
        return "Billed \(renew) Starts with a \(trial); cancel before it ends and you won't be charged."
    }

    /// "year", "month" or "6 months".
    static func unit(_ product: Product) -> String {
        guard let p = product.subscription?.subscriptionPeriod else { return "" }
        let name = switch p.unit {
        case .day: "day"
        case .week: "week"
        case .month: "month"
        case .year: "year"
        @unknown default: ""
        }
        return p.value == 1 ? name : "\(p.value) \(name)s"
    }

    private func load() async {
        do {
            let found = try await Product.products(for: PlusStore.productIDs)
            products = PlusStore.productIDs.compactMap { id in found.first { $0.id == id } }
            for p in products where await p.subscription?.isEligibleForIntroOffer == true {
                trialEligible.insert(p.id)
            }
            if products.isEmpty { errorText = "Couldn't load subscriptions. Check your connection and try again." }
        } catch {
            errorText = "Couldn't load subscriptions. Check your connection and try again."
        }
    }

    private func buy(_ product: Product) async {
        purchasing = true
        errorText = nil
        defer { purchasing = false }
        do {
            if case .success(let result) = try await product.purchase(), case .verified(let transaction) = result {
                await transaction.finish()
                await PlusStore.shared.refresh()
                dismiss()
            }
        } catch {
            errorText = "The purchase didn't go through. Please try again."
        }
    }

    private func restore() async {
        try? await AppStore.sync()
        await PlusStore.shared.refresh()
        if PlusStore.shared.isPlus { dismiss() } else { errorText = "No active Organic Games Plus subscription found for this Apple Account." }
    }
}

/// One plan: its price is the most prominent text; the trial is a smaller line beneath.
private struct PlanRow: View {
    let product: Product
    let trial: String?
    let isSelected: Bool

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(product.displayPrice) / \(PlusPaywall.unit(product))")
                    .font(.title2.bold())
                Text(product.displayName)
                    .font(.subheadline)
                if let trial {
                    Text(trial)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .font(.title2)
                .foregroundStyle(isSelected ? Color.orange : Color.secondary)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 14).fill(Color(.secondarySystemBackground)))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(isSelected ? Color.orange : .clear, lineWidth: 2))
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }
}
