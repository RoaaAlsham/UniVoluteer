import Foundation

enum MockSkillProvider {
    static func skills(clubName: String, role: String, reflections: [String]) -> [ExtractedSkill] {
        let combined = reflections.joined(separator: " ").lowercased()
        let sentences = extractSentences(from: reflections)

        var scored: [(template: SkillTemplate, score: Int)] = templates.compactMap { t in
            let score = t.triggerKeywords.filter { combined.contains($0) }.count
            return score > 0 ? (t, score) : nil
        }

        scored.sort { lhs, rhs in
            if lhs.score != rhs.score { return lhs.score > rhs.score }
            return lhs.template.confidenceLevel.sortOrder > rhs.template.confidenceLevel.sortOrder
        }

        var selected = scored.prefix(pickCount()).map(\.template)

        while selected.count < 4 {
            for fallback in fallbackTemplates where !selected.contains(where: { $0.name == fallback.name }) {
                selected.append(fallback)
                if selected.count >= 4 { break }
            }
            if selected.count < 4 { break }
        }

        var usedQuotes = Set<String>()
        return selected.map { template in
            let quote = pickQuote(for: template, sentences: sentences, used: &usedQuotes, clubName: clubName, role: role)
            return ExtractedSkill(
                name: template.name,
                evidenceQuote: quote,
                confidenceLevel: template.confidenceLevel
            )
        }
    }

    // MARK: - Quote Selection

    private static func pickQuote(for template: SkillTemplate, sentences: [String], used: inout Set<String>, clubName: String, role: String) -> String {
        let triggers = template.triggerKeywords
        let best = sentences
            .filter { !used.contains($0) }
            .map { s -> (String, Int) in
                let lower = s.lowercased()
                let score = triggers.filter { lower.contains($0) }.count
                return (s, score)
            }
            .sorted { $0.1 > $1.1 }
            .first { $0.1 > 0 }?.0

        if let found = best {
            used.insert(found)
            return String(found.prefix(140)) + (found.count > 140 ? "..." : "")
        }

        let unused = sentences.filter { !used.contains($0) && $0.count > 30 }
        if let fallback = unused.first {
            used.insert(fallback)
            return String(fallback.prefix(140)) + (fallback.count > 140 ? "..." : "")
        }

        return "Demonstrated through \(role) responsibilities at \(clubName)"
    }

    private static func extractSentences(from reflections: [String]) -> [String] {
        reflections.flatMap { text in
            text.components(separatedBy: CharacterSet(charactersIn: ".!?"))
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { $0.count > 20 }
        }
    }

    private static func pickCount() -> Int {
        let roll = Int.random(in: 1...10)
        if roll <= 2 { return 4 }
        if roll <= 7 { return 5 }
        return 6
    }

    // MARK: - Templates

    private struct SkillTemplate {
        let name: String
        let confidenceLevel: ConfidenceLevel
        let triggerKeywords: [String]
    }

    private static let fallbackTemplates: [SkillTemplate] = [
        SkillTemplate(name: "Outcome-Based Reflection", confidenceLevel: .introduced,
                      triggerKeywords: ["learn", "ders", "improve", "geliştir"]),
        SkillTemplate(name: "Operational Resilience", confidenceLevel: .practiced,
                      triggerKeywords: ["backup", "yedek", "alternative", "alternatif"]),
        SkillTemplate(name: "Stakeholder Communication", confidenceLevel: .practiced,
                      triggerKeywords: ["communicat", "iletişim", "report", "rapor"]),
        SkillTemplate(name: "Team Leadership Without Authority", confidenceLevel: .practiced,
                      triggerKeywords: ["lead", "lider", "team", "ekip"]),
    ]

    private static let templates: [SkillTemplate] = [
        SkillTemplate(name: "Crisis Vendor Negotiation", confidenceLevel: .proficient,
                      triggerKeywords: ["sponsor", "vendor", "cancel", "iptal", "bütçe", "budget", "negotia", "müzakere", "deal", "anlaş"]),
        SkillTemplate(name: "Real-Time Process Redesign", confidenceLevel: .practiced,
                      triggerKeywords: ["crash", "fail", "broke", "improvise", "doğaçlama", "plan değiş", "alternative", "yedek", "pivot"]),
        SkillTemplate(name: "Bilingual Workshop Facilitation", confidenceLevel: .practiced,
                      triggerKeywords: ["workshop", "atölye", "facilitat", "bilingual", "iki dil", "english", "ingilizce", "translate", "çeviri"]),
        SkillTemplate(name: "Cross-Generational Mentorship", confidenceLevel: .proficient,
                      triggerKeywords: ["mentor", "mentörlük", "teach", "öğret", "younger", "kid", "child", "öğrenci", "lise", "ortaokul"]),
        SkillTemplate(name: "Volunteer Recruitment and Retention", confidenceLevel: .practiced,
                      triggerKeywords: ["volunteer", "gönüllü", "recruit", "team", "ekip", "join", "katıl", "people", "kişi"]),
        SkillTemplate(name: "Event Logistics Coordination", confidenceLevel: .proficient,
                      triggerKeywords: ["event", "etkinlik", "venue", "mekan", "schedule", "program", "logistic", "organizasyon"]),
        SkillTemplate(name: "Conflict Resolution Under Pressure", confidenceLevel: .practiced,
                      triggerKeywords: ["argument", "tartışma", "conflict", "anlaşmaz", "disagree", "fight", "kavga", "tense", "gergin"]),
        SkillTemplate(name: "Public Speaking to Mixed Audiences", confidenceLevel: .practiced,
                      triggerKeywords: ["speak", "konuşma", "present", "sunum", "audience", "izleyici", "stage", "sahne"]),
        SkillTemplate(name: "Social Media Campaign Strategy", confidenceLevel: .proficient,
                      triggerKeywords: ["instagram", "social media", "sosyal medya", "post", "follower", "takipçi", "reach", "engagement", "kampanya"]),
        SkillTemplate(name: "Budget Stewardship", confidenceLevel: .practiced,
                      triggerKeywords: ["budget", "bütçe", "cost", "maliyet", "money", "para", "spend", "harca", "expense", "gider"]),
        SkillTemplate(name: "Stakeholder Communication", confidenceLevel: .practiced,
                      triggerKeywords: ["communicat", "iletişim", "stakeholder", "paydaş", "email", "mail", "report", "rapor", "update", "bilgi"]),
        SkillTemplate(name: "Data-Driven Decision Making", confidenceLevel: .introduced,
                      triggerKeywords: ["data", "veri", "analysis", "analiz", "track", "ölç", "measure", "metric", "number", "sayı", "%", "percent"]),
        SkillTemplate(name: "Cross-Cultural Communication", confidenceLevel: .proficient,
                      triggerKeywords: ["refugee", "mülteci", "international", "uluslararası", "language barrier", "foreign", "yabancı", "culture", "kültür"]),
        SkillTemplate(name: "Time-Critical Problem Solving", confidenceLevel: .practiced,
                      triggerKeywords: ["deadline", "son tarih", "hour", "saat", "rush", "acele", "last minute", "son dakika", "urgent", "acil", "72 hour"]),
        SkillTemplate(name: "Team Leadership Without Authority", confidenceLevel: .practiced,
                      triggerKeywords: ["lead", "lider", "team", "ekip", "coordinate", "koordin", "delegate", "görev", "manage", "yönet"]),
        SkillTemplate(name: "Empathetic Active Listening", confidenceLevel: .introduced,
                      triggerKeywords: ["listen", "dinle", "empath", "empati", "support", "destek", "feeling", "story", "hikaye"]),
        SkillTemplate(name: "Rapid Skill Acquisition", confidenceLevel: .introduced,
                      triggerKeywords: ["learn", "öğren", "new", "yeni", "first time", "ilk kez", "figure out", "çöz", "research", "araştır"]),
        SkillTemplate(name: "Stakeholder Mapping", confidenceLevel: .practiced,
                      triggerKeywords: ["partner", "ortak", "sponsor", "network", "ağ", "connection", "bağlantı", "stakeholder"]),
        SkillTemplate(name: "Crisis Communication", confidenceLevel: .practiced,
                      triggerKeywords: ["announce", "duyur", "crisis", "kriz", "explain", "açıkla", "calm", "sakin", "reassure"]),
        SkillTemplate(name: "Inclusive Event Design", confidenceLevel: .introduced,
                      triggerKeywords: ["accessib", "erişile", "disabilit", "engelli", "inclusiv", "kapsayıcı", "diverse", "çeşit"]),
        SkillTemplate(name: "Operational Resilience", confidenceLevel: .practiced,
                      triggerKeywords: ["backup", "yedek", "contingen", "plan b", "alternative", "alternatif", "fail-safe", "dropped out"]),
        SkillTemplate(name: "Outcome-Based Reflection", confidenceLevel: .introduced,
                      triggerKeywords: ["learn", "ders", "next time", "gelecek sefer", "improve", "geliştir", "better", "daha iyi", "different", "farklı"]),
    ]
}

private extension ConfidenceLevel {
    var sortOrder: Int {
        switch self {
        case .proficient: 3
        case .practiced: 2
        case .introduced: 1
        }
    }
}
