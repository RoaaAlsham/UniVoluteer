import SwiftUI

struct LaunchView: View {
    @State private var logoScale = 0.8
    @State private var logoOpacity = 0.0

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.brandPrimary, Color.brandPrimary.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 88, height: 88)

                Image(systemName: "hands.sparkles.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.white)
            }
            .scaleEffect(logoScale)
            .opacity(logoOpacity)

            VStack(spacing: 4) {
                Text("UniVolunteer")
                    .font(.system(.title, design: .default, weight: .bold))
                    .foregroundStyle(Color.brandPrimary)

                Text("Verified Skills from Real Experience")
                    .font(.system(.caption, design: .default, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            .opacity(logoOpacity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.brandBg)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }
        }
    }
}
