//
//  Extensions.swift
//  BaseChat
//
//  Created by Caner Kaya on 07.01.21.
//

import Foundation
import UIKit

extension UIView
{
    public var width: CGFloat {
        return self.frame.size.width
    }
    
    public var height: CGFloat {
        return self.frame.size.height
    }
    
    public var top: CGFloat {
        return self.frame.origin.y
    }
    
    public var bottom: CGFloat {
        return self.frame.size.height + self.frame.origin.y
    }
    
    public var left: CGFloat {
        return self.frame.origin.x
    }
    
    public var right: CGFloat {
        return self.frame.size.width + self.frame.origin.x
    }
}

extension Notification.Name
{
    static let didLogInNotification = Notification.Name("didLogInNotification")
}

extension UIImage
{
    public func Rotate(radians: Float) -> UIImage?
    {
        var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size
        
        //Trim off the extremely small float value to prevent core graphics from rounding
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        let context = UIGraphicsGetCurrentContext()
        
        //Move origin to center
        context?.translateBy(x: newSize.width/2, y: newSize.height/2)
        //Rotate around middle
        context?.rotate(by: CGFloat(radians))
        //Draw the image at its center
        self.draw(in: CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
