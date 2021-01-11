//
//  ChatViewController.swift
//  BaseChat
//
//  Created by Caner Kaya on 09.01.21.
//

import UIKit
import MessageKit
import InputBarAccessoryView

class ChatViewController: MessagesViewController {

    public var isNewConversation = false
    public let otherUserEmail: String
    
    public static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.locale = .current
        return formatter
    }()
    
    private var messages = [Message]()
    private var selfSender: Sender? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else
        {
            return nil
        }
        
        return Sender(senderId: email,
                      displayName: "User name",
                      photoURL: "")
    }
    
    init(with email: String)
    {
        self.otherUserEmail = email
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //view.backgroundColor = .purple
        
        showMessageTimestampOnSwipeLeft = true
        
        messageInputBar.sendButton.image = UIImage(systemName: "paperplane.fill")?.Rotate(radians: .pi/4)
        
        /*messagesCollectionView.backgroundColor = .blue
        messagesCollectionView.tintColor = .red
        messages.append(Message(sender: selfSender as! SenderType, messageId: "1", sentDate: Date(), kind: .text("Lol")))
        */
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        //show the keyboard once view has appeared
        messageInputBar.inputTextView.becomeFirstResponder()
    }
}

extension ChatViewController: InputBarAccessoryViewDelegate
{
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String)
    {
        //Quick validation
        //doesn't allow user to send message with only spaces
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
              let selfSender = self.selfSender,
              let messageID = GenerateMessageID() else {
            return
        }
        
        print("Text to send: \(text)")
        
        //Send message
        if isNewConversation
        {
            //create new conversation in database
            let message = Message(sender: selfSender,
                                  messageId: messageID,
                                  sentDate: Date(),
                                  kind: .text(text))
            
            DatabaseManager.shared.CreateNewConversation(with: otherUserEmail, firstMessage: message) { (success) in
                if success
                {
                    print("Message sent")
                }
                else
                {
                    print("Failed to send message")
                }
            }
        }
        else
        {
            //use existing conversation from database and append to it
            
        }
    }
    
    private func GenerateMessageID() -> String?
    {
        //current date, otherUserEmail, senderEmail
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        
        let safeEmail = DatabaseManager.SafeEmail(email: currentUserEmail)
        
        //attention: the self property on dateFormatter is written with a capital S because it is a static property!
        let dateString = Self.dateFormatter.string(from: Date())
        let ID = "\(otherUserEmail)_\(safeEmail)_\(dateString)"
        print("Message ID: \(ID)")
        return ID
    }
}

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate
{
    func currentSender() -> SenderType
    {
        if let sender = selfSender
        {
            return sender
        }
        
        fatalError("Self sender is nil, email should be cached!")
        return Sender(senderId: "1", displayName: "Dummy Sender", photoURL: "")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType
    {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    
}
