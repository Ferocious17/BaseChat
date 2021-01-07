//
//  LoginViewController.swift
//  BaseChat
//
//  Created by Caner Kaya on 07.01.21.
//

import UIKit

class LoginViewController: UIViewController {

    //Create scroll view so elements can accessed on smaller screens
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let logo: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "BaseChatLogo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Sign in"
        label.font = .boldSystemFont(ofSize: 33)
        label.textAlignment = .left
        return label
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
    
    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Sign in", for: .normal)
        button.backgroundColor = .link
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()
    
    private let noAccountLabel: UILabel = {
        let label = UILabel()
        label.text = "No account yet?"
        label.font = .boldSystemFont(ofSize: 16)
        label.textAlignment = .center
        label.textColor = .lightGray
        return label
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
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        //make the keyboard disappear if user taps on empty space on screen
        let dismissKeyboard = UITapGestureRecognizer(target: self, action: #selector(DismissKeyboard))
        view.addGestureRecognizer(dismissKeyboard)
        
        // title = "Log in"
        view.backgroundColor = .white
        
        /*navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sign up",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(DidTapSignUp))
        */
 
        //Add target / function to buttons
        loginButton.addTarget(self, action: #selector(DidTapLoginButton), for: .touchUpInside)
        signUpButton.addTarget(self, action: #selector(DidTapSignUp), for: .touchUpInside)
        
        emailField.delegate = self
        passwordField.delegate = self
        
        //Add subviews to view
        view.addSubview(scrollView)
        scrollView.addSubview(logo)
        scrollView.addSubview(titleLabel)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(loginButton)
        scrollView.addSubview(noAccountLabel)
        scrollView.addSubview(signUpButton)
    }
    
    //call the hide function here again
    //the sign up view does a have a navigation bar in order to get back to the sign in screen
    //because it is there in the sign up screen it doesn't hide again in the sign in screen when you go back
    //because it is only called when view the view loads (viewDidLoad)
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        let size = view.width / 3
        logo.frame = CGRect(x: (scrollView.width-size)/2,
                            y: 30,
                            width: size,
                            height: size)
        
        titleLabel.frame = CGRect(x: 30,
                                  y: logo.bottom+10,
                                  width: scrollView.width-60,
                                  height: 40)
        
        emailField.frame = CGRect(x: 30,
                                  y: titleLabel.bottom+15,
                                  width: scrollView.width-60,
                                  height: 52)
        
        passwordField.frame = CGRect(x: 30,
                                     y: emailField.bottom+15,
                                     width: scrollView.width-60,
                                     height: 52)
        
        loginButton.frame = CGRect(x: 30,
                                   y: passwordField.bottom+15,
                                   width: scrollView.width-60,
                                   height: 52)
        
        noAccountLabel.frame = CGRect(x: 30,
                                   y: loginButton.bottom+20,
                                   width: scrollView.width-60,
                                   height: 52)
        
        signUpButton.frame = CGRect(x: 30,
                                   y: noAccountLabel.bottom+20,
                                   width: scrollView.width-60,
                                   height: 52)
    }
    
    @objc private func DidTapLoginButton()
    {
        //Get rid of the keyboard
        if emailField.isFirstResponder
        {
            emailField.resignFirstResponder()
        }
        else if passwordField.isFirstResponder
        {
            passwordField.resignFirstResponder()
        }
        
        //Check if fields are filled out properly
        guard let email = emailField.text,
              let password = passwordField.text,
              !email.isEmpty, !password.isEmpty else
        {
            AlertLoginError()
            return
        }
        
        //Firebase login process
    }
    
    private func AlertLoginError()
    {
        let alert = UIAlertController(title: "Empty fields", message: "Please fill in all fields for login", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    @objc private func DidTapSignUp()
    {
        let viewController = RegistrationViewController()
        viewController.title = "Sign up"
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    //force the keyboard to disappear
    @objc private func DismissKeyboard()
    {
        view.endEditing(true)
    }
}

extension LoginViewController: UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        if textField == emailField
        {
            passwordField.becomeFirstResponder()
        }
        else if textField == passwordField
        {
            DidTapLoginButton()
        }
        
        return true
    }
}
