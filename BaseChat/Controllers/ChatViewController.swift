//
//  ChatViewController.swift
//  BaseChat
//
//  Created by Caner Kaya on 09.01.21.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import SDWebImage

class ChatViewController: MessagesViewController {
    
    public var isNewConversation = false
    public let otherUserEmail: String
    private let conversationID: String?
    
    public static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.locale = .current
        return formatter
    }()
    
    private var messages = [Message]()
    
    private var selfSender: Sender? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else
        {
            return nil
        }
        
        let safeEmail = DatabaseManager.SafeEmail(email: email)
        
        return Sender(senderId: safeEmail,
                      displayName: "User name",
                      photoURL: "")
    }
    
    init(with email: String, id: String?)
    {
        self.otherUserEmail = email
        self.conversationID = id
        super.init(nibName: nil, bundle: nil)
        
        if let id = conversationID
        {
            ListenForMessages(id, true)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func ListenForMessages(_ id: String, _ shouldScrollToBottom: Bool)
    {
        DatabaseManager.shared.GetAllMessagesForConversation(with: id) { [weak self] (result) in
            switch result
            {
            case .success(let messages):
                guard !messages.isEmpty else {
                    return
                }
                
                self?.messages = messages
                
                DispatchQueue.main.async
                {
                    self?.messagesCollectionView.reloadDataAndKeepOffset()
                    
                    if shouldScrollToBottom
                    {
                        self?.messagesCollectionView.scrollToBottom()
                    }
                }
                
            case .failure(let error):
                print("Failed to get messages: \(error)")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //view.backgroundColor = .purple
        
        showMessageTimestampOnSwipeLeft = true
        
        //messageInputBar.sendButton.image = UIImage(systemName: "paperplane.fill")?.Rotate(radians: .pi/4)
        
        /*messagesCollectionView.backgroundColor = .blue
         messagesCollectionView.tintColor = .red
         messages.append(Message(sender: selfSender as! SenderType, messageId: "1", sentDate: Date(), kind: .text("Lol")))
         */
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messageInputBar.delegate = self
        
        SetupInputButton()
    }
    
    private func SetupInputButton()
    {
        let button = InputBarButtonItem()
        button.setSize(CGSize(width: 35, height: 35), animated: false)
        button.setImage(UIImage(systemName: "camera.fill"), for: .normal)
        button.onTouchUpInside { [weak self] (_) in
            self?.PresentInputActions()
        }
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.setStackViewItems([button], forStack: .left, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        //show the keyboard once view has appeared
        messageInputBar.inputTextView.becomeFirstResponder()
    }
}

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    private func PresentInputActions()
    {
        let alert = UIAlertController(title: "Attach media", message: "What would you like to attach?", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Select photo from library", style: .default, handler: { [weak self] (_) in
            self?.PresentPhotoLibrary()
        }))
        
        alert.addAction(UIAlertAction(title: "Take photo", style: .default, handler: { [weak self] (_) in
            self?.PresentCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Select video from library", style: .default, handler: { [weak self] (_) in
            self?.PresentVideoLibrary()
        }))
        
        alert.addAction(UIAlertAction(title: "Record video", style: .default, handler: { [weak self] (_) in
            self?.PresentVideoCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    private func PresentVideoCamera()
    {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        picker.mediaTypes = ["public.movie"]
        picker.videoQuality = .typeMedium
        picker.allowsEditing = true
        self.present(picker, animated: true, completion: nil)
    }
    
    private func PresentVideoLibrary()
    {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.mediaTypes = ["public.movie"]
        picker.videoQuality = .typeMedium
        picker.allowsEditing = true
        self.present(picker, animated: true, completion: nil)
    }
    
    private func PresentCamera()
    {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        picker.allowsEditing = true
        self.present(picker, animated: true, completion: nil)
    }
    
    private func PresentPhotoLibrary()
    {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        self.present(picker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let messageID = GenerateMessageID(),
              let conversationID = conversationID,
              let name = self.title
              /*let selfSender = selfSender*/ else {
            return
        }
        
        if let image = info[.editedImage] as? UIImage,
           let imageData = image.pngData()
        {
            //upload photo
            let fileName = "photo_message_\(messageID.replacingOccurrences(of: " ", with: "-")).png"
            UploadImage(imageData: imageData, fileName: fileName, messageID: messageID, conversationID: conversationID, name: name)
        }
        else if let videoURL = info[.mediaURL] as? URL
        {
            //upload video
            let fileName = "video_message_\(messageID.replacingOccurrences(of: " ", with: "-")).mov"
            UploadVideo(videoURL: videoURL, fileName: fileName, messageID: messageID, conversationID: conversationID, name: name)
        }
        
        
        
        //Upload image
        /*StorageManager.shared.UploadMessagePhoto(with: imageData, fileName: fileName) { [weak self] (result) in
            guard let strongSelf = self else {
                return
            }
            
            switch result
            {
            case .success(let urlString):
                //Send message
                print("Message image uploaded: \(urlString)")
                
                guard let downloadURL = URL(string: urlString),
                      let placeholder = UIImage(systemName: "globe") else {
                    return
                }
                
                let media = Media(url: downloadURL,
                                  image: nil,
                                  placeholderImage: placeholder,
                                  size: .zero)
                
                let message = Message(sender: selfSender,
                                      messageId: messageID,
                                      sentDate: Date(),
                                      kind: .photo(media))
                
                DatabaseManager.shared.SendMessage(to: conversationID, otherUserEmail: strongSelf.otherUserEmail, name: name, newMessage: message) { (success) in
                    if success
                    {
                        print("Photo message sent")
                    }
                    else
                    {
                        print("Failed to send photo message")
                    }
                }
                
            case .failure(let error):
                print("Photo message upload error: \(error)")
            }
        }*/
    }
    
    private func UploadVideo(videoURL: URL, fileName: String, messageID: String, conversationID: String, name: String)
    {
        StorageManager.shared.UploadMessageVideo(with: videoURL, fileName: fileName) { [weak self] (result) in
            
            guard let strongSelf = self else {
                return
            }
            
            switch result
            {
            case .success(let urlString):
                //Send message
                print("Message video uploaded: \(urlString)")
                strongSelf.SendVideo(videoURL: urlString, messageID: messageID, conversationID: conversationID, name: name)
                
            case .failure(let error):
                print("Video message upload error: \(error)")
            }
        }
    }
    
    private func SendVideo(videoURL: String, messageID: String, conversationID: String, name: String)
    {
        guard let downloadURL = URL(string: videoURL),
              let placeholder = UIImage(systemName: "globe"),
              let selfSender = selfSender else {
            return
        }
        
        let media = Media(url: downloadURL,
                          image: nil,
                          placeholderImage: placeholder,
                          size: .zero)
        
        let message = Message(sender: selfSender,
                              messageId: messageID,
                              sentDate: Date(),
                              kind: .video(media))
        
        DatabaseManager.shared.SendMessage(to: conversationID, otherUserEmail: self.otherUserEmail, name: name, newMessage: message) { (success) in
            if success
            {
                print("Video message sent")
            }
            else
            {
                print("Failed to send video message")
            }
        }
    }
    
    private func UploadImage(imageData: Data, fileName: String, messageID: String, conversationID: String, name: String)
    {
        StorageManager.shared.UploadMessagePhoto(with: imageData, fileName: fileName) { [weak self] (result) in
            switch result
            {
            case .success(let urlString):
                //Send message
                print("Message image uploaded: \(urlString)")
                self?.SendImage(urlString: urlString, messageID: messageID, conversationID: conversationID, name: name)
                
            case .failure(let error):
                print("Photo message upload error: \(error)")
            }
        }
    }
    
    private func SendImage(urlString: String, messageID: String, conversationID: String, name: String)
    {
        guard let downloadURL = URL(string: urlString),
              let placeholder = UIImage(systemName: "globe"),
              let selfSender = selfSender else {
            return
        }
        
        let media = Media(url: downloadURL,
                          image: nil,
                          placeholderImage: placeholder,
                          size: .zero)
        
        let message = Message(sender: selfSender,
                              messageId: messageID,
                              sentDate: Date(),
                              kind: .photo(media))
        
        DatabaseManager.shared.SendMessage(to: conversationID, otherUserEmail: otherUserEmail, name: name, newMessage: message) { (success) in
            if success
            {
                print("Photo message sent")
            }
            else
            {
                print("Failed to send photo message")
            }
        }
    }
    
    /*func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage,
              let imageData = image.pngData(),
              let messageID = GenerateMessageID(),
              let conversationID = conversationID,
              let name = self.title else {
            return
        }
        
        let fileName = "photo_message_\(messageID)"
        
        //Upload image
        UploadImage(imageData: imageData, fileName: fileName, messageID: messageID, name: name, conversationID: conversationID)
    }
    
    private func SendImage(url: String, messageID: String, name: String, conversationID: String)
    {
        //Send image message
        guard let strongSelf = self else {
            return
        }
        
        guard let downloadURL = URL(string: url),
              let placeholder = UIImage(systemName: "globe"),
              let selfSender = selfSender else {
            return
        }
        
        let media = Media(url: downloadURL,
                          image: nil,
                          placeholderImage: placeholder,
                          size: .zero)
        
        let message = Message(sender: selfSender,
                              messageId: messageID,
                              sentDate: Date(),
                              kind: .photo(media))
        
        DatabaseManager.shared.SendMessage(to: conversationID, otherUserEmail: otherUserEmail, name: name, newMessage: message) { (success) in
            if success
            {
                print("Photo message sent")
            }
            else
            {
                print("Failed to send photo message")
            }
        }
    }*/
}

extension ChatViewController: InputBarAccessoryViewDelegate
{
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String)
    {
        //Quick validation
        //doesn't allow user to send message with only spaces
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
              let selfSender = self.selfSender,
              let messageID = GenerateMessageID() else {
            return
        }
        
        print("Text to send: \(text)")
        
        let message = Message(sender: selfSender,
                              messageId: messageID,
                              sentDate: Date(),
                              kind: .text(text))
        
        //Send message
        if isNewConversation
        {
            //create new conversation in database
            DatabaseManager.shared.CreateNewConversation(with: otherUserEmail, name: self.title ?? "User Name", firstMessage: message) { [weak self] (success) in
                if success
                {
                    print("Message sent")
                    self?.isNewConversation = false
                }
                else
                {
                    print("Failed to send message")
                }
            }
        }
        else
        {
            //use existing conversation from database and append to it
            
            guard let conversationID = conversationID, let name = self.title else {
                return
            }
            
            DatabaseManager.shared.SendMessage(to: conversationID, otherUserEmail: otherUserEmail, name: name, newMessage: message) { (success) in
                if success
                {
                    print("Message sent")
                }
                else
                {
                    print("Failed to send message")
                }
            }
        }
    }
    
    private func GenerateMessageID() -> String?
    {
        //current date, otherUserEmail, senderEmail
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        
        let safeEmail = DatabaseManager.SafeEmail(email: currentUserEmail)
        
        //attention: the self property on dateFormatter is written with a capital S because it is a static property!
        let dateString = Self.dateFormatter.string(from: Date())
        let ID = "\(otherUserEmail)_\(safeEmail)_\(dateString)"
        print("Message ID: \(ID)")
        return ID
    }
}

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate
{
    func currentSender() -> SenderType
    {
        if let sender = selfSender
        {
            return sender
        }
        
        fatalError("Self sender is nil, email should be cached!")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType
    {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        guard let message = message as? Message else {
            return
        }
        
        switch message.kind
        {
        case .photo(let media):
            guard let imageURL = media.url else {
                return
            }
            
            imageView.sd_setImage(with: imageURL, completed: nil)
        default:
            break
        }
    }
}

extension ChatViewController: MessageCellDelegate
{
    func didTapImage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else {
            return
        }
        
        let message = messages[indexPath.section]
        
        switch message.kind
        {
        case .photo(let media):
            guard let imageURL = media.url else {
                return
            }
            
            let viewController = PhotoViewerController(with: imageURL)
            self.navigationController?.pushViewController(viewController, animated: true)
        default:
            break
        }
    }
}
