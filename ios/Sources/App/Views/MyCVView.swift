import SwiftUI

struct SkillWithContext: Identifiable {
    let skill: ExtractedSkill
    let activity: ClubActivity
    var id: UUID { skill.id }
}

struct MyCVView: View {
    @Environment(AppState.self) private var appState
    @State private var selectedSkill: SkillWithContext?
    @State private var showResetConfirm = false

    private var allSkillsWithContext: [SkillWithContext] {
        appState.activities.flatMap { activity in
            activity.extractedSkills.map { SkillWithContext(skill: $0, activity: activity) }
        }
    }

    private var verifiedSkills: [SkillWithContext] {
        allSkillsWithContext.filter { $0.skill.verificationStatus == .verified }
    }

    private var pendingSkills: [SkillWithContext] {
        allSkillsWithContext.filter { $0.skill.verificationStatus == .pending }
    }

    private var totalHours: Int {
        appState.activities.reduce(0) { $0 + $1.hours }
    }

    private var uniqueOrgs: Int {
        Set(appState.activities.map(\.clubName)).count
    }

    private var uniqueUniversities: [University] {
        let ids = Set(appState.activities.map(\.hostUniversityId))
        return ids.compactMap { ClubService.university(for: $0) }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 32) {
                        profileHeader
                        if !verifiedSkills.isEmpty { verifiedSection }
                        if !pendingSkills.isEmpty { pendingSection }
                        experiencesSection
                        poweredByTag
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 100)
                }

                shareButton
            }
            .background(Color.brandBg)
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $selectedSkill) { item in
                SkillDetailSheet(item: item)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
            .alert("Reset Demo Data?", isPresented: $showResetConfirm) {
                Button("Reset", role: .destructive) {
                    UserDefaults.standard.removeObject(forKey: "uni_volunteer_activities")
                    appState.activities = SeedDataService.seedIfNeeded()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will clear all data and reload the seed activities. Use between demo rounds.")
            }
        }
    }

    // MARK: - Profile Header

    private var profileHeader: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.brandPrimary, Color.brandPrimary.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)

                Text(String((appState.currentUser?.fullName ?? "AK").prefix(2)))
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
            .onTapGesture(count: 3) { showResetConfirm = true }

            VStack(spacing: 4) {
                Text(appState.currentUser?.fullName ?? "")
                    .font(.system(.title2, design: .default, weight: .bold))

                Text("\(appState.currentUniversity?.name ?? "") \u{00B7} Class of 2026")
                    .font(.system(.subheadline, design: .default, weight: .regular))
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 4) {
                Image(systemName: "graduationcap.fill")
                    .font(.caption2)
                    .foregroundStyle(Color.brandPrimary)
                Text("\(appState.currentUniversity?.name ?? "") Verified Student")
                    .font(.system(.caption, design: .default, weight: .semibold))
                    .foregroundStyle(Color.brandPrimary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Color.brandPrimary.opacity(0.08))
            .clipShape(Capsule())

            HStack(spacing: 0) {
                StatPill(value: "\(totalHours)", label: "hours")
                StatDivider()
                StatPill(value: "\(verifiedSkills.count)", label: "verified skills")
                StatDivider()
                StatPill(value: "\(uniqueUniversities.count)", label: "universities")
                StatDivider()
                StatPill(value: "\(uniqueOrgs)", label: "organizations")
            }
            .padding(.top, 4)

            if uniqueUniversities.count > 1 {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Verified Across")
                        .font(.system(.caption2, design: .default, weight: .semibold))
                        .foregroundStyle(.tertiary)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(uniqueUniversities) { uni in
                                HStack(spacing: 6) {
                                    Circle()
                                        .fill(uni.primaryGradient)
                                        .frame(width: 20, height: 20)
                                        .overlay {
                                            Text(String(uni.shortName.prefix(1)))
                                                .font(.system(size: 9, weight: .bold))
                                                .foregroundStyle(.white)
                                        }
                                    Text(uni.shortName)
                                        .font(.system(.caption2, design: .default, weight: .medium))
                                        .foregroundStyle(.primary)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(.white.opacity(0.8))
                                .clipShape(Capsule())
                                .shadow(color: .black.opacity(0.04), radius: 2, y: 1)
                            }
                        }
                    }
                }
                .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .padding(.horizontal, 16)
        .background(
            LinearGradient(
                colors: [.white, Color.brandBg],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.04), radius: 8, y: 4)
    }

    // MARK: - Verified Skills

    private var verifiedSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Verified Life Skills")
                    .font(.system(.headline, design: .default, weight: .semibold))
                Spacer()
                Text("\(verifiedSkills.count)")
                    .font(.system(.subheadline, design: .rounded, weight: .bold))
                    .foregroundStyle(Color.brandPrimary)
            }

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                ForEach(verifiedSkills) { item in
                    VerifiedSkillCard(item: item)
                        .onTapGesture { selectedSkill = item }
                }
            }
        }
    }

    // MARK: - Pending Skills

    private var pendingSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 6) {
                Image(systemName: "clock.fill")
                    .font(.caption)
                    .foregroundStyle(Color.brandAccent)
                Text("Awaiting Verification")
                    .font(.system(.headline, design: .default, weight: .semibold))
                Spacer()
                Text("\(pendingSkills.count)")
                    .font(.system(.subheadline, design: .rounded, weight: .bold))
                    .foregroundStyle(Color.brandAccent)
            }

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                ForEach(pendingSkills) { item in
                    PendingSkillCard(item: item)
                        .onTapGesture { selectedSkill = item }
                }
            }
        }
    }

    // MARK: - Experiences

    private var experiencesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Volunteer Experiences")
                .font(.system(.headline, design: .default, weight: .semibold))

            let sorted = appState.activities.sorted { $0.date > $1.date }
            ForEach(sorted) { activity in
                NavigationLink(value: activity.id) {
                    ExperienceRow(activity: activity)
                }
                .buttonStyle(.plain)
            }
            .navigationDestination(for: UUID.self) { id in
                if let activity = appState.activities.first(where: { $0.id == id }) {
                    ActivityDetailView(activity: activity)
                }
            }
        }
    }

    // MARK: - Share

    private var shareButton: some View {
        ShareLink(
            item: "Check out my verified volunteer credentials from \(appState.currentUniversity?.name ?? "my university") — univolunteer.app/u/ayse-kaya"
        ) {
            HStack(spacing: 8) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(.body, design: .default, weight: .semibold))
                Text("Share My CV")
                    .font(.system(.subheadline, design: .default, weight: .semibold))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(Color.brandPrimary)
            .clipShape(Capsule())
            .shadow(color: Color.brandPrimary.opacity(0.3), radius: 8, y: 4)
        }
        .padding(.trailing, 16)
        .padding(.bottom, 16)
        .simultaneousGesture(TapGesture().onEnded { HapticService.impactLight() })
    }

    private var poweredByTag: some View {
        HStack(spacing: 4) {
            Image(systemName: "cpu")
                .font(.system(size: 10))
            Text("Skill extraction powered by Claude")
                .font(.system(.caption2, design: .default, weight: .medium))
        }
        .foregroundStyle(.quaternary)
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }
}

// MARK: - Sub-components

private struct StatPill: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 1) {
            Text(value)
                .font(.system(.subheadline, design: .rounded, weight: .bold))
                .foregroundStyle(Color.brandPrimary)
            Text(label)
                .font(.system(.caption2, design: .default, weight: .medium))
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct StatDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color.primary.opacity(0.08))
            .frame(width: 1, height: 28)
    }
}

private struct VerifiedSkillCard: View {
    let item: SkillWithContext

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            confidenceBar

            Text(item.skill.name)
                .font(.system(.footnote, design: .default, weight: .semibold))
                .foregroundStyle(.primary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)

            VStack(alignment: .leading, spacing: 1) {
                if let name = item.skill.verifiedByName {
                    HStack(spacing: 3) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 9))
                            .foregroundStyle(Color.brandSuccess)
                        Text(name)
                            .font(.system(.caption2, design: .default, weight: .medium))
                            .foregroundStyle(Color.brandSuccess)
                            .lineLimit(1)
                    }
                }
                if let clubName = item.skill.verifiedByClubName {
                    Text("\(clubName) \u{2713}")
                        .font(.system(.caption2, design: .default, weight: .regular))
                        .foregroundStyle(.tertiary)
                        .lineLimit(1)
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 100, alignment: .topLeading)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }

    private var confidenceBar: some View {
        let (color, _): (Color, String) = switch item.skill.confidenceLevel {
        case .introduced: (Color(.systemGray4), "Introduced")
        case .practiced: (Color.brandAccent, "Practiced")
        case .proficient: (Color.brandPrimary, "Proficient")
        }

        return RoundedRectangle(cornerRadius: 2)
            .fill(color)
            .frame(height: 3)
    }
}

private struct PendingSkillCard: View {
    let item: SkillWithContext

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                Image(systemName: "clock.fill")
                    .font(.system(size: 8))
                    .foregroundStyle(Color.brandAccent)
                Text("Pending")
                    .font(.system(.caption2, design: .default, weight: .semibold))
                    .foregroundStyle(Color.brandAccent)
            }

            Text(item.skill.name)
                .font(.system(.footnote, design: .default, weight: .semibold))
                .foregroundStyle(.primary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)

            Text(item.activity.clubName)
                .font(.system(.caption2, design: .default, weight: .medium))
                .foregroundStyle(.tertiary)
                .lineLimit(1)
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 100, alignment: .topLeading)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.brandAccent.opacity(0.35), lineWidth: 1.5)
        )
        .shadow(color: .black.opacity(0.03), radius: 4, y: 2)
    }
}

private struct ExperienceRow: View {
    let activity: ClubActivity

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.brandPrimary.opacity(0.1))
                .frame(width: 40, height: 40)
                .overlay {
                    Text(String(activity.clubName.prefix(1)))
                        .font(.system(.subheadline, design: .default, weight: .semibold))
                        .foregroundStyle(Color.brandPrimary)
                }

            VStack(alignment: .leading, spacing: 2) {
                Text(activity.clubName)
                    .font(.system(.subheadline, design: .default, weight: .semibold))
                    .foregroundStyle(.primary)
                Text("\(activity.role) \u{00B7} \(activity.date.formatted(.dateTime.month(.abbreviated).year()))")
                    .font(.system(.caption, design: .default, weight: .regular))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text("\(activity.hours)h")
                .font(.system(.caption, design: .rounded, weight: .bold))
                .foregroundStyle(Color.brandPrimary)
        }
        .padding(12)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(color: .black.opacity(0.03), radius: 3, y: 1)
    }
}

private struct SkillDetailSheet: View {
    let item: SkillWithContext

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Spacer()
            }

            VStack(alignment: .leading, spacing: 8) {
                confidenceTag

                Text(item.skill.name)
                    .font(.system(.title3, design: .default, weight: .bold))

                if item.skill.verificationStatus == .verified, let name = item.skill.verifiedByName {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundStyle(Color.brandSuccess)
                            Text("Verified by \(name)")
                                .foregroundStyle(Color.brandSuccess)
                        }
                        .font(.system(.caption, design: .default, weight: .semibold))
                        if let clubName = item.skill.verifiedByClubName {
                            Text("\(clubName) \u{00B7} Recognized by University \u{2713}")
                                .font(.system(.caption2, design: .default, weight: .regular))
                                .foregroundStyle(.secondary)
                        }
                    }
                } else {
                    HStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                            .foregroundStyle(Color.brandAccent)
                        Text("Awaiting verification from \(item.activity.clubName)")
                            .foregroundStyle(Color.brandAccent)
                    }
                    .font(.system(.caption, design: .default, weight: .semibold))
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Evidence")
                    .font(.system(.caption, design: .default, weight: .semibold))
                    .foregroundStyle(.tertiary)

                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "quote.opening")
                        .font(.caption)
                        .foregroundStyle(Color.brandPrimary.opacity(0.4))
                        .padding(.top, 2)

                    Text(item.skill.evidenceQuote)
                        .font(.system(.subheadline, design: .default, weight: .regular))
                        .italic()
                        .foregroundStyle(.secondary)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Activity")
                    .font(.system(.caption, design: .default, weight: .semibold))
                    .foregroundStyle(.tertiary)

                HStack(spacing: 12) {
                    Circle()
                        .fill(Color.brandPrimary.opacity(0.1))
                        .frame(width: 36, height: 36)
                        .overlay {
                            Text(String(item.activity.clubName.prefix(1)))
                                .font(.system(.caption, design: .default, weight: .semibold))
                                .foregroundStyle(Color.brandPrimary)
                        }

                    VStack(alignment: .leading, spacing: 1) {
                        Text(item.activity.clubName)
                            .font(.system(.subheadline, design: .default, weight: .semibold))
                        Text("\(item.activity.role) \u{00B7} \(item.activity.hours)h \u{00B7} \(item.activity.date.formatted(.dateTime.month(.abbreviated).year()))")
                            .font(.system(.caption, design: .default, weight: .regular))
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()
        }
        .padding(24)
    }

    private var confidenceTag: some View {
        let (label, color): (String, Color) = switch item.skill.confidenceLevel {
        case .introduced: ("Introduced", Color(.systemGray4))
        case .practiced: ("Practiced", Color.brandAccent)
        case .proficient: ("Proficient", Color.brandPrimary)
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

// MARK: - Mode Switch Sheet (removed — now uses LoginView)
