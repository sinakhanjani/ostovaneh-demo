//
//  BadConnectionView.swift
//  Ostovaneh
//
//  Created by Sina khanjani on 8/30/1400 AP.
//

import UIKit

class BadConnectionView: UIView {
    
    let inboxImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "archivebox")!)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .clear
        imageView.tintColor = UIColor.label
        
        return imageView
    }()
    
    let coverView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .secondarySystemGroupedBackground
        view.cornerRadius = 18
        
        return view
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.font = UIFont.iranSans(.bold, size: 21)
        label.cornerRadius = 18
        label.numberOfLines = 1
        label.text = "عدم دسترسی به اینترنت"
        label.textAlignment = .center
        
        return label
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.font = UIFont.iranSans(.medium, size: 17)
        label.cornerRadius = 18
        label.numberOfLines = 3
        label.text = "لطفا از اتصال خود به اینترنت مطمئن شوید"
        label.textAlignment = .center
        
        return label
    }()
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 240, height: 240))
        backgroundColor = .clear
        
        addSubview(coverView)
        
        coverView.addSubview(inboxImageView)
        coverView.addSubview(titleLabel)
        coverView.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            // bgView constraint:
            coverView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0),
            coverView.leftAnchor.constraint(equalTo: leftAnchor, constant: 16),
            coverView.rightAnchor.constraint(equalTo: rightAnchor, constant: -16),
            coverView.heightAnchor.constraint(equalToConstant: 240),
            // inboxImageView constraint:
            inboxImageView.topAnchor.constraint(equalTo: coverView.topAnchor, constant: 32),
            inboxImageView.centerXAnchor.constraint(equalTo: coverView.centerXAnchor, constant: 0),
            inboxImageView.widthAnchor.constraint(equalToConstant: 54),
            inboxImageView.heightAnchor.constraint(equalToConstant: 54),
            // titleLabel constraint:
            titleLabel.leftAnchor.constraint(equalTo: coverView.leftAnchor, constant: 16),
            titleLabel.rightAnchor.constraint(equalTo: coverView.rightAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: inboxImageView.bottomAnchor, constant: 8),
            titleLabel.heightAnchor.constraint(equalToConstant: 32),
            // descriptionLabel constailet
            descriptionLabel.leftAnchor.constraint(equalTo: coverView.leftAnchor, constant: 16),
            descriptionLabel.rightAnchor.constraint(equalTo: coverView.rightAnchor, constant: -16),
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            descriptionLabel.heightAnchor.constraint(equalToConstant: 80),
        ])
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)

    }
}
