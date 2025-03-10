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
        print("dhighih")
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
            userName: email, password: password,
            softwareType: "AN",
            releaseVersion: "049",
            email: email,
            firstName: "",
            lastName: "",
            gender: "",
            dateOfBirth: "",
            height: 0.0
        )

        Task {
            fetchData(user: user) { result in
                switch result {
                case .success(let responseData):
                    print("✅ API Success: \(responseData)")
                    DispatchQueue.main.async {
                        let firstName = responseData.firstName ?? ""
                        let lastName = responseData.lastName ?? ""
                        let dob = responseData.dob ?? ""
                        let gender = responseData.gender == 1 ? "Male" : "Female"
                        let height = Double(responseData.heightCM ?? 0)
                        print(firstName)
                        print(lastName)
                        print(dob)
                        print(gender)
                        print(height)
                        print("dfnknkdfhkgkhkfhgkfhkg")

                        // Store user data in SQLite
                        if DatabaseHelper.shared.insertOrUpdateUser(email: email, password: password, firstName: firstName, lastName: lastName, gender: gender, dateOfBirth: dob, height: height) {
                            print("✅ User data saved successfully in SQLite")
                            UserDefaults.standard.set(email, forKey: "user_email")
                            self.navigateToSignupScreen()
                        } else {
                            print("❌ Failed to save user data in SQLite")
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

    private func navigateToSignupScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let signupVC = storyboard.instantiateViewController(withIdentifier: "SignupViewController") as? SignupViewController {
            self.navigationController?.pushViewController(signupVC, animated: true)
        } else {
            print("❌ Failed to instantiate SignupViewController")
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
