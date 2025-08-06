//
//  QuickLogPopup.swift
//  GUGUios
//
//  Created by Arihant Marwaha on 26/07/25.
//

import SwiftUI
import Foundation

struct QuickLogPopup: View {
    let goal: Goal
    let tracker: GoalTracker?
    let isHoveringButton: Bool
    let onDismiss: () -> Void
    let onButtonFrameChanged: (CGRect) -> Void
    
    @State private var progress: Double = 0
    @State private var showingSuccess = false
    @State private var isLogging = false
    
    var body: some View {
        ZStack {
            // Background blur overlay
            Color.black.opacity(0.4)
                .ignoresSafeArea(.all)
                .onTapGesture {
                    onDismiss()
                }
            
            // Popup content
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Text(goal.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    
                    HStack(spacing: 8) {
                        Text("\(Int(progress * 100))%")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(goal.colorScheme.primary)
                        
                        Text("(\(Int(progress * Double(goal.targetCount)))/\(goal.targetCount))")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Progress ring
                CircularProgressView(
                    progress: progress,
                    colorScheme: goal.colorScheme
                )
                .frame(width: 100, height: 100)
                
                // Cooldown timer if active
                if let tracker = tracker, tracker.isInCooldown {
                    VStack(spacing: 4) {
                        Text("Next available in:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        CountdownTimer(endTime: tracker.cooldownEndTime)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.orange)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
                }
                
                // Log button (visual only - no tap interaction)
                GeometryReader { geometry in
                    HStack(spacing: 8) {
                        if isLogging {
                            ProgressView()
                                .scaleEffect(0.8)
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else if showingSuccess {
                            Image(systemName: "checkmark")
                                .font(.title3)
                                .fontWeight(.semibold)
                        } else {
                            Image(systemName: isHoveringButton ? "arrow.down.circle.fill" : "hand.tap.fill")
                                .font(.title3)
                        }
                        
                        Text(buttonText)
                            .font(.title3)
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(buttonBackgroundColor)
                    .cornerRadius(28)
                    .scaleEffect(buttonScale)
                    .animation(.spring(response: 0.3), value: isHoveringButton)
                    .animation(.spring(response: 0.3), value: showingSuccess)
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .stroke(isHoveringButton ? Color.white.opacity(0.3) : Color.clear, lineWidth: 2)
                            .animation(.easeInOut(duration: 0.2), value: isHoveringButton)
                    )
                    .accessibilityLabel(buttonText)
                    .accessibilityHint("Drag here to log this goal")
                    .onAppear {
                        // Convert local frame to global coordinates
                        let globalFrame = geometry.frame(in: .global)
                        onButtonFrameChanged(globalFrame)
                    }
                    .onChange(of: geometry.frame(in: .global)) { newFrame in
                        onButtonFrameChanged(newFrame)
                    }
                }
                .frame(height: 56)
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(.regularMaterial)
                    .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
            )
            .padding(.horizontal, 32)
            .scaleEffect(showingSuccess ? 0.95 : 1.0)
            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: showingSuccess)
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Quick log popup for \(goal.title)")
        }
        .onAppear {
            updateProgress()
        }
        .onChange(of: tracker?.todayEntries ?? []) {
            updateProgress()
        }
    }
    
    private var canLog: Bool {
        guard let tracker = tracker else { return false }
        return tracker.canLogEntry() && !tracker.isFullyCompleted()
    }
    
    private var buttonText: String {
        if isLogging {
            return "Logging..."
        } else if showingSuccess {
            return "Logged!"
        } else if tracker?.isFullyCompleted() == true {
            return "Goal Complete"
        } else if tracker?.isInCooldown == true {
            return "On Cooldown"
        } else if isHoveringButton {
            return "Release to Log"
        } else {
            return "Drag here to log"
        }
    }
    
    private var buttonBackgroundColor: Color {
        if showingSuccess {
            return .green
        } else if !canLog {
            return .gray
        } else if isHoveringButton {
            return goal.colorScheme.primary.opacity(0.8)
        } else {
            return goal.colorScheme.primary
        }
    }
    
    private var buttonScale: CGFloat {
        if showingSuccess {
            return 1.05
        } else if isHoveringButton {
            return 1.1
        } else {
            return 1.0
        }
    }
    
    
    private func updateProgress() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            progress = tracker?.getProgress() ?? 0
        }
    }
}

struct QuickLogPopup_Previews: PreviewProvider {
    static var previews: some View {
        let sampleGoal = Goal(
            title: "Water Intake",
            targetCount: 8,
            intervalInSeconds: 3600,
            colorScheme: .blue
        )
        
        let tracker = GoalTracker(
            goal: sampleGoal,
            analyticsManager: AnalyticsManager()
        )
        
        QuickLogPopup(
            goal: sampleGoal,
            tracker: tracker,
            isHoveringButton: false,
            onDismiss: {},
            onButtonFrameChanged: { _ in }
        )
        .previewDisplayName("Water Goal")
    }
}