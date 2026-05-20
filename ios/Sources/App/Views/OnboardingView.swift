import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    var onComplete: () -> Void

    private let pages: [(icon: String, title: String, subtitle: String)] = [
        ("list.clipboard.fill", "Log Your Volunteer Work",
         "Record activities from your university clubs with hours, dates, and detailed reflections about what you actually did."),
        ("sparkles", "AI Extracts Real Skills",
         "Our AI reads your reflections and identifies specific, evidence-backed skills — not generic buzzwords, but real competencies."),
        ("checkmark.seal.fill", "Get Verified Credentials",
         "Club supervisors verify your skills, creating a trusted credential that employers can rely on."),
    ]

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $currentPage) {
                ForEach(0..<3, id: \.self) { index in
                    OnboardingPage(
                        icon: pages[index].icon,
                        title: pages[index].title,
                        subtitle: pages[index].subtitle,
                        index: index
                    )
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut(duration: 0.3), value: currentPage)

            VStack(spacing: 16) {
                HStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { i in
                        Capsule()
                            .fill(i == currentPage ? Color.brandPrimary : Color.brandPrimary.opacity(0.2))
                            .frame(width: i == currentPage ? 24 : 8, height: 8)
                            .animation(.spring(response: 0.3), value: currentPage)
                    }
                }

                Button(action: {
                    if currentPage < 2 {
                        currentPage += 1
                    } else {
                        onComplete()
                    }
                }) {
                    Text(currentPage == 2 ? "Get Started" : "Next")
                        .font(.system(.body, design: .default, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.brandPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }

                if currentPage < 2 {
                    Button("Skip") { onComplete() }
                        .font(.system(.subheadline, design: .default, weight: .medium))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 48)
        }
        .background(Color.brandBg)
    }
}

private struct OnboardingPage: View {
    let icon: String
    let title: String
    let subtitle: String
    let index: Int

    private var iconColor: Color {
        [Color.brandPrimary, Color.brandAccent, Color.brandSuccess][min(index, 2)]
    }

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.1))
                    .frame(width: 120, height: 120)
                Image(systemName: icon)
                    .font(.system(size: 48))
                    .foregroundStyle(iconColor)
            }

            VStack(spacing: 12) {
                Text(title)
                    .font(.system(.title2, design: .default, weight: .bold))
                    .multilineTextAlignment(.center)

                Text(subtitle)
                    .font(.system(.body, design: .default, weight: .regular))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 32)

            Spacer()
            Spacer()
        }
    }
}
