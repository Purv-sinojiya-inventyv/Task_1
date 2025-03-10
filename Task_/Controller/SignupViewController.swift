import UIKit

class SignupViewController: UIViewController {
    
    @IBOutlet weak var txtFirstname: UITextField!
    @IBOutlet weak var txtLastname: UITextField!
    @IBOutlet weak var btnGenderMale: UIButton!
    @IBOutlet weak var btnGenderFemale: UIButton!
    @IBOutlet weak var dateOfBirth: UIDatePicker!
    @IBOutlet weak var txtHeight: UITextField!
    @IBOutlet weak var btnSave: UIButton!
    
    var email: String?
    var user: UserModel?

    override func viewDidLoad() {
        super.viewDidLoad()

        email = UserDefaults.standard.string(forKey: "user_email")
        if let email = email {
            print(" Fetched email from UserDefaults: \(email)")
            user = DatabaseHelper.shared.fetchUser(byEmail: email)
            setupUI()
        } else {
            print(" No user email found in UserDefaults")
        }
    }

    private func setupUI() {
        guard let user = user else {
            print(" User not found in database")
            return
        }

        print(" Loaded User: \(user.firstName) \(user.lastName) | Gender: \(user.gender) | DOB: \(user.dateOfBirth)")

        txtFirstname.text = user.firstName
        txtLastname.text = user.lastName
        txtHeight.text = user.height > 0 ? "\(user.height)" : ""

        let dobString = user.dateOfBirth
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        if let date = dateFormatter.date(from: dobString) {
            dateOfBirth.date = date
        }
        dateOfBirth.tintColor = .white // Works for some iOS versions

        // Force set the text color to white
        dateOfBirth.setValue(UIColor.white, forKey: "textColor")

        // If using a dark background, also set background color (optional)
        dateOfBirth.backgroundColor = .white

        genderSelection(gender: user.gender)
    }

    enum Gender {
        case Male, Female
    }

    var selectedGender: Gender?

    private func genderSelection(gender: String) {
        if gender == "Male" {
            selectedGender = .Male
        } else if gender == "Female" {
            selectedGender = .Female
        }

        updateGenderButtons()
    }

    private func updateGenderButtons() {
        btnGenderMale.setImage(
            UIImage(systemName: selectedGender == .Male ? "largecircle.fill.circle" : "circle"),
            for: .normal
        )
        
        btnGenderFemale.setImage(
            UIImage(systemName: selectedGender == .Female ? "largecircle.fill.circle" : "circle"),
            for: .normal
        )
    }

    @IBAction func onGenderMaleClick(_ sender: UIButton) {
        genderSelection(gender: "Male")
    }

    @IBAction func onGenderFemaleClick(_ sender: UIButton) {
        genderSelection(gender: "Female")
    }


    @IBAction func onSaveBtnClick(_ sender: UIButton) {
        guard let userEmail = email,
              let firstName = txtFirstname.text, !firstName.isEmpty,
              let lastName = txtLastname.text, !lastName.isEmpty,
              let gender = user?.gender, !gender.isEmpty
        else {
            print(" Validation failed: Missing required fields")
            showAlert(title: "Error", message: "Please fill all required fields.")
            return
        }

        let height = Double(txtHeight.text ?? "0") ?? 0
        let dobString = formatDateToString(dateOfBirth.date)

        btnSave.setTitle("Saving...", for: .normal)

        DispatchQueue.global(qos: .userInitiated).async {
            let success = DatabaseHelper.shared.updateUser(email: userEmail, firstName: firstName, lastName: lastName, gender: gender, dateOfBirth: dobString, height: height)

            DispatchQueue.main.async {
                self.btnSave.setTitle("Save", for: .normal)

                if success {
                    print(" User data updated successfully in database")
                    self.showAlert(title: "Status", message: "Your data was saved successfully")
                } else {
                    print(" Failed to update user data")
                    self.showAlert(title: "Error", message: "Failed to update user data.")
                }
            }
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func formatDateToString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
