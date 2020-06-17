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
    
    public typealias UpLoadProfilePicture = (Result<String,Error>) -> Void
    public  func uploadProfilePicture(with data: Data, fileName: String, completion: @escaping UpLoadProfilePicture){
        
        storage.child("images/\(fileName)").putData(data, metadata: nil, completion: {metadata, error in
            guard error == nil else{
                print("error")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            self.storage.child("images/\(fileName)").downloadURL(completion: {url, error in
                guard  let url = url else{
                    completion(.failure(StorageErrors.failedToGetDownloadURL))
                    return
                }
                let urlString = url.absoluteString
                print("Download URL returned")
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
 
