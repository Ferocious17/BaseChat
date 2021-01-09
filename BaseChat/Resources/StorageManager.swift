//
//  StorageManager.swift
//  BaseChat
//
//  Created by Caner Kaya on 09.01.21.
//

import Foundation
import FirebaseStorage

public enum StorageError: Error
{
    case FailedToUpload
    case FailedToGetDownloadURL
}

final class StorageManager
{
    static let shared = StorageManager()
    
    private let storage = Storage.storage().reference()
    
    /*
     /images/caner-kaya2003-outlook-com_profile_picture.png
     */
    
    public typealias UploadProfilePictureCompletion = (Result<String, Error>) -> Void
    public typealias DownloadProfilePictureCompletion = (Result<URL, Error>) -> Void
    
    // Uploads picked profile picture to firebase storage and returns completion with URL string to download
    public func UploadProfilePicture(with data: Data, fileName: String, completion: @escaping UploadProfilePictureCompletion)
    {
        storage.child("images/\(fileName)").putData(data, metadata: nil) { (metadata, error) in
            guard error == nil else
            {
                //failed
                print("Failed to upload profile picture")
                completion(.failure(StorageError.FailedToUpload))
                return
            }
            
            self.storage.child("images/\(fileName)").downloadURL { (url, error) in
                guard let url = url else
                {
                    print("Failed to get download URL")
                    completion(.failure(StorageError.FailedToGetDownloadURL))
                    return
                }
                
                let URLString = url.absoluteString
                print("Download URL: \(URLString)")
                completion(.success(URLString))
            }
        }
    }
    
    public func DowndloadURL(for path: String, completion: @escaping DownloadProfilePictureCompletion)
    {
        let reference = storage.child(path)
        
        reference.downloadURL { (url, error) in
            guard let url = url, error == nil else {
                completion(.failure(StorageError.FailedToGetDownloadURL))
                return
            }
            
            completion(.success(url))
        }
    }
}
