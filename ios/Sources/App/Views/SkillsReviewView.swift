import SwiftUI

struct SkillsReviewView: View {
    let clubId: UUID
    let clubName: String
    let role: String
    let hours: Int
    let date: Date
    let extractedSkills: [ExtractedSkill]
    var onSave: () -> Void

    @State private var visibleCards: Set<UUID> = []

    private var supervisorNames: String {
        ClubService.supervisors(for: clubId).map(\.fullName).joined(separator: ", ")
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                supervisorBanner
                activitySummary
                skillsSection
                saveButton
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
        .background(Color.brandBg)
        .navigationTitle("Review Skills")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { staggerCards() }
    }

    private func staggerCards() {
        for (index, skill) in extractedSkills.enumerated() {
            let skillId = skill.id
            let delay = 0.15 * Double(index)
            Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(Int(delay * 1000)))
                _ = withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    visibleCards.insert(skillId)
                }
            }
        }
    }

    private var supervisorBanner: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Image(systemName: "person.badge.shield.checkmark")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.brandPrimary)
                Text("Skills shown below will be sent to your club's supervisor for verification.")
                    .font(.system(.caption, design: .default, weight: .medium))
                    .foregroundStyle(.primary)
            }
            if !supervisorNames.isEmpty {
                Text("\(supervisorNames) will review these skills for \(clubName).")
                    .font(.system(.caption2, design: .default, weight: .regular))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.brandPrimary.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private var activitySummary: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(clubName)
                .titleStyle()
            HStack(spacing: 16) {
                Label(role, systemImage: "person.fill")
                Label("\(hours)h", systemImage: "clock.fill")
            }
            .captionStyle()
            Label(date.formatted(.dateTime.day().month(.wide).year()), systemImage: "calendar")
                .captionStyle()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }

    private var skillsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Skills extracted from your reflection")
                    .headlineStyle()
                Text("\(extractedSkills.count) skills identified")
                    .captionStyle()
            }

            if extractedSkills.isEmpty {
                emptyState
            } else {
                ForEach(extractedSkills) { skill in
                    AnimatedSkillCard(skill: skill, clubName: clubName, isVisible: visibleCards.contains(skill.id))
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "sparkles")
                .font(.largeTitle)
                .foregroundStyle(Color.brandPrimary.opacity(0.3))
            Text("No skills extracted yet")
                .font(.system(.subheadline, design: .default, weight: .medium))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var saveButton: some View {
        Button(action: onSave) {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                Text("Save to My CV")
            }
            .font(.system(.body, design: .default, weight: .semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.brandPrimary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(.top, 8)
    }
}

private struct ReviewSkillCard: View {
    let skill: ExtractedSkill
    let clubName: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                Text(skill.name)
                    .font(.system(.subheadline, design: .default, weight: .semibold))
                    .foregroundStyle(.primary)
                Spacer()
                confidenceTag
            }

            HStack(spacing: 4) {
                Image(systemName: "clock.fill")
                    .foregroundStyle(Color.brandAccent)
                Text("Pending verification from \(clubName)")
                    .foregroundStyle(Color.brandAccent)
            }
            .font(.system(.caption, design: .default, weight: .medium))

            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "quote.opening")
                    .font(.caption)
                    .foregroundStyle(Color.brandPrimary.opacity(0.4))
                    .padding(.top, 2)
                Text(skill.evidenceQuote)
                    .font(.system(.footnote, design: .default, weight: .regular))
                    .italic()
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }

    private var confidenceTag: some View {
        let (label, color): (String, Color) = switch skill.confidenceLevel {
        case .introduced: ("Introduced", .secondary)
        case .practiced: ("Practiced", .brandAccent)
        case .proficient: ("Proficient", .brandPrimary)
        }
        return Text(label)
            .font(.system(.caption2, design: .default, weight: .semibold))
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.12))
            .clipShape(Capsule())
    }
}

private struct AnimatedSkillCard: View {
    let skill: ExtractedSkill
    let clubName: String
    let isVisible: Bool

    var body: some View {
        ReviewSkillCard(skill: skill, clubName: clubName)
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 20)
            .scaleEffect(isVisible ? 1 : 0.95)
    }
}
