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
    
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}

struct Sender: SenderType{
    var photoURL : String
    var senderId: String
    var displayName: String
    
    
}
class ChatViewController: MessagesViewController {
    
    
    public let otherUserEmail: String
    public var isNewConversation  = false
    
    private var messages = [Message]()
    private let selfSender = Sender(photoURL: "", senderId: "1", displayName: "Joe Smith")
    
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
    }
    
    init(with email: String) {
        self.otherUserEmail  = email
        
        super.init(nibName: nil,bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
extension ChatViewController: InputBarAccessoryViewDelegate{

    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty else{
            return
        }
//        send Message
        if isNewConversation{
            
        }else{
            
        }
    }

}
extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    func currentSender() -> SenderType {
        return selfSender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
        
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    
    
    
    
}
