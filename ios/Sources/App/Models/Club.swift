import Foundation

struct Club: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let universityId: UUID
    let authorizedSupervisorIds: [UUID]
    let isRecognized: Bool
}
