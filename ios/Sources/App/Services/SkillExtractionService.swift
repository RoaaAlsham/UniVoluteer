import Foundation

enum SkillExtractionService {
    private struct APIResponse: Decodable {
        struct Content: Decodable { let text: String }
        let content: [Content]
    }

    private struct SkillsPayload: Decodable {
        struct RawSkill: Decodable {
            let name: String
            let evidenceQuote: String
            let confidenceLevel: String
        }
        let skills: [RawSkill]
    }

    static func extract(
        clubName: String,
        role: String,
        hours: Int,
        date: Date,
        reflections: [String]
    ) async -> [ExtractedSkill] {
        let startTime = ContinuousClock.now

        if Config.useCachedDemoResponse {
            print("🎭 [SkillExtraction] Demo mode forced via Config flag")
            await enforceMinimumDelay(from: startTime)
            return MockSkillProvider.skills(clubName: clubName, role: role, reflections: reflections)
        }

        guard !Config.anthropicAPIKey.isEmpty, Config.anthropicAPIKey != "YOUR_API_KEY_HERE" else {
            print("⚠️ [SkillExtraction] API key missing — using mock fallback")
            await enforceMinimumDelay(from: startTime)
            return MockSkillProvider.skills(clubName: clubName, role: role, reflections: reflections)
        }

        do {
            let skills = try await withTimeout(seconds: Config.extractionTotalTimeout) {
                try await callAPI(clubName: clubName, role: role, hours: hours, date: date, reflections: reflections)
            }
            if skills.isEmpty {
                print("⚠️ [SkillExtraction] Empty skills returned — using mock fallback")
                await enforceMinimumDelay(from: startTime)
                return MockSkillProvider.skills(clubName: clubName, role: role, reflections: reflections)
            }
            print("✅ [SkillExtraction] Real API success — extracted \(skills.count) skills")
            await enforceMinimumDelay(from: startTime)
            return skills
        } catch {
            print("⚠️ [SkillExtraction] \(describeError(error)) — using mock fallback")
            await enforceMinimumDelay(from: startTime)
            return MockSkillProvider.skills(clubName: clubName, role: role, reflections: reflections)
        }
    }

    // MARK: - API Call

    private static func callAPI(
        clubName: String, role: String, hours: Int, date: Date, reflections: [String]
    ) async throws -> [ExtractedSkill] {
        let prompt = buildPrompt(clubName: clubName, role: role, hours: hours, date: date, reflections: reflections)

        let body: [String: Any] = [
            "model": Config.model,
            "max_tokens": Config.maxTokens,
            "messages": [["role": "user", "content": prompt]]
        ]

        var request = URLRequest(url: URL(string: "https://api.anthropic.com/v1/messages")!)
        request.httpMethod = "POST"
        request.setValue(Config.anthropicAPIKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        request.timeoutInterval = Config.extractionTotalTimeout
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard (200...299).contains(http.statusCode) else {
            let msg = String(data: data, encoding: .utf8) ?? "HTTP \(http.statusCode)"
            print("⚠️ [SkillExtraction] HTTP \(http.statusCode): \(msg.prefix(200))")
            throw URLError(.badServerResponse)
        }

        let apiResponse = try JSONDecoder().decode(APIResponse.self, from: data)

        guard let text = apiResponse.content.first?.text, !text.isEmpty else {
            throw URLError(.cannotParseResponse)
        }

        return try parseSkills(from: text)
    }

    // MARK: - Parsing

    private static func parseSkills(from text: String) throws -> [ExtractedSkill] {
        var cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleaned.hasPrefix("```") {
            cleaned = cleaned
                .replacingOccurrences(of: "```json", with: "")
                .replacingOccurrences(of: "```", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }

        guard let jsonData = cleaned.data(using: .utf8) else {
            throw URLError(.cannotDecodeContentData)
        }

        let payload = try JSONDecoder().decode(SkillsPayload.self, from: jsonData)

        return payload.skills.map { raw in
            ExtractedSkill(
                name: raw.name,
                evidenceQuote: raw.evidenceQuote,
                confidenceLevel: ConfidenceLevel(rawValue: raw.confidenceLevel) ?? .introduced
            )
        }
    }

    // MARK: - Prompt

    private static func buildPrompt(
        clubName: String, role: String, hours: Int, date: Date, reflections: [String]
    ) -> String {
        let dateStr = date.formatted(.dateTime.day().month(.wide).year())
        let r1 = reflections.indices.contains(0) ? reflections[0] : ""
        let r2 = reflections.indices.contains(1) ? reflections[1] : ""
        let r3 = reflections.indices.contains(2) ? reflections[2] : ""

        return """
        You are extracting verifiable life skills from a university student's \
        volunteer activity reflection. These skills will appear on their CV and \
        must be credible, specific, and evidence-backed.

        ACTIVITY:
        Club: \(clubName)
        Role: \(role)
        Hours: \(hours)
        Date: \(dateStr)

        REFLECTIONS:
        1. What they specifically did: \(r1)
        2. Hardest part and how they handled it: \(r2)
        3. What they'd do differently: \(r3)

        TASK:
        Extract 3 to 6 specific skills demonstrated in this reflection. Each skill must be:
        - Specific, not generic. "Crisis Vendor Negotiation" not "Communication". \
        "Bilingual Workshop Facilitation" not "Teaching".
        - Evidence-backed by a direct quote from the reflection.
        - Calibrated to hours and depth. A 4-hour activity does not produce \
        "Strategic Leadership". Be honest.
        - Cause-and-effect demonstrated, not just claimed.

        CONFIDENCE LEVELS:
        - "introduced": first exposure, basic competence
        - "practiced": done multiple times, comfortable
        - "proficient": deep skill, could teach others

        If the reflection is too vague to support any specific skills, return \
        fewer skills or an empty array. Do not inflate.

        OUTPUT FORMAT — return ONLY valid JSON, no preamble, no markdown fences:

        {
          "skills": [
            {
              "name": "string",
              "evidenceQuote": "exact substring from reflection",
              "confidenceLevel": "introduced" | "practiced" | "proficient"
            }
          ]
        }
        """
    }

    // MARK: - Helpers

    private static func enforceMinimumDelay(from start: ContinuousClock.Instant) async {
        let elapsed = ContinuousClock.now - start
        let minimum = Duration.seconds(Config.mockFallbackMinimumDelay)
        if elapsed < minimum {
            try? await Task.sleep(for: minimum - elapsed)
        }
    }

    private static func withTimeout<T: Sendable>(seconds: TimeInterval, operation: @escaping @Sendable () async throws -> T) async throws -> T {
        try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask { try await operation() }
            group.addTask {
                try await Task.sleep(for: .seconds(seconds))
                throw CancellationError()
            }
            guard let result = try await group.next() else {
                throw CancellationError()
            }
            group.cancelAll()
            return result
        }
    }

    private static func describeError(_ error: Error) -> String {
        if error is CancellationError { return "Timeout after \(Config.extractionTotalTimeout)s" }
        if let urlError = error as? URLError { return "Network: \(urlError.localizedDescription)" }
        return "Error: \(error.localizedDescription)"
    }
}
