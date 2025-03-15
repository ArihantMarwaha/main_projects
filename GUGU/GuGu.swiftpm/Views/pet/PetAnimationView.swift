import SwiftUI

struct PetAnimationView: View {
    let state: PetState
    @State private var currentFrameIndex = 0
    
    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        state.animationFrames[currentFrameIndex]
            .resizable()
            .scaledToFit()
            .frame(width: 400, height: 400)
            .foregroundColor(state.color)
            .onReceive(timer) { _ in
                withAnimation(.easeInOut(duration: 0.5)) {
                    currentFrameIndex = (currentFrameIndex + 1) % state.animationFrames.count
                }
            }
    }
}
