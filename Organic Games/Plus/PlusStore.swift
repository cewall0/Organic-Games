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

    static let productIDs = ["com.Wallace.OrganicGames.plus.semester", "com.Wallace.OrganicGames.plus.monthly"]
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

/// Apple's subscription screen: prices, trial terms, Restore Purchases and policy links.
struct PlusPaywall: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        SubscriptionStoreView(productIDs: PlusStore.productIDs) {
            VStack(spacing: 14) {
                Image(systemName: "graduationcap.fill")
                    .font(.system(size: 52))
                    .foregroundStyle(.orange)
                    .accessibilityHidden(true)
                Text("Organic Games Plus")
                    .font(.title.bold())
                VStack(alignment: .leading, spacing: 10) {
                    Label("Study sets from the WallaceWay Organic textbook: IR, reactions, mechanisms", systemImage: "books.vertical.fill")
                    Label("Tracks what you've mastered and drills your weak spots", systemImage: "chart.bar.fill")
                    Label("New sets added through the semester", systemImage: "sparkles")
                    Label("No ads", systemImage: "nosign")
                }
                .font(.subheadline)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
        }
        .storeButton(.visible, for: .restorePurchases)
        .storeButton(.visible, for: .policies)
        .subscriptionStorePolicyDestination(url: PlusStore.termsURL, for: .termsOfService)
        .subscriptionStorePolicyDestination(url: PlusStore.privacyURL, for: .privacyPolicy)
        .subscriptionStoreControlStyle(.prominentPicker)
        .onInAppPurchaseCompletion { _, result in
            if case .success(.success) = result {
                await PlusStore.shared.refresh()
                dismiss()
            }
        }
    }
}
