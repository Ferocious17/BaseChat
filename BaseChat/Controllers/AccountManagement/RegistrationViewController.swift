//
//  RegistrationViewController.swift
//  BaseChat
//
//  Created by Caner Kaya on 07.01.21.
//

import UIKit

class RegistrationViewController: UIViewController {

    //Create scroll view so elements can accessed on smaller screens
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let profilePicture: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person")
        imageView.tintColor = .gray
        imageView.contentMode = .scaleAspectFit
        
        //circular image picker
        imageView.layer.masksToBounds = false
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.black.cgColor
        
        return imageView
    }()
    
    /*private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Sign up"
        label.font = .boldSystemFont(ofSize: 33)
        label.textAlignment = .left
        return label
    }()*/
    
    private let firstnameField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "First name"
        
        //add a padding to the left
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        
        return field
    }()
    
    private let lastnameField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Last name"
        
        //add a padding to the left
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        
        return field
    }()
    
    private let emailField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "email@provider.com"
        
        //add a padding to the left
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        
        return field
    }()
    
    private let passwordField: UITextField = {
        let field = UITextField()
        field.isSecureTextEntry = true
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Password"
        
        //add a padding to the left
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        
        return field
    }()
    
    private let signUpButton: UIButton = {
        let button = UIButton()
        button.setTitle("Sign up", for: .normal)
        button.backgroundColor = .link
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        //make the keyboard disappear if user taps on empty space on screen
        let dismissKeyboard = UITapGestureRecognizer(target: self, action: #selector(DismissKeyboard))
        view.addGestureRecognizer(dismissKeyboard)
        
        title = "Sign up"
        view.backgroundColor = .white
        
        //Add target / function to buttons
        signUpButton.addTarget(self, action: #selector(DidTapSignUpButton), for: .touchUpInside)
        
        emailField.delegate = self
        passwordField.delegate = self
        
        //Add subviews to view
        view.addSubview(scrollView)
        scrollView.addSubview(profilePicture)
        //scrollView.addSubview(titleLabel)
        scrollView.addSubview(firstnameField)
        scrollView.addSubview(lastnameField)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(signUpButton)
        
        //Add gesture recognizer so user can change picute on tap
        profilePicture.isUserInteractionEnabled = true
        scrollView.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(DidTapChangeProfilePicture))
        profilePicture.addGestureRecognizer(gesture)
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        let size = view.width / 3
        
        profilePicture.frame = CGRect(x: (scrollView.width-size)/2,
                            y: 30,
                            width: size,
                            height: size)
        profilePicture.layer.cornerRadius = profilePicture.width/2
        
        /*titleLabel.frame = CGRect(x: 30,
                                  y: profilePicture.bottom+10,
                                  width: scrollView.width-60,
                                  height: 40)*/
        
        firstnameField.frame = CGRect(x: 30,
                                      y: profilePicture.bottom+30,
                                      width: scrollView.width-60,
                                      height: 52)
        
        lastnameField.frame = CGRect(x: 30,
                                     y: firstnameField.bottom+15,
                                     width: scrollView.width-60,
                                     height: 52)
        
        emailField.frame = CGRect(x: 30,
                                  y: lastnameField.bottom+15,
                                  width: scrollView.width-60,
                                  height: 52)
        
        passwordField.frame = CGRect(x: 30,
                                     y: emailField.bottom+15,
                                     width: scrollView.width-60,
                                     height: 52)
        
        signUpButton.frame = CGRect(x: 30,
                                   y: passwordField.bottom+15,
                                   width: scrollView.width-60,
                                   height: 52)
    }
    
    @objc private func DidTapSignUpButton()
    {
        //Get rid of the keyboard
        if firstnameField.isFirstResponder
        {
            firstnameField.resignFirstResponder()
        }
        else if lastnameField.isFirstResponder
        {
            lastnameField.resignFirstResponder()
        }
        else if emailField.isFirstResponder
        {
            emailField.resignFirstResponder()
        }
        else if passwordField.isFirstResponder
        {
            passwordField.resignFirstResponder()
        }
        
        //Check if fields are filled out properly
        guard let firstname = firstnameField.text,
              let lastname = lastnameField.text,
              let email = emailField.text,
              let password = passwordField.text,
              !firstname.isEmpty, !lastname.isEmpty, !email.isEmpty, !password.isEmpty, password.count >= 8 else
        {
            AlertLoginError()
            return
        }
        
        //Firebase login process
    }
    
    private func AlertLoginError()
    {
        let alert = UIAlertController(title: "Empty fields", message: "Please fill in all fields to create a new account", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    @objc private func DidTapSignUp()
    {
        let viewController = RegistrationViewController()
        viewController.title = "Sign up"
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc private func DidTapChangeProfilePicture()
    {
        print("Change profile picture called")
    }
    
    //Get rid of the keyboard
    @objc private func DismissKeyboard()
    {
        view.endEditing(true)
    }
}

extension RegistrationViewController: UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        if textField == firstnameField
        {
            lastnameField.becomeFirstResponder()
        }
        else if textField == lastnameField
        {
            emailField.becomeFirstResponder()
        }
        else if textField == emailField
        {
            passwordField.becomeFirstResponder()
        }
        else if textField == passwordField
        {
            DidTapSignUpButton()
        }
        
        return true
    }
}
