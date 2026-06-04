import UIKit

final class ImageLoader {
    static let shared = ImageLoader()
    private let cache = NSCache<NSURL, UIImage>()
    private init() {}

    func loadImage(from url: URL?) async -> UIImage? {
        guard let url else { return UIImage(systemName: "film") }
        let nsURL = url as NSURL
        if let cached = cache.object(forKey: nsURL) { return cached }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let image = UIImage(data: data) else { return UIImage(systemName: "film") }
            cache.setObject(image, forKey: nsURL)
            return image
        } catch {
            return UIImage(systemName: "film")
        }
    }
}
