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
    static func generateSafeEmail(emailAddress: String) -> String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "&")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
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
    public func createNewConversation(with otherUserEmail: String, firstMessage: Message, completion: @escaping(Bool)->Void){
        
        guard let currEmail = UserDefaults.standard.value(forKey: "email") as? String,
            let uid = UserDefaults.standard.value(forKey: "userUID") as? String else{
                print("Failing wiwth user defaults")
            return
        }
        print(uid)
//        let safeEmail = DatabaseManager.generateSafeEmail(emailAddress: currEmail)
        let ref = database.child("users").child(uid)
        ref.observeSingleEvent(of: .value, with: {snapshot in
            guard var userNode = snapshot.value as? [String:Any] else{
                completion(false)
                print("User not found")
                return
            }
            print(userNode)
            let conversationID =  "conversation_\(firstMessage.messageId)"
            let messageDate = firstMessage.sentDate
            let dateString = ChatViewController.dateFormatter.string(from: messageDate)
            var message = ""
            switch firstMessage.kind{
                
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
            case .custom(_):
                break
            }
            let newConversationData: [String:Any] = [
                "id":conversationID,
                "otherUserEmail":otherUserEmail,
                "latest_message": [
                        "date": dateString,
                        "message": message,
                        "is_read": false
                ]
            ]
            
            if var conversations  = userNode["conversations"] as? [[String:Any]] {
//                append to conversations array
                
                conversations.append(newConversationData)
                userNode["conversations"]  = conversations
                ref.setValue(userNode, withCompletionBlock: {[weak self]err, _ in
                               
                    guard err == nil else{
                        completion(false)
                        return
                    }
                    self?.createConversationNode(conversationID: conversationID, firstMessage: firstMessage, completion: completion)
                    
                })
                
                
            }else{
                userNode["conversations"] = [
                    newConversationData
                ]
                ref.setValue(userNode, withCompletionBlock: {[weak self] err, _ in
                     
                    guard err == nil else{
                        completion(false)
                        return
                    }
                    
                    self?.createConversationNode(conversationID: conversationID, firstMessage: firstMessage, completion: completion)
                    
                })
            }
            
        })
        
        
    }
    private func createConversationNode(conversationID: String, firstMessage: Message, completion: @escaping(Bool)->Void){
//        {
//
//        }
        var message = ""
        switch firstMessage.kind{
            
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
        case .custom(_):
            break
        }
        let conversationID =  "conversation_\(firstMessage.messageId)"
        let messageDate = firstMessage.sentDate
        let dateString = ChatViewController.dateFormatter.string(from: messageDate)
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else{
            completion(false)
            return
        }
        let messageNode: [String:Any] = [
            "id":firstMessage.messageId,
            "type": firstMessage.kind.rawValue,
            "content": message,
            "date":dateString,
            "sender_email":currentUserEmail,
            "is_read":false
        ]
        let value: [String: Any] = [
        
            "message": [
                messageNode
            ]
        ]
        
        database.child("\(conversationID)").setValue(value, withCompletionBlock: {err, _ in
            
            guard err == nil else{
                completion(false)
                return
            }
            completion(true)
        })
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
