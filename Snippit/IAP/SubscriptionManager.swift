import Foundation
import RevenueCat
import SwiftUI

/// Manages premium subscription state and usage limits via RevenueCat.
@MainActor
final class SubscriptionManager: ObservableObject {

    static let shared = SubscriptionManager()

    // MARK: - Published State

    @Published private(set) var isPremium = false
    @Published private(set) var offerings: Offerings?
    @Published private(set) var savesUsed: Int = 0

    // MARK: - Constants

    static let freeSaveLimit = 5
    static let entitlementID = "premium"

    var savesRemaining: Int {
        isPremium ? .max : max(0, Self.freeSaveLimit - savesUsed)
    }

    var canSave: Bool {
        isPremium || savesUsed < Self.freeSaveLimit
    }

    // MARK: - Init

    private init() {
        savesUsed = UserDefaults.standard.integer(forKey: "snippit_saves_used")
    }

    // MARK: - Configure

    func configure() {
        Purchases.logLevel = .warn
        Purchases.configure(withAPIKey: AppConfig.shared.revenueCat!.apiKey)

        Task {
            await refreshStatus()
            await loadOfferings()
        }
    }

    // MARK: - Status

    func refreshStatus() async {
        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            isPremium = customerInfo.entitlements[Self.entitlementID]?.isActive == true
        } catch {
            print("RevenueCat: failed to fetch status — \(error.localizedDescription)")
        }
    }

    // MARK: - Offerings

    func loadOfferings() async {
        do {
            offerings = try await Purchases.shared.offerings()
        } catch {
            print("RevenueCat: failed to load offerings — \(error.localizedDescription)")
        }
    }

    // MARK: - Purchase

    func purchase(package: Package) async throws {
        let result = try await Purchases.shared.purchase(package: package)
        isPremium = result.customerInfo.entitlements[Self.entitlementID]?.isActive == true
    }

    func restorePurchases() async throws {
        let customerInfo = try await Purchases.shared.restorePurchases()
        isPremium = customerInfo.entitlements[Self.entitlementID]?.isActive == true
    }

    // MARK: - Usage Tracking

    func recordSave() {
        guard !isPremium else { return }
        savesUsed += 1
        UserDefaults.standard.set(savesUsed, forKey: "snippit_saves_used")
    }
}
