//
//  Media.swift
//  BaseChat
//
//  Created by Caner Kaya on 13.01.21.
//

import Foundation
import MessageKit

struct Media: MediaItem
{
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
}
