import UIKit

class SignupViewController: UIViewController {
    
    @IBOutlet weak var txtFirstname: UILabel!
    @IBOutlet weak var txtLastname: UITextField!
    @IBOutlet weak var btnGenderMale: UIButton!
    @IBOutlet weak var btnGenderFemale: UIButton!
    @IBOutlet weak var dateOfBirth: UIDatePicker!
    @IBOutlet weak var txtHeight: UITextField!
    @IBOutlet weak var btnSave: UIButton!
    
    var email: String?
    var password: String?
    var dob: String?
    var firstName: String?
    var lastName: String?
    var gender: String? // "Male" or "Female"
    var height: Double?

    override func viewDidLoad() {
        super.viewDidLoad()

        print("📝 SignupViewController Loaded")
        print("   - First Name: \(firstName ?? "❌ Missing")")
        print("   - Last Name: \(lastName ?? "❌ Missing")")
        print("   - DOB: \(dob ?? "❌ Missing")")
        print("   - Gender: \(gender ?? "❌ Missing")")
        print("   - Height: \(height ?? 0) cm")

        setupUI()
        retrieveUserDefaults()
    }

    private func setupUI() {
        txtFirstname.text = firstName ?? "Unknown"
        txtLastname.text = lastName
        txtHeight.text = height != nil ? "\(height!)" : ""

        if let dobString = dob, !dobString.isEmpty {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            if let date = dateFormatter.date(from: dobString) {
                dateOfBirth.date = date
            }
        }
        
        updateGenderSelection()
    }

    private func retrieveUserDefaults() {
        if email == nil {
            email = UserDefaults.standard.string(forKey: "user_email")
        }
        if password == nil {
            password = UserDefaults.standard.string(forKey: "user_password")
        }
    }

    private func updateGenderSelection() {
        if gender == "Male" {
            btnGenderMale.backgroundColor = .blue
            btnGenderMale.setTitleColor(.white, for: .normal)
            btnGenderFemale.backgroundColor = .clear
            btnGenderFemale.setTitleColor(.black, for: .normal)
        } else if gender == "Female" {
            btnGenderFemale.backgroundColor = .blue
            btnGenderFemale.setTitleColor(.white, for: .normal)
            btnGenderMale.backgroundColor = .clear
            btnGenderMale.setTitleColor(.black, for: .normal)
        }
    }

    @IBAction func onGenderMaleClick(_ sender: UIButton) {
        gender = "Male"
        updateGenderSelection()
    }

    @IBAction func onGenderFemaleClick(_ sender: UIButton) {
        gender = "Female"
        updateGenderSelection()
    }

    @IBAction func onSaveBtnClick(_ sender: UIButton) {
        guard let firstName = txtFirstname.text, !firstName.isEmpty,
              let lastName = txtLastname.text, !lastName.isEmpty,
              let gender = gender, !gender.isEmpty,
              let height = Double(txtHeight.text ?? ""),
              let userEmail = email,
              let userPassword = password
        else {
            print("❌ Validation failed: Missing required fields")
            return
        }

        let dob = dateOfBirth.date
        let dobString = formatDateToString(dob)

        btnSave.setTitle("Saving...", for: .normal)

        if DatabaseHelper.shared.insertUser(email: userEmail, password: userPassword, firstName: firstName, lastName: lastName, gender: gender, dateOfBirth: dobString, height: height) {
            print("✅ Success: User data saved")
            handleSuccess()
            DatabaseHelper.shared.fetchAllUsers()
        } else {
            print("❌ Failed to insert user data")
        }
    }

    private func handleSuccess() {
        DispatchQueue.main.async {
            self.btnSave.setTitle("Save", for: .normal)
            let alert = UIAlertController(title: "Status", message: "Your data was saved successfully", preferredStyle: .alert)
            let cancelBtn = UIAlertAction(title: "OK", style: .default)
            alert.addAction(cancelBtn)
            self.present(alert, animated: true)
        }
    }

    func formatDateToString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
