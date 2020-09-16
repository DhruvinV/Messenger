//
//  DatabaseManager.swift
//  Messenger
//
//  Created by Dhruvin Vekariya on 2020-06-11.
//  Copyright © 2020 Neural Inc. All rights reserved.
//

import Foundation
import FirebaseDatabase
import MessageKit

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
    public func getDataFor(path: String, completion: @escaping (Result <Any,Error>) -> Void){
        self.database.child("\(path)").observeSingleEvent(of: .value, with: {snapshot in
            guard let value = snapshot.value else{
                completion(.failure(DatabaseManagerError.failedToFetch))
                return
            }
            completion(.success(value))
            
        })
        
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
// Mark: - Firebase Code for sending and receiving messages
extension DatabaseManager{
    /// Creates new database entry of new conversation for the current user
    public func createNewConversation(with otherUserEmail: String,otherUserName: String ,otherUserUid: String,firstMessage: Message, completion: @escaping(Bool)->Void){
        
        guard let currEmail = UserDefaults.standard.value(forKey: "email") as? String,
            let currUseruid = UserDefaults.standard.value(forKey: "userUID") as? String,
            let currUserName = UserDefaults.standard.value(forKey: "fullName") as? String else{
                print("Failing wiwth user defaults")
            return
        }
//        print(uid)
//        let safeEmail = DatabaseManager.generateSafeEmail(emailAddress: currEmail)
        let ref = database.child("users").child(currUseruid)
        ref.observeSingleEvent(of: .value, with: {[weak self]snapshot in
            guard var userNode = snapshot.value as? [String:Any] else{
                completion(false)
                print("User not found")
                return
            }
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
                "otherUserName": otherUserName,
                "otherUserUID": otherUserUid,
                "latest_message": [
                        "date": dateString,
                        "message": message,
                        "is_read": false
                ]
            ]
            let recipient_newConversationData: [String:Any] = [
                "id":conversationID,
                "otherUserEmail": DatabaseManager.generateSafeEmail(emailAddress: currEmail),
                "otherUserName": currUserName,
                "otherUserUID": currUseruid,
                "latest_message": [
                        "date": dateString,
                        "message": message,
                        "is_read": false
                ]
            ]
            self?.database.child("users/\(otherUserUid)/conversations").observeSingleEvent(of: .value, with: {[weak self]snapshot in
                if var conversationsArray = snapshot.value as? [[String:Any]] {
                    conversationsArray.append(recipient_newConversationData)
                    self?.database.child("users/\(otherUserUid)/conversations").setValue(conversationsArray)
                }else{
                    self?.database.child("users/\(otherUserUid)/conversations").setValue([recipient_newConversationData])
                }
                
            })
            
            
            if var conversations  = userNode["conversations"] as? [[String:Any]] {
//                append to conversations array
                conversations.append(newConversationData)
                userNode["conversations"]  = conversations
                ref.setValue(userNode, withCompletionBlock: {[weak self]err, _ in
                               
                    guard err == nil else{
                        completion(false)
                        return
                    }
                    self?.createConversationNode(name: otherUserName,conversationID: conversationID,firstMessage: firstMessage, otherUserUid: newConversationData["otherUserUID"] as! String ,completion: completion)
                    
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
                    
                    self?.createConversationNode(name: otherUserName,conversationID: conversationID, firstMessage: firstMessage, otherUserUid: newConversationData["otherUserUID"] as! String ,completion: completion)
                    
                })
            }
            
        })
        
        
    }
    private func createConversationNode(name: String, conversationID: String, firstMessage: Message, otherUserUid: String,completion: @escaping(Bool)->Void){
        
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
            "otherUserUID": otherUserUid,
            "is_read":false,
            "otherUserName": name
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
    public func getAllConversation(for email:String, uid: String ,completion: @escaping(Result<[Conversation],Error>) -> Void){
        
        database.child("users/\(uid)/conversations").observe(.value, with: {snapshot in
            guard let value  = snapshot.value as? [[String:Any]] else{
                completion(.failure(DatabaseManagerError.failedToFetch))
                return
            }
            let fetchedConversation: [Conversation] = value.compactMap({hMap in
                guard let conversationId = hMap["id"] as? String,
                let name = hMap["otherUserName"] as? String,
                let email = hMap["otherUserEmail"] as? String,
                let otherUserUid = hMap["otherUserUID"]  as? String,
                let latestMessage = hMap["latest_message"] as? [String:Any],
                let date = latestMessage["date"] as? String,
                let message = latestMessage["message"] as? String,
                    let isRead = latestMessage["is_read"] as? Bool else {
                        return nil
                }
                let lastMessageObj = LatestMessage(date: date, text: message, isRead: isRead)
                return Conversation(id: conversationId, name: name, otherUserEmail: email, latestMessage: lastMessageObj, otherUserUID: otherUserUid)
            })
//            print(fetchedConversation)
            
            completion(.success(fetchedConversation))
 
        })
        
        
    }
    
    public func getAllMessagesForConversation(with id: String, completion: @escaping (Result<[Message],Error>)->Void){
        database.child("\(id)/message").observe(.value, with: {snapshot in
            guard let value  = snapshot.value as? [[String:Any]] else{
                completion(.failure(DatabaseManagerError.failedToFetch))
                return
            }
            let messages: [Message] = value.compactMap({hMap in
                guard let otherUserName = hMap["otherUserName"] as? String,
                    let type = hMap["type"] as? String,
                    let senderUid  = hMap["otherUserUID"] as? String,
                    let isRead = hMap["is_read"] as? Bool,
                    let messageid = hMap["id"] as? String,
                    let dateString = hMap["date"] as? String,
                    let content = hMap["content"] as? String,
                    let senderEmail = hMap["sender_email"] as? String,
                    let date  = ChatViewController.dateFormatter.date(from:dateString)else{
                        return nil
                }
                
                var kind: MessageKind?
                if type == "photo"{
                    guard let imageURL = URL(string: content),
                        let placeHolder = UIImage(systemName: "plus") else {
                            return nil
                    
                    }
                    let media =  Media(url: imageURL,image: nil, placeholderImage: placeHolder,
                                       size: CGSize(width: 250, height: 250))
                    kind = .photo(media)
                }
                else if type == "video" {
                    // photo
                    guard let videoUrl = URL(string: content),
                        let placeHolder = UIImage(named: "video_placeholder") else {
                            return nil
                    }
                    
                    let media = Media(url: videoUrl,
                                      image: nil,
                                      placeholderImage: placeHolder,
                                      size: CGSize(width: 250, height: 200))
                    kind = .video(media)
                }
                else{
                    kind = .text(content)
                }
                guard let finalKind = kind else {
                                return nil
                    }
                
                let sender = Sender(photoURL: "", senderId: senderEmail, displayName: otherUserName, SenderUID: senderUid)
                
                return Message(sender: sender, messageId: messageid, sentDate: date, kind: finalKind)
                
            })
            
            completion(.success(messages))
            
        })
        
    }
    
    public func sendMessage(to conversation: String, otherUserEmail: String, otherUserName: String,otherUserUID: String, latestMessage: Message, completion: @escaping (Bool) -> Void) {
    
        guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String, let currUID = UserDefaults.standard.string(forKey:"userUID") else {
            completion(false)
            return
        }
//
        let currentEmail = DatabaseManager.generateSafeEmail(emailAddress: myEmail)
//
        database.child("\(conversation)/message").observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard let strongSelf = self else {
                return
            }
//
            guard var currentMessages = snapshot.value as? [[String: Any]] else {
                completion(false)
                return
            }
//
            let messageDate = latestMessage.sentDate
            let dateString = ChatViewController.dateFormatter.string(from: messageDate)
            var message = ""
            switch latestMessage.kind {
            case .text(let messageText):
                message = messageText
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .custom(_):
                break
            case .attributedText(_):
                break
            case .photo(let mediaData):
                if let targetUrlString = mediaData.url?.absoluteString {
                    message = targetUrlString
                }
                break
            case .video(let mediaData):
                if let targetUrlString = mediaData.url?.absoluteString {
                    message = targetUrlString
                }
                    break
            case .location(_):
                break
            }
//
            let newMessageEntry: [String: Any] = [
                "id": latestMessage.messageId,
                "type": latestMessage.kind.rawValue,
                "content": message,
                "date": dateString,
                "sender_email": myEmail,
                "is_read": false,
                "otherUserName": otherUserName,
                "otherUserUID": otherUserUID
            ]
//
            currentMessages.append(newMessageEntry)
//
            strongSelf.database.child("\(conversation)/message").setValue(currentMessages) { error, _ in
                guard error == nil else {
                    completion(false)
                    return
                }
//
                strongSelf.database.child("users/\(currUID)/conversations").observeSingleEvent(of: .value, with: { snapshot in
                    var databaseEntryConversations = [[String: Any]]()
                    let updatedValue: [String: Any] = [
                        "date": dateString,
                        "is_read": false,
                        "message": message
                    ]
//
                    if var currentUserConversations = snapshot.value as? [[String: Any]] {
                        var targetConversation: [String: Any]?
                        var position = 0

                        for conversationDictionary in currentUserConversations {
                            if let currentId = conversationDictionary["id"] as? String, currentId == conversation {
                                targetConversation = conversationDictionary
                                break
                            }
                            position += 1
                        }
//
                        if var targetConversation = targetConversation {
                            targetConversation["latest_message"] = updatedValue
                            currentUserConversations[position] = targetConversation
                            databaseEntryConversations = currentUserConversations
                        }
                        else {
                            let newConversationData: [String: Any] = [
                                "id": conversation,
                                "otherUserEmail": DatabaseManager.generateSafeEmail(emailAddress: otherUserEmail),
                                "otherUserName": otherUserName,
                                "otherUserUID": otherUserUID,
                                "latest_message": updatedValue
                            ]
                            currentUserConversations.append(newConversationData)
                            databaseEntryConversations = currentUserConversations
                        }
                    }
                    else {
                        let newConversationData: [String: Any] = [
                            "id": conversation,
                            "otherUserEmail": DatabaseManager.generateSafeEmail(emailAddress: otherUserEmail),
                            "otherUserName": otherUserName,
                            "otherUserUID": otherUserUID,
                            "latest_message": updatedValue
                        ]
                        databaseEntryConversations = [
                            newConversationData
                        ]
                    }
//
                    strongSelf.database.child("users/\(currUID)/conversations").setValue(databaseEntryConversations, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
//
//
//                        // Update latest message for recipient user
                        strongSelf.database.child("users/\(otherUserUID)/conversations").observeSingleEvent(of: .value, with: { snapshot in
                            let updatedValue: [String: Any] = [
                                "date": dateString,
                                "is_read": false,
                                "message": message
                            ]
                            var databaseEntryConversations = [[String: Any]]()
//
//
                            if var otherUserConversations = snapshot.value as? [[String: Any]] {
                                var targetConversation: [String: Any]?
                                var position = 0

                                for conversationDictionary in otherUserConversations {
                                    if let currentId = conversationDictionary["id"] as? String, currentId == conversation {
                                        targetConversation = conversationDictionary
                                        break
                                    }
                                    position += 1
                                }
                                if var targetConversation = targetConversation {
                                    targetConversation["latest_message"] = updatedValue
                                    otherUserConversations[position] = targetConversation
                                    databaseEntryConversations = otherUserConversations
                                }
                                else {
                                    // failed to find in current colleciton
                                    let newConversationData: [String: Any] = [
                                        "id": conversation,
                                        "otherUserEmail": DatabaseManager.generateSafeEmail(emailAddress: currentEmail),
                                        "otherUserName": UserDefaults.standard.string(forKey: "fullName") ?? "",
                                        "otherUserUID": currUID,
                                        "latest_message": updatedValue
                                    ]
                                    otherUserConversations.append(newConversationData)
                                    databaseEntryConversations = otherUserConversations
                                }
                            }
                            else {
                                // current collection does not exist
                             let newConversationData: [String: Any] = [
                                    "id": conversation,
                                    "otherUserEmail": DatabaseManager.generateSafeEmail(emailAddress: currentEmail),
                                    "otherUserName": UserDefaults.standard.string(forKey: "fullName") ?? "",
                                    "otherUserUID": currUID,
                                    "latest_message": updatedValue
                                ]
                                databaseEntryConversations = [
                                    newConversationData
                                ]
                            }
//
                            strongSelf.database.child("users/\(otherUserUID)/conversations").setValue(databaseEntryConversations, withCompletionBlock: { error, _ in
                                guard error == nil else {
                                    completion(false)
                                    return
                                }

                                completion(true)
                            })
                        })
                    })
                })
            }
        })
    }
        
    public func checkForExistingConversation(with targetRecipientName: String, targetRecipientUID: String, completion: @escaping(Result<String, Error>)->Void){
        guard let senderUID = UserDefaults.standard.string(forKey: "userUID") else{
            return
        }
        database.child("users/\(targetRecipientUID)/conversations").observeSingleEvent(of: .value, with: {snapshot in
            guard let collection = snapshot.value as? [[String:Any]] else {
                completion(.failure(DatabaseManagerError.failedToFetch))
                return
            }
            if let existingConv = collection.first(where: {
            guard let targetSenderEmail = $0["otherUserUID"] as? String else {
                    return false
            }
                return  senderUID == targetSenderEmail
                
            }) {
                
                guard let convID  = existingConv["id"] as? String else{
                    completion(.failure(DatabaseManagerError.failedToFetch))
                    return
                }
                completion(.success(convID))
                return
            }
            
            completion(.failure(DatabaseManagerError.failedToFetch))
            return
            
        })
        
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
