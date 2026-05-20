import Foundation

enum UserRole: String, Codable, CaseIterable {
    case volunteer
    case supervisor
}

struct User: Identifiable, Codable, Hashable {
    let id: UUID
    let fullName: String
    let email: String
    let universityId: UUID
    let role: UserRole
    let authorizedClubIds: [UUID]
    let studentId: String?
    let program: String?

    var firstName: String {
        fullName.components(separatedBy: " ").first ?? fullName
    }
}
