//
//  HomeViewController.swift
//  animeal
//
//  Created by Ihar Tsimafeichyk on 30/05/2022.
//

import UIKit

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

        title.text = "Animeal"
        title.textColor = Asset.Colors.tiffany.color
    }
}
