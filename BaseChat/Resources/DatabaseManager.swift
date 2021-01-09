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
