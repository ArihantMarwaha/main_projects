//
//  SDJournalEntry.swift
//  GUGUios
//
//  SwiftData model for JournalEntry persistence
//

import Foundation
import SwiftData
import SwiftUI
import Combine

@Model
class SDJournalEntry {
    @Attribute(.unique) var id: UUID
    var title: String
    var content: String
    var date: Date
    var images: [String] // Base64 encoded image data
    var wordCount: Int
    var createdAt: Date
    var updatedAt: Date
    
    init(id: UUID = UUID(),
         title: String,
         content: String,
         date: Date = Date(),
         images: [String] = [],
         wordCount: Int? = nil) {
        self.id = id
        self.title = title
        self.content = content
        self.date = date
        self.images = images
        self.wordCount = wordCount ?? content.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }.count
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    // Convert to legacy JournalEntry model for compatibility
    func toLegacyJournalEntry() -> JournalEntry {
        return JournalEntry(
            id: id,
            title: title,
            content: content,
            date: date,
            images: images,
            wordCount: wordCount
        )
    }
    
    // Create from legacy JournalEntry model
    static func fromLegacyJournalEntry(_ entry: JournalEntry) -> SDJournalEntry {
        return SDJournalEntry(
            id: entry.id,
            title: entry.title,
            content: entry.content,
            date: entry.date,
            images: entry.images,
            wordCount: entry.wordCount
        )
    }
    
    // Computed properties
    var hasImages: Bool {
        !images.isEmpty
    }
    
    var uiImages: [UIImage] {
        images.compactMap { base64String in
            guard let imageData = Data(base64Encoded: base64String) else { return nil }
            return UIImage(data: imageData)
        }
    }
    
    // Helper methods
    func addImage(_ image: UIImage) {
        if let data = image.jpegData(compressionQuality: 0.8) {
            let base64String = data.base64EncodedString()
            images.append(base64String)
            updatedAt = Date()
        }
    }
    
    func removeImage(at index: Int) {
        guard index >= 0 && index < images.count else { return }
        images.remove(at: index)
        updatedAt = Date()
    }
    
    func updateWordCount() {
        wordCount = content.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .count
        updatedAt = Date()
    }
}
