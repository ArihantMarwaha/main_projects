//
//  SwiftUIView.swift
//  jour
//
//  Created by Arihant Marwaha on 06/02/25.
//

import SwiftUI
import Combine

struct MainJournalView: View {
    @StateObject private var repository = JournalRepository()
    @State private var showingNewEntry = false
    @State private var searchText = ""
    @State private var sortOption: SortOption = .dateDesc
    
    enum SortOption: Identifiable, CaseIterable {
        case dateDesc, dateAsc, titleAsc, titleDesc
        
        var id: Self { self }
        
        var label: String {
            switch self {
            case .dateDesc: return "Newest First"
            case .dateAsc: return "Oldest First"
            case .titleAsc: return "Title A-Z"
            case .titleDesc: return "Title Z-A"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 24) {
                    statsSection
                        .transition(.scale.combined(with: .opacity))
                    
                    entriesList
                }
            }
            .searchable(text: $searchText, prompt: "Search entries...")
            .navigationTitle("Journal")
            .toolbar { toolbarContent }
            .overlay(
                newEntryButton
                    .padding(24)
                    .zIndex(0),
                alignment: .bottomTrailing
            )
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: filteredAndSortedEntries)
        }
        .sheet(isPresented: $showingNewEntry) {
            NewEntryView(repository: repository)
        }
    }
    
    private var statsSection: some View {
        HStack {
            StatView(icon: "book.closed", value: "\(repository.totalEntries)", title: "Entry This Year")
                .frame(maxWidth: .infinity)
            StatView(icon: "text.quote", value: "\(repository.totalWordsWritten)", title: "Words Written")
                .frame(maxWidth: .infinity)
            StatView(icon: "calendar", value: "\(repository.daysJournaled)", title: "Days Journaled")
                .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
    
    private var entriesList: some View {
        ForEach(groupedEntries.keys.sorted().reversed(), id: \.self) { month in
            VStack(alignment: .leading, spacing: 12) {
                Text(month)
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.horizontal, 16)
                
                LazyVStack(spacing: 12) {
                    ForEach(groupedEntries[month] ?? []) { entry in
                        JournalEntryCard(entry: entry, repository: repository)
                            .transition(.asymmetric(
                                insertion: .scale(scale: 0.9).combined(with: .opacity),
                                removal: .scale(scale: 0.9).combined(with: .opacity)
                            ))
                    }
                }
            }
            .padding(.bottom, 8)
            .transition(.asymmetric(
                insertion: .move(edge: .leading).combined(with: .opacity),
                removal: .move(edge: .trailing).combined(with: .opacity)
            ))
        }
    }
    
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            HStack(spacing: 16) {
                Menu {
                    ForEach(SortOption.allCases) { option in
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                sortOption = option
                            }
                        }) {
                            HStack {
                                Text(option.label)
                                if sortOption == option {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.primary)
                }
            }
        }
    }
    
    private var newEntryButton: some View {
        Button(action: { showingNewEntry = true }) {
            Circle()
                .fill(Color.blue)
                .frame(width: 56, height: 56)
                .overlay(
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.white)
                )
                .shadow(radius: 4)
        }
    }
    
    private var filteredAndSortedEntries: [JournalEntry] {
        let filtered = searchText.isEmpty ? repository.entries : repository.entries.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.content.localizedCaseInsensitiveContains(searchText)
        }
        
        return filtered.sorted { first, second in
            switch sortOption {
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
    
    private var groupedEntries: [String: [JournalEntry]] {
        Dictionary(grouping: filteredAndSortedEntries) { entry in
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: entry.date)
        }
    }
}

struct StatView: View {
    let icon: String
    let value: String
    let title: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.blue)
            Text(value)
                .font(.system(size: 20, weight: .bold))
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct JournalEntryCard: View {
    let entry: JournalEntry
    let repository: JournalRepository
    @State private var showingDeleteAlert = false
    
    var body: some View {
        NavigationLink(destination: JournalEntryDetailView(entry: entry, repository: repository)) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top) {
                    Text(entry.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Menu {
                        Button(role: .destructive, action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                showingDeleteAlert = true
                            }
                        }) {
                            Label("Delete Entry", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.secondary)
                            .frame(width: 24, height: 24)
                            .offset(y: -4)
                    }
                }
                
                Text(entry.content)
                    .lineLimit(3)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if !entry.images.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(entry.images, id: \.self) { imageString in
                                if let imageData = Data(base64Encoded: imageString),
                                   let uiImage = UIImage(data: imageData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .cornerRadius(8)
                                        .clipped()
                                }
                            }
                        }
                        .padding(.horizontal, 2)
                    }
                }
                
                Text(entry.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .padding(.horizontal, 16)
        .transition(.asymmetric(
            insertion: .scale.combined(with: .opacity),
            removal: .opacity
        ))
        .alert("Delete Entry", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    repository.deleteEntry(entry)
                }
            }
        } message: {
            Text("Are you sure you want to delete this entry? This action cannot be undone.")
        }
    }
}
