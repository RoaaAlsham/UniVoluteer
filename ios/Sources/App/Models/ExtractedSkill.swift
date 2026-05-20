import Foundation

enum ConfidenceLevel: String, Codable, CaseIterable {
    case introduced
    case practiced
    case proficient
}

enum VerificationStatus: String, Codable, CaseIterable {
    case pending
    case verified
    case rejected
}

struct ExtractedSkill: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var evidenceQuote: String
    var confidenceLevel: ConfidenceLevel
    var verificationStatus: VerificationStatus = .pending
    var verifiedByUserId: UUID?
    var verifiedByClubId: UUID?
    var verifiedAt: Date?

    var verifiedByName: String? {
        guard let userId = verifiedByUserId else { return nil }
        return ClubService.user(for: userId)?.fullName
    }

    var verifiedByClubName: String? {
        guard let clubId = verifiedByClubId else { return nil }
        return ClubService.club(for: clubId)?.name
    }
}
