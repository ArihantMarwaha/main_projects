import SwiftUI
import PhotosUI
import Combine

struct JournalEntryDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var repository: JournalRepository
    @State private var entry: JournalEntry
    @State private var showingImagePicker = false
    
    // Editing states
    @State private var editedTitle: String
    @State private var editedContent: String
    @State private var editedImages: [String]
    
    init(entry: JournalEntry, repository: JournalRepository) {
        self.repository = repository
        _entry = State(initialValue: entry)
        _editedTitle = State(initialValue: entry.title)
        _editedContent = State(initialValue: entry.content)
        _editedImages = State(initialValue: entry.images)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                TextField("Title", text: $editedTitle)
                    .font(.title.weight(.bold))
                    .padding(.horizontal, 16)
                
                Divider()
                    .padding(.horizontal, 16)
                
                TextEditor(text: $editedContent)
                    .font(.body)
                    .frame(minHeight: 200)
                    .padding(.horizontal, 12)
                
                Divider()
                    .padding(.horizontal, 16)
                
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Images")
                            .font(.headline)
                        Spacer()
                        Button(action: { showingImagePicker = true }) {
                            Label("Add Image", systemImage: "plus.circle.fill")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    if !editedImages.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(editedImages.indices, id: \.self) { index in
                                    if let imageData = Data(base64Encoded: editedImages[index]),
                                       let uiImage = UIImage(data: imageData) {
                                        ZStack(alignment: .topTrailing) {
                                            Image(uiImage: uiImage)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 120, height: 120)
                                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                            
                                            Button(action: {
                                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                    deleteImage(at: index)
                                                }
                                            }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .font(.system(size: 22))
                                                    .symbolRenderingMode(.palette)
                                                    .foregroundStyle(.white, Color(.systemGray3))
                                                    .shadow(radius: 1)
                                            }
                                            .padding(8)
                                        }
                                        .transition(.scale.combined(with: .opacity))
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: editedImages.count)
                        }
                    } else {
                        Text("Add images to your journal entry")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .transition(.opacity)
                    }
                }
                
                Text(entry.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 16)
            }
            .padding(.vertical, 16)
        }
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: editedTitle) { _ in saveChanges() }
        .onChange(of: editedContent) { _ in saveChanges() }
        .onChange(of: editedImages) { _ in saveChanges() }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(images: $editedImages)
        }
        .transition(.asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        ))
    }
    
    private func deleteImage(at index: Int) {
        editedImages.remove(at: index)
        saveChanges()
    }
    
    private func saveChanges() {
        let updatedEntry = JournalEntry(
            id: entry.id,
            title: editedTitle,
            content: editedContent,
            date: entry.date,
            images: editedImages
        )
        repository.updateEntry(updatedEntry)
        entry = updatedEntry
    }
}

