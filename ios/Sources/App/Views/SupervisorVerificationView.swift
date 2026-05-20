import SwiftUI

struct SupervisorVerificationView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    let activity: ClubActivity

    @State private var editingSkill: ExtractedSkill?

    private var volunteer: User {
        ClubService.users.first { $0.role == .volunteer } ?? ClubService.user(for: ClubService.IDs.ayse)!
    }

    private var pendingSkills: [ExtractedSkill] {
        activity.extractedSkills.filter { $0.verificationStatus == .pending }
    }

    private var currentActivity: ClubActivity {
        appState.activities.first(where: { $0.id == activity.id }) ?? activity
    }

    private var allDecided: Bool {
        currentActivity.extractedSkills.allSatisfy { $0.verificationStatus != .pending }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                authorizationBanner
                studentHeader
                reflectionsSection
                skillsSection

                if allDecided {
                    doneButton
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
        .background(Color.brandBg)
        .navigationTitle("Verify Skills")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $editingSkill) { skill in
            EditSkillSheet(
                name: skill.name,
                onSave: { newName in
                    appState.renameSkill(activityId: activity.id, skillId: skill.id, newName: newName)
                    editingSkill = nil
                },
                onCancel: { editingSkill = nil }
            )
            .presentationDetents([.height(220)])
            .presentationDragIndicator(.visible)
        }
    }

    private var authorizationBanner: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.shield.fill")
                .foregroundStyle(Color.brandSuccess)
            Text("You are authorized to verify skills for \(currentActivity.clubName)")
                .font(.system(.caption, design: .default, weight: .medium))
                .foregroundStyle(Color.brandSuccess)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.brandSuccess.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private var studentHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Circle()
                    .fill(Color.brandPrimary.opacity(0.15))
                    .frame(width: 48, height: 48)
                    .overlay {
                        Text(String(volunteer.fullName.prefix(1)))
                            .font(.system(.title3, design: .default, weight: .semibold))
                            .foregroundStyle(Color.brandPrimary)
                    }

                VStack(alignment: .leading, spacing: 2) {
                    Text(volunteer.fullName)
                        .font(.system(.headline, design: .default, weight: .semibold))
                    Text(ClubService.university(for: volunteer.universityId)?.name ?? "")
                        .captionStyle()
                }
            }

            Divider()

            HStack(spacing: 16) {
                Label(currentActivity.clubName, systemImage: "building.2.fill")
                Label(currentActivity.role, systemImage: "person.fill")
            }
            .captionStyle()

            HStack(spacing: 16) {
                Label("\(currentActivity.hours) hours", systemImage: "clock.fill")
                Label(currentActivity.date.formatted(.dateTime.day().month(.wide).year()), systemImage: "calendar")
            }
            .captionStyle()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }

    private var reflectionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Student's Reflections")
                .headlineStyle()

            ForEach(Array(currentActivity.reflections.enumerated()), id: \.offset) { index, reflection in
                VStack(alignment: .leading, spacing: 4) {
                    Text(["What they did", "Hardest part", "What they'd change"][min(index, 2)])
                        .font(.system(.caption, design: .default, weight: .semibold))
                        .foregroundStyle(Color.brandPrimary)
                    Text(reflection)
                        .font(.system(.footnote, design: .default, weight: .regular))
                        .foregroundStyle(.secondary)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.brandPrimary.opacity(0.04))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }

    private var skillsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Skills to Verify")
                .headlineStyle()

            ForEach(currentActivity.extractedSkills) { skill in
                VerificationSkillCard(
                    skill: skill,
                    onConfirm: {
                        HapticService.impactMedium()
                        withAnimation(.easeInOut(duration: 0.3)) {
                            appState.updateSkill(
                                activityId: activity.id,
                                skillId: skill.id,
                                status: .verified,
                                verifiedByUserId: appState.currentUser?.id,
                                verifiedByClubId: currentActivity.clubId
                            )
                        }
                    },
                    onEdit: { editingSkill = skill },
                    onReject: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            appState.updateSkill(
                                activityId: activity.id,
                                skillId: skill.id,
                                status: .rejected
                            )
                        }
                    }
                )
            }
        }
    }

    private var doneButton: some View {
        Button(action: { dismiss() }) {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                Text("Done")
            }
            .font(.system(.body, design: .default, weight: .semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.brandSuccess)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(.top, 8)
    }
}

private struct VerificationSkillCard: View {
    let skill: ExtractedSkill
    let onConfirm: () -> Void
    let onEdit: () -> Void
    let onReject: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(skill.name)
                .font(.system(.subheadline, design: .default, weight: .semibold))
                .foregroundStyle(.primary)

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

            confidenceTag

            statusOrActions
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
    private var statusOrActions: some View {
        switch skill.verificationStatus {
        case .pending:
            HStack(spacing: 8) {
                Button(action: onConfirm) {
                    Label("Confirm", systemImage: "checkmark")
                        .font(.system(.caption, design: .default, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Color.brandSuccess)
                        .clipShape(Capsule())
                }

                Button(action: onEdit) {
                    Label("Edit", systemImage: "pencil")
                        .font(.system(.caption, design: .default, weight: .semibold))
                        .foregroundStyle(Color.brandPrimary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Color.brandPrimary.opacity(0.1))
                        .clipShape(Capsule())
                }

                Button(action: onReject) {
                    Label("Reject", systemImage: "xmark")
                        .font(.system(.caption, design: .default, weight: .semibold))
                        .foregroundStyle(.red)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Color.red.opacity(0.1))
                        .clipShape(Capsule())
                }
            }

        case .verified:
            HStack(spacing: 4) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(Color.brandSuccess)
                Text("Verified")
                    .foregroundStyle(Color.brandSuccess)
            }
            .font(.system(.caption, design: .default, weight: .medium))

        case .rejected:
            HStack(spacing: 4) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.red)
                Text("Rejected")
                    .foregroundStyle(.red)
            }
            .font(.system(.caption, design: .default, weight: .medium))
        }
    }
}

private struct EditSkillSheet: View {
    @State var name: String
    let onSave: (String) -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Edit Skill Name")
                .font(.system(.headline, design: .default, weight: .semibold))
                .padding(.top, 20)

            TextField("Skill name", text: $name)
                .padding(12)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal, 24)

            HStack(spacing: 12) {
                Button(action: onCancel) {
                    Text("Cancel")
                        .font(.system(.body, design: .default, weight: .medium))
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.primary.opacity(0.06))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }

                Button { onSave(name) } label: {
                    Text("Save")
                        .font(.system(.body, design: .default, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(name.isEmpty ? Color.brandPrimary.opacity(0.35) : Color.brandPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .disabled(name.isEmpty)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
    }
}
