import UIKit

enum MovieListMode {
    case popular
    case nowPlaying
    case recommendations(movie: Movie)
}

final class MoviesGridViewController: UIViewController {
    var mode: MovieListMode = .popular

    private var movies: [Movie] = []
    private var collectionView: UICollectionView!
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let messageLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureModeFromTabIfNeeded()
        setupUI()
        loadMovies()
    }

    private func configureModeFromTabIfNeeded() {
        guard navigationController?.tabBarItem.title != nil else { return }
        if tabBarController?.selectedIndex == 1 {
            mode = .nowPlaying
        }
    }

    private func setupUI() {
        view.backgroundColor = .black

        switch mode {
        case .popular:
            title = "Popular Movies"
            tabBarItem = UITabBarItem(title: "Popular", image: UIImage(systemName: "film"), tag: 0)
        case .nowPlaying:
            title = "Now in Theatres"
            tabBarItem = UITabBarItem(title: "Theatres", image: UIImage(systemName: "ticket"), tag: 1)
        case .recommendations:
            title = "Similar Movies"
        }

        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 6
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .black
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(MovieCell.self, forCellWithReuseIdentifier: MovieCell.identifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        activityIndicator.color = .white
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false

        messageLabel.textColor = .lightGray
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.isHidden = true
        messageLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(collectionView)
        view.addSubview(activityIndicator)
        view.addSubview(messageLabel)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            messageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            messageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            messageLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func loadMovies() {
        activityIndicator.startAnimating()
        messageLabel.isHidden = true

        Task {
            do {
                let fetchedMovies: [Movie]
                switch mode {
                case .popular:
                    fetchedMovies = try await TMDBService.shared.fetchPopularMovies()
                case .nowPlaying:
                    fetchedMovies = try await TMDBService.shared.fetchNowPlayingMovies()
                case .recommendations(let movie):
                    fetchedMovies = try await TMDBService.shared.fetchSimilarMovies(movieID: movie.id)
                }

                await MainActor.run {
                    self.movies = fetchedMovies
                    self.collectionView.reloadData()
                    self.activityIndicator.stopAnimating()
                    self.messageLabel.isHidden = !fetchedMovies.isEmpty
                    self.messageLabel.text = fetchedMovies.isEmpty ? "No movies found." : nil
                }
            } catch {
                await MainActor.run {
                    self.activityIndicator.stopAnimating()
                    self.messageLabel.text = "Unable to load movies. Check your API key or internet connection."
                    self.messageLabel.isHidden = false
                }
            }
        }
    }
}

extension MoviesGridViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        movies.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCell.identifier, for: indexPath) as! MovieCell
        cell.configure(with: movies[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailVC = MovieDetailViewController()
        detailVC.movie = movies[indexPath.item]
        navigationController?.pushViewController(detailVC, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacing: CGFloat = 6
        let sideInsets: CGFloat = 16
        let availableWidth = collectionView.bounds.width - sideInsets - (spacing * 2)
        let width = floor(availableWidth / 3)
        return CGSize(width: width, height: width * 1.65)
    }
}
