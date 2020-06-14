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
    public func insertUser(with user: ChatAppUser){
        let value = ["firstName": user.firstName, "lastName": user.lastName, "emailAddress":user.safeEmail]
        let userRef = database.child("users").child(user.uID)
        userRef.updateChildValues(value, withCompletionBlock: {(err, ref) in
            if err != nil{
                print(err!)
                return
            }
        })
    }
  
}
struct ChatAppUser{
    let firstName: String
    let lastName: String
    let emailAddress: String
    let uID: String
    
    var safeEmail: String{
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "&")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
}
