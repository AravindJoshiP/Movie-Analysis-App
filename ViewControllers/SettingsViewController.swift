import UIKit

final class SettingsViewController: UIViewController {
    private let stack = UIStackView()
    private let themeSwitch = UISwitch()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .black
        title = "Settings"
        tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gearshape"), tag: 4)

        stack.axis = .vertical
        stack.spacing = 18
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false

        let heading = UILabel()
        heading.text = "Movie Browser"
        heading.textColor = .white
        heading.font = .systemFont(ofSize: 28, weight: .bold)
        heading.textAlignment = .center

        let about = UILabel()
        about.text = "This app uses TMDB to browse popular movies, now playing movies, search titles, view cast details, discover similar movies, and save favorites locally."
        about.textColor = .lightGray
        about.font = .systemFont(ofSize: 16)
        about.numberOfLines = 0
        about.textAlignment = .center

        let themeRow = makeThemeRow()

        [heading, about, themeRow].forEach { stack.addArrangedSubview($0) }
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
    }

    private func makeThemeRow() -> UIView {
        let label = UILabel()
        label.text = "Light Theme"
        label.textColor = .white
        label.font = .systemFont(ofSize: 17, weight: .semibold)

        themeSwitch.addTarget(self, action: #selector(themeChanged), for: .valueChanged)

        let row = UIStackView(arrangedSubviews: [label, themeSwitch])
        row.axis = .horizontal
        row.alignment = .center
        row.distribution = .equalSpacing
        row.isLayoutMarginsRelativeArrangement = true
        row.layoutMargins = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        row.backgroundColor = UIColor(white: 0.12, alpha: 1)
        row.layer.cornerRadius = 12
        return row
    }

    @objc private func themeChanged() {
        let isLight = themeSwitch.isOn
        overrideUserInterfaceStyle = isLight ? .light : .dark
        tabBarController?.overrideUserInterfaceStyle = isLight ? .light : .dark
        navigationController?.overrideUserInterfaceStyle = isLight ? .light : .dark
    }
}
