import SwiftUI
import AppKit

// MARK: - Note Model
struct Note: Identifiable {
    let id = UUID()
    var position: CGPoint
    var content: String
    var fontSize: CGFloat
    var textColor: Color
    var backgroundColor: Color
    var borderColor: Color
    var isBold: Bool
    var isItalic: Bool
    var isUnderlined: Bool
    var isStrikethrough: Bool
    var size: CGSize
    var cornerRadius: CGFloat
    var borderWidth: CGFloat
    var opacity: Double
    var fontFamily: String
    
    init(position: CGPoint) {
        self.position = position
        self.content = "New note..."
        self.fontSize = 16
        self.textColor = .black
        self.backgroundColor = Color.yellow.opacity(0.8)
        self.borderColor = Color.yellow
        self.isBold = false
        self.isItalic = false
        self.isUnderlined = false
        self.isStrikethrough = false
        self.size = CGSize(width: 200, height: 150)
        self.cornerRadius = 8
        self.borderWidth = 2
        self.opacity = 1.0
        self.fontFamily = "System"
    }
}



// MARK: - Content View
struct ContentView: View {
    @State private var notes: [Note] = []
    @State private var selectedNoteId: UUID?
    @State private var canvasOffset: CGPoint = .zero
    @State private var isDraggingCanvas = false
    @State private var lastDragPosition: CGPoint = .zero
    
    // Formatting state
    @State private var currentFontSize: CGFloat = 16
    @State private var currentTextColor: Color = .black
    @State private var currentBackgroundColor: Color = Color.yellow.opacity(0.8)
    @State private var currentBorderColor: Color = Color.yellow
    @State private var currentIsBold = false
    @State private var currentIsItalic = false
    @State private var currentIsUnderlined = false
    @State private var currentIsStrikethrough = false
    @State private var currentCornerRadius: CGFloat = 8
    @State private var currentBorderWidth: CGFloat = 2
    @State private var currentOpacity: Double = 1.0
    @State private var currentFontFamily = "System"
    @State private var showCustomizationPanel = false
    // Add zoom scale state
    @State private var zoomScale: CGFloat = 1.0
    // Add grid toggle state
    @State private var showGrid: Bool = true
    
    var body: some View {
        ZStack {
            // Canvas Background
            CanvasView(
                canvasOffset: $canvasOffset,
                isDraggingCanvas: $isDraggingCanvas,
                lastDragPosition: $lastDragPosition,
                onDoubleClick: addNote,
                zoomScale: zoomScale, // Pass zoomScale
                showGrid: showGrid // Pass showGrid
            )
            
            // Notes
            ForEach(notes) { note in
                NoteView(
                    note: binding(for: note),
                    canvasOffset: canvasOffset,
                    isSelected: selectedNoteId == note.id,
                    onSelect: { selectNote(note.id) },
                    onDelete: { deleteNote(note.id) },
                    zoomScale: zoomScale // Pass zoomScale
                )
            }
            
            // Toolbar
            VStack {
                FormattingToolbar(
                    fontSize: $currentFontSize,
                    textColor: $currentTextColor,
                    backgroundColor: $currentBackgroundColor,
                    borderColor: $currentBorderColor,
                    isBold: $currentIsBold,
                    isItalic: $currentIsItalic,
                    isUnderlined: $currentIsUnderlined,
                    isStrikethrough: $currentIsStrikethrough,
                    cornerRadius: $currentCornerRadius,
                    borderWidth: $currentBorderWidth,
                    opacity: $currentOpacity,
                    fontFamily: $currentFontFamily,
                    showCustomizationPanel: $showCustomizationPanel,
                    onFormattingChange: applyFormatting,
                    zoomScale: $zoomScale, // Pass zoomScale binding
                    showGrid: $showGrid // Pass showGrid binding
                )
                
                Spacer()
            }
        }
        .frame(minWidth: 800, minHeight: 600)
        .background(Color(NSColor.controlBackgroundColor))
        .clipped()
    }
    
    private func binding(for note: Note) -> Binding<Note> {
        guard let index = notes.firstIndex(where: { $0.id == note.id }) else {
            fatalError("Note not found")
        }
        return $notes[index]
    }
    
    private func addNote(at position: CGPoint) {
        let adjustedPosition = CGPoint(
            x: position.x - canvasOffset.x,
            y: position.y - canvasOffset.y
        )
        
        var newNote = Note(position: adjustedPosition)
        newNote.fontSize = currentFontSize
        newNote.textColor = currentTextColor
        newNote.backgroundColor = currentBackgroundColor
        newNote.borderColor = currentBorderColor
        newNote.isBold = currentIsBold
        newNote.isItalic = currentIsItalic
        newNote.isUnderlined = currentIsUnderlined
        newNote.isStrikethrough = currentIsStrikethrough
        newNote.cornerRadius = currentCornerRadius
        newNote.borderWidth = currentBorderWidth
        newNote.opacity = currentOpacity
        newNote.fontFamily = currentFontFamily
        
        notes.append(newNote)
        selectedNoteId = newNote.id
    }
    
    private func selectNote(_ id: UUID) {
        selectedNoteId = id
        if let note = notes.first(where: { $0.id == id }) {
            currentFontSize = note.fontSize
            currentTextColor = note.textColor
            currentBackgroundColor = note.backgroundColor
            currentBorderColor = note.borderColor
            currentIsBold = note.isBold
            currentIsItalic = note.isItalic
            currentIsUnderlined = note.isUnderlined
            currentIsStrikethrough = note.isStrikethrough
            currentCornerRadius = note.cornerRadius
            currentBorderWidth = note.borderWidth
            currentOpacity = note.opacity
            currentFontFamily = note.fontFamily
        }
    }
    
    private func deleteNote(_ id: UUID) {
        notes.removeAll { $0.id == id }
        if selectedNoteId == id {
            selectedNoteId = nil
        }
    }
    
    private func applyFormatting() {
        guard let selectedId = selectedNoteId,
              let index = notes.firstIndex(where: { $0.id == selectedId }) else {
            return
        }
        
        notes[index].fontSize = currentFontSize
        notes[index].textColor = currentTextColor
        notes[index].backgroundColor = currentBackgroundColor
        notes[index].borderColor = currentBorderColor
        notes[index].isBold = currentIsBold
        notes[index].isItalic = currentIsItalic
        notes[index].isUnderlined = currentIsUnderlined
        notes[index].isStrikethrough = currentIsStrikethrough
        notes[index].cornerRadius = currentCornerRadius
        notes[index].borderWidth = currentBorderWidth
        notes[index].opacity = currentOpacity
        notes[index].fontFamily = currentFontFamily
    }
}

// MARK: - Canvas View
struct CanvasView: View {
    @Binding var canvasOffset: CGPoint
    @Binding var isDraggingCanvas: Bool
    @Binding var lastDragPosition: CGPoint
    let onDoubleClick: (CGPoint) -> Void
    let zoomScale: CGFloat // Add this line
    let showGrid: Bool // Add this line

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Conditionally show grid
                if showGrid {
                    GridBackground(offset: canvasOffset, zoomScale: zoomScale)
                }
                // Invisible overlay for interactions
                Rectangle()
                    .fill(Color.clear)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                if !isDraggingCanvas {
                                    isDraggingCanvas = true
                                    lastDragPosition = value.startLocation
                                }
                                
                                let delta = CGPoint(
                                    x: value.location.x - lastDragPosition.x,
                                    y: value.location.y - lastDragPosition.y
                                )
                                
                                canvasOffset = CGPoint(
                                    x: canvasOffset.x + delta.x,
                                    y: canvasOffset.y + delta.y
                                )
                                
                                lastDragPosition = value.location
                            }
                            .onEnded { _ in
                                isDraggingCanvas = false
                            }
                    )
                    .onTapGesture(count: 2) { location in
                        onDoubleClick(location)
                    }
            }
            .scaleEffect(zoomScale) // Apply zoom
            .animation(.easeInOut(duration: 0.15), value: zoomScale)
        }
    }
}

// MARK: - Grid Background
struct GridBackground: View {
    let offset: CGPoint
    let zoomScale: CGFloat // Add this line
    let gridSize: CGFloat = 20
    
    var body: some View {
        Canvas { context, size in
            let scaledGridSize = gridSize * zoomScale
            let adjustedOffset = CGPoint(
                x: offset.x.truncatingRemainder(dividingBy: scaledGridSize),
                y: offset.y.truncatingRemainder(dividingBy: scaledGridSize)
            )
            
            // Draw vertical lines
            var x = adjustedOffset.x
            while x < size.width {
                context.stroke(
                    Path { path in
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: size.height))
                    },
                    with: .color(.gray.opacity(0.3)),
                    lineWidth: 0.5
                )
                x += scaledGridSize
            }
            
            // Draw horizontal lines
            var y = adjustedOffset.y
            while y < size.height {
                context.stroke(
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: size.width, y: y))
                    },
                    with: .color(.gray.opacity(0.3)),
                    lineWidth: 0.5
                )
                y += scaledGridSize
            }
        }
    }
}

// MARK: - Note View
struct NoteView: View {
    @Binding var note: Note
    let canvasOffset: CGPoint
    let isSelected: Bool
    let onSelect: () -> Void
    let onDelete: () -> Void
    let zoomScale: CGFloat // Add this line

    @State private var isDragging = false
    @State private var isEditing = false
    @State private var dragOffset: CGSize = .zero
    @State private var isResizing = false
    @State private var resizeOffset: CGSize = .zero
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Image(systemName: "move.3d")
                    .foregroundColor(.gray)
                    .font(.system(size: 12))
                
                Text("Note")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                
                Spacer()
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .font(.system(size: 12))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(note.backgroundColor.opacity(0.5))
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if !isDragging {
                            isDragging = true
                            onSelect()
                        }
                        dragOffset = value.translation
                    }
                    .onEnded { _ in
                        note.position = CGPoint(
                            x: note.position.x + dragOffset.width / zoomScale,
                            y: note.position.y + dragOffset.height / zoomScale
                        )
                        dragOffset = .zero
                        isDragging = false
                    }
            )
            
            // Content
            Group {
                if isEditing {
                    TextEditor(text: $note.content)
                        .font(fontFromFamily(note.fontFamily, size: note.fontSize, weight: note.isBold ? .bold : .regular))
                        .foregroundColor(note.textColor)
                        .italic(note.isItalic)
                        .underline(note.isUnderlined)
                        .strikethrough(note.isStrikethrough)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .padding(8)
                        .onSubmit {
                            isEditing = false
                        }
                } else {
                    Text(note.content)
                        .font(fontFromFamily(note.fontFamily, size: note.fontSize, weight: note.isBold ? .bold : .regular))
                        .foregroundColor(note.textColor)
                        .italic(note.isItalic)
                        .underline(note.isUnderlined)
                        .strikethrough(note.isStrikethrough)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .padding(8)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            isEditing = true
                            onSelect()
                        }
                }
            }
        }
        // Make note size independent of zoom (so it stays the same visual size)
        .frame(
            width: note.size.width + resizeOffset.width,
            height: note.size.height + resizeOffset.height
        )
        .background(note.backgroundColor)
        .cornerRadius(note.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: note.cornerRadius)
                .stroke(isSelected ? Color.blue : note.borderColor, lineWidth: note.borderWidth)
        )
        .overlay(
            // Resize handle
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                        .foregroundColor(.gray)
                        .font(.system(size: 12))
                        .padding(4)
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(4)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    if !isResizing {
                                        isResizing = true
                                        onSelect()
                                    }
                                    resizeOffset = value.translation
                                }
                                .onEnded { _ in
                                    note.size = CGSize(
                                        width: max(100, note.size.width + resizeOffset.width),
                                        height: max(80, note.size.height + resizeOffset.height)
                                    )
                                    resizeOffset = .zero
                                    isResizing = false
                                }
                        )
                        .opacity(isSelected ? 1 : 0.3)
                }
                .padding(4)
            }
        )
        .shadow(radius: 3)
        .opacity(note.opacity)
        // Position must scale with zoom
        .position(
            x: (note.position.x + canvasOffset.x + dragOffset.width / zoomScale + (note.size.width + resizeOffset.width) / 2) * zoomScale,
            y: (note.position.y + canvasOffset.y + dragOffset.height / zoomScale + (note.size.height + resizeOffset.height) / 2) * zoomScale
        )
        .onTapGesture {
            onSelect()
        }
    }
    
    private func fontFromFamily(_ family: String, size: CGFloat, weight: Font.Weight) -> Font {
        switch family {
        case "Helvetica":
            return .custom("Helvetica", size: size)
        case "Times":
            return .custom("Times New Roman", size: size)
        case "Courier":
            return .custom("Courier New", size: size)
        case "Georgia":
            return .custom("Georgia", size: size)
        case "Verdana":
            return .custom("Verdana", size: size)
        default:
            return .system(size: size, weight: weight)
        }
    }
}

// MARK: - Formatting Toolbar
struct FormattingToolbar: View {
    @Binding var fontSize: CGFloat
    @Binding var textColor: Color
    @Binding var backgroundColor: Color
    @Binding var borderColor: Color
    @Binding var isBold: Bool
    @Binding var isItalic: Bool
    @Binding var isUnderlined: Bool
    @Binding var isStrikethrough: Bool
    @Binding var cornerRadius: CGFloat
    @Binding var borderWidth: CGFloat
    @Binding var opacity: Double
    @Binding var fontFamily: String
    @Binding var showCustomizationPanel: Bool
    let onFormattingChange: () -> Void
    @Binding var zoomScale: CGFloat // Add this line
    @Binding var showGrid: Bool // Add this line
    
    let fontFamilies = ["System", "Helvetica", "Times", "Courier", "Georgia", "Verdana"]
    
    var body: some View {
        VStack(spacing: 12) {
            // Main toolbar
            HStack(spacing: 16) {
                // Text formatting buttons
                HStack(spacing: 8) {
                    FormatButton(
                        icon: "bold",
                        isActive: isBold,
                        action: {
                            isBold.toggle()
                            onFormattingChange()
                        }
                    )
                    
                    FormatButton(
                        icon: "italic",
                        isActive: isItalic,
                        action: {
                            isItalic.toggle()
                            onFormattingChange()
                        }
                    )
                    
                    FormatButton(
                        icon: "underline",
                        isActive: isUnderlined,
                        action: {
                            isUnderlined.toggle()
                            onFormattingChange()
                        }
                    )
                    
                    FormatButton(
                        icon: "strikethrough",
                        isActive: isStrikethrough,
                        action: {
                            isStrikethrough.toggle()
                            onFormattingChange()
                        }
                    )
                }
                
                Divider()
                    .frame(height: 20)
                
                // Font size controls
                HStack(spacing: 8) {
                    Button(action: {
                        fontSize = max(10, fontSize - 2)
                        onFormattingChange()
                    }) {
                        Image(systemName: "minus")
                            .font(.system(size: 12))
                    }
                    .buttonStyle(.plain)
                    .padding(6)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(4)
                    
                    Text("\(Int(fontSize))")
                        .font(.system(size: 12, weight: .medium))
                        .frame(minWidth: 20)
                    
                    Button(action: {
                        fontSize = min(32, fontSize + 2)
                        onFormattingChange()
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 12))
                    }
                    .buttonStyle(.plain)
                    .padding(6)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(4)
                }
                
                Divider()
                    .frame(height: 20)
                
                // Zoom controls
                HStack(spacing: 4) {
                    Button(action: {
                        zoomScale = max(0.5, zoomScale - 0.1)
                    }) {
                        Image(systemName: "minus.magnifyingglass")
                    }
                    .buttonStyle(.plain)
                    .padding(6)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(4)
                    
                    Text("\(Int(zoomScale * 100))%")
                        .font(.system(size: 12, weight: .medium))
                        .frame(minWidth: 36)
                    
                    Button(action: {
                        zoomScale = min(2.0, zoomScale + 0.1)
                    }) {
                        Image(systemName: "plus.magnifyingglass")
                    }
                    .buttonStyle(.plain)
                    .padding(6)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(4)
                }
                
                Divider()
                    .frame(height: 20)
                
                // Grid toggle
                Toggle(isOn: $showGrid) {
                    Image(systemName: "square.grid.3x3")
                        .font(.system(size: 14))
                }
                .toggleStyle(.switch)
                .frame(width: 60)
                .padding(.leading, 8)
                
                // Text color picker
                HStack(spacing: 8) {
                    Image(systemName: "textformat")
                        .font(.system(size: 14))
                    
                    ColorPicker("", selection: $textColor)
                        .frame(width: 30, height: 30)
                        .onChange(of: textColor) { _ in
                            onFormattingChange()
                        }
                }
                
                Divider()
                    .frame(height: 20)
                
                // Customization toggle
                Button(action: {
                    showCustomizationPanel.toggle()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 14))
                        Text("Customize")
                            .font(.system(size: 12))
                    }
                }
                .buttonStyle(.plain)
                .padding(8)
                .background(showCustomizationPanel ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(showCustomizationPanel ? .white : .primary)
                .cornerRadius(6)
                
                Divider()
                    .frame(height: 20)
                
                // Instructions
                HStack(spacing: 4) {
                    Image(systemName: "hand.point.up.left")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    
                    Text("Double-click to create note")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
            }
            
            // Customization panel
            if showCustomizationPanel {
                CustomizationPanel(
                    backgroundColor: $backgroundColor,
                    borderColor: $borderColor,
                    cornerRadius: $cornerRadius,
                    borderWidth: $borderWidth,
                    opacity: $opacity,
                    fontFamily: $fontFamily,
                    fontFamilies: fontFamilies,
                    onFormattingChange: onFormattingChange
                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
        .shadow(radius: 4)
        .padding(.top, 20)
    }
}

// MARK: - Customization Panel
struct CustomizationPanel: View {
    @Binding var backgroundColor: Color
    @Binding var borderColor: Color
    @Binding var cornerRadius: CGFloat
    @Binding var borderWidth: CGFloat
    @Binding var opacity: Double
    @Binding var fontFamily: String
    let fontFamilies: [String]
    let onFormattingChange: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            // Colors row
            HStack(spacing: 20) {
                // Background color
                VStack(spacing: 4) {
                    Text("Background")
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                    
                    ColorPicker("", selection: $backgroundColor)
                        .frame(width: 40, height: 30)
                        .onChange(of: backgroundColor) { _ in
                            onFormattingChange()
                        }
                }
                
                // Border color
                VStack(spacing: 4) {
                    Text("Border")
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                    
                    ColorPicker("", selection: $borderColor)
                        .frame(width: 40, height: 30)
                        .onChange(of: borderColor) { _ in
                            onFormattingChange()
                        }
                }
                
                Divider()
                    .frame(height: 30)
                
                // Font family
                VStack(spacing: 4) {
                    Text("Font")
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                    
                    Picker("Font", selection: $fontFamily) {
                        ForEach(fontFamilies, id: \.self) { font in
                            Text(font).tag(font)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(width: 100)
                    .onChange(of: fontFamily) { _ in
                        onFormattingChange()
                    }
                }
            }
            
            // Sliders row
            HStack(spacing: 20) {
                // Corner radius
                VStack(spacing: 4) {
                    Text("Roundness: \(Int(cornerRadius))")
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                    
                    Slider(value: $cornerRadius, in: 0...20, step: 1)
                        .frame(width: 80)
                        .onChange(of: cornerRadius) { _ in
                            onFormattingChange()
                        }
                }
                
                // Border width
                VStack(spacing: 4) {
                    Text("Border: \(Int(borderWidth))")
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                    
                    Slider(value: $borderWidth, in: 0...5, step: 1)
                        .frame(width: 80)
                        .onChange(of: borderWidth) { _ in
                            onFormattingChange()
                        }
                }
                
                // Opacity
                VStack(spacing: 4) {
                    Text("Opacity: \(Int(opacity * 100))%")
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                    
                    Slider(value: $opacity, in: 0.1...1.0, step: 0.1)
                        .frame(width: 80)
                        .onChange(of: opacity) { _ in
                            onFormattingChange()
                        }
                }
            }
            
            // Preset colors row
            HStack(spacing: 8) {
                Text("Presets:")
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
                
                ForEach(presetColors, id: \.name) { preset in
                    Button(action: {
                        backgroundColor = preset.background
                        borderColor = preset.border
                        onFormattingChange()
                    }) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(preset.background)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(preset.border, lineWidth: 2)
                            )
                            .frame(width: 20, height: 20)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(12)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
    
    private var presetColors: [(name: String, background: Color, border: Color)] {
        [
            ("Yellow", Color.yellow.opacity(0.8), Color.yellow),
            ("Blue", Color.blue.opacity(0.3), Color.blue),
            ("Green", Color.green.opacity(0.3), Color.green),
            ("Pink", Color.pink.opacity(0.3), Color.pink),
            ("Orange", Color.orange.opacity(0.3), Color.orange),
            ("Purple", Color.purple.opacity(0.3), Color.purple),
            ("Gray", Color.gray.opacity(0.3), Color.gray)
        ]
    }
}


// MARK: - Format Button
struct FormatButton: View {
    let icon: String
    let isActive: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(isActive ? .white : .primary)
        }
        .buttonStyle(.plain)
        .padding(8)
        .background(isActive ? Color.blue : Color.gray.opacity(0.2))
        .cornerRadius(6)
    }
}

// MARK: - Text Extension for Italic, Underline, and Strikethrough
extension Text {
    func italic(_ isItalic: Bool) -> Text {
        if isItalic {
            return self.italic()
        }
        return self
    }
    
    func underline(_ isUnderlined: Bool) -> Text {
        if isUnderlined {
            return self.underline()
        }
        return self
    }
    
    func strikethrough(_ isStrikethrough: Bool) -> Text {
        if isStrikethrough {
            return self.strikethrough()
        }
        return self
    }
}
