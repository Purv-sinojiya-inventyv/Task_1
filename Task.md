# Assignment 1 - iOS App

## Overview

This iOS application includes functionalities for **User Login**, **Fetching Data from an API**, and **User Signup** using **Swift** and **SQLite**.

## Features

- **User Login**: Validate user credentials and fetch data from an API.
- **Fetch Data from API**: Calls an API to authenticate users.
- **User Signup**: Allows users to register and store data in an SQLite database.

---

##  Getting Started

### Prerequisites

- Xcode
- iOS Device/Simulator
- Swift
- SQLite.swift (for database management)

### Installation

1. Clone the repository:
    
    ```sh
    git clone https://github.com/Purv-sinojiya-inventyv/Task_1.git
    ```
    
2. Open the project in Xcode.
3. Build and run the app on a simulator or device.

---

## Login Page

### Description

- Users enter their **Email** and **Password**.
- Validates user input.
- Calls an API to authenticate the user.
- If successful, navigates to the next screen.

### Code Flow

1. **Validate Email & Password**
2. **Check API Response**
3. **Navigate to Next Screen on Success**

### Example API Call (Inside `ViewController.swift`)

```swift
Task {
    await fetchData(user: user) { result in
        switch result {
        case .success(let responseData):
            DispatchQueue.main.async {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let signupVC = storyboard.instantiateViewController(withIdentifier: "SignupViewController") as? SignupViewController {
                    self.navigationController?.pushViewController(signupVC, animated: true)
                }
            }
        case .failure(let error):
            DispatchQueue.main.async {
                self.showError("Failed to fetch data: \(error.localizedDescription)")
            }
        }
    }
}
```

---

## Fetch Data from API

### API Endpoint Example

The app sends a request with user credentials and fetches a response.

```swift
let user = UserModel(
    userName: email,
    password: password,
    softwareType: "AN",
    releaseVersion: "049"
)
```

---

## Signup Page

### Description

- Allows users to **register** by entering their **First Name, Last Name, Gender, Date of Birth, and Height**.
- Saves the data into an **SQLite database**.

### SQLite Database Setup

```swift
let createTableQuery = """
CREATE TABLE IF NOT EXISTS Users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    firstName TEXT NOT NULL,
    lastName TEXT NOT NULL,
    gender TEXT DEFAULT 'Not Specified',
    dob TEXT NOT NULL,
    height TEXT NOT NULL
);
"""
```

---

