import SwiftUI

struct SupervisorHomeView: View {
    @Environment(AppState.self) private var appState

    private var supervisor: User? { appState.currentUser }

    private var authorizedClubIds: [UUID] {
        supervisor?.authorizedClubIds ?? []
    }

    private var pendingActivities: [ClubActivity] {
        appState.activities
            .filter { authorizedClubIds.contains($0.clubId) }
            .filter { $0.extractedSkills.contains { $0.verificationStatus == .pending } }
            .sorted { $0.createdAt > $1.createdAt }
    }

    private var recentlyVerified: [ClubActivity] {
        appState.activities
            .filter { authorizedClubIds.contains($0.clubId) }
            .filter { $0.extractedSkills.contains { $0.verificationStatus == .verified } }
            .filter { !$0.extractedSkills.contains { $0.verificationStatus == .pending } }
            .sorted { $0.createdAt > $1.createdAt }
            .prefix(5).map { $0 }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    headerSection
                    pendingSection
                    if !recentlyVerified.isEmpty { recentSection }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 32)
            }
            .background(Color.brandBg)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        appState.logout()
                    } label: {
                        Text("Switch")
                            .font(.system(.subheadline, design: .default, weight: .medium))
                            .foregroundStyle(Color.brandPrimary)
                    }
                }
            }
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Circle()
                    .fill(Color.brandAccent.opacity(0.15))
                    .frame(width: 52, height: 52)
                    .overlay {
                        Image(systemName: "person.badge.shield.checkmark")
                            .font(.system(size: 22))
                            .foregroundStyle(Color.brandAccent)
                    }

                VStack(alignment: .leading, spacing: 2) {
                    Text(supervisor?.fullName ?? "Supervisor")
                        .font(.system(.title3, design: .default, weight: .bold))
                    Text("Supervisor \u{00B7} \(appState.currentUniversity?.name ?? "")")
                        .captionStyle()
                }
            }

            HStack(spacing: 8) {
                ForEach(authorizedClubIds, id: \.self) { clubId in
                    if let club = ClubService.club(for: clubId) {
                        Text(club.name)
                            .font(.system(.caption2, design: .default, weight: .semibold))
                            .foregroundStyle(Color.brandPrimary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.brandPrimary.opacity(0.08))
                            .clipShape(Capsule())
                    }
                }
            }

            Text("Provisioned by University Admin \u{00B7} \(appState.currentUniversity?.shortName ?? "") Student Affairs")
                .font(.system(.caption2, design: .default, weight: .regular))
                .foregroundStyle(.quaternary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }

    private var pendingSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Pending Verifications")
                    .headlineStyle()
                if !pendingActivities.isEmpty {
                    Text("\(pendingActivities.flatMap(\.extractedSkills).filter { $0.verificationStatus == .pending }.count)")
                        .font(.system(.caption, design: .rounded, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.brandAccent)
                        .clipShape(Capsule())
                }
            }

            if pendingActivities.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(Color.brandSuccess)
                    Text("All caught up!")
                        .font(.system(.subheadline, design: .default, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                ForEach(pendingActivities) { activity in
                    NavigationLink(value: activity.id) {
                        PendingActivityRow(activity: activity)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .navigationDestination(for: UUID.self) { id in
            if let activity = appState.activities.first(where: { $0.id == id }) {
                SupervisorVerificationView(activity: activity)
            }
        }
    }

    private var recentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recently Verified")
                .font(.system(.subheadline, design: .default, weight: .semibold))
                .foregroundStyle(.secondary)

            ForEach(recentlyVerified) { activity in
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(Color.brandSuccess)
                    VStack(alignment: .leading, spacing: 1) {
                        Text(activity.clubName)
                            .font(.system(.caption, design: .default, weight: .semibold))
                        Text("\(activity.extractedSkills.filter { $0.verificationStatus == .verified }.count) skills verified")
                            .font(.system(.caption2, design: .default, weight: .regular))
                            .foregroundStyle(.tertiary)
                    }
                    Spacer()
                }
                .padding(10)
                .background(Color.brandSuccess.opacity(0.04))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }
}

private struct PendingActivityRow: View {
    let activity: ClubActivity

    private var pendingCount: Int {
        activity.extractedSkills.filter { $0.verificationStatus == .pending }.count
    }

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.brandPrimary.opacity(0.1))
                .frame(width: 40, height: 40)
                .overlay {
                    Text("AK")
                        .font(.system(.caption, design: .default, weight: .semibold))
                        .foregroundStyle(Color.brandPrimary)
                }

            VStack(alignment: .leading, spacing: 2) {
                Text("Ayşe Kaya")
                    .font(.system(.subheadline, design: .default, weight: .semibold))
                Text("\(activity.clubName) \u{00B7} \(activity.role)")
                    .font(.system(.caption, design: .default, weight: .regular))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("\(pendingCount)")
                    .font(.system(.subheadline, design: .rounded, weight: .bold))
                    .foregroundStyle(Color.brandAccent)
                Text("pending")
                    .font(.system(.caption2, design: .default, weight: .medium))
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(14)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }
}
