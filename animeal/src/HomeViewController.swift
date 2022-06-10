//
//  HomeViewController.swift
//  animeal
//
//  Created by Ihar Tsimafeichyk on 30/05/2022.
//

import UIKit
import Style

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        let imageView = UIImageView(image: Asset.Images.animealLogo.image)
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        let title = UILabel()
        view.addSubview(title)
        title.translatesAutoresizingMaskIntoConstraints = false
        title.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        title.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 12).isActive = true
        title.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12).isActive = true
        title.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12).isActive = true

        title.text = L10n.AddPetScreen.Header.info
        title.numberOfLines = 3
        title.textAlignment = .center
        title.textColor = Asset.Colors.darkTurquoise.color
    }
}
