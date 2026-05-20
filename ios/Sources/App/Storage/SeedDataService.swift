import Foundation

@MainActor
enum SeedDataService {
    static func seedIfNeeded() -> [ClubActivity] {
        let persistence = PersistenceService.shared
        if persistence.hasExistingData() {
            return persistence.load()
        }
        let activities = makeSeedActivities()
        try? persistence.save(activities)
        return activities
    }

    private static func makeSeedActivities() -> [ClubActivity] {
        let cal = Calendar.current
        let ids = ClubService.IDs.self

        let activity1 = ClubActivity(
            clubId: ids.aiesec,
            hostUniversityId: ids.bogazici,
            role: "Workshop Facilitator",
            hours: 18,
            date: cal.date(byAdding: .month, value: -3, to: .now)!,
            reflections: [
                "I designed a 90-minute leadership workshop for 40 incoming exchange students who spoke five different languages. I had to restructure my slides three times because the first version assumed everyone understood Turkish idioms.",
                "The hardest part was when the projector died mid-session and I had to pivot to a fully interactive format with zero preparation. I split the group into pairs and turned my talking points into debate prompts.",
                "After the workshop, two participants told me they'd never had a session delivered in both Turkish and English simultaneously. I realized that switching languages mid-sentence wasn't a weakness — it was actually keeping both groups engaged."
            ],
            extractedSkills: [
                ExtractedSkill(name: "Bilingual Workshop Design",
                    evidenceQuote: "switching languages mid-sentence wasn't a weakness — it was actually keeping both groups engaged",
                    confidenceLevel: .proficient, verificationStatus: .verified,
                    verifiedByUserId: ids.mehmet, verifiedByClubId: ids.aiesec,
                    verifiedAt: cal.date(byAdding: .month, value: -2, to: .now)),
                ExtractedSkill(name: "Improvised Facilitation Under Equipment Failure",
                    evidenceQuote: "the projector died mid-session and I had to pivot to a fully interactive format with zero preparation",
                    confidenceLevel: .practiced, verificationStatus: .verified,
                    verifiedByUserId: ids.mehmet, verifiedByClubId: ids.aiesec,
                    verifiedAt: cal.date(byAdding: .month, value: -2, to: .now)),
                ExtractedSkill(name: "Cross-Cultural Audience Calibration",
                    evidenceQuote: "I had to restructure my slides three times because the first version assumed everyone understood Turkish idioms",
                    confidenceLevel: .practiced, verificationStatus: .verified,
                    verifiedByUserId: ids.mehmet, verifiedByClubId: ids.aiesec,
                    verifiedAt: cal.date(byAdding: .month, value: -2, to: .now)),
                ExtractedSkill(name: "Rapid Session Redesign",
                    evidenceQuote: "I split the group into pairs and turned my talking points into debate prompts",
                    confidenceLevel: .proficient, verificationStatus: .verified,
                    verifiedByUserId: ids.mehmet, verifiedByClubId: ids.aiesec,
                    verifiedAt: cal.date(byAdding: .month, value: -2, to: .now)),
            ]
        )

        let activity2 = ClubActivity(
            clubId: ids.fsmvuSosyal,
            hostUniversityId: ids.fsmvu,
            role: "Community Outreach Coordinator",
            hours: 32,
            date: cal.date(byAdding: .month, value: -6, to: .now)!,
            reflections: [
                "I organized a neighbourhood literacy program through FSMVÜ's social responsibility club, reaching 45 families in Fatih district. I had to coordinate with local muhtars and school principals to find safe spaces for weekend reading sessions.",
                "The hardest part was when three venue hosts cancelled in the same week due to renovation works. I pivoted to a park-based reading circle format and convinced a local tea garden owner to let us use his outdoor space for free on Saturday mornings.",
                "What I'd change: I would have built a volunteer rotation system from day one. By month two I was personally running every session, and when I got sick for a week the whole program paused. I learned that sustainable impact requires distributing responsibility, not centralizing it."
            ],
            extractedSkills: [
                ExtractedSkill(name: "Community Stakeholder Navigation",
                    evidenceQuote: "I had to coordinate with local muhtars and school principals to find safe spaces for weekend reading sessions",
                    confidenceLevel: .proficient, verificationStatus: .verified,
                    verifiedByUserId: ids.selin, verifiedByClubId: ids.fsmvuSosyal,
                    verifiedAt: cal.date(byAdding: .month, value: -5, to: .now)),
                ExtractedSkill(name: "Venue Crisis Recovery",
                    evidenceQuote: "three venue hosts cancelled in the same week… I pivoted to a park-based reading circle format",
                    confidenceLevel: .practiced, verificationStatus: .verified,
                    verifiedByUserId: ids.selin, verifiedByClubId: ids.fsmvuSosyal,
                    verifiedAt: cal.date(byAdding: .month, value: -5, to: .now)),
                ExtractedSkill(name: "Program Sustainability Design",
                    evidenceQuote: "sustainable impact requires distributing responsibility, not centralizing it",
                    confidenceLevel: .introduced, verificationStatus: .verified,
                    verifiedByUserId: ids.selin, verifiedByClubId: ids.fsmvuSosyal,
                    verifiedAt: cal.date(byAdding: .month, value: -5, to: .now)),
            ]
        )

        let activity3 = ClubActivity(
            clubId: ids.altToplum,
            hostUniversityId: ids.altinbas,
            role: "Campaign Lead",
            hours: 24,
            date: cal.date(byAdding: .month, value: -2, to: .now)!,
            reflections: [
                "I led a campus-wide zero-waste campaign through Altınbaş's community services club, targeting the three canteens and two cafeterias. The administration initially refused to meet us, so I mapped out every stakeholder — from the canteen operators to the dean's sustainability advisor — and found a back channel through the student council budget committee.",
                "We had 72 hours to prepare for a surprise inspection by the municipality's environment office. I coordinated 14 volunteers across three shifts to audit waste bins, photograph violations, and compile a report. Two volunteers dropped out the night before, and I had to redistribute their zones at 6 AM.",
                "The campaign reduced single-use plastic in the main canteen by 40% in one month. But the real win was getting the canteen operator to voluntarily switch to paper straws — that only happened because I spent three weeks building trust with him over tea, not because of any policy we wrote."
            ],
            extractedSkills: [
                ExtractedSkill(name: "Stakeholder Mapping Under Institutional Resistance",
                    evidenceQuote: "I mapped out every stakeholder — from the canteen operators to the dean's sustainability advisor — and found a back channel through the student council budget committee",
                    confidenceLevel: .proficient, verificationStatus: .verified,
                    verifiedByUserId: ids.deniz, verifiedByClubId: ids.altToplum,
                    verifiedAt: cal.date(byAdding: .month, value: -1, to: .now)),
                ExtractedSkill(name: "Crisis Resource Mobilization",
                    evidenceQuote: "Two volunteers dropped out the night before, and I had to redistribute their zones at 6 AM",
                    confidenceLevel: .practiced, verificationStatus: .verified,
                    verifiedByUserId: ids.deniz, verifiedByClubId: ids.altToplum,
                    verifiedAt: cal.date(byAdding: .month, value: -1, to: .now)),
                ExtractedSkill(name: "Trust-Based Vendor Negotiation",
                    evidenceQuote: "I spent three weeks building trust with him over tea, not because of any policy we wrote",
                    confidenceLevel: .proficient, verificationStatus: .verified,
                    verifiedByUserId: ids.deniz, verifiedByClubId: ids.altToplum,
                    verifiedAt: cal.date(byAdding: .month, value: -1, to: .now)),
                ExtractedSkill(name: "Rapid Multi-Shift Volunteer Coordination",
                    evidenceQuote: "I coordinated 14 volunteers across three shifts to audit waste bins, photograph violations, and compile a report",
                    confidenceLevel: .practiced, verificationStatus: .verified,
                    verifiedByUserId: ids.deniz, verifiedByClubId: ids.altToplum,
                    verifiedAt: cal.date(byAdding: .month, value: -1, to: .now)),
                ExtractedSkill(name: "Environmental Impact Measurement",
                    evidenceQuote: "The campaign reduced single-use plastic in the main canteen by 40% in one month",
                    confidenceLevel: .introduced, verificationStatus: .verified,
                    verifiedByUserId: ids.deniz, verifiedByClubId: ids.altToplum,
                    verifiedAt: cal.date(byAdding: .month, value: -1, to: .now)),
            ]
        )

        return [activity1, activity2, activity3]
    }
}
