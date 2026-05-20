import SwiftUI

struct ActivityCardView: View {
    @Environment(AppState.self) private var appState
    let activity: ClubActivity

    private var verifiedCount: Int {
        activity.extractedSkills.filter { $0.verificationStatus == .verified }.count
    }

    private var pendingCount: Int {
        activity.extractedSkills.filter { $0.verificationStatus == .pending }.count
    }

    private var statusLine: String {
        var parts = ["\(activity.extractedSkills.count) skills extracted"]
        if verifiedCount > 0 { parts.append("\(verifiedCount) verified \u{2713}") }
        if pendingCount > 0 { parts.append("\(pendingCount) pending") }
        return parts.joined(separator: " \u{00B7} ")
    }

    private var isCross: Bool {
        guard let homeId = appState.currentUser?.universityId else { return false }
        return activity.isCrossUniversity(homeUniversityId: homeId)
    }

    private var hostUni: University? {
        ClubService.university(for: activity.hostUniversityId)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(activity.clubName)
                        .headlineStyle()
                        .foregroundStyle(.primary)

                    Text("\(activity.role) \u{00B7} \(activity.date.formatted(.dateTime.month(.wide).year()))")
                        .captionStyle()
                }

                Spacer()

                Text("\(activity.hours)h")
                    .font(.system(.caption, design: .rounded, weight: .bold))
                    .foregroundStyle(Color.brandPrimary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.brandPrimary.opacity(0.1))
                    .clipShape(Capsule())
            }

            HStack(spacing: 4) {
                if isCross {
                    Text("\u{1F91D}")
                        .font(.system(size: 10))
                }
                Image(systemName: "checkmark.shield.fill")
                    .font(.system(size: 10))
                    .foregroundStyle(hostUni?.brandColor ?? Color.brandSuccess)
                Text("Recognized by \(activity.universityName)")
                    .font(.system(.caption2, design: .default, weight: .medium))
                    .foregroundStyle(hostUni?.brandColor ?? Color.brandSuccess)
            }

            Text(statusLine)
                .font(.system(.footnote, design: .default, weight: .regular))
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }
}
