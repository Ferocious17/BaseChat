//
//  DatabaseManager.swift
//  BaseChat
//
//  Created by Caner Kaya on 08.01.21.
//

import Foundation
import FirebaseDatabase
import MessageKit

public enum DatabaseError: Error
{
    case FailedToFetch
}

//Final indicates that this class cannot be subclassed
final class DatabaseManager
{
    static let shared = DatabaseManager()
    private let database = Database.database().reference()
    
    static func SafeEmail(email: String) -> String
    {
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
    /*public func Test()
    {
        //Firebase uses NoSQL - JSON
        //So you have a key and set the value to the key
        // "foo" {
        // "key":"value"
        // }
        database.child("foo").setValue("")
        
    }*/
}

// MARK: Account Management
extension DatabaseManager
{
    /// Check if user exists already by verifying if the e-mail is already in use
    public func UserExists(with email: String, completion: @escaping((Bool) -> Void))
    {
        //We have to make a new string because . and @ are not allowed in Firebase
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        
        database.child(safeEmail).observeSingleEvent(of: .value) { (snapshot) in
            guard snapshot.value as? String != nil else {
                completion(false)
                return
            }
            
            completion(true)
        }
    }
    
    /// Create new user object in database. Inserts new data for user
    public func CreateNewUser(with user: BaseChatUser, completion: @escaping (Bool) -> Void)
    {
        //the key of the record for the user is his or her e-mail address
        //the other values like first and lastname are set under their e-mail
        //There cannot be two users with the same e-mail address
        database.child(user.safeEmail).setValue(["first_name":user.firstname,
                                                 "last_name":user.lastname]) { (error, _) in
            guard error == nil else
            {
                print("Failed to write to database")
                completion(false)
                return
            }
            
            self.database.child("users").observeSingleEvent(of: .value) { (snapshot) in
                if var usersCollection = snapshot.value as? [[String:String]]
                {
                    //append to user dictionary-array
                    let newElement = ["name":user.firstname+" "+user.lastname,
                                      "email":user.safeEmail
                    ]
                    usersCollection.append(newElement)
                    
                    self.database.child("users").setValue(usersCollection) { (error, _) in
                        guard error == nil else
                        {
                            completion(false)
                            return
                        }
                    }
                    
                    completion(true)
                }
                else
                {
                    //create dictionary-array
                    let newCollection: [[String:String]] = [
                        ["name":user.firstname+" "+user.lastname,
                         "email":user.safeEmail
                        ]
                        
                    ]
                    
                    self.database.child("users").setValue(newCollection) { (error, _) in
                        guard error == nil else
                        {
                            completion(false)
                            return
                        }
                        
                        completion(true)
                    }
                }
            }
        }
    }
    
    public func GetAllUsers(completion: @escaping (Result<[[String:String]], Error>) -> Void)
    {
        database.child("users").observeSingleEvent(of: .value) { (snapshot) in
            guard let value = snapshot.value as? [[String:String]] else
            {
                completion(.failure(DatabaseError.FailedToFetch))
                return
            }
            
            completion(.success(value))
        }
    }
}

// MARK: Get first and last name of user
extension DatabaseManager
{
    public func GetFirstLastname(for path: String, completion: @escaping (Result<Any, Error>) -> Void)
    {
        self.database.child(path).observeSingleEvent(of: .value) { (snapshot) in
            guard let value = snapshot.value else {
                completion(.failure(DatabaseError.FailedToFetch))
                return
            }
            
            completion(.success(value))
        }
    }
}

// MARK: Send messages
extension DatabaseManager
{
    private func FinishCreatingConversation(name: String, conversationID: String, firstMessage: Message, completion: @escaping (Bool) -> Void)
    {
        let messageDate = firstMessage.sentDate
        let dateString = ChatViewController.dateFormatter.string(from: messageDate)
        
        var message = ""
        
        switch firstMessage.kind
        {
        case .text(let messageText):
            message = messageText
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
        
        guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            completion(false)
            return
        }
        
        let currentUserEmail = DatabaseManager.SafeEmail(email: myEmail)
        
        let collectionMessage: [String: Any] = [
            "id":firstMessage.messageId,
            "type":firstMessage.kind.messageKindString,
            "content":message,
            "date":dateString,
            "sender_email":currentUserEmail,
            "is_read":false,
            "name":name
        ]
        
        let value: [String:Any] = [
            "messages":[
                collectionMessage
            ]
        ]
        
        print("Adding conversation: \(conversationID)")
        
        database.child("\(conversationID)").setValue(value) { (error, _) in
            guard error == nil else {
                completion(false)
                return
            }
            
            completion(true)
        }
    }
    
    /// Creates a new conversation with target user e-mail address and first message in chat
    public func CreateNewConversation(with otherUserEmail: String, name: String, firstMessage: Message, completion: @escaping (Bool) -> Void)
    {
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String,
              let currentName = UserDefaults.standard.value(forKey: "name") as? String else {
            return
        }
        
        let safeEmail = DatabaseManager.SafeEmail(email: currentEmail)
        let reference = database.child("\(safeEmail)")
        reference.observeSingleEvent(of: .value) { [weak self] (snapshot) in
            guard var userNode = snapshot.value as? [String:Any] else
            {
                completion(false)
                print("User not found");
                return
            }
            
            let messageDate = firstMessage.sentDate
            let dateString = ChatViewController.dateFormatter.string(from: messageDate)
            
            var message = ""
            
            switch firstMessage.kind
            {
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            
            let conversationID = "conversation_\(firstMessage.messageId)"
            
            //conversation data for sender user
            let newConversaionData: [String:Any] = [
                "id":conversationID,
                "other_user_email":otherUserEmail,
                "name":name,
                "latest_message":[
                    "date":dateString,
                    "message":message,
                    "is_read":false
                ]
            ]
            
            //conversation data for recipient user
            let recipientNewConversaionData: [String:Any] = [
                "id":conversationID,
                "other_user_email":safeEmail,
                "name":currentName,
                "latest_message":[
                    "date":dateString,
                    "message":message,
                    "is_read":false
                ]
            ]
            
            //update recipient user conversation entry
            self?.database.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value) { [weak self] (snapshot) in
                if var conversations = snapshot.value as? [[String:Any]]
                {
                    //append
                    conversations.append(recipientNewConversaionData)
                    self?.database.child("\(otherUserEmail)/conversations").setValue(conversationID)
                }
                else
                {
                    //create new
                    self?.database.child("\(otherUserEmail)/conversations").setValue([recipientNewConversaionData])
                }
            }
            
            //update sender user conversation entry
            if var conversations = userNode["conversations"] as? [[String:Any]]
            {
                //conversations array exists for current user
                //append message
                conversations.append(newConversaionData)
                userNode["conversations"] = conversations
                reference.setValue(userNode) { [weak self] (error, _) in
                    guard error == nil else
                    {
                        completion(false)
                        return
                    }
                    
                    self?.FinishCreatingConversation(name: name, conversationID: conversationID, firstMessage: firstMessage, completion: completion)
                }
            }
            else
            {
                //conversation does not exist
                //create new
                userNode["conversations"] = [
                    newConversaionData
                ]
                
                reference.setValue(userNode) { [weak self] (error, _) in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    
                    self?.FinishCreatingConversation(name: name, conversationID: conversationID, firstMessage: firstMessage, completion: completion)
                }
            }
        }
    }
    
    /// Fetches and returns all conversation for user with passed e-mail
    public func GetAllConversations(for email: String, completion: @escaping (Result<[Conversation], Error>) -> Void)
    {
        database.child("\(email)/conversations").observe(.value) { (snapshot) in
            guard let value = snapshot.value as? [[String:Any]] else
            {
                completion(.failure(DatabaseError.FailedToFetch))
                return
            }
            
            let conversations: [Conversation] = value.compactMap { (dictionary) in
                guard let conversationID = dictionary["id"] as? String,
                      let name = dictionary["name"] as? String,
                      let otherUserEmail = dictionary["other_user_email"] as? String,
                      let latestMessage = dictionary["latest_message"] as? [String:Any],
                      let date = latestMessage["date"] as? String,
                      let message = latestMessage["message"] as? String,
                      let isRead = latestMessage["is_read"] as? Bool else {
                        return nil
                }
                
                let latestMessageObj = LatestMessage(date: date, text: message, isRead: isRead)
                
                return Conversation(id: conversationID, name: name, otherUserEmail: otherUserEmail, latestMessage: latestMessageObj)
            }
            
            completion(.success(conversations))
        }
    }
    
    /// Fetches and returns all messages of conversation with passed conversation-id
    public func GetAllMessagesForConversation(with id: String, completion: @escaping (Result<[Message], Error>) -> Void)
    {
        database.child("\(id)/messages").observe(.value) { (snapshot) in
            guard let value = snapshot.value as? [[String:Any]] else
            {
                completion(.failure(DatabaseError.FailedToFetch))
                return
            }
            
            let messages: [Message] = value.compactMap { (dictionary) in
                guard let name = dictionary["name"] as? String,
                      let isRead = dictionary["is_read"] as? Bool,
                      let messageID = dictionary["id"] as? String,
                      let content = dictionary["content"] as? String,
                      let senderEmail = dictionary["sender_email"] as? String,
                      let dateString = dictionary["date"] as? String,
                      let date = ChatViewController.dateFormatter.date(from: dateString),
                      let type = dictionary["type"] as? String else {
                    return nil
                }
                
                let sender = Sender(senderId: senderEmail, displayName: name, photoURL: "")
                
                var kind: MessageKind?
                if type == "text"
                {
                    kind = .text(content)
                }
                else if type == "photo"
                {
                    guard let url = URL(string: content),
                          let placeholder = UIImage(systemName: "globe") else {
                        return nil
                    }
                    
                    let media = Media(url: url,
                                      image: nil,
                                      placeholderImage: placeholder,
                                      size: CGSize(width: 300, height: 300))
                    kind = .photo(media)
                }
                else if type == "video"
                {
                    guard let videoURL = URL(string: content),
                          let placeholder = UIImage(systemName: "play.fill") else {
                        return nil
                    }
                    
                    let media = Media(url: videoURL,
                                      image: nil,
                                      placeholderImage: placeholder,
                                      size: CGSize(width: 300, height: 300))
                    kind = .video(media)
                }
                
                guard let targetKind = kind else {
                    return nil
                }
                
                return Message(sender: sender,
                               messageId: messageID,
                               sentDate: date,
                               kind: targetKind)
            }
            
            completion(.success(messages))
        }
    }
    
    /// Sends a message to target conversation
    public func SendMessage(to conversationID: String, otherUserEmail: String, name: String, newMessage: Message, completion: @escaping (Bool) -> Void)
    {
        //add new message to messages with id
        //update latest message of sender
        //update latest message of recipient
        
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            completion(false)
            return
        }
        
        let currentSafeEmail = DatabaseManager.SafeEmail(email: currentUserEmail)
        
        database.child("\(conversationID)/messages").observeSingleEvent(of: .value) { [weak self] (snapshot) in
            guard let strongSelf = self else {
                return
            }
            
            guard var currentMessages = snapshot.value as? [[String:Any]] else {
                completion(false)
                return
            }
            
            let messageDate = newMessage.sentDate
            let dateString = ChatViewController.dateFormatter.string(from: messageDate)
            
            var message = ""
            
            switch newMessage.kind
            {
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(let media):
                if let targetURL = media.url?.absoluteString
                {
                    message = targetURL
                }
            case .video(let media):
                if let targetURL = media.url?.absoluteString
                {
                    message = targetURL
                }
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            
            guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
                completion(false)
                return
            }
            
            let currentUserEmail = DatabaseManager.SafeEmail(email: myEmail)
            
            let newMessageObj: [String: Any] = [
                "id":newMessage.messageId,
                "type":newMessage.kind.messageKindString,
                "content":message,
                "date":dateString,
                "sender_email":currentUserEmail,
                "is_read":false,
                "name":name
            ]
            
            currentMessages.append(newMessageObj)
            strongSelf.database.child("\(conversationID)/messages").setValue(currentMessages) { (error, _) in
                guard error == nil else {
                    completion(false)
                    return
                }
                
                strongSelf.database.child("\(currentSafeEmail)/conversations").observeSingleEvent(of: .value) { (snapshot) in
                    guard var currentUserConversations = snapshot.value as? [[String:Any]] else {
                        completion(false)
                        return
                    }
                    
                    let updatedValue: [String:Any] = [
                        "date":dateString,
                        "is_read":false,
                        "message":message
                    ]
                    
                    var targetConversation: [String:Any]?
                    var index = 0
                    
                    for conversation in currentUserConversations
                    {
                        if let currentConversationID = conversation["id"] as? String, currentConversationID == conversationID
                        {
                            targetConversation = conversation
                            break
                        }
                        
                        index += 1
                    }
                    
                    targetConversation?["latest_message"] = updatedValue
                    
                    guard let target = targetConversation else {
                        completion(false)
                        return
                    }
                    
                    currentUserConversations[index] = target
                    strongSelf.database.child("\(currentSafeEmail)/conversations").setValue(currentUserConversations) { (error, _) in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        
                        //update latest for recipient aswell
                        strongSelf.database.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value) { (snapshot) in
                            guard var recipientUserConversations = snapshot.value as? [[String:Any]] else {
                                completion(false)
                                return
                            }
                            
                            let updatedValue: [String:Any] = [
                                "date":dateString,
                                "is_read":false,
                                "message":message
                            ]
                            
                            var targetConversation: [String:Any]?
                            var index = 0
                            
                            for conversation in recipientUserConversations
                            {
                                if let currentConversationID = conversation["id"] as? String, currentConversationID == conversationID
                                {
                                    targetConversation = conversation
                                    break
                                }
                                
                                index += 1
                            }
                            
                            targetConversation?["latest_message"] = updatedValue
                            
                            guard let target = targetConversation else {
                                completion(false)
                                return
                            }
                            
                            recipientUserConversations[index] = target
                            strongSelf.database.child("\(otherUserEmail)/conversations").setValue(recipientUserConversations) { (error, _) in
                                guard error == nil else {
                                    completion(false)
                                    return
                                }
                                
                                completion(true)
                            }
                        }
                    }
                }
            }
        }
    }
    
    public func DeleteConversation(conversationID: String, completion: @escaping (Bool) -> Void)
    {
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            completion(false)
            return
        }
        
        let safeEmail = DatabaseManager.SafeEmail(email: currentUserEmail)
        
        //Get all conversations for current user
        //delete conversation in collection with target ID
        //reset conversations in database for current user
        let reference = database.child("\(safeEmail)/conversations")
        reference.observeSingleEvent(of: .value) { (snapshot) in
            if var conversations = snapshot.value as? [[String:Any]]
            {
                var indexToRemove = 0
                
                for conversation in conversations
                {
                    if let id = conversation["id"] as? String,
                       id == conversationID
                    {
                        break
                    }
                    indexToRemove += 1
                }
                
                conversations.remove(at: indexToRemove)
                reference.setValue(conversations) { (error, _) in
                    guard error == nil else {
                        completion(false)
                        print("Failed to delete conversation")
                        return
                    }
                    print("Successfully deleted conversation")
                    completion(true)
                }
            }
        }
    }
}
