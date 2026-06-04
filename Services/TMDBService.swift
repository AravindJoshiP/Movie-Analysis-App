import Foundation

enum TMDBError: Error {
    case invalidURL
    case missingAPIKey
    case invalidResponse
}

final class TMDBService {
    static let shared = TMDBService()
    private init() {}

    func fetchPopularMovies() async throws -> [Movie] {
        try await requestMovieList(path: "/movie/popular", queryItems: [])
    }

    func fetchNowPlayingMovies() async throws -> [Movie] {
        try await requestMovieList(path: "/movie/now_playing", queryItems: [])
    }

    func searchMovies(query: String) async throws -> [Movie] {
        try await requestMovieList(path: "/search/movie", queryItems: [URLQueryItem(name: "query", value: query)])
    }

    func fetchSimilarMovies(movieID: Int) async throws -> [Movie] {
        try await requestMovieList(path: "/movie/\(movieID)/similar", queryItems: [])
    }

    func fetchCast(movieID: Int) async throws -> [CastMember] {
        guard TMDBConfig.apiKey != "PUT_YOUR_TMDB_API_KEY_HERE" else { throw TMDBError.missingAPIKey }
        guard var components = URLComponents(string: TMDBConfig.baseURL + "/movie/\(movieID)/credits") else {
            throw TMDBError.invalidURL
        }
        components.queryItems = [URLQueryItem(name: "api_key", value: TMDBConfig.apiKey)]
        guard let url = components.url else { throw TMDBError.invalidURL }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, 200...299 ~= httpResponse.statusCode else {
            throw TMDBError.invalidResponse
        }
        return try JSONDecoder().decode(CastResponse.self, from: data).cast
    }

    private func requestMovieList(path: String, queryItems: [URLQueryItem]) async throws -> [Movie] {
        guard TMDBConfig.apiKey != "PUT_YOUR_TMDB_API_KEY_HERE" else { throw TMDBError.missingAPIKey }
        guard var components = URLComponents(string: TMDBConfig.baseURL + path) else {
            throw TMDBError.invalidURL
        }
        var items = [URLQueryItem(name: "api_key", value: TMDBConfig.apiKey)]
        items.append(contentsOf: queryItems)
        components.queryItems = items
        guard let url = components.url else { throw TMDBError.invalidURL }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, 200...299 ~= httpResponse.statusCode else {
            throw TMDBError.invalidResponse
        }
        return try JSONDecoder().decode(MovieResponse.self, from: data).results
    }
}
