//
//  ConversationTableViewCell.swift
//  BaseChat
//
//  Created by Caner Kaya on 12.01.21.
//

import UIKit
import SDWebImage

class ConversationTableViewCell: UITableViewCell {
    
    static let identifier = "ConversationTableViewCell"

    private let userProfilePicture: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 21, weight: .semibold)
        return label
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .regular)
        //wrap lines
        label.numberOfLines = 0
        label.textColor = .lightGray
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(userProfilePicture)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(messageLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        userProfilePicture.frame = CGRect(x: 10,
                                          y: 10,
                                          width: contentView.height*0.78,
                                          height: contentView.height*0.78)
        
        userProfilePicture.layer.cornerRadius = userProfilePicture.height/2
        
        userNameLabel.frame = CGRect(x: userProfilePicture.right + 10,
                                     y: 10,
                                     width: contentView.width-20 - userProfilePicture.width,
                                     height: (contentView.height-20)/3)
        
        messageLabel.frame = CGRect(x: userProfilePicture.right + 10,
                                    y: userNameLabel.bottom + 5,
                                    width: contentView.width-20-userProfilePicture.width,
                                    height: (contentView.height-20)/2)
    }
    
    public func Configure(with model: Conversation)
    {
        self.messageLabel.text = model.latestMessage.text
        self.userNameLabel.text = model.name
     
        let path = "images/\(model.otherUserEmail)_profile_picture.png"
        StorageManager.shared.DownloadURL(for: path) { [weak self] (result) in
            switch result
            {
            case .success(let url):
                
                DispatchQueue.main.async
                {
                    self?.userProfilePicture.sd_setImage(with: url, completed: nil)
                }
                
            case .failure(let error):
                print("Failed to get profile picture URL: \(error)")
            }
        }
    }
}
