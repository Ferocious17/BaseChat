//
//  SearchResultCell.swift
//  BaseChat
//
//  Created by Caner Kaya on 14.01.21.
//

import UIKit
import SDWebImage

class SearchResultCell: UITableViewCell {
    
    static let identifier = "SearchResultCell"

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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(userProfilePicture)
        contentView.addSubview(userNameLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        userProfilePicture.frame = CGRect(x: 10,
                                          y: 7.5,
                                          width: contentView.height*0.8,
                                          height: contentView.height*0.8)
        
        userProfilePicture.layer.cornerRadius = userProfilePicture.height/2
        
        userNameLabel.frame = CGRect(x: userProfilePicture.right + 10,
                                     y: 10,
                                     width: contentView.width-20 - userProfilePicture.width,
                                     height: (contentView.height-20))
    }
    
    public func Configure(with model: SearchResult)
    {
        self.userNameLabel.text = model.name
     
        let path = "images/\(model.email)_profile_picture.png"
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
