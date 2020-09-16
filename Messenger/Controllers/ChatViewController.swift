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
import SDWebImage
import CoreLocation
import AVFoundation
import AVKit

struct Media: MediaItem {
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
}

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
    public var SenderUID: String
    
    
}
struct Location: LocationItem{
    var location: CLLocation
    var size: CGSize
}
final class ChatViewController: MessagesViewController {
    
    public static let dateFormatter: DateFormatter = {
        let formatted = DateFormatter()
        formatted.dateStyle = .medium
        formatted.timeStyle = .long
        formatted.locale = .current
        return formatted
    }()
    public let otherUserEmail: String
    public var isNewConversation  = false
    public let otherUserUID: String?
    public var oppositeUserName: String?
    private var conversationID: String?
    
    private var messages = [Message]()
    private var selfSender:  Sender?{
        guard let email = UserDefaults.standard.value(forKey: "email"), let myUid = UserDefaults.standard.value(forKey: "userUID") as? String else{
            return nil
        }
//        let safeEmail = DatabaseManager.generateSafeEmail(emailAddress: email as! String)
        return Sender(photoURL: "", senderId: email as! String, displayName: "Me", SenderUID:  myUid)
        
    }

    
    init(with email: String, id: String?, otherUserUid: String?, otherUserName: String?) {
        self.otherUserEmail  = email
        self.conversationID = id
        self.oppositeUserName = otherUserName
        self.otherUserUID = otherUserUid
        super.init(nibName: nil,bundle: nil)

       
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messageInputBar.delegate = self
        // Do any additional setup after loading the view.
        setupInputButton()
        
        
    }
    
    private func  setupInputButton(){
        let button = InputBarButtonItem()
        button.setSize(CGSize(width: 35, height: 35),animated: false)
        button.setImage(UIImage(systemName: "paperclip"),for: .normal)
        button.onTouchUpInside{[weak self] _ in self?.presentInputActionSheet()}
        
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.setStackViewItems([button], forStack: .left, animated: false)
    }
    private func presentInputActionSheet() {
        let actionSheet = UIAlertController(title: "Attach Media",
                                            message: "What would you like to attach?",
                                            preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Photo", style: .default, handler: {  [weak self] _ in

            self?.presentPhotoActions()
        }))
        actionSheet.addAction(UIAlertAction(title: "Video", style: .default, handler: {  [weak self] _ in
            self?.presentVideoActions()
           }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        present(actionSheet, animated: true)
    }
    
    
    private func presentVideoActions() {
        let actionSheet = UIAlertController(title: "Send Videos",
                                            message: "Where would you like to sends a video from?",
                                            preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [weak self] _ in

            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            picker.mediaTypes = ["public.movie"]
            picker.videoQuality = .typeMedium
            picker.allowsEditing = true
            self?.present(picker, animated: true)

        }))
        actionSheet.addAction(UIAlertAction(title: "Library", style: .default, handler: { [weak self] _ in

            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.mediaTypes = ["public.movie"]
            picker.videoQuality = .typeMedium
             picker.allowsEditing = true
            self?.present(picker, animated: true)

        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        present(actionSheet, animated: true)
    }
    private func presentPhotoActions(){
        let actionSheet = UIAlertController(title: "Send Pictures",
                                            message: "Where would you like to send picture from?",
                                            preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Take a picture", style: .default, handler: { [weak self] _ in

            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            picker.allowsEditing = true
            self?.present(picker,animated: true)
        }))
        actionSheet.addAction(UIAlertAction(title: "Choose a picture from Photo Library", style: .default, handler: { [weak self] _ in
            
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.allowsEditing = true
            self?.present(picker,animated: true)
            
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        present(actionSheet, animated: true)
        
        
    }
    private func listenForMessages(id: String, shouldScrollToBottom: Bool){
        DatabaseManager.shared.getAllMessagesForConversation(with: id, completion: {[weak self] res in
            switch res{
            case.success(let messages):
                guard !messages.isEmpty else{
                    return
                }
                self?.messages = messages
                DispatchQueue.main.async{
                    
                self?.messagesCollectionView.reloadDataAndKeepOffset()
                    if shouldScrollToBottom{
                        self?.messagesCollectionView.scrollToBottom()
                    }
                  
                }
                
            case.failure(let eroor):
                print("failed to get messages \(eroor)")
            }
            
        })
        
        
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
        
        if let conversationID  = conversationID{
            listenForMessages(id: conversationID, shouldScrollToBottom: true)
        }
    }
    
}

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let messageId  = createMessageId(),
            let conversationID = conversationID,
            let selfSender = selfSender else{
            return
        }
        if let photo = info[.editedImage] as? UIImage, let imgData = photo.pngData(){
            let filePath = "photo_message_" + messageId.replacingOccurrences(of: " ", with: "-") + ".png"
        
        StorageManager.shared.savePhotoMessage(with: imgData, fileName: filePath, completion: {[weak self] result in
//            guard let strongSelf = self else{
//                return
//            }
            switch result{
            case.success(let photoURL):
                guard let url = URL(string: photoURL),
                    let placeholder = UIImage(systemName: "plus") else {
                        return
                }
                
                let media = Media(url: url,
                                image: nil,
                                placeholderImage: placeholder,
                                size: .zero)
                let message = Message(sender: selfSender,
                                                         messageId: messageId,
                                                         sentDate: Date(),
                                                         kind: .photo(media))
                DatabaseManager.shared.sendMessage(to: conversationID, otherUserEmail:  self?.otherUserEmail ?? "", otherUserName:  self?.oppositeUserName ?? "User", otherUserUID: self?.otherUserUID ?? "uid", latestMessage: message, completion: { success in
                    if success {
                        print("sent photo message")
                    }
                    else {
                        print("failed to send photo message")
                    }
                    
                })
                
            case .failure(let error):
                print("message photo upload error: \(error)")
            }
        })

        }else if let videoUrl = info[.mediaURL] as? URL {
            let filePath = "photo_message_" + messageId.replacingOccurrences(of: " ", with: "-").replacingOccurrences(of: ",", with: "k").replacingOccurrences(of: ":", with: "_").lowercased() + ".MOV"

                print(filePath, "VideoURL")
                // Upload Video
                StorageManager.shared.saveVideoMessage(with: videoUrl, fileName: filePath, completion: { [weak self] result in
//                    guard let strongSelf = self else {
//                        return
//                    }

                    switch result {
                    case .success(let urlString):
                        // Ready to send message
                        print("Uploaded Message Video: \(urlString)")

                        guard let url = URL(string: urlString),
                            let placeholder = UIImage(systemName: "plus") else {
                                return
                        }

                        let media = Media(url: url,
                                          image: nil,
                                          placeholderImage: placeholder,
                                          size: .zero)

                        let message = Message(sender: selfSender,
                                              messageId: messageId,
                                              sentDate: Date(),
                                              kind: .video(media))

                        DatabaseManager.shared.sendMessage(to: conversationID, otherUserEmail:  self?.otherUserEmail ?? "", otherUserName:  self?.oppositeUserName ?? "User", otherUserUID: self?.otherUserUID ?? "uid", latestMessage: message,completion: { success in

                            if success {
                                print("sent photo message")
                            }
                            else {
                                print("failed to send photo message")
                            }

                        })

                    case .failure(let error):
                        print("message photo upload error: \(error)")
                    }
                })
            }
        }
    }
extension ChatViewController: InputBarAccessoryViewDelegate{

    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
            let selfSender = self.selfSender, let messageID = createMessageId() else{
                print("fail")
                return
        }
    
        let message = Message(sender: selfSender, messageId: messageID, sentDate: Date(), kind: .text(text))
        
        if isNewConversation{
            DatabaseManager.shared.createNewConversation(with: otherUserEmail, otherUserName: self.oppositeUserName ?? "User" ,otherUserUid: self.otherUserUID ?? "uid",firstMessage: message, completion: { [weak self]res in
                if res{
                    print("messageSent")
                    self?.isNewConversation = false
                    let newConversationId = "conversation_\(message.messageId)"
                    self?.conversationID = newConversationId
                    self?.listenForMessages(id: newConversationId, shouldScrollToBottom: true)
                    self?.messageInputBar.inputTextView.text = nil
                }else{
                  print("Failed to send")
                }
            })
            
        }else{
            guard let conversationID = conversationID else{
                return
            }
            DatabaseManager.shared.sendMessage(to: conversationID, otherUserEmail: otherUserEmail, otherUserName: self.oppositeUserName ?? "User", otherUserUID: self.otherUserUID ?? "uid", latestMessage: message, completion: {[weak self] res in
                if res{
                    self?.messageInputBar.inputTextView.text = nil
                    print("message sent")
                }else{
                    print("failed to send")
                }
            })
            
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
        return newIdentifier
    }

}
extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    func currentSender() -> SenderType {
        if let sender = selfSender{
            return sender
        }
        fatalError("selfSender is nil email should be cached")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
        
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }

    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        let sender = message.sender
        if sender.senderId == selfSender?.senderId {
            // our message that we've sent
            return UIColor(red: 0.40, green: 0.86, blue: 0.98, alpha: 1.00)
        }
        return UIColor(red: 0.56, green: 0.92, blue: 0.73, alpha: 1.00)
    }

    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        guard let message = message as? Message else {
            return
        }

        switch message.kind {
        case .photo(let media):
            guard let imageUrl = media.url else {
                return
            }
            imageView.sd_setImage(with: imageUrl, completed: nil)
        default:
            break
        }
    }

}

extension ChatViewController: MessageCellDelegate {
    func didTapImage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else {
            return
        }

        let message = messages[indexPath.section]

        switch message.kind {
        case .photo(let media):
            print(media,"Dsds")
            guard let imageUrl = media.url else {
                return
            }
            let vc = PhotoViewController(with: imageUrl)
            navigationController?.pushViewController(vc, animated: true)
        case .video(let media):
            guard let videoUrl = media.url else {
                return
            }

            let vc = AVPlayerViewController()
            vc.player = AVPlayer(url: videoUrl)
            present(vc, animated: true)
        default:
            break
        }
    }
}

