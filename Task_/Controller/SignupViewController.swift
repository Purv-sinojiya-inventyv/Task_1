import UIKit

class SignupViewController: UIViewController {
    
    @IBOutlet weak var txtFirstname: UILabel!
  
   
    @IBOutlet weak var txtLastname: UITextField!
    
    @IBOutlet weak var btnGender: UIButton!
    @IBOutlet weak var dateOfBirth: UIDatePicker!
   
    @IBOutlet weak var txtHeight: UITextField!
   
    @IBOutlet weak var btnSave: UIButton!
    
    
    
    var dob: String?
    var firstName: String?
    var lastName: String?
    var gender: String?
    var height: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        formatDate()
    }
    
    private func formatDate(){
        if let firstName = firstName{
            txtFirstname.text = firstName
        }
        
        if let lastName = lastName{
            txtLastname.text = lastName
        }
        
        if let gender = gender{
            btnGender.setTitle(gender, for: .normal)
        }
        if let height = height{
            txtHeight.text = String(height)
        }
        
        if let dobString = self.dob {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            
            if let date = dateFormatter.date(from: dobString) {
                dateOfBirth.date = date
            }
        }
    }
    
    @IBAction func onGenderBtnClick(_ sender: UIAction) {
        btnGender.setTitle(sender.title, for: .normal)
    }
    
    @IBAction func onSaveBtnClick(_ sender: UIButton) {
        guard let firstName = txtFirstname.text, !firstName.isEmpty,
              let lastName = txtLastname.text, !lastName.isEmpty,
              let gender = btnGender.titleLabel?.text,
              let height = Double(txtHeight.text ?? "") else {
            print("Validation failed: Missing required fields")
            return
        }
        
        let dob = dateOfBirth.date
        let dobString = formatDateToString(dob)
        
     
        
        btnSave.titleLabel?.text = "Saving..."
        
        if DatabaseHelper.shared.insertUser(firstName: firstName, lastName: lastName, gender: gender, dateOfBirth: dobString, height:height ){
            print("Success")
            handleSuccess()
            DatabaseHelper.shared.fetchAllUsers()
        }
    }
    
    private func handleSuccess(){
        DispatchQueue.main.async {
            self.btnSave.titleLabel?.text = "Save"
            let alert = UIAlertController(title: "Status", message: "Your data saved successfully", preferredStyle: .alert)
            let cancelBtn = UIAlertAction(title: "Cancel", style: .cancel)
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
