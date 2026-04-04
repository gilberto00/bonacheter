//
//  ListSyncService.swift
//  BonAcheter
//
//  Abstraction for real-time shared list (Supabase Realtime / Firebase).
//  MVP ships `LocalOnlyListSyncService`; swap implementation when backend is configured.
//

import Foundation

/// Publishes list changes to other household members (future: WebSocket / Supabase channel).
protocol ListSyncServicing: AnyObject {
    var isConnected: Bool { get }
    func start(householdId: String, onRemoteList: @escaping ([ListItem]) -> Void)
    func stop()
    /// Push local list to server / channel (no-op locally).
    func publishList(_ items: [ListItem])
}

/// Default: no network; list is device-local until Supabase (see docs).
final class LocalOnlyListSyncService: ListSyncServicing {
    private(set) var isConnected: Bool = false
    
    func start(householdId: String, onRemoteList: @escaping ([ListItem]) -> Void) {
        isConnected = false
        _ = householdId
        _ = onRemoteList
    }
    
    func stop() {
        isConnected = false
    }
    
    func publishList(_ items: [ListItem]) {
        _ = items
    }
}
