import UIKit

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
        
        if !isValidEmail(email) {
            showError("Invalid email format")
            return
        }
        
        if password.count < 6 {
            showError("Password must be at least 6 characters")
            return
        }
        
        txtError.isHidden = true
        print("Login Successful for: \(email)")

        let user = UserModel(
            userName: email,
            password: password,
            softwareType: "AN",
            releaseVersion: "049"
        )

        Task {
            fetchData(user: user) { result in
                switch result {
                case .success(let responseData):
                    print("✅ API Success: \(responseData)")
                    DispatchQueue.main.async {
                        let firstName = responseData.firstName ?? ""
                        print("📝 Data Received:")
                        print("   - First Name: \(firstName.isEmpty ? "❌ Missing" : firstName)")
                        let lastName = responseData.lastName ?? ""
                        print("   - Last Name: \(lastName.isEmpty ? "❌ Missing" : lastName)")
                        let dob = responseData.dob ?? ""
                        print("   - DOB: \(dob.isEmpty ? "❌ Missing" : dob)")
                        let gender = responseData.gender == 1 ? "Male" : "Female"
                        print("   - Gender: \(gender.isEmpty ? "❌ Missing" : gender)")
                        let height = Double(responseData.heightCM ?? 0)
                        print("   - Height: \(height == 0 ? "❌ Missing" : "\(height) cm")")

                        // Debugging: Print which data is missing
                       
                     
                      
                      
                       

                        if DatabaseHelper.shared.insertUser(email: email, password: password, firstName: firstName, lastName: lastName, gender: gender, dateOfBirth: dob, height: height) {
                            print("✅ User data saved successfully in SQLite")
                        } else {
                            print("❌ Failed to save user data in SQLite")
                        }

                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        if let signupVC = storyboard.instantiateViewController(withIdentifier: "SignupViewController") as? SignupViewController {
                            signupVC.firstName = firstName
                            signupVC.lastName = lastName
                            signupVC.dob = dob
                            signupVC.gender = gender
                            signupVC.height = height
                            self.navigationController?.pushViewController(signupVC, animated: true)
                        } else {
                            print("❌ Failed to instantiate SignupViewController")
                        }
                    }

                case .failure(let error):
                    print("❌ API Failure: \(error.localizedDescription)")
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
