//
//   NoteEditorView.swift
//  StudyBuddy
//
//  Created by Arihant Marwaha on 12/07/25.
//

import SwiftUI
import AppKit

struct NoteEditorView: View {
    @EnvironmentObject var notesManager: NotesManager
    @EnvironmentObject var aiService: AIService
    @State var note: Note
    @State private var isEditingTitle = false
    @State private var showingAIMenu = false
    @State private var showingAttachmentPicker = false
    @State private var showingVoiceRecorder = false
    @State private var showingHandwritingImport = false
    @State private var selectedAIAction: AIAction?
    @State private var showingQuizGenerator = false
    @State private var aiProcessingResult: AIProcessingResult?
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with AI Controls
            EditorHeader(
                note: $note,
                isEditingTitle: $isEditingTitle,
                showingAIMenu: $showingAIMenu,
                selectedAIAction: $selectedAIAction
            )
            .padding()
            .background(.ultraThinMaterial)
            
            // Main Editor Area
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // AI Summary Card (if available)
                    if let summary = note.aiSummary {
                        AISummaryCard(summary: summary, keyPoints: note.aiKeyPoints)
                            .transition(.asymmetric(
                                insertion: .scale.combined(with: .opacity),
                                removal: .opacity
                            ))
                    }
                    
                    // Text Editor
                    TextEditor(text: Binding(
                        get: { note.content },
                        set: { newValue in
                            note.content = newValue
                            notesManager.updateNote(note)
                        }
                    ))
                    .font(.system(.body, design: .default))
                    .frame(minHeight: 400)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.regularMaterial)
                            .glassEffect(in: .rect(cornerRadius: 8))
                    )
                    .overlay(alignment: .bottomTrailing) {
                        if aiService.isProcessing {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .scaleEffect(0.8)
                                .padding()
                        }
                    }
                    
                    // Voice Notes Section
                    if !note.voiceNotes.isEmpty {
                        VoiceNotesSection(voiceNotes: note.voiceNotes)
                    }
                    
                    // Handwritten Notes Section
                    if !note.handwrittenImages.isEmpty {
                        HandwrittenNotesSection(handwrittenNotes: note.handwrittenImages)
                    }
                    
                    // Attachments Section
                    if !note.attachments.isEmpty {
                        AttachmentsSection(attachments: note.attachments)
                    }
                }
                .padding()
            }
            
            // Bottom Toolbar
            EditorToolbar(
                showingAttachmentPicker: $showingAttachmentPicker,
                showingVoiceRecorder: $showingVoiceRecorder,
                showingHandwritingImport: $showingHandwritingImport,
                showingQuizGenerator: $showingQuizGenerator
            )
            .padding()
            .background(.ultraThinMaterial)
        }
        .sheet(isPresented: $showingVoiceRecorder) {
            VoiceRecorderView(note: $note)
        }
        .sheet(isPresented: $showingHandwritingImport) {
            HandwritingImportView(note: $note)
        }
        .sheet(isPresented: $showingQuizGenerator) {
            QuizGeneratorView(note: note)
        }
        .task(id: selectedAIAction) {
            if let action = selectedAIAction {
                await performAIAction(action)
                selectedAIAction = nil
            }
        }
    }
    
    // MARK: - AI Actions
    private func performAIAction(_ action: AIAction) async {
        switch action {
        case .proofread:
            aiProcessingResult = await aiService.proofreadText(note.content)
            // Apply corrections if needed
            
        case .summarize:
            note.aiSummary = await aiService.summarizeText(note.content)
            note.aiKeyPoints = await aiService.extractKeyPoints(from: note.content)
            notesManager.updateNote(note)
            
        case .explain:
            let explanation = await aiService.explainText(note.content, level: .intermediate)
            note.content += "\n\n## AI Explanation\n\(explanation)"
            notesManager.updateNote(note)
            
        case .findMistakes:
            let result = await aiService.proofreadText(note.content)
            // Show mistakes in UI
            aiProcessingResult = result
            
        case .generateNotes:
            // This would be triggered from document import
            break
        }
    }
}
// MARK: - Editor Header
struct EditorHeader: View {
    @Binding var note: Note
    @Binding var isEditingTitle: Bool
    @Binding var showingAIMenu: Bool
    @Binding var selectedAIAction: AIAction?
    
    var body: some View {
        HStack {
            // Title Editor
            if isEditingTitle {
                TextField("Note Title", text: $note.title, onCommit: {
                    isEditingTitle = false
                })
                .textFieldStyle(.plain)
                .font(.title2.bold())
            } else {
                Text(note.title)
                    .font(.title2.bold())
                    .onTapGesture {
                        isEditingTitle = true
                    }
            }
            
            Spacer()
            
            // AI Features Menu
            Menu {
                Button {
                    selectedAIAction = .proofread
                } label: {
                    Label("Proofread", systemImage: "text.badge.checkmark")
                }
                
                Button {
                    selectedAIAction = .summarize
                } label: {
                    Label("Summarize", systemImage: "text.bubble")
                }
                
                Button {
                    selectedAIAction = .explain
                } label: {
                    Label("Explain", systemImage: "questionmark.circle")
                }
                
                Button {
                    selectedAIAction = .findMistakes
                } label: {
                    Label("Find Mistakes", systemImage: "exclamationmark.triangle")
                }
            } label: {
                Label("AI Features", systemImage: "brain")
                    .symbolRenderingMode(.multicolor)
            }
            .menuStyle(.borderlessButton)
            .help("Use AI to enhance your notes")
            
            // Export Menu
            Menu {
                ForEach(ExportFormat.allCases, id: \.self) { format in
                    Button("Export as \(format.rawValue)") {
                        // Export action
                    }
                }
            } label: {
                Label("Export", systemImage: "square.and.arrow.up")
            }
            .menuStyle(.borderlessButton)
        }
    }
}


// MARK: - Voice Notes Section
struct VoiceNotesSection: View {
    let voiceNotes: [VoiceNote]
    @State private var playingNoteId: UUID?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Voice Notes", systemImage: "mic.fill")
                .font(.headline)
            
            ForEach(voiceNotes) { voiceNote in
                VoiceNoteCard(
                    voiceNote: voiceNote,
                    isPlaying: playingNoteId == voiceNote.id,
                    onPlayToggle: {
                        playingNoteId = playingNoteId == voiceNote.id ? nil : voiceNote.id
                    }
                )
            }
        }
    }
}



// MARK: - Handwritten Notes Section
struct HandwrittenNotesSection: View {
    let handwrittenNotes: [HandwrittenNote]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Handwritten Notes", systemImage: "pencil.tip")
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(handwrittenNotes) { note in
                        HandwrittenNoteCard(handwrittenNote: note)
                    }
                }
            }
        }
    }
}

struct AttachmentsSection: View {
    let attachments: [Attachment]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Attachments", systemImage: "paperclip")
                .font(.headline)
            
            ForEach(attachments) { attachment in
                AttachmentCard(attachment: attachment)
            }
        }
    }
}



// MARK: - Supporting Types
import Combine
enum AIAction {
    case proofread
    case summarize
    case explain
    case findMistakes
    case generateNotes
}




