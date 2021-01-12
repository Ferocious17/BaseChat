//
//  DatabaseManager.swift
//  BaseChat
//
//  Created by Caner Kaya on 08.01.21.
//

import Foundation
import FirebaseDatabase

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
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String else {
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
                "name":"Self",
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
                
                return Message(sender: sender, messageId: messageID, sentDate: date, kind: .text(content))
            }
            
            completion(.success(messages))
        }
    }
    
    /// Sends a message to target conversation
    public func SendMessage(to conversation: String, message: Message, completion: @escaping (Bool) -> Void)
    {
        
    }
}
