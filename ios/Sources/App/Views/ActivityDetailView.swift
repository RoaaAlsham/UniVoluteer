import SwiftUI

struct ActivityDetailView: View {
    @Environment(AppState.self) private var appState
    let activity: ClubActivity

    private var isCross: Bool {
        guard let homeId = appState.currentUser?.universityId else { return false }
        return activity.isCrossUniversity(homeUniversityId: homeId)
    }

    private var verifiedCount: Int {
        activity.extractedSkills.filter { $0.verificationStatus == .verified }.count
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerSection
                skillsSection
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
        .background(Color.brandBg)
        .navigationTitle(activity.clubName)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let photoData = activity.photoData,
               let uiImage = UIImage(data: photoData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(activity.clubName)
                    .largeTitleStyle()

                HStack(spacing: 16) {
                    Label(activity.role, systemImage: "person.fill")
                    Label("\(activity.hours) hours", systemImage: "clock.fill")
                }
                .captionStyle()

                Label(activity.date.formatted(.dateTime.day().month(.wide).year()), systemImage: "calendar")
                    .captionStyle()

                HStack(spacing: 4) {
                    if isCross { Text("\u{1F91D}").font(.system(size: 10)) }
                    Image(systemName: "checkmark.shield.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(Color.brandSuccess)
                    Text("\(activity.clubName) \u{00B7} \(activity.universityName)")
                        .font(.system(.caption, design: .default, weight: .medium))
                        .foregroundStyle(Color.brandSuccess)
                }
                if isCross {
                    Text("Cross-university experience \u{00B7} You are a \(appState.currentUniversity?.shortName ?? "") student")
                        .font(.system(.caption2, design: .default, weight: .regular))
                        .foregroundStyle(.secondary)
                }
            }

            HStack(spacing: 12) {
                StatBadge(
                    value: "\(activity.extractedSkills.count)",
                    label: "Skills",
                    color: .brandPrimary
                )
                StatBadge(
                    value: "\(verifiedCount)",
                    label: "Verified",
                    color: .brandSuccess
                )
                StatBadge(
                    value: "\(activity.hours)",
                    label: "Hours",
                    color: .brandAccent
                )
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }

    private var skillsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Skills Extracted From This Experience")
                .headlineStyle()

            ForEach(activity.extractedSkills) { skill in
                SkillCard(skill: skill)
            }
        }
    }
}

private struct StatBadge: View {
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(.title2, design: .rounded, weight: .bold))
                .foregroundStyle(color)
            Text(label)
                .font(.system(.caption2, design: .default, weight: .medium))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

private struct SkillCard: View {
    let skill: ExtractedSkill

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                Text(skill.name)
                    .font(.system(.subheadline, design: .default, weight: .semibold))
                    .foregroundStyle(.primary)

                Spacer()

                confidenceTag
            }

            verificationBadge

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

    @ViewBuilder
    private var verificationBadge: some View {
        switch skill.verificationStatus {
        case .verified:
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.brandSuccess)
                    Text("Verified by \(skill.verifiedByName ?? "supervisor")")
                        .foregroundStyle(Color.brandSuccess)
                }
                .font(.system(.caption, design: .default, weight: .medium))
                if let clubName = skill.verifiedByClubName {
                    Text("\(clubName) \u{00B7} Recognized by University \u{2713}")
                        .font(.system(.caption2, design: .default, weight: .regular))
                        .foregroundStyle(.secondary)
                }
            }
        case .pending:
            HStack(spacing: 4) {
                Image(systemName: "clock.fill")
                    .foregroundStyle(Color.brandAccent)
                Text("Awaiting confirmation")
                    .foregroundStyle(Color.brandAccent)
            }
            .font(.system(.caption, design: .default, weight: .medium))
        case .rejected:
            HStack(spacing: 4) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.red)
                Text("Not verified")
                    .foregroundStyle(.red)
            }
            .font(.system(.caption, design: .default, weight: .medium))
        }
    }
}
