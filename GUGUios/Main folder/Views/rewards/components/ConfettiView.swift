import SwiftUI

/// A reusable confetti animation view for celebrations.
/// Show it by setting `isPresented` to true. It will auto-dismiss after the animation ends.
struct ConfettiView: View {
    @Binding var isPresented: Bool
    var particleCount: Int = 30
    var duration: Double = 2.0
    
    @State private var confettiParticles: [ConfettiParticle] = []
    @State private var timeElapsed: Double = 0
    @State private var timer: Timer? = nil
    
    var body: some View {
        ZStack {
            ForEach(confettiParticles) { particle in
                Circle()
                    .fill(particle.color)
                    .frame(width: particle.size, height: particle.size)
                    .position(x: particle.x, y: particle.y)
                    .opacity(particle.opacity)
                    .animation(.easeOut(duration: duration), value: particle.y)
            }
        }
        .allowsHitTesting(false)
        .onAppear {
            generateParticles()
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private func generateParticles() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height / 2
        confettiParticles = (0..<particleCount).map { _ in
            ConfettiParticle(
                x: CGFloat.random(in: 0...screenWidth),
                y: -20,
                size: CGFloat.random(in: 8...18),
                color: Color.randomConfetti,
                opacity: 1
            )
        }
        // Animate to random end Y positions
        for i in confettiParticles.indices {
            let endY = CGFloat.random(in: screenHeight...(screenHeight + 250))
            let delay = Double.random(in: 0...0.2)
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.easeOut(duration: duration)) {
                    confettiParticles[i].y = endY
                    confettiParticles[i].opacity = 0
                }
            }
        }
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { _ in
            DispatchQueue.main.async {
                isPresented = false
            }
        }
    }
}

private struct ConfettiParticle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var color: Color
    var opacity: Double
}

private extension Color {
    static var confettiPalette: [Color] {
        [.red, .orange, .yellow, .green, .blue, .purple, .pink]
    }
    static var randomConfetti: Color {
        confettiPalette.randomElement() ?? .yellow
    }
}
