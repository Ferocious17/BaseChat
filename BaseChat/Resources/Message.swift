//
//  Message.swift
//  BaseChat
//
//  Created by Caner Kaya on 09.01.21.
//

import Foundation
import MessageKit

struct Message: MessageType
{
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}
