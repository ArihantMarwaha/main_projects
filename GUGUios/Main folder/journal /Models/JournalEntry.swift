import Foundation
import UIKit
import Combine

struct JournalEntry: Identifiable, Codable, Equatable {
    var id: UUID
    var title: String
    var content: String
    var date: Date
    var images: [String] // Base64 encoded image data
    var wordCount: Int
    
    init(id: UUID = UUID(), title: String, content: String, date: Date = Date(), images: [String] = [], wordCount: Int? = nil) {
        self.id = id
        self.title = title
        self.content = content
        self.date = date
        self.images = images
        self.wordCount = wordCount ?? content.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }.count
    }
    
    var uiImages: [UIImage] {
        images.compactMap { base64String in
            guard let imageData = Data(base64Encoded: base64String) else { return nil }
            return UIImage(data: imageData)
        }
    }
    
    static func == (lhs: JournalEntry, rhs: JournalEntry) -> Bool {
        lhs.id == rhs.id &&
        lhs.title == rhs.title &&
        lhs.content == rhs.content &&
        lhs.date == rhs.date &&
        lhs.images == rhs.images &&
        lhs.wordCount == rhs.wordCount
    }
}
