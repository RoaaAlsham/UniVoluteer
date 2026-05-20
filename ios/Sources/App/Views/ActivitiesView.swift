import SwiftUI

struct ActivitiesView: View {
    @Environment(AppState.self) private var appState
    @State private var filterUniversityId: UUID?

    private var totalHours: Int {
        appState.activities.reduce(0) { $0 + $1.hours }
    }

    private var verifiedSkills: [ExtractedSkill] {
        appState.activities
            .flatMap(\.extractedSkills)
            .filter { $0.verificationStatus == .verified }
    }

    private var sortedActivities: [ClubActivity] {
        let sorted = appState.activities.sorted { $0.date > $1.date }
        if let filterId = filterUniversityId {
            return sorted.filter { $0.hostUniversityId == filterId }
        }
        return sorted
    }

    private var universityIds: [UUID] {
        Array(Set(appState.activities.map(\.hostUniversityId)))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    greetingSection
                    if !verifiedSkills.isEmpty { skillCarousel }
                    if universityIds.count > 1 { filterPills }
                    activityList
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 32)
            }
            .background(Color.brandBg)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { appState.logout() } label: {
                        Text("Switch")
                            .font(.system(.subheadline, design: .default, weight: .medium))
                            .foregroundStyle(Color.brandPrimary)
                    }
                }
            }
        }
    }

    private var greetingSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Hi \(appState.currentUser?.firstName ?? "") \u{1F44B}")
                .largeTitleStyle()
            Text("\(appState.currentUniversity?.name ?? "") \u{00B7} \(totalHours) hours volunteered \u{00B7} \(verifiedSkills.count) verified skills")
                .captionStyle()
        }
        .padding(.top, 8)
    }

    private var skillCarousel: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Verified Skills")
                .headlineStyle()

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(Array(verifiedSkills.prefix(8))) { skill in
                        SkillPill(skill: skill)
                    }
                }
            }
        }
    }

    private var filterPills: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterPill(label: "All Universities", isSelected: filterUniversityId == nil) {
                    filterUniversityId = nil
                }
                ForEach(universityIds, id: \.self) { uniId in
                    if let uni = ClubService.university(for: uniId) {
                        FilterPill(
                            label: uni.shortName,
                            isSelected: filterUniversityId == uniId,
                            color: uni.brandColor
                        ) {
                            filterUniversityId = uniId
                        }
                    }
                }
            }
        }
    }

    private var activityList: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Activities")
                .headlineStyle()

            if sortedActivities.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "hands.sparkles.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(Color.brandPrimary.opacity(0.3))
                    Text(filterUniversityId != nil ? "No activities at this university" : "Log your first volunteer activity")
                        .font(.system(.subheadline, design: .default, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 48)
            }

            ForEach(sortedActivities) { activity in
                NavigationLink(value: activity.id) {
                    ActivityCardView(activity: activity)
                }
                .buttonStyle(.plain)
            }
        }
        .navigationDestination(for: UUID.self) { id in
            if let activity = appState.activities.first(where: { $0.id == id }) {
                ActivityDetailView(activity: activity)
            }
        }
    }
}

private struct FilterPill: View {
    let label: String
    let isSelected: Bool
    var color: Color = .brandPrimary
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(label)
                .font(.system(.caption, design: .default, weight: .semibold))
                .foregroundStyle(isSelected ? .white : color)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(isSelected ? color : color.opacity(0.08))
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

private struct SkillPill: View {
    let skill: ExtractedSkill

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "checkmark.seal.fill")
                .font(.caption2)
                .foregroundStyle(Color.brandSuccess)
            Text(skill.name)
                .font(.system(.caption, design: .default, weight: .medium))
                .foregroundStyle(.primary)
                .lineLimit(1)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.white)
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }
}
