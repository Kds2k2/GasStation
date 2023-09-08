//
//  GasStationTableViewCell.swift
//  GasStationInfo
//
//  Created by Dmitro Kryzhanovsky on 07.09.2023.
//

import UIKit
import MapKit

class GasStationTableViewCell: UITableViewCell {
    
    static let identifier = "GasStationTableViewCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var model: GasStationViewModel? {
        didSet{
            configuration()
        }
    }
    
    private var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 10
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        return stackView
    }()
    
    private var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textAlignment = .left
        return label
    }()
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black.withAlphaComponent(0.9)
        label.font = UIFont.systemFont(ofSize: 12, weight: .light)
        label.numberOfLines = 2
        label.textAlignment = .left
        return label
    }()
    
    private var distanceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()
    
    private func setup() {
        contentView.backgroundColor = .white
        
        contentView.addSubview(distanceLabel)
        NSLayoutConstraint.activate([
            distanceLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            distanceLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
            distanceLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 15),
            distanceLabel.widthAnchor.constraint(equalToConstant: 60)
        ])
        
        contentView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
            stackView.leftAnchor.constraint(equalTo: distanceLabel.rightAnchor, constant: 0),
            stackView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: 0)
        ])
        
        stackView.addArrangedSubview(nameLabel)
        stackView.addArrangedSubview(titleLabel)
    }
    
    private func configuration() {
        if let model = model {
            nameLabel.text = model.gasStation.name ?? "No name"
            titleLabel.text = model.gasStation.placemark.title ?? "No title"
            distanceLabel.text = "\(model.distanceToUser!)\nKM"
        }
    }
}
