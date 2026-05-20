import Foundation

struct ClubActivity: Identifiable, Codable {
    var id = UUID()
    var clubId: UUID
    var hostUniversityId: UUID
    var role: String
    var hours: Int
    var date: Date
    var reflections: [String]
    var extractedSkills: [ExtractedSkill]
    var photoData: Data?
    var createdAt = Date()

    var clubName: String {
        ClubService.club(for: clubId)?.name ?? "Unknown Club"
    }

    var universityName: String {
        ClubService.university(for: hostUniversityId)?.name ?? "Unknown University"
    }

    var universityShortName: String {
        ClubService.university(for: hostUniversityId)?.shortName ?? ""
    }

    func isCrossUniversity(homeUniversityId: UUID) -> Bool {
        hostUniversityId != homeUniversityId
    }
}
