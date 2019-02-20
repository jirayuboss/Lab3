//
//  RegisterViewController.swift
//  JiraSnap
//
//  Created by Jirayu Promsongwong on 20/2/2562 BE.
//  Copyright © 2562 KMITL. All rights reserved.
//

import UIKit

import UIKit

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repeatpasswordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        
        let myActivityIndecator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
        
        myActivityIndecator.center = view.center
        
        myActivityIndecator.hidesWhenStopped = false
        
        myActivityIndecator.startAnimating()
        view.addSubview(myActivityIndecator)
        
        let myUrl = URL(string: "http://35.202.48.146:5000/")
        var request = URLRequest(url: myUrl!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let postString = ["username": userNameTextField.text!,
                          "password": passwordTextField.text!,
                          "email": emailTextField.text!,
                          "name": nameTextField.text!,
                          "phone":phoneTextField.text!] as [String:String]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: postString, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
            displayMessage(userMessage: "Something went wrong. Try again.", alertMessage: "")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            self.removeActivityIndicator(activityIndicator: myActivityIndecator)
            if error != nil
            {
                self.displayMessage(userMessage: "Could not successfully perform this request. Please try again later", alertMessage: "")
                print("error=\(String(describing: error))")
                return
            }
        }
        task.resume()
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        print("cancelButton clicked.")
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func registerButton(_ sender: Any) {
        let providedEmailAddress = emailTextField.text
        let providedPhone = phoneTextField.text
        let phone_count = phoneTextField.text?.count
        let count_user = userNameTextField.text?.count
        let char_user = userNameTextField.text
        let count_pass = passwordTextField.text?.count
        let char_pass = passwordTextField.text
        let characterset = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
        let char_repeatpass = repeatpasswordTextField.text
        
        if (userNameTextField.text?.isEmpty)! || (passwordTextField.text?.isEmpty)! || (repeatpasswordTextField.text?.isEmpty)! || (emailTextField.text?.isEmpty)! ||
            (nameTextField.text?.isEmpty)! || (phoneTextField.text?.isEmpty)!
        {
            displayMessage(userMessage: "All fields are required to fill in", alertMessage: "")
            return
        }
            
        else if char_user!.rangeOfCharacter(from: characterset.inverted) != nil {
            displayMessage(userMessage: "Change your username",alertMessage: "Username contains special alphabet.")
            return
        }
            
        else if char_pass!.rangeOfCharacter(from: characterset.inverted) != nil {
            displayMessage(userMessage: "Change your password",alertMessage: "Password contains special alphabet.")
            return
        }
            
        else if (count_user! > 16 || count_user! < 8) {
            displayMessage(userMessage: "Change your username",alertMessage: "Username length should be 8-16 characters.")
            return
        }
            
        else if (count_pass! > 16 || count_pass! < 8 ){
            displayMessage(userMessage: "Change your password",alertMessage: "Password length should be 8-16 characters.")
            return
        }
            
        else if (phone_count! < 12){
            displayMessage(userMessage: "Change your phone number",alertMessage: "Incorrect phone number")
            return
        }
            
        else if
            (char_pass! != char_repeatpass!)
        {
            displayMessage(userMessage: "", alertMessage: "Repeat password not match")
            return
        }
            
            //        Email
        else if (isValidEmail(testStr: providedEmailAddress!) == false)
        {
            displayMessage(userMessage: "Please change your email.", alertMessage: "Email address is not valid.")
            return
        }
            
            //        Phone
        else if (validate(value: providedPhone!) == false)
        {
            displayMessage(userMessage: "Please change your phone number", alertMessage: "Phone is not valid.")
            return
        }
            
        else{
            checkEmail(email: providedEmailAddress!,username: char_user!)
        }
    }
    
    func isValidEmail(testStr:String) -> Bool {
        print("validate emilId: \(testStr)")
        let emailRegEx = "^(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?(?:(?:(?:[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+(?:\\.[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+)*)|(?:\"(?:(?:(?:(?: )*(?:(?:[!#-Z^-~]|\\[|\\])|(?:\\\\(?:\\t|[ -~]))))+(?: )*)|(?: )+)\"))(?:@)(?:(?:(?:[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)(?:\\.[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)*)|(?:\\[(?:(?:(?:(?:(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))\\.){3}(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))))|(?:(?:(?: )*[!-Z^-~])*(?: )*)|(?:[Vv][0-9A-Fa-f]+\\.[-A-Za-z0-9._~!$&'()*+,;=:]+))\\])))(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluate(with: testStr)
        return result
    }
    
    func validate(value: String) -> Bool {
        let PHONE_REGEX = "^((\\+)|(00))[0-9]{6,14}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        let result =  phoneTest.evaluate(with: value)
        return result
    }
    
    private func checkEmail(email:String, username:String) {
        
        let usernameText = userNameTextField.text
        let passwordText = passwordTextField.text
        let emailText = emailTextField.text
        let nameText = nameTextField.text
        let phoneText = phoneTextField.text
        let myActivityIndecator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
        
        let url = URL(string: "http://35.202.48.146:5000/check/\(email)/\(username)")! //change the url
        
        //create the session object
        let session = URLSession.shared
        
        //now create the URLRequest object using the url object
        let request = URLRequest(url: url)
        
        //create dataTask using the session object to send data to the server
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            guard error == nil else {
                return
            }
            
            guard let data = data else {
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Int]
                let validation_email = json?["validation_email"]
                let validation_username = json?["validation_username"]
                //create json object from data
                self.removeActivityIndicator(activityIndicator: myActivityIndecator)
                
                if error != nil
                {
                    self.displayMessage(userMessage: "Could not successfully perform this request. Ples try again later", alertMessage: "")
                    print("error=\(String(describing: error))")
                    return
                }
                else if ( validation_username! == 1){
                    self.displayMessage(userMessage: "Please change your username", alertMessage: "Username is valid.")
                    return
                }
                    
                else if ( validation_email! == 1 ){
                    self.displayMessage(userMessage: "Please change your email", alertMessage: "Email is valid.")
                    return
                }
                else{
                    self.registration(username: usernameText!, password: passwordText!, email: emailText!, name: nameText!, phone: phoneText!)
                }
            } catch let error {
                print(error.localizedDescription)
            }
        })
        task.resume()
    }
    
    private func registration(username:String, password:String, email:String, name:String, phone:String) {
        //create the url with NSURL
        
        let url = URL(string: "http://35.202.48.146:5000/\(username)/\(password)/\(email)/\(name)/\(phone)")! //change the url
        
        //create the session object
        let session = URLSession.shared
        
        //now create the URLRequest object using the url object
        let request = URLRequest(url: url)
        
        //create dataTask using the session object to send data to the server
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            guard error == nil else {
                return
            }
            
            guard let data = data else {
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Int]
                let status = json?["status"]
                if (status! == 1){
                    self.displayMessageCorrect(userMessage: "Press OK to go to login page.", alertMessage: "Register success.")
                }
                
            } catch let error {
                print(error.localizedDescription)
            }
        })
        task.resume()
    }
    
    func displayMessage(userMessage:String,alertMessage:String) -> Void {
        DispatchQueue.main.async
            {
                let alertControl = UIAlertController(title: alertMessage, message: userMessage, preferredStyle: .alert)
                
                let OKAction = UIAlertAction(title: "OK", style: .default){(action:UIAlertAction!) in
                    print("OK button tapped")
                    DispatchQueue.main.async {
                    }
                }
                alertControl.addAction(OKAction)
                self.present(alertControl, animated: true, completion: nil)
        }
    }
    
    func displayMessageCorrect(userMessage:String,alertMessage:String) -> Void {
        DispatchQueue.main.async
            {
                let alertControl = UIAlertController(title: alertMessage, message: userMessage, preferredStyle: .alert)
                
                let OKAction = UIAlertAction(title: "OK", style: .default){(action:UIAlertAction!) in
                    print("OK button tapped")
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "LoginPage", sender: self)
                    }
                }
                alertControl.addAction(OKAction)
                self.present(alertControl, animated: true, completion: nil)
        }
    }
    
    func removeActivityIndicator(activityIndicator: UIActivityIndicatorView)
    {
        DispatchQueue.main.async {
            activityIndicator.stopAnimating()
            activityIndicator.removeFromSuperview()
        }
    }
}


extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer =     UITapGestureRecognizer(target: self, action:    #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
}
