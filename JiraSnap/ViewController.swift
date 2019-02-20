//
//  ViewController.swift
//  JiraSnap
//
//  Created by Jirayu Promsongwong on 20/2/2562 BE.
//  Copyright © 2562 KMITL. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBAction func loginButton(_ sender: Any) {
        let characterset = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
        
        let char_user = usernameTextField.text
        let count_user = usernameTextField.text?.count
        let char_pass = passwordTextField.text
        let count_pass = passwordTextField.text?.count
        
        if ((usernameTextField.text?.isEmpty)! || (passwordTextField.text?.isEmpty)!)
        {
            displayMessage(userMessage: "Please fill in your username and password.", alertMessage: "")
            return
        }
            
        else if (char_user!.rangeOfCharacter(from: characterset.inverted)) != nil {
            displayMessage(userMessage: "Change your username",alertMessage: "Username contains special alphabet.")
            return
        }
            
        else if (char_pass!.rangeOfCharacter(from: characterset.inverted)) != nil {
            displayMessage(userMessage: "Change your password",alertMessage: "Password contains special alphabet.")
            return
        }
            
        else if (count_user! > 16 || count_user! < 8 ){
            displayMessage(userMessage: "Change your username",alertMessage: "Username length should be 8-16 characters.")
            return
        }
            
        else if (count_pass! > 16 || count_pass! < 8 ){
            displayMessage(userMessage: "Change your password",alertMessage: "Password length should be 8-16 characters.")
            return
        }
            
        else{
            checkValidation()
        }
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
                        self.performSegue(withIdentifier: "Homepage", sender: self)
                    }
                }
                alertControl.addAction(OKAction)
                self.present(alertControl, animated: true, completion: nil)
        }
    }
    
    private func httpRequest() {
        
        //create the url with NSURL
        let url = URL(string: "http://35.202.48.146:5000/allusernames")! //change the url
        
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
                //create json object from data
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    print(json)
                }
            } catch let error {
                print(error.localizedDescription)
            }
        })
        task.resume()
    }
    
    private func checkValidation() {
        let usernameText = usernameTextField.text
        let passwordText = passwordTextField.text
        //create the url with NSURL
        
        let url = URL(string: "http://35.202.48.146:5000/checkuser/\(usernameText!)/\(passwordText!)")! //change the url
        
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
                let validation = json?["validation"]
                print(validation!)
                //create json object from data
                if ( validation! >= 1 ){
                    self.displayMessageCorrect(userMessage: "Press OK to move to Homepage.", alertMessage: "Login Success.")
                    CommonValues.Username = usernameText!
                }
                else{
                    self.displayMessage(userMessage: "Incorrect username or password",alertMessage: "Login failed.")
                    return
                }
            } catch let error {
                print(error.localizedDescription)
            }
        })
        task.resume()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
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
        
        let postString = ["username": usernameTextField.text!,]
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
                self.displayMessage(userMessage: "Could not successfully perform this request. Ples try again later", alertMessage: "")
                print("error=\(String(describing: error))")
                return
            }
        }
        task.resume()
    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated) // No need for semicolon
        
    }
    
    func removeActivityIndicator(activityIndicator: UIActivityIndicatorView)
    {
        DispatchQueue.main.async {
            activityIndicator.stopAnimating()
            activityIndicator.removeFromSuperview()
        }
    }
    
}

struct CommonValues {
    static var Username: String = ""
}

