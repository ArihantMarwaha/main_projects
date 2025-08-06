//
//  SwiftDataJournalRepository.swift
//  GUGUios
//
//  SwiftData repository for Journal management
//

import Foundation
import SwiftData
import SwiftUI
import Combine

@MainActor
class SwiftDataJournalRepository: ObservableObject {
    private let modelContext: ModelContext
    
    @Published private(set) var entries: [SDJournalEntry] = []
    @Published private(set) var isLoading = false
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadEntries()
    }
    
    // MARK: - Entry Management
    
    func loadEntries() {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let descriptor = FetchDescriptor<SDJournalEntry>(
                sortBy: [SortDescriptor(\.date, order: .reverse)]
            )
            entries = try modelContext.fetch(descriptor)
        } catch {
            print("Failed to load journal entries: \(error)")
            entries = []
        }
    }
    
    func addEntry(_ entry: SDJournalEntry) throws {
        modelContext.insert(entry)
        try modelContext.save()
        loadEntries()
    }
    
    func updateEntry(_ entry: SDJournalEntry) throws {
        entry.updatedAt = Date()
        try modelContext.save()
        loadEntries()
    }
    
    func deleteEntry(_ entry: SDJournalEntry) throws {
        modelContext.delete(entry)
        try modelContext.save()
        loadEntries()
    }
    
    // MARK: - Search and Filter
    
    func searchEntries(matching query: String) -> [SDJournalEntry] {
        guard !query.isEmpty else { return entries }
        
        do {
            let descriptor = FetchDescriptor<SDJournalEntry>(
                predicate: #Predicate<SDJournalEntry> { entry in
                    entry.title.localizedStandardContains(query) ||
                    entry.content.localizedStandardContains(query)
                },
                sortBy: [SortDescriptor(\.date, order: .reverse)]
            )
            return try modelContext.fetch(descriptor)
        } catch {
            print("Failed to search journal entries: \(error)")
            return []
        }
    }
    
    func getEntriesForDateRange(from startDate: Date, to endDate: Date) -> [SDJournalEntry] {
        do {
            let descriptor = FetchDescriptor<SDJournalEntry>(
                predicate: #Predicate<SDJournalEntry> { entry in
                    entry.date >= startDate && entry.date <= endDate
                },
                sortBy: [SortDescriptor(\.date, order: .reverse)]
            )
            return try modelContext.fetch(descriptor)
        } catch {
            print("Failed to load entries for date range: \(error)")
            return []
        }
    }
    
    func getEntriesForMonth(year: Int, month: Int) -> [SDJournalEntry] {
        let calendar = Calendar.current
        let startComponents = DateComponents(year: year, month: month, day: 1)
        let endComponents = DateComponents(year: year, month: month + 1, day: 1)
        
        guard let startDate = calendar.date(from: startComponents),
              let endDate = calendar.date(from: endComponents) else {
            return []
        }
        
        return getEntriesForDateRange(from: startDate, to: endDate)
    }
    
    func getEntriesWithImages() -> [SDJournalEntry] {
        do {
            let descriptor = FetchDescriptor<SDJournalEntry>(
                predicate: #Predicate<SDJournalEntry> { entry in
                    !entry.images.isEmpty
                },
                sortBy: [SortDescriptor(\.date, order: .reverse)]
            )
            return try modelContext.fetch(descriptor)
        } catch {
            print("Failed to load entries with images: \(error)")
            return []
        }
    }
    
    // Note: Mood functionality removed as it's not in the base JournalEntry model
    // This method is kept for potential future use but returns all entries for now
    func getEntriesByWordCount(minimumWords: Int) -> [SDJournalEntry] {
        do {
            let descriptor = FetchDescriptor<SDJournalEntry>(
                predicate: #Predicate<SDJournalEntry> { entry in
                    entry.wordCount >= minimumWords
                },
                sortBy: [SortDescriptor(\.date, order: .reverse)]
            )
            return try modelContext.fetch(descriptor)
        } catch {
            print("Failed to load entries by word count: \(error)")
            return []
        }
    }
    
    // MARK: - Statistics
    
    var totalEntries: Int {
        entries.count
    }
    
    var totalWordsWritten: Int {
        entries.reduce(0) { $0 + $1.wordCount }
    }
    
    var daysJournaled: Int {
        let uniqueDates = Set(entries.map { Calendar.current.startOfDay(for: $0.date) })
        return uniqueDates.count
    }
    
    func getAverageWordCount() -> Double {
        guard !entries.isEmpty else { return 0.0 }
        let totalWords = entries.reduce(0) { $0 + $1.wordCount }
        return Double(totalWords) / Double(entries.count)
    }
    
    func getEntriesCountForLast30Days() -> Int {
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        return entries.filter { $0.date >= thirtyDaysAgo }.count
    }
    
    func getWritingStreak() -> Int {
        let calendar = Calendar.current
        let sortedEntries = entries.sorted { $0.date > $1.date }
        
        var streak = 0
        var currentDate = Date()
        
        for entry in sortedEntries {
            let entryDate = calendar.startOfDay(for: entry.date)
            let checkDate = calendar.startOfDay(for: currentDate)
            
            if calendar.isDate(entryDate, inSameDayAs: checkDate) {
                streak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else if entryDate < checkDate {
                break
            }
        }
        
        return streak
    }
    
    // MARK: - Compatibility Methods (for gradual migration)
    
    func toLegacyEntries() -> [JournalEntry] {
        return entries.map { $0.toLegacyJournalEntry() }
    }
    
    // MARK: - Sorting
    
    enum SortOption: CaseIterable {
        case dateDesc, dateAsc, titleAsc, titleDesc
        
        var title: String {
            switch self {
            case .dateDesc: return "Date (Newest First)"
            case .dateAsc: return "Date (Oldest First)"
            case .titleAsc: return "Title (A-Z)"
            case .titleDesc: return "Title (Z-A)"
            }
        }
    }
    
    func sortEntries(_ entries: [SDJournalEntry], by option: SortOption) -> [SDJournalEntry] {
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
    
    // MARK: - Export/Import
    
    func exportToJSON() throws -> Data {
        let exportData = entries.map { entry in
            [
                "id": entry.id.uuidString,
                "title": entry.title,
                "content": entry.content,
                "date": ISO8601DateFormatter().string(from: entry.date),
                "images": entry.images,
                "wordCount": entry.wordCount,
                "hasImages": entry.hasImages,
                "createdAt": ISO8601DateFormatter().string(from: entry.createdAt),
                "updatedAt": ISO8601DateFormatter().string(from: entry.updatedAt)
            ]
        }
        
        return try JSONSerialization.data(withJSONObject: exportData, options: .prettyPrinted)
    }
    
    func exportToCSV() throws -> String {
        var csv = "ID,Title,Content,Date,Word Count,Has Images,Image Count,Created At,Updated At\n"
        
        let dateFormatter = ISO8601DateFormatter()
        
        for entry in entries {
            let cleanContent = entry.content.replacingOccurrences(of: "\"", with: "\"\"")
            let cleanTitle = entry.title.replacingOccurrences(of: "\"", with: "\"\"")
            
            csv += "\"\(entry.id.uuidString)\","
            csv += "\"\(cleanTitle)\","
            csv += "\"\(cleanContent)\","
            csv += "\"\(dateFormatter.string(from: entry.date))\","
            csv += "\(entry.wordCount),"
            csv += "\(entry.hasImages),"
            csv += "\(entry.images.count),"
            csv += "\"\(dateFormatter.string(from: entry.createdAt))\","
            csv += "\"\(dateFormatter.string(from: entry.updatedAt))\"\n"
        }
        
        return csv
    }
}
