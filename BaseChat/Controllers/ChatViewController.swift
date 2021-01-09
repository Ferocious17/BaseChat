//
//  ChatViewController.swift
//  BaseChat
//
//  Created by Caner Kaya on 09.01.21.
//

import UIKit
import MessageKit

class ChatViewController: MessagesViewController {

    private var messages = [Message]()
    private let selfSender = Sender(senderId: "1", displayName: "Max Miller", photoURL: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .purple
        
        messages.append(Message(sender: selfSender, messageId: "1", sentDate: Date(), kind: .text("LOL")))
        
        messages.append(Message(sender: selfSender, messageId: "2", sentDate: Date(), kind: .text("LOLOLOLOLOLOLOL")))
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
    }
}

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate
{
    func currentSender() -> SenderType
    {
        return selfSender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType
    {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    
}
