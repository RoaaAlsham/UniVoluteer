import SwiftUI

struct ActivityInfoView: View {
    @Environment(AppState.self) private var appState
    @Binding var selectedUniversityId: UUID?
    @Binding var selectedClubId: UUID?
    @Binding var role: String
    @Binding var hours: Int
    @Binding var date: Date

    var onContinue: () -> Void

    @State private var selectedUniversity: University?
    @State private var selectedClub: Club?

    private var homeUniversityId: UUID {
        appState.currentUser?.universityId ?? ClubService.IDs.bogazici
    }

    private var isCrossUniversity: Bool {
        guard let sel = selectedUniversity else { return false }
        return sel.id != homeUniversityId
    }

    private var clubsForSelectedUni: [Club] {
        guard let uni = selectedUniversity else { return [] }
        return ClubService.clubs(for: uni.id)
    }

    private var sortedUniversities: [University] {
        ClubService.universities.sorted {
            if $0.id == homeUniversityId { return true }
            if $1.id == homeUniversityId { return false }
            return $0.name < $1.name
        }
    }

    private var isValid: Bool {
        selectedUniversity != nil && selectedClub != nil && !role.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Log New Activity")
                        .largeTitleStyle()
                    Text("Pick the university hosting the activity, then the specific club.")
                        .captionStyle()
                }
                .padding(.top, 8)

                VStack(alignment: .leading, spacing: 16) {
                    ComboBoxField(
                        label: "Host University",
                        placeholder: "Select a university...",
                        items: sortedUniversities,
                        selection: $selectedUniversity,
                        displayName: { $0.name },
                        searchableText: { "\($0.name) \($0.shortName)" },
                        rowContent: { uni in universityRow(uni) }
                    )

                    if let uni = selectedUniversity {
                        if isCrossUniversity {
                            crossUniversityBanner(uni: uni)
                        } else {
                            homeUniversityBanner
                        }
                    }

                    ComboBoxField(
                        label: "Club",
                        placeholder: "Select a club...",
                        items: clubsForSelectedUni,
                        selection: $selectedClub,
                        displayName: { $0.name },
                        searchableText: { $0.name },
                        rowContent: { club in clubRow(club) },
                        isDisabled: selectedUniversity == nil,
                        disabledMessage: "Pick a university first"
                    )

                    if let club = selectedClub {
                        supervisorPreview(for: club)
                    }

                    fieldSection("Your Role") {
                        TextField("e.g. Event Coordinator, Social Media Lead", text: $role)
                            .padding(12)
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.primary.opacity(0.1)))
                    }

                    HStack(spacing: 24) {
                        fieldSection("Hours") {
                            Stepper("\(hours)h", value: $hours, in: 1...100)
                                .padding(12)
                                .background(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.primary.opacity(0.1)))
                        }
                        fieldSection("Date") {
                            DatePicker("", selection: $date, displayedComponents: .date)
                                .labelsHidden()
                                .padding(8)
                                .background(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.primary.opacity(0.1)))
                        }
                    }
                }

                Button(action: onContinue) {
                    Text("Continue")
                        .font(.system(.body, design: .default, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(isValid ? Color.brandPrimary : Color.brandPrimary.opacity(0.35))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(!isValid)
                .padding(.top, 8)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
        }
        .background(Color.brandBg)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if selectedUniversity == nil, let home = ClubService.university(for: homeUniversityId) {
                selectedUniversity = home
                selectedUniversityId = home.id
            }
            if let clubId = selectedClubId {
                selectedClub = ClubService.club(for: clubId)
            }
        }
        .onChange(of: selectedUniversity) { _, newUni in
            selectedUniversityId = newUni?.id
            if newUni?.id != selectedClub.flatMap({ ClubService.universityForClub($0.id) })?.id {
                selectedClub = nil
                selectedClubId = nil
            }
        }
        .onChange(of: selectedClub) { _, newClub in
            selectedClubId = newClub?.id
        }
    }

    // MARK: - Row Content

    private func universityRow(_ uni: University) -> some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 8)
                .fill(uni.primaryGradient)
                .frame(width: 40, height: 40)
                .overlay {
                    Text(String(uni.shortName.prefix(1)))
                        .font(.system(.subheadline, design: .default, weight: .bold))
                        .foregroundStyle(.white)
                }

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(uni.name)
                        .font(.system(.body, design: .default, weight: .medium))
                        .foregroundStyle(.primary)
                    if uni.id == homeUniversityId {
                        Text("Your University")
                            .font(.system(.caption2, design: .default, weight: .semibold))
                            .foregroundStyle(Color.brandPrimary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.brandPrimary.opacity(0.1))
                            .clipShape(Capsule())
                    }
                }
                Text("\(ClubService.clubs(for: uni.id).count) recognized clubs")
                    .font(.system(.caption, design: .default, weight: .regular))
                    .foregroundStyle(.tertiary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .frame(minHeight: 48)
    }

    private func clubRow(_ club: Club) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill((selectedUniversity?.brandColor ?? .gray).opacity(0.12))
                .frame(width: 32, height: 32)
                .overlay {
                    Text(String(club.name.prefix(1)))
                        .font(.system(.caption2, design: .default, weight: .semibold))
                        .foregroundStyle(selectedUniversity?.brandColor ?? .gray)
                }

            VStack(alignment: .leading, spacing: 2) {
                Text(club.name)
                    .font(.system(.body, design: .default, weight: .medium))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                let supervisors = ClubService.supervisors(for: club.id).map(\.fullName).joined(separator: ", ")
                if !supervisors.isEmpty {
                    Text("\(supervisors) \u{00B7} \(selectedUniversity?.shortName ?? "")")
                        .font(.system(.caption, design: .default, weight: .regular))
                        .foregroundStyle(.tertiary)
                        .lineLimit(1)
                }
            }

            Spacer()
        }
        .frame(minHeight: 40)
    }

    // MARK: - Banners

    private func crossUniversityBanner(uni: University) -> some View {
        HStack(spacing: 8) {
            Text("\u{1F91D}")
                .font(.system(size: 14))
            Text("Cross-university activity — verified by \(uni.shortName)'s supervisors")
                .font(.system(.caption, design: .default, weight: .medium))
                .foregroundStyle(uni.brandColor)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(uni.brandColor.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private var homeUniversityBanner: some View {
        HStack(spacing: 6) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 12))
                .foregroundStyle(Color.brandSuccess)
            Text("At your home university")
                .font(.system(.caption, design: .default, weight: .medium))
                .foregroundStyle(Color.brandSuccess)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.brandSuccess.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func supervisorPreview(for club: Club) -> some View {
        let supervisors = ClubService.supervisors(for: club.id)
        let names = supervisors.map(\.fullName).joined(separator: ", ")
        let uni = ClubService.universityForClub(club.id)

        return VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: "checkmark.shield.fill")
                    .font(.system(size: 10))
                    .foregroundStyle(Color.brandSuccess)
                Text("Recognized by \(uni?.name ?? "University")")
                    .font(.system(.caption, design: .default, weight: .medium))
                    .foregroundStyle(Color.brandSuccess)
            }
            if !names.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "person.fill")
                        .font(.system(size: 9))
                    Text("Will be reviewed by \(names)")
                }
                .font(.system(.caption2, design: .default, weight: .medium))
                .foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.brandSuccess.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func fieldSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(.subheadline, design: .default, weight: .medium))
            content()
        }
    }
}
