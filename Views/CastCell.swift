import UIKit

final class CastCell: UITableViewCell {
    static let identifier = "CastCell"

    private let actorImageView = UIImageView()
    private let nameLabel = UILabel()
    private let characterLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    func configure(with member: CastMember) {
        nameLabel.text = member.displayName
        characterLabel.text = "as \(member.displayCharacter)"
        Task { [weak self] in
            let image = await ImageLoader.shared.loadImage(from: member.profileURL)
            await MainActor.run { self?.actorImageView.image = image }
        }
    }

    private func setupUI() {
        backgroundColor = .black
        selectionStyle = .none

        actorImageView.contentMode = .scaleAspectFill
        actorImageView.clipsToBounds = true
        actorImageView.layer.cornerRadius = 25
        actorImageView.tintColor = .secondaryLabel
        actorImageView.translatesAutoresizingMaskIntoConstraints = false

        nameLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        nameLabel.textColor = .white
        characterLabel.font = .systemFont(ofSize: 14, weight: .regular)
        characterLabel.textColor = .lightGray

        let stack = UIStackView(arrangedSubviews: [nameLabel, characterLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(actorImageView)
        contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            actorImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            actorImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            actorImageView.widthAnchor.constraint(equalToConstant: 50),
            actorImageView.heightAnchor.constraint(equalToConstant: 50),

            stack.leadingAnchor.constraint(equalTo: actorImageView.trailingAnchor, constant: 14),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}
