//
//  DatabaseManager.swift
//  Messenger
//
//  Created by Dhruvin Vekariya on 2020-06-11.
//  Copyright © 2020 Neural Inc. All rights reserved.
//

import Foundation
import FirebaseDatabase

final class DatabaseManager {
    
    static let shared = DatabaseManager()
    private var database = Database.database().reference()
    
    
}
extension DatabaseManager{
    public func userExists(with email: String,completion: @escaping((Bool)->Void)){
        
        var safeEmail = email.replacingOccurrences(of: ".", with: "&")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        database.child("users").queryOrdered(byChild: "emailAddress").observeSingleEvent(of: .value, with:{snapshot in
            for childSnapShot in snapshot.children {
                let snap = childSnapShot as! DataSnapshot
                let dict = snap.value as! [String: Any]
                let emailAddress = dict["emailAddress"] as? String ?? ""
                if emailAddress == safeEmail {
                    completion(false)
                    return
                }
            }
            completion(true)
        })
    }
    /// Inserts new user to database
    public func insertUser(with user: ChatAppUser, completion: @escaping (Bool)->Void) {
        let value = ["firstName": user.firstName, "lastName": user.lastName, "emailAddress":user.safeEmail,"profilePic":user.profilePictureURL]
        let userRef = database.child("users").child(user.uID)
        userRef.updateChildValues(value, withCompletionBlock:{ err, _ in
            guard err == nil else{
                print("failed to write to the database")
                completion(false)
                return
            }
            self.database.child("usersCollection").observeSingleEvent(of: .value, with: {snapshot in
                if var usersCollection = snapshot.value as? [[String:String]]{
                    //                    append to user
                    let newElement = [
                        "name":user.firstName + " " + user.lastName,
                        "uid": user.uID,
                        "email":user.safeEmail
                    ]
                    
                    usersCollection.append(newElement)
                    self.database.child("usersCollection").setValue(usersCollection, withCompletionBlock: {error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        completion(true)
                    })
                }else{
                    //                    create that array
                    let newCollection: [[String:String]] = [
                        [
                            "name":user.firstName + " " + user.lastName,
                            "uid": user.uID,
                            "email":user.safeEmail
                        ]
                    ]
                    self.database.child("usersCollection").setValue(newCollection, withCompletionBlock: {error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        completion(true)
                    })
                }
            })
        })
        completion(true)
    }
    
    
    public func getAllUsers(completion: @escaping(Result<[[String:String]],Error>) -> Void){
        print("IN get all Users")
        self.database.child("usersCollection").observeSingleEvent(of: .value, with: {snapshot in
            guard let value  = snapshot.value  as? [[String:String]] else{
                completion(.failure(DatabaseManagerError.failedToFetch))
                return
            }
            completion(.success(value))
        })
    }
    public enum DatabaseManagerError: Error{
        case failedToFetch
    }
    
    
    
}
// MARK: - Firebase Code for sending and receiving messages
extension DatabaseManager{
    /// Creates new database entry of new conversation for the current user
    public func createNewConversation(with otherUserEmail: String, firstMessage: String,completion: @escaping(Bool)->Void){
        
    }
    /// Fetches all  conversation from the database of the current user
    public func getAllConversation(for email:String, completion: @escaping(Result<String,Error>) -> Void){
        
    }
    
    public func getAllMessagesForConversation(with id: String, completion: @escaping (Result<String,Error>)->Void){
        
    }
    public func sendMessage(to conversation: String, message: Message, completion: @escaping(Bool)->Void){
        
        
    }
    
    
}

struct ChatAppUser{
    let firstName: String
    let lastName: String
    let emailAddress: String
    let uID: String
    var profilePictureURL: String {
        return  "\(uID)_profile_picture.png"
    }
    
    var safeEmail: String{
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "&")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
}
