//
//  ConversationTableViewCell.swift
//  Messenger
//
//  Created by Dhruvin Vekariya on 2020-06-28.
//  Copyright © 2020 Neural Inc. All rights reserved.
//

import UIKit
import SDWebImage


class ConversationTableViewCell: UITableViewCell {
    
    static let identifier = "ConversationTableViewCell"
    
    
    private let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 50
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let userNameLabel: UILabel = {
       let newLabel = UILabel()
        newLabel.font = .systemFont(ofSize: 21,weight: .semibold)
        return newLabel
    }()
    
    
    private let userMessageLabel: UILabel = {
       let messageLabel = UILabel()
        messageLabel.font = .systemFont(ofSize: 17, weight: .regular)
        messageLabel.numberOfLines = 0
        return messageLabel
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(userImageView)
               contentView.addSubview(userNameLabel)
               contentView.addSubview(userMessageLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.backgroundColor = .systemGray6
        userImageView.frame = CGRect(x: 10, y: 10, width: 100, height: 100)
        userNameLabel.frame = CGRect(x: userImageView.right+10, y: 10, width: contentView.width - 20 - userImageView.width, height: (contentView.heigt-20)/2)
        userMessageLabel.frame = CGRect(x: userImageView.right+10, y: userNameLabel.bottom + 10, width: contentView.width - 20 - userImageView.width, height: (contentView.heigt-20)/2)
       
    }
    public func configure(with model: Conversation){
        
        self.userMessageLabel.text  = model.latestMessage.text
        self.userNameLabel.text = model.name
        let otherUserIdentifier = model.otherUserUID
        let path = "images/\(otherUserIdentifier)_profile_picture.png"
        StorageManager.shared.donwloadURL(for: path, completion: {[weak self] res in
            switch res {
            case .success(let url):
                DispatchQueue.main.async {
                     self?.userImageView.sd_setImage(with: url, completed: nil)
                }
            case .failure(let err):
                print("Failed to download image \(err)")
            }
            
        })
        
    }
    
}
