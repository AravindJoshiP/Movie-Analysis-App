import Foundation

struct CastResponse: Codable {
    let cast: [CastMember]
}

struct CastMember: Codable, Hashable {
    let id: Int
    let name: String?
    let character: String?
    let profilePath: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case character
        case profilePath = "profile_path"
    }

    var displayName: String { name ?? "Unknown Actor" }
    var displayCharacter: String { character ?? "Unknown Role" }

    var profileURL: URL? {
        guard let profilePath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w185\(profilePath)")
    }
}
