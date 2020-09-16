//
//  StorageManager.swift
//  Messenger
//
//  Created by Dhruvin Vekariya on 2020-06-15.
//  Copyright © 2020 Neural Inc. All rights reserved.
//

import Foundation
import FirebaseStorage

final class StorageManager {
    static let shared  = StorageManager()
    private let storage = Storage.storage().reference()
/// Uploads to firebase and returns url string to download
    
//images/Uid_profile_picture.png
    
    public  func uploadProfilePicture(with data: Data, fileName: String, completion: @escaping (Result<String,Error>) -> Void){
        storage.child("images/\(fileName)").putData(data, metadata: nil, completion: {metadata, error in
            guard error == nil else{
                print("Failed to upload to firebase database")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            self.storage.child("images/\(fileName)").downloadURL(completion: {url, error in
                guard  let url = url else{
                    print("failed to get download url")
                    completion(.failure(StorageErrors.failedToGetDownloadURL))
                    return
                }
                let urlString = url.absoluteString
                print("download url returned \(urlString)")
                completion(.success(urlString))
            })
        })
        
    }
    
    public func savePhotoMessage(with data: Data, fileName: String, completion: @escaping((Result<String,Error>) -> Void)){
        
        storage.child("message_images/\(fileName)").putData(data, metadata: nil, completion: {[weak self]metadata, error  in
            guard error == nil else{
                print("Failed to save photo message")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            self?.storage.child("message_images/\(fileName)").downloadURL(completion: {url, error in
                guard  let url = url else{
                    print("failed to get download url")
                    completion(.failure(StorageErrors.failedToGetDownloadURL))
                    return
                }
                let urlString = url.absoluteString
                print("download url returned \(urlString)")
                completion(.success(urlString))
            })
            
        })
        
    }
    
    public func saveVideoMessage(with url: URL, fileName: String, completion: @escaping(Result<String,Error>) -> Void){
        
        storage.child("message_videos/\(fileName)").putFile(from: url, metadata: nil, completion: {[weak self] metadata, error in
            guard error == nil else{
                print("Failed to save video message")
                print(error as Any)
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            self?.storage.child("message_videos/\(fileName)").downloadURL(completion: {url, error in
                guard  let url = url else{
                    print("failed to get download url")
                    completion(.failure(StorageErrors.failedToGetDownloadURL))
                    return
                }
                let urlString = url.absoluteString
                print("download url returned \(urlString)")
                completion(.success(urlString))
            })
            
        })
        
        
    }
    
    public enum StorageErrors: Error{
        case failedToUpload
        case failedToGetDownloadURL
    }
    
    public func donwloadURL(for path: String, completion:  @escaping (Result<URL,Error>) -> Void){
        let reference = storage.child(path)
        reference.downloadURL(completion: {url , error in
            guard let url = url, error == nil else{

                completion(.failure(StorageErrors.failedToGetDownloadURL))
                return
            }
            completion(.success(url))
        })
    }
}
 
