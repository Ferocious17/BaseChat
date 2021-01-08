//
//  BaseChatUser.swift
//  BaseChat
//
//  Created by Caner Kaya on 08.01.21.
//

import Foundation

struct BaseChatUser
{
    let firstname: String
    let lastname: String
    let emailAddress: String
    //let profilePictureURL: String
    
    var safeEmail: String {
        var email  = emailAddress.replacingOccurrences(of: ".", with: "-")
        email = email.replacingOccurrences(of: "@", with: "-")
        return email
    }
}
