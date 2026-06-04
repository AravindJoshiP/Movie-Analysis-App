import Foundation
import CoreData

final class CoreDataManager {
    static let shared = CoreDataManager()

    let persistentContainer: NSPersistentContainer

    private init() {
        let model = NSManagedObjectModel()

        let entity = NSEntityDescription()
        entity.name = "FavoriteMovie"
        entity.managedObjectClassName = NSStringFromClass(FavoriteMovie.self)

        let id = NSAttributeDescription()
        id.name = "id"
        id.attributeType = .integer64AttributeType
        id.isOptional = false

        let title = NSAttributeDescription()
        title.name = "title"
        title.attributeType = .stringAttributeType
        title.isOptional = true

        let overview = NSAttributeDescription()
        overview.name = "overviewText"
        overview.attributeType = .stringAttributeType
        overview.isOptional = true

        let posterPath = NSAttributeDescription()
        posterPath.name = "posterPath"
        posterPath.attributeType = .stringAttributeType
        posterPath.isOptional = true

        let releaseDate = NSAttributeDescription()
        releaseDate.name = "releaseDate"
        releaseDate.attributeType = .stringAttributeType
        releaseDate.isOptional = true

        let voteAverage = NSAttributeDescription()
        voteAverage.name = "voteAverage"
        voteAverage.attributeType = .doubleAttributeType
        voteAverage.isOptional = true

        entity.properties = [id, title, overview, posterPath, releaseDate, voteAverage]
        model.entities = [entity]

        persistentContainer = NSPersistentContainer(name: "MovieBrowserModel", managedObjectModel: model)
        persistentContainer.loadPersistentStores { _, error in
            if let error { print("Core Data error: \(error.localizedDescription)") }
        }
    }

    var context: NSManagedObjectContext { persistentContainer.viewContext }

    func saveMovie(_ movie: Movie) {
        if isFavorite(movieID: movie.id) { return }
        let favorite = FavoriteMovie(context: context)
        favorite.id = Int64(movie.id)
        favorite.title = movie.displayTitle
        favorite.overviewText = movie.overview
        favorite.posterPath = movie.posterPath
        favorite.releaseDate = movie.releaseDate
        favorite.voteAverage = movie.voteAverage ?? 0
        saveContext()
    }

    func removeMovie(movieID: Int) {
        let request = FavoriteMovie.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", movieID)
        if let results = try? context.fetch(request) {
            results.forEach { context.delete($0) }
            saveContext()
        }
    }

    func isFavorite(movieID: Int) -> Bool {
        let request = FavoriteMovie.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", movieID)
        request.fetchLimit = 1
        return ((try? context.count(for: request)) ?? 0) > 0
    }

    func fetchFavorites() -> [Movie] {
        let request = FavoriteMovie.fetchRequest()
        let favorites = (try? context.fetch(request)) ?? []
        return favorites.map {
            Movie(
                id: Int($0.id),
                title: $0.title,
                originalTitle: $0.title,
                overview: $0.overviewText,
                posterPath: $0.posterPath,
                backdropPath: nil,
                releaseDate: $0.releaseDate,
                voteAverage: $0.voteAverage
            )
        }
    }

    private func saveContext() {
        if context.hasChanges {
            do { try context.save() }
            catch { print("Save error: \(error.localizedDescription)") }
        }
    }
}

@objc(FavoriteMovie)
final class FavoriteMovie: NSManagedObject {
    @NSManaged var id: Int64
    @NSManaged var title: String?
    @NSManaged var overviewText: String?
    @NSManaged var posterPath: String?
    @NSManaged var releaseDate: String?
    @NSManaged var voteAverage: Double

    @nonobjc class func fetchRequest() -> NSFetchRequest<FavoriteMovie> {
        NSFetchRequest<FavoriteMovie>(entityName: "FavoriteMovie")
    }
}
