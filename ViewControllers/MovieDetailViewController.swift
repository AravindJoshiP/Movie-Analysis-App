import UIKit

final class MovieDetailViewController: UIViewController {
    var movie: Movie!

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let posterImageView = UIImageView()
    private let titleLabel = UILabel()
    private let infoLabel = UILabel()
    private let overviewLabel = UILabel()
    private let favoriteButton = UIButton(type: .system)
    private let similarButton = UIButton(type: .system)
    private let castButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateFavoriteButton()
    }

    private func setupUI() {
        view.backgroundColor = .black
        title = "Movie Details"

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.alignment = .fill
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        posterImageView.contentMode = .scaleAspectFill
        posterImageView.clipsToBounds = true
        posterImageView.layer.cornerRadius = 12
        posterImageView.tintColor = .secondaryLabel
        posterImageView.heightAnchor.constraint(equalToConstant: 420).isActive = true

        titleLabel.font = .systemFont(ofSize: 26, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center

        infoLabel.font = .systemFont(ofSize: 15, weight: .medium)
        infoLabel.textColor = .lightGray
        infoLabel.textAlignment = .center
        infoLabel.numberOfLines = 0

        overviewLabel.font = .systemFont(ofSize: 16, weight: .regular)
        overviewLabel.textColor = .white
        overviewLabel.numberOfLines = 0

        configureButton(favoriteButton, title: "Add to Favorites", systemImage: "heart")
        configureButton(similarButton, title: "Show Similar Movies", systemImage: "rectangle.stack")
        configureButton(castButton, title: "View Cast", systemImage: "person.3")

        favoriteButton.addTarget(self, action: #selector(favoriteTapped), for: .touchUpInside)
        similarButton.addTarget(self, action: #selector(similarTapped), for: .touchUpInside)
        castButton.addTarget(self, action: #selector(castTapped), for: .touchUpInside)

        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)

        [posterImageView, titleLabel, infoLabel, overviewLabel, favoriteButton, similarButton, castButton].forEach {
            contentStack.addArrangedSubview($0)
        }

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 20),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24)
        ])
    }

    private func configureButton(_ button: UIButton, title: String, systemImage: String) {
        var config = UIButton.Configuration.filled()
        config.title = title
        config.image = UIImage(systemName: systemImage)
        config.imagePadding = 8
        config.cornerStyle = .large
        button.configuration = config
        button.heightAnchor.constraint(equalToConstant: 48).isActive = true
    }

    private func configureData() {
        titleLabel.text = movie.displayTitle
        overviewLabel.text = movie.overview?.isEmpty == false ? movie.overview : "No overview available."
        let rating = String(format: "%.1f", movie.voteAverage ?? 0)
        infoLabel.text = "Release: \(movie.releaseDate ?? "Unknown")  •  Rating: \(rating)/10"

        Task { [weak self] in
            let image = await ImageLoader.shared.loadImage(from: self?.movie.posterURL)
            await MainActor.run { self?.posterImageView.image = image }
        }
    }

    private func updateFavoriteButton() {
        let isFavorite = CoreDataManager.shared.isFavorite(movieID: movie.id)
        favoriteButton.configuration?.title = isFavorite ? "Remove from Favorites" : "Add to Favorites"
        favoriteButton.configuration?.image = UIImage(systemName: isFavorite ? "heart.fill" : "heart")
    }

    @objc private func favoriteTapped() {
        if CoreDataManager.shared.isFavorite(movieID: movie.id) {
            CoreDataManager.shared.removeMovie(movieID: movie.id)
        } else {
            CoreDataManager.shared.saveMovie(movie)
        }
        updateFavoriteButton()
    }

    @objc private func similarTapped() {
        let vc = MoviesGridViewController()
        vc.mode = .recommendations(movie: movie)
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func castTapped() {
        let vc = CastViewController()
        vc.movie = movie
        navigationController?.pushViewController(vc, animated: true)
    }
}
