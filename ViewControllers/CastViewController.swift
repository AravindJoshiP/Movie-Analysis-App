import UIKit

final class CastViewController: UIViewController {
    var movie: Movie!
    private var cast: [CastMember] = []
    private let tableView = UITableView()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let messageLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadCast()
    }

    private func setupUI() {
        view.backgroundColor = .black
        title = "Movie Cast"

        tableView.backgroundColor = .black
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 76
        tableView.register(CastCell.self, forCellReuseIdentifier: CastCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        activityIndicator.color = .white
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false

        messageLabel.textColor = .lightGray
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.isHidden = true
        messageLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        view.addSubview(messageLabel)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            messageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            messageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    private func loadCast() {
        activityIndicator.startAnimating()
        Task {
            do {
                let fetchedCast = try await TMDBService.shared.fetchCast(movieID: movie.id)
                await MainActor.run {
                    self.cast = Array(fetchedCast.prefix(30))
                    self.tableView.reloadData()
                    self.activityIndicator.stopAnimating()
                    self.messageLabel.text = self.cast.isEmpty ? "No cast found." : nil
                    self.messageLabel.isHidden = !self.cast.isEmpty
                }
            } catch {
                await MainActor.run {
                    self.activityIndicator.stopAnimating()
                    self.messageLabel.text = "Unable to load cast."
                    self.messageLabel.isHidden = false
                }
            }
        }
    }
}

extension CastViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { cast.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CastCell.identifier, for: indexPath) as! CastCell
        cell.configure(with: cast[indexPath.row])
        return cell
    }
}
