import SwiftUI

struct ExtractingSkillsView: View {
    let clubName: String
    let role: String
    let hours: Int
    let date: Date
    let reflections: [String]

    var onComplete: ([ExtractedSkill]) -> Void
    var onCancel: () -> Void

    @State private var statusIndex = 0
    @State private var pulse = false

    private let statusTexts = [
        "Reading your reflection...",
        "Identifying skill patterns...",
        "Matching to industry frameworks...",
        "Generating evidence...",
    ]

    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            loadingState
            Spacer()
        }
        .padding(.horizontal, 32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.brandBg)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", action: onCancel)
                    .foregroundStyle(.secondary)
            }
        }
        .task { await extract() }
    }

    private var loadingState: some View {
        VStack(spacing: 24) {
            Image(systemName: "sparkles")
                .font(.system(size: 48))
                .foregroundStyle(Color.brandPrimary)
                .scaleEffect(pulse ? 1.15 : 0.9)
                .opacity(pulse ? 1 : 0.6)
                .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: pulse)
                .onAppear { pulse = true }

            Text(statusTexts[statusIndex])
                .font(.system(.body, design: .default, weight: .medium))
                .foregroundStyle(.secondary)
                .contentTransition(.numericText())
                .animation(.easeInOut(duration: 0.3), value: statusIndex)
                .onReceive(
                    Timer.publish(every: 1.5, on: .main, in: .common).autoconnect()
                ) { _ in
                    statusIndex = (statusIndex + 1) % statusTexts.count
                }

            ProgressView()
                .tint(Color.brandPrimary)
        }
    }

    private func extract() async {
        let skills = await SkillExtractionService.extract(
            clubName: clubName,
            role: role,
            hours: hours,
            date: date,
            reflections: reflections
        )
        HapticService.success()
        onComplete(skills)
    }
}
