import SwiftUI
import PhotosUI

enum AddNewStep: Hashable {
    case reflection
    case extracting
    case review
}

struct AddNewView: View {
    @Environment(AppState.self) private var appState
    @State private var path = NavigationPath()

    @State private var selectedUniversityId: UUID?
    @State private var selectedClubId: UUID?
    @State private var role = ""
    @State private var hours = 4
    @State private var date = Date()
    @State private var reflections = ["", "", ""]
    @State private var photoData: Data?
    @State private var extractedSkills: [ExtractedSkill] = []

    private var selectedClubName: String {
        guard let id = selectedClubId else { return "" }
        return ClubService.club(for: id)?.name ?? ""
    }

    var body: some View {
        NavigationStack(path: $path) {
            ActivityInfoView(
                selectedUniversityId: $selectedUniversityId,
                selectedClubId: $selectedClubId,
                role: $role,
                hours: $hours,
                date: $date,
                onContinue: { path.append(AddNewStep.reflection) }
            )
            .navigationDestination(for: AddNewStep.self) { step in
                switch step {
                case .reflection:
                    ReflectionView(
                        reflections: $reflections,
                        photoData: $photoData,
                        onExtract: { path.append(AddNewStep.extracting) }
                    )
                case .extracting:
                    ExtractingSkillsView(
                        clubName: selectedClubName,
                        role: role,
                        hours: hours,
                        date: date,
                        reflections: reflections,
                        onComplete: { skills in
                            extractedSkills = skills
                            path.append(AddNewStep.review)
                        },
                        onCancel: { path.removeLast() }
                    )
                case .review:
                    SkillsReviewView(
                        clubId: selectedClubId ?? UUID(),
                        clubName: selectedClubName,
                        role: role,
                        hours: hours,
                        date: date,
                        extractedSkills: extractedSkills,
                        onSave: saveActivity
                    )
                }
            }
        }
    }

    private func saveActivity() {
        guard let clubId = selectedClubId,
              let uniId = selectedUniversityId else { return }
        let activity = ClubActivity(
            clubId: clubId,
            hostUniversityId: uniId,
            role: role,
            hours: hours,
            date: date,
            reflections: reflections,
            extractedSkills: extractedSkills,
            photoData: photoData
        )
        appState.activities.insert(activity, at: 0)
        appState.saveActivities()
        resetDraft()
        appState.selectedTab = 0
    }

    private func resetDraft() {
        selectedUniversityId = nil
        selectedClubId = nil
        role = ""
        hours = 4
        date = Date()
        reflections = ["", "", ""]
        photoData = nil
        extractedSkills = []
        path = NavigationPath()
    }
}
