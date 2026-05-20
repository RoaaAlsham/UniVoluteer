import SwiftUI

struct University: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let shortName: String
    let adminContactEmail: String

    var brandColor: Color {
        if id == ClubService.IDs.bogazici { return Color.brandPrimary }
        if id == ClubService.IDs.fsmvu { return Color(red: 0.7, green: 0.15, blue: 0.15) }
        if id == ClubService.IDs.altinbas { return Color(red: 0.1, green: 0.3, blue: 0.45) }
        return .gray
    }

    var gradientColors: [Color] {
        if id == ClubService.IDs.bogazici { return [Color(red: 0.15, green: 0.15, blue: 0.5), Color.brandPrimary] }
        if id == ClubService.IDs.fsmvu { return [Color(red: 0.55, green: 0.1, blue: 0.1), Color(red: 0.85, green: 0.6, blue: 0.15)] }
        if id == ClubService.IDs.altinbas { return [Color(red: 0.08, green: 0.15, blue: 0.35), Color(red: 0.15, green: 0.5, blue: 0.5)] }
        return [.gray, .gray.opacity(0.6)]
    }

    var primaryGradient: LinearGradient {
        LinearGradient(colors: gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}
