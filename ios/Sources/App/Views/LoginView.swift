import SwiftUI

struct LoginView: View {
    @Environment(AppState.self) private var appState
    @State private var showSupervisorPicker = false

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.brandPrimary, Color.brandPrimary.opacity(0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 72, height: 72)
                    Image(systemName: "hands.sparkles.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(.white)
                }

                Text("UniVolunteer")
                    .font(.system(.title, design: .default, weight: .bold))

                if let uni = ClubService.universities.first {
                    Text(uni.name)
                        .font(.system(.subheadline, design: .default, weight: .medium))
                        .foregroundStyle(.secondary)
                }
            }

            VStack(spacing: 12) {
                Text("Sign in as...")
                    .font(.system(.subheadline, design: .default, weight: .medium))
                    .foregroundStyle(.secondary)

                Button {
                    let ayse = ClubService.users.first { $0.role == .volunteer }!
                    appState.login(user: ayse)
                } label: {
                    RoleCard(
                        icon: "graduationcap.fill",
                        title: "Volunteer",
                        subtitle: "Log activities, build verified skills",
                        color: .brandPrimary
                    )
                }
                .buttonStyle(.plain)

                Button { showSupervisorPicker = true } label: {
                    RoleCard(
                        icon: "person.badge.shield.checkmark",
                        title: "Supervisor",
                        subtitle: "Verify skills for your club volunteers",
                        color: .brandAccent
                    )
                }
                .buttonStyle(.plain)
            }

            Spacer()

            if let uni = ClubService.universities.first {
                Text("Clubs and supervisors are provisioned by your University Admin via the web dashboard. Contact \(uni.adminContactEmail) to onboard.")
                    .font(.system(.caption2, design: .default, weight: .regular))
                    .foregroundStyle(.quaternary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 16)
            }
        }
        .padding(.horizontal, 24)
        .background(Color.brandBg)
        .sheet(isPresented: $showSupervisorPicker) {
            SupervisorPickerSheet()
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
    }
}

private struct RoleCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.1))
                    .frame(width: 48, height: 48)
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(color)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(.headline, design: .default, weight: .semibold))
                    .foregroundStyle(.primary)
                Text(subtitle)
                    .font(.system(.caption, design: .default, weight: .regular))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }
}

private struct SupervisorPickerSheet: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Select Supervisor Account")
                .font(.system(.headline, design: .default, weight: .semibold))
                .padding(.top, 20)
                .padding(.horizontal, 24)

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(ClubService.universities) { uni in
                        let supervisors = ClubService.supervisorUsers().filter { $0.universityId == uni.id }
                        if !supervisors.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 6) {
                                    Circle()
                                        .fill(uni.primaryGradient)
                                        .frame(width: 18, height: 18)
                                        .overlay {
                                            Text(String(uni.shortName.prefix(1)))
                                                .font(.system(size: 8, weight: .bold))
                                                .foregroundStyle(.white)
                                        }
                                    Text(uni.name)
                                        .font(.system(.caption, design: .default, weight: .semibold))
                                        .foregroundStyle(.secondary)
                                }

                                ForEach(supervisors) { supervisor in
                                    Button {
                                        appState.login(user: supervisor)
                                        dismiss()
                                    } label: {
                                        SupervisorRow(supervisor: supervisor, brandColor: uni.brandColor)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
            }
        }
    }
}

private struct SupervisorRow: View {
    let supervisor: User
    var brandColor: Color = .brandAccent

    private var clubNames: String {
        supervisor.authorizedClubIds
            .compactMap { ClubService.club(for: $0)?.name }
            .joined(separator: ", ")
    }

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(brandColor.opacity(0.15))
                .frame(width: 40, height: 40)
                .overlay {
                    Text(String(supervisor.fullName.prefix(1)))
                        .font(.system(.subheadline, design: .default, weight: .semibold))
                        .foregroundStyle(brandColor)
                }

            VStack(alignment: .leading, spacing: 2) {
                Text(supervisor.fullName)
                    .font(.system(.subheadline, design: .default, weight: .semibold))
                    .foregroundStyle(.primary)
                Text(clubNames)
                    .font(.system(.caption, design: .default, weight: .regular))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(12)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(color: .black.opacity(0.03), radius: 3, y: 1)
    }
}
