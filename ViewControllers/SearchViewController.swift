import UIKit

final class SearchViewController: UIViewController {
    private let searchController = UISearchController(searchResultsController: nil)
    private let tableView = UITableView()
    private var movies: [Movie] = []
    private let messageLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .black
        title = "Search"
        tabBarItem = UITabBarItem(title: "Search", image: UIImage(systemName: "magnifyingglass"), tag: 2)

        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search movies"
        navigationItem.searchController = searchController
        definesPresentationContext = true

        tableView.backgroundColor = .black
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SearchCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false

        messageLabel.text = "Search for a movie title."
        messageLabel.textColor = .lightGray
        messageLabel.textAlignment = .center
        messageLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(tableView)
        view.addSubview(messageLabel)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            messageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            messageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    private func performSearch(query: String) {
        guard query.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2 else {
            movies = []
            tableView.reloadData()
            messageLabel.text = "Search for a movie title."
            messageLabel.isHidden = false
            return
        }

        Task {
            do {
                let results = try await TMDBService.shared.searchMovies(query: query)
                await MainActor.run {
                    self.movies = results
                    self.tableView.reloadData()
                    self.messageLabel.text = results.isEmpty ? "No results found." : nil
                    self.messageLabel.isHidden = !results.isEmpty
                }
            } catch {
                await MainActor.run {
                    self.messageLabel.text = "Unable to search movies."
                    self.messageLabel.isHidden = false
                }
            }
        }
    }
}

extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        performSearch(query: searchController.searchBar.text ?? "")
    }
}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { movies.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath)
        let movie = movies[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = movie.displayTitle
        content.secondaryText = movie.releaseDate
        content.textProperties.color = .white
        content.secondaryTextProperties.color = .lightGray
        cell.contentConfiguration = content
        cell.backgroundColor = .black
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = MovieDetailViewController()
        vc.movie = movies[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
}
