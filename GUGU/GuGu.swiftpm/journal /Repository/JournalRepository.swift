import Foundation
import SwiftUI

class JournalRepository: ObservableObject {
    @Published private(set) var entries: [JournalEntry] = []
    
    // Cache for statistics
    private var _totalEntries: Int = 0
    private var _totalWordsWritten: Int = 0
    private var _daysJournaled: Int = 0
    
    private let userDefaults = UserDefaults.standard
    private let entriesKey = "journal_entries"
    
    init() {
        loadEntries()
        updateStatistics()
    }
    
    private func updateStatistics() {
        _totalEntries = entries.count
        _totalWordsWritten = entries.reduce(0) { $0 + $1.wordCount }
        _daysJournaled = Set(entries.map { Calendar.current.startOfDay(for: $0.date) }).count
    }
    
    func loadEntries() {
        if let data = userDefaults.data(forKey: entriesKey),
           let decoded = try? JSONDecoder().decode([JournalEntry].self, from: data) {
            entries = decoded
        }
    }
    
    func saveEntries() {
        if let encoded = try? JSONEncoder().encode(entries) {
            userDefaults.set(encoded, forKey: entriesKey)
        }
    }
    
    func addEntry(_ entry: JournalEntry) {
        entries.append(entry)
        updateStatistics()
        saveEntries()
    }
    
    func updateEntry(_ entry: JournalEntry) {
        if let index = entries.firstIndex(where: { $0.id == entry.id }) {
            entries[index] = entry
            updateStatistics()
            saveEntries()
        }
    }
    
    func deleteEntry(_ entry: JournalEntry) {
        entries.removeAll { $0.id == entry.id }
        updateStatistics()
        saveEntries()
    }
    
    // Cached statistics accessors
    var totalEntries: Int { _totalEntries }
    var totalWordsWritten: Int { _totalWordsWritten }
    var daysJournaled: Int { _daysJournaled }
    
    func searchEntries(matching query: String) -> [JournalEntry] {
        guard !query.isEmpty else { return entries }
        return entries.filter {
            $0.title.localizedCaseInsensitiveContains(query) ||
            $0.content.localizedCaseInsensitiveContains(query)
        }
    }
    
    func sortEntries(_ entries: [JournalEntry], by option: MainJournalView.SortOption) -> [JournalEntry] {
        entries.sorted { first, second in
            switch option {
            case .dateDesc:
                return first.date > second.date
            case .dateAsc:
                return first.date < second.date
            case .titleAsc:
                return first.title.localizedCompare(second.title) == .orderedAscending
            case .titleDesc:
                return first.title.localizedCompare(second.title) == .orderedDescending
            }
        }
    }
}


