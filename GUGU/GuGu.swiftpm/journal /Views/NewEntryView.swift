import SwiftUI
import PhotosUI

struct NewEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var repository: JournalRepository
    
    @State private var title = ""
    @State private var content = ""
    @State private var showingImagePicker = false
    @State private var images: [String] = []
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    titleSection
                    contentSection
                    imagesSection
                }
            }
            .navigationTitle("New Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                toolbarButtons
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(images: $images)
            }
        }
    }
    
    private var titleSection: some View {
        VStack {
            TextField("Title", text: $title)
                .font(.title2.weight(.bold))
                .padding(.horizontal, 16)
                .padding(.top, 16)
            
            Divider()
                .padding(.horizontal, 16)
        }
    }
    
    private var contentSection: some View {
        VStack {
            TextEditor(text: $content)
                .font(.body)
                .frame(minHeight: 200)
                .padding(.horizontal, 12)
            
            Divider()
                .padding(.horizontal, 16)
        }
    }
    
    private var imagesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            imagesSectionHeader
            imagesList
        }
    }
    
    private var imagesSectionHeader: some View {
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
    }
    
    @ViewBuilder
    private var imagesList: some View {
        if !images.isEmpty {
            imagesScrollView
        } else {
            emptyImagesPlaceholder
        }
    }
    
    private var imagesScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(images.indices, id: \.self) { index in
                    imageView(for: index)
                }
            }
            .padding(.horizontal, 16)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: images.count)
        }
    }
    
    private func imageView(for index: Int) -> some View {
        Group {
            if let imageData = Data(base64Encoded: images[index]),
               let uiImage = UIImage(data: imageData) {
                ZStack(alignment: .topTrailing) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    deleteButton(for: index)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
    }
    
    private func deleteImage(at index: Int) {
        let _ = images.remove(at: index)
    }
    
    private func deleteButton(for index: Int) -> some View {
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
    
    private var emptyImagesPlaceholder: some View {
        Text("Add images to your journal entry")
            .foregroundColor(.secondary)
            .font(.subheadline)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .transition(.opacity)
    }
    
    private var toolbarButtons: some ToolbarContent {
        Group {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(.red)
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    saveEntry()
                }
                .disabled(title.isEmpty || content.isEmpty)
                .foregroundColor(title.isEmpty || content.isEmpty ? .gray : .blue)
            }
        }
    }
    
    private func saveEntry() {
        let entry = JournalEntry(
            title: title,
            content: content,
            images: images
        )
        repository.addEntry(entry)
        dismiss()
    }
}
