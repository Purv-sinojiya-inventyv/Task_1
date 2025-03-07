//
//  ViewController.swift
//  Assignment_1
//
//  Created by Purv Sinojiya on 25/02/25.
//

import UIKit

// Define User Model


// Define API Response Model


class LoginViewController: UIViewController {
    
    @IBOutlet private weak var txtEmail: UITextField!
    @IBOutlet private weak var txtPassword: UITextField!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet private weak var txtError: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtError.isHidden = true // Hide error label initially
    }

    @IBAction private func loginButtonTapped(_ sender: UIButton) {
        validateLogin()
    }
    
    private func validateLogin() {
        guard let email = txtEmail.text, !email.isEmpty,
              let password = txtPassword.text, !password.isEmpty else {
            showError("Email and Password cannot be empty")
            return
        }
        
        // Email format validation
        if !isValidEmail(email) {
            showError("Invalid email format")
            return
        }
        
        // Password length validation
        if password.count < 6 {
            showError("Password must be at least 6 characters")
            return
        }
        
        txtError.isHidden = true
        print("Login Successful for: \(email)")

        // Create UserModel instance with dynamic email & password
        let user = UserModel(
            userName: email,
            password: password,
            softwareType: "AN",  // Static Value
            releaseVersion: "049" // Static Value
        )
        
        Task {
             fetchData(user: user) { result in
                switch result {
                case .success(let responseData):
                    print("API Success: \(responseData)")
                   
                    DispatchQueue.main.async {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        if let signupVC = storyboard.instantiateViewController(withIdentifier: "SignupViewController") as? SignupViewController {
                            signupVC.firstName=responseData.firstName
                            signupVC.lastName=responseData.lastName
                            signupVC.dob=responseData.dob
                            signupVC.gender = responseData.gender == 1 ? "Male" : "Female"
                            signupVC.height = Double(responseData.heightCM ?? 0)
                            self.navigationController?.pushViewController(signupVC, animated: true)
                        }
                    }
                    
                case .failure(let error):
                    print("API Failure: \(error.localizedDescription)")
                    // ✅ Show an error alert
                    DispatchQueue.main.async {
                        self.showError("Failed to fetch data: \(error.localizedDescription)")
                    }
                }
            }
        }

    }
    
    private func showError(_ message: String) {
        txtError.text = message
        txtError.isHidden = false
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }


    }


     
