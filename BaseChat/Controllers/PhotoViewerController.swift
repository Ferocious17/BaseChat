//
//  PhotoViewerController.swift
//  BaseChat
//
//  Created by Caner Kaya on 07.01.21.
//

import UIKit
import SDWebImage

class PhotoViewerController: UIViewController {
    
    private var url: URL
    
    private let imageView: UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    init(with url: URL)
    {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Media"
        navigationItem.largeTitleDisplayMode = .never
        //view.backgroundColor = UIColor(red: 49, green: 49, blue: 49, alpha: 0.5)
        view.backgroundColor = .systemBackground
        view.addSubview(imageView)
        self.imageView.sd_setImage(with: self.url, completed: nil)
    }
    
    override func viewDidLayoutSubviews() {
        imageView.frame = view.bounds
    }
}
