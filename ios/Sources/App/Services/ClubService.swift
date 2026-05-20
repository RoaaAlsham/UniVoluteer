import Foundation

enum ClubService {
    // MARK: - Fixed UUIDs

    enum IDs {
        // Universities
        static let bogazici = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
        static let fsmvu = UUID(uuidString: "00000000-0000-0000-0000-000000000002")!
        static let altinbas = UUID(uuidString: "00000000-0000-0000-0000-000000000003")!

        // Boğaziçi Clubs
        static let aiesec = UUID(uuidString: "00000000-0000-0000-0001-000000000001")!
        static let tegv = UUID(uuidString: "00000000-0000-0000-0001-000000000002")!
        static let cevre = UUID(uuidString: "00000000-0000-0000-0001-000000000003")!
        static let tiyatro = UUID(uuidString: "00000000-0000-0000-0001-000000000004")!

        // FSMVÜ Clubs
        static let fsmvuGonullu = UUID(uuidString: "00000000-0000-0000-0001-000000000005")!
        static let fsmvuSosyal = UUID(uuidString: "00000000-0000-0000-0001-000000000006")!
        static let fsmvuYazilim = UUID(uuidString: "00000000-0000-0000-0001-000000000007")!
        static let fsmvuHayat = UUID(uuidString: "00000000-0000-0000-0001-000000000008")!

        // Altınbaş Clubs
        static let altToplum = UUID(uuidString: "00000000-0000-0000-0001-000000000009")!
        static let altGirisim = UUID(uuidString: "00000000-0000-0000-0001-00000000000A")!
        static let altMentor = UUID(uuidString: "00000000-0000-0000-0001-00000000000B")!

        // Boğaziçi Users
        static let ayse = UUID(uuidString: "00000000-0000-0000-0002-000000000001")!
        static let mehmet = UUID(uuidString: "00000000-0000-0000-0002-000000000002")!
        static let zeynep = UUID(uuidString: "00000000-0000-0000-0002-000000000003")!
        static let can = UUID(uuidString: "00000000-0000-0000-0002-000000000004")!

        // FSMVÜ Users
        static let emre = UUID(uuidString: "00000000-0000-0000-0002-000000000005")!
        static let selin = UUID(uuidString: "00000000-0000-0000-0002-000000000006")!
        static let burak = UUID(uuidString: "00000000-0000-0000-0002-000000000007")!

        // Altınbaş Users
        static let deniz = UUID(uuidString: "00000000-0000-0000-0002-000000000008")!
        static let ece = UUID(uuidString: "00000000-0000-0000-0002-000000000009")!
    }

    // MARK: - Universities

    static let universities: [University] = [
        University(id: IDs.bogazici, name: "Boğaziçi University", shortName: "Boğaziçi",
                   adminContactEmail: "studentaffairs@boun.edu.tr"),
        University(id: IDs.fsmvu, name: "Fatih Sultan Mehmet Vakıf University", shortName: "FSMVÜ",
                   adminContactEmail: "ogrenciisleri@fsm.edu.tr"),
        University(id: IDs.altinbas, name: "Altınbaş University", shortName: "Altınbaş",
                   adminContactEmail: "ogrencidekanligi@altinbas.edu.tr"),
    ]

    // MARK: - Clubs

    static let clubs: [Club] = [
        // Boğaziçi
        Club(id: IDs.aiesec, name: "AIESEC Boğaziçi", universityId: IDs.bogazici,
             authorizedSupervisorIds: [IDs.mehmet], isRecognized: true),
        Club(id: IDs.tegv, name: "TEGV Volunteers — Boğaziçi", universityId: IDs.bogazici,
             authorizedSupervisorIds: [IDs.zeynep], isRecognized: true),
        Club(id: IDs.cevre, name: "Çevre Kulübü — Boğaziçi", universityId: IDs.bogazici,
             authorizedSupervisorIds: [IDs.zeynep], isRecognized: true),
        Club(id: IDs.tiyatro, name: "Boğaziçi Tiyatro Kulübü", universityId: IDs.bogazici,
             authorizedSupervisorIds: [IDs.can], isRecognized: true),
        // FSMVÜ
        Club(id: IDs.fsmvuGonullu, name: "FSMVÜ Gönüllü Topluluğu", universityId: IDs.fsmvu,
             authorizedSupervisorIds: [IDs.emre], isRecognized: true),
        Club(id: IDs.fsmvuSosyal, name: "FSMVÜ Sosyal Sorumluluk Kulübü", universityId: IDs.fsmvu,
             authorizedSupervisorIds: [IDs.selin], isRecognized: true),
        Club(id: IDs.fsmvuYazilim, name: "FSMVÜ Yazılım Kulübü", universityId: IDs.fsmvu,
             authorizedSupervisorIds: [IDs.burak], isRecognized: true),
        Club(id: IDs.fsmvuHayat, name: "Hayat Boyu Öğrenme Topluluğu", universityId: IDs.fsmvu,
             authorizedSupervisorIds: [IDs.emre], isRecognized: true),
        // Altınbaş
        Club(id: IDs.altToplum, name: "Altınbaş Toplum Hizmetleri Kulübü", universityId: IDs.altinbas,
             authorizedSupervisorIds: [IDs.deniz], isRecognized: true),
        Club(id: IDs.altGirisim, name: "Altınbaş Girişimcilik Kulübü", universityId: IDs.altinbas,
             authorizedSupervisorIds: [IDs.ece], isRecognized: true),
        Club(id: IDs.altMentor, name: "Altınbaş Mentörlük Programı", universityId: IDs.altinbas,
             authorizedSupervisorIds: [IDs.deniz], isRecognized: true),
    ]

    // MARK: - Users

    static let users: [User] = [
        // Volunteer
        User(id: IDs.ayse, fullName: "Ayşe Kaya", email: "ayse.kaya@boun.edu.tr",
             universityId: IDs.bogazici, role: .volunteer, authorizedClubIds: [],
             studentId: "2021400123", program: "Computer Engineering"),
        // Boğaziçi Supervisors
        User(id: IDs.mehmet, fullName: "Mehmet Yıldız", email: "mehmet.yildiz@boun.edu.tr",
             universityId: IDs.bogazici, role: .supervisor, authorizedClubIds: [IDs.aiesec],
             studentId: nil, program: nil),
        User(id: IDs.zeynep, fullName: "Zeynep Demir", email: "zeynep.demir@boun.edu.tr",
             universityId: IDs.bogazici, role: .supervisor, authorizedClubIds: [IDs.tegv, IDs.cevre],
             studentId: nil, program: nil),
        User(id: IDs.can, fullName: "Can Öztürk", email: "can.ozturk@boun.edu.tr",
             universityId: IDs.bogazici, role: .supervisor, authorizedClubIds: [IDs.tiyatro],
             studentId: nil, program: nil),
        // FSMVÜ Supervisors
        User(id: IDs.emre, fullName: "Emre Aydın", email: "emre.aydin@fsm.edu.tr",
             universityId: IDs.fsmvu, role: .supervisor, authorizedClubIds: [IDs.fsmvuGonullu, IDs.fsmvuHayat],
             studentId: nil, program: nil),
        User(id: IDs.selin, fullName: "Selin Kara", email: "selin.kara@fsm.edu.tr",
             universityId: IDs.fsmvu, role: .supervisor, authorizedClubIds: [IDs.fsmvuSosyal],
             studentId: nil, program: nil),
        User(id: IDs.burak, fullName: "Burak Şen", email: "burak.sen@fsm.edu.tr",
             universityId: IDs.fsmvu, role: .supervisor, authorizedClubIds: [IDs.fsmvuYazilim],
             studentId: nil, program: nil),
        // Altınbaş Supervisors
        User(id: IDs.deniz, fullName: "Deniz Arslan", email: "deniz.arslan@altinbas.edu.tr",
             universityId: IDs.altinbas, role: .supervisor, authorizedClubIds: [IDs.altToplum, IDs.altMentor],
             studentId: nil, program: nil),
        User(id: IDs.ece, fullName: "Ece Yalçın", email: "ece.yalcin@altinbas.edu.tr",
             universityId: IDs.altinbas, role: .supervisor, authorizedClubIds: [IDs.altGirisim],
             studentId: nil, program: nil),
    ]

    // MARK: - Lookups

    static func club(for id: UUID) -> Club? {
        clubs.first { $0.id == id }
    }

    static func university(for id: UUID) -> University? {
        universities.first { $0.id == id }
    }

    static func user(for id: UUID) -> User? {
        users.first { $0.id == id }
    }

    static func clubs(for universityId: UUID) -> [Club] {
        clubs.filter { $0.universityId == universityId }
    }

    static func supervisors(for clubId: UUID) -> [User] {
        guard let club = club(for: clubId) else { return [] }
        return club.authorizedSupervisorIds.compactMap { user(for: $0) }
    }

    static func supervisorUsers() -> [User] {
        users.filter { $0.role == .supervisor }
    }

    static func canVerify(supervisorId: UUID, clubId: UUID) -> Bool {
        guard let club = club(for: clubId) else { return false }
        return club.authorizedSupervisorIds.contains(supervisorId)
    }

    static func universityForClub(_ clubId: UUID) -> University? {
        guard let club = club(for: clubId) else { return nil }
        return university(for: club.universityId)
    }
}
