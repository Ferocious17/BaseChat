//
//  SettingsViewController.swift
//  BaseChat
//
//  Created by Caner Kaya on 07.01.21.
//

import UIKit
import FirebaseAuth

class SettingsViewController: UIViewController {

    private let profilePicture: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.circle")
        imageView.tintColor = .gray
        imageView.contentMode = .scaleAspectFit
        
        //circular image picker
        imageView.layer.masksToBounds = true
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        return imageView
    }()
    
    private let signOutButton: UIButton = {
        let button = UIButton()
        button.setTitle("Sign out", for: .normal)
        button.backgroundColor = .link
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        signOutButton.addTarget(self, action: #selector(DidTapSignOut), for: .touchUpInside)
        view.addSubview(profilePicture)
        view.addSubview(signOutButton)
        
        profilePicture.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(DidTapChangeProfilePicture))
        profilePicture.addGestureRecognizer(gesture)
        LoadProfilePicture()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        /*let imagePNGData = UserDefaults.standard.data(forKey: "profilePictureData")
        let optionalImagePNGData = UIImage(systemName: "person.circle")?.pngData()
        profilePicture.image = UIImage(data: (imagePNGData ?? optionalImagePNGData)!)*/
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        let size = view.width / 3
        
        profilePicture.frame = CGRect(x: (view.width-size)/2,
                                      y: view.top+175,
                                      width: size,
                                      height: size)
        profilePicture.layer.cornerRadius = profilePicture.width/2
        
        signOutButton.frame = CGRect(x: 30,
                                     y: view.bottom-150,
                                     width: view.width-60,
                                     height: 52)
    }
    
    private func DownloadImage(imageView: UIImageView, url: URL)
    {
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            guard let data = data, error == nil else
            {
                return
            }
            
            DispatchQueue.main.async
            {
                let image = UIImage(data: data)
                self.profilePicture.image = image
                /*let imagePNGData = image?.pngData()
                UserDefaults.standard.setValue(imagePNGData, forKey: "profilePictureData")*/
            }
        }.resume()
    }
    
    public func LoadProfilePicture()
    {
        //get the email address of the current user from cache
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else
        {
            return
        }
        
        let safeEmail = DatabaseManager.SafeEmail(email: email)
        let fileName = safeEmail + "_profile_picture.png"
        let path = "images/"+fileName
        
        StorageManager.shared.DownloadURL(for: path) { [weak self] (result) in
            switch result
            {
            case .success(let url):
                self?.DownloadImage(imageView: self!.profilePicture, url: url)
            case .failure(let error):
                print("Failed to get download URL: \(error)")
            }
        }
    }
    
    @objc func DidTapChangeProfilePicture()
    {
        PresentPhotoOptions()
    }
    
    @objc func DidTapSignOut()
    {
        let alert = UIAlertController(title: "Sign out", message: "Do you really want to sign out?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Sign out", style: .destructive, handler: { [weak self] (_) in
            
            guard let strongSelf = self else
            {
                return
            }
        
            strongSelf.SignOut()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func SignOut() -> Void
    {
        do
        {
            try FirebaseAuth.Auth.auth().signOut()
            //go back to login screen
            let viewController = LoginViewController()
            let navigationController = UINavigationController(rootViewController: viewController)
            navigationController.modalPresentationStyle = .fullScreen
            present(navigationController, animated: true, completion: nil)
        }
        catch
        {
            print("Failed to log out")
        }
    }
}

extension SettingsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        picker.dismiss(animated: true, completion: nil)
        print(info)
        //update the profile picture on the UI
        //displays the picked image on screen
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else
        {
            return
        }
        
        self.profilePicture.image = selectedImage
        UpdateProfilePicture()
    }
    
    private func UpdateProfilePicture()
    {
        guard let image = self.profilePicture.image,
              let data = image.pngData(),
              let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        
        let safeEmail = DatabaseManager.SafeEmail(email: email)
        let fileName = "\(safeEmail)_profile_picture.png"
        StorageManager.shared.UploadProfilePicture(with: data, fileName: fileName) { (result) in
            switch result
            {
            case .success(let downloadURL):
                UserDefaults.standard.set(downloadURL, forKey: "profile_picture_url")
                print(downloadURL)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func PresentPhotoOptions()
    {
        let alert = UIAlertController(title: "Profile picture", message: "How would you like to select your profile picture?", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Take photo", style: .default, handler: { [weak self] (_) in
            self?.PresentCamera()
        }))
        alert.addAction(UIAlertAction(title: "Choose from library", style: .default, handler: { [weak self] (_) in
            self?.PresentLibrary()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    func PresentCamera()
    {
        let controller = UIImagePickerController()
        controller.sourceType = .camera
        controller.delegate = self
        //allows user to select a cropped square
        controller.allowsEditing = true
        present(controller, animated: true)
    }
    
    func PresentLibrary()
    {
        let controller = UIImagePickerController()
        controller.sourceType = .photoLibrary
        controller.delegate = self
        //allows user to select a cropped square
        controller.allowsEditing = true
        present(controller, animated: true)
    }
}
