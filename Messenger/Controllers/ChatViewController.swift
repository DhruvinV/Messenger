//
//  ChatViewController.swift
//  Messenger
//
//  Created by Dhruvin Vekariya on 2020-06-14.
//  Copyright © 2020 Neural Inc. All rights reserved.
//

import UIKit
import MessageKit
import InputBarAccessoryView

struct Message: MessageType{
    
   public var sender: SenderType
   public var messageId: String
   public var sentDate: Date
   public var kind: MessageKind
}
extension MessageKind {
    var rawValue: String {
        switch self{
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributedText"
        case .photo(_):
            return "photo"
        case .video(_):
            return "video"
        case .location(_):
            return "location"
        case .emoji(_):
            return "emoji"
        case .audio(_):
            return "audio"
        case .contact(_):
            return "contact"
        case .custom(_):
            return "custom"
        }
    }
}

struct Sender: SenderType{
   public var photoURL : String
   public var senderId: String
   public var displayName: String
    
    
}
class ChatViewController: MessagesViewController {
    
    public static let dateFormatter: DateFormatter = {
        let formatted = DateFormatter()
        formatted.dateStyle = .medium
        formatted.timeStyle = .long
        formatted.locale = .current
        return formatted
    }()
    public let otherUserEmail: String
    public var isNewConversation  = true
    private let conversationID: String?
    
    private var messages = [Message]()
    private var selfSender:  Sender?{
        guard let email = UserDefaults.standard.value(forKey: "email") else{
            return nil
        }
        
        let safeEmail = DatabaseManager.generateSafeEmail(emailAddress: email as! String)
        return Sender(photoURL: "", senderId: safeEmail as! String, displayName: "Joe Smith")
        
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
//        messages.append(Message(sender: selfSender, messageId: "1", sentDate: Date(), kind: .text("Hellocdcdascads casdcadscsadcsad")))
        view.backgroundColor = .red
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        // Do any additional setup after loading the view.
        
    }
    
    
    private func listenForMessages(id: String){
        DatabaseManager.shared.getAllMessagesForConversation(with: id, completion: {[weak self] res in
            switch res{
            case.success(let messages):
                guard !messages.isEmpty else{
                    return
                }
                self?.messages = messages
                DispatchQueue.main.async{
                    self?.messagesCollectionView.reloadDataAndKeepOffset()
                }
                
            case.failure(let eroor):
                print("failed to get messages \(eroor)")
            }
            
        })
        
        
        
    }
    
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
    }
    
    init(with email: String, id: String?) {
        self.otherUserEmail  = email
        self.conversationID = id
        super.init(nibName: nil,bundle: nil)
        if let coversationId  = conversationID{
            listenForMessages(id: coversationId )
        }
       
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
extension ChatViewController: InputBarAccessoryViewDelegate{

    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
            let selfSender = self.selfSender, let messageID = createMessageId() else{
                print("fail")
                return
        }
       
        //        send Message
        if isNewConversation{
            print("Sending message")
            let message = Message(sender: selfSender, messageId: messageID, sentDate: Date(), kind: .text(text))
            DatabaseManager.shared.createNewConversation(with: otherUserEmail, otherUserName: self.title ?? "User" ,firstMessage: message, completion: { res in
                if res{
                    print("messageSent")
                }else{
                    print("Failed to sent")
                }
            })
            
        }else{
            
        }
    }
    private func createMessageId() -> String?{
//        date, otheruseremail, senderemail, randomint
        
        guard let currUserEmail = UserDefaults.standard.value(forKey: "email") as? String
             else {
            return nil
        }
        let safeEmail = DatabaseManager.generateSafeEmail(emailAddress: currUserEmail)
        let dateString = Self.dateFormatter.string(from: Date())
        let newIdentifier = "\(otherUserEmail)_\(safeEmail)_\(dateString)"
        print("message id \(newIdentifier)")
        return newIdentifier
    }

}
extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    func currentSender() -> SenderType {
        if let sender = selfSender{
            return sender
        }
        fatalError("selfSender is nil email should be cached")
//        return Sender(photoURL: "", senderId: "", displayName: "")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
        
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
}

