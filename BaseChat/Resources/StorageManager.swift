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

///Manager for storage interactions
final class StorageManager
{
    static let shared = StorageManager()
    
    private let storage = Storage.storage().reference()
    
    public typealias UploadMediaCompletion = (Result<String, Error>) -> Void
    public typealias DownloadMediaCompletion = (Result<URL, Error>) -> Void
    
    /// Uploads picked profile picture to firebase storage and returns completion with URL string to download
    public func UploadProfilePicture(with data: Data, fileName: String, completion: @escaping UploadMediaCompletion)
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
    
    ///Uploads image which will be sent to a conversation
    public func UploadMessagePhoto(with data: Data, fileName: String, completion: @escaping UploadMediaCompletion)
    {
        storage.child("message_images/\(fileName)").putData(data, metadata: nil) { [weak self] (metadata, error) in
            guard error == nil else
            {
                //failed
                print("Failed to upload picture")
                completion(.failure(StorageError.FailedToUpload))
                return
            }
            
            self?.storage.child("message_images/\(fileName)").downloadURL { (url, error) in
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
    
    ///Uploads video which will be sent to a conversation
    public func UploadMessageVideo(with fileURL: URL, fileName: String, completion: @escaping UploadMediaCompletion)
    {
        storage.child("message_videos/\(fileName)").putFile(from: fileURL, metadata: nil) { [weak self] (metadata, error) in
            guard error == nil else
            {
                //failed
                print("Failed to upload video")
                completion(.failure(StorageError.FailedToUpload))
                return
            }
            
            self?.storage.child("message_videos/\(fileName)").downloadURL { (url, error) in
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
    
    public func DownloadURL(for path: String, completion: @escaping DownloadMediaCompletion)
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
