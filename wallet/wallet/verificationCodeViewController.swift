//
//  verificationCodeViewController.swift
//  wallet
//
//  Created by Brandon Jones Gunaman on 10/14/19.
//  Copyright © 2019 Brandon Jones Gunaman. All rights reserved.
//

import UIKit

class verificationCodeViewController: UIViewController,PinTextFieldDelegate {
   
    
    var formattedNumber: String = ""

    @IBOutlet var textField1: PinTextField!
    @IBOutlet var textField2: PinTextField!
    @IBOutlet var textField3: PinTextField!
    @IBOutlet var textField4: PinTextField!
    @IBOutlet var textField5: PinTextField!
    @IBOutlet var textField6: PinTextField!
    
    @IBOutlet var responseText: UILabel!
    
    @IBOutlet var loadingIndicator: UIActivityIndicatorView!
    
    @IBOutlet var resendVerificationButton: UIButton!
    @IBOutlet var sentToNumber: UILabel!
    
    var textFieldArr = [UITextField]()
    var index = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //instructions
        self.sentToNumber.textColor = UIColor.green
        self.sentToNumber.text = "Enter the code sent to \(formattedNumber)"
        textFieldArr = [textField1, textField2, textField3, textField4,textField5, textField6]
        //hiding activity indicator
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.stopAnimating()
        //setting text field delgates
        textField1.delegate = self
        textField2.delegate = self
        textField3.delegate = self
        textField4.delegate = self
        textField5.delegate = self
        textField6.delegate = self
        
        textField1.becomeFirstResponder()
        // Do any additional setup after loading the view.
    }
 
    //function to verify code
    func verifyCode() {
        var counter: Int = 0
        //checking if all the textfields are filled in with 1 character
        for i in 0...5 {
            if let inputCode = textFieldArr[i].text {
                if(inputCode.count == 1) {
                    counter += 1
                }
            }
        }
        //if all the textfields are filled in with one character
        if counter == 6 {
            //putting the codes in the textfields together
            let inputCode = textFieldArr.compactMap{$0.text}.reduce(""){$0 + $1}
            //verifying the code
            loadingAnimation()
            Api.verifyCode(phoneNumber: self.formattedNumber, code: inputCode) {response, error in
                //if there is an error(verification failed)
                if let errorCode = error?.code, let errorMessage = error?.message {
                    self.responseText.textColor = UIColor.red
                    if errorCode == "invalid_phone_number" || errorCode == "incorrect_code" || errorCode == "code_expired" {
                        self.responseText.text = errorMessage
                        self.loadingAnimation()
                    } else if errorCode == "codes_sent_rate_limit" {
                        self.responseText.text = "Number Blocked. Too many failed tries"
                        self.loadingAnimation()
                    } else {
                        self.responseText.text = "Error Processing Code"
                        self.loadingAnimation()
                    }
                    
                } else {
                    self.responseText.textColor = UIColor.green
                    self.responseText.text = "Verified"
                    //store phonenymber and auth code in Storage
                    Storage.phoneNumberInE164 = self.formattedNumber
                    Storage.authToken = response?["auth_token"] as? String
                    //segue to loginViewController if verification is success
                    self.performSegue(withIdentifier: "homeSegue", sender: nil)
                    self.loadingAnimation()
                }
            }
        }
    }
    //disabling user interaction for all text fields and buttons
    func disableUserInteraction() {
        textField1.isUserInteractionEnabled = false
        textField2.isUserInteractionEnabled = false
        textField3.isUserInteractionEnabled = false
        textField4.isUserInteractionEnabled = false
        textField5.isUserInteractionEnabled = false
        textField6.isUserInteractionEnabled = false
        resendVerificationButton.isUserInteractionEnabled = false
        
    }
    //enabling user interaction for all text fields and buttons
    func enableUserInteraction() {
        textField1.isUserInteractionEnabled = true
        textField2.isUserInteractionEnabled = true
        textField3.isUserInteractionEnabled = true
        textField4.isUserInteractionEnabled = true
        textField5.isUserInteractionEnabled = true
        textField6.isUserInteractionEnabled = true
        resendVerificationButton.isUserInteractionEnabled = true
    }
    
    /*
     controls activity indicator
     hides and stops animating if activity indicator was not hidden and animating
     makes tha indicator animate and appear if indicator was hidden and not animating
    */
    func loadingAnimation() {
        if loadingIndicator.isAnimating == true {
            loadingIndicator.isHidden = true
            loadingIndicator.stopAnimating()
            enableUserInteraction()
        } else {
            loadingIndicator.isHidden = false
            loadingIndicator.startAnimating()
            disableUserInteraction()
        }
    }
    
    /*
        disables all text fields other than what the user is on
        user's text field index is indicated by position
    */
    func disablingTextfields(_ position: Int) {
        for i in 0...5 {
            if(i != position) {
                textFieldArr[i].isUserInteractionEnabled = false
            }
            
        }
        textFieldArr[position].isUserInteractionEnabled = true
    }
    
    //associate the disablingTextFields function with all the textfields
    @IBAction func disableTextField(_ sender: Any) {
        disablingTextfields(index)
        
    }
    //if input is more than once character
    func inputTooLong(_ userInput:String) -> Bool {
        let position = userInput.index(userInput.startIndex, offsetBy: 1)
        let mySubstring = userInput[..<position]
        let displayString = String(mySubstring)
        //just display the first character of the string
        textFieldArr[index].text = displayString
        
        //filling in next textfield if not last textfield
        if(index < 5) {
            index += 1
            disablingTextfields(index)
            textFieldArr[index].becomeFirstResponder()
            
            return true
        }
        return false
    }
    
    //switching from text field to text field if text field gets field
    @IBAction func textFieldChanged() {
        let userInput = textFieldArr[index].text ?? ""
        //checking user count
        if userInput.count >= 1 {
            //making sure that text field has only length of one
            if(userInput.count >= 2) {
                let position = userInput.index(userInput.startIndex, offsetBy: 1)
                let mySubstring = userInput[..<position]
                let displayString = String(mySubstring)
                //just display the first character of the string
                textFieldArr[index].text = displayString
                if(index + 1 <= 5) {
                    textFieldArr[index + 1].text = String(userInput[position])
                }
            }
            
            //if at textfield 6 don't change text fields
            if(index < 5) {
                index += 1
                disablingTextfields(index)
                //switch to textfield in front of it
                textFieldArr[index].becomeFirstResponder()
            }
            
        }
        //if we are at the last textfield verify the code
        if(index == 5) {
            verifyCode()
        }
        
    }
    //resend verification code when "resend code" button is pressed
    @IBAction func resendCode(_ sender: Any) {
        loadingAnimation()
        //resend verification code to same number as inserted in the phoneNumberView Controller
        Api.sendVerificationCode(phoneNumber: self.formattedNumber) { response, error in
            //if there is an errror
            if let errorCode = error?.code, let errorMessage = error?.message {
                self.responseText.textColor = UIColor.red
                if errorCode == "invalid_phone_number" || errorCode == "incorrect_code" || errorCode == "code_expired" {
                    self.responseText.text = errorMessage
                    self.loadingAnimation()
                    return
                } else if errorCode == "codes_sent_rate_limit" {
                    self.responseText.text = "Sent 5 times limit reached. Try again tomorrow"
                    self.loadingAnimation()
                    print(errorMessage)
                    return
                } else {
                    self.responseText.text = "Error Processing Code"
                    self.loadingAnimation()
                }
            } else {
                //if sending is successful
                self.sentToNumber.textColor = UIColor.green
                self.sentToNumber.text = "Code resent to \(self.formattedNumber)"
                self.loadingAnimation()
            }
        }
    }
    // MARK: protocol implementation for PinTextField
    //implementing backspace action
    func didPressBackspace(textField: PinTextField) {
       let inputText = textField.text ?? ""
       //if current text field not filled
       if inputText.count > 0 {
           //only delete current text
           textField.text = ""
           return
       } else {
           //else delete previous text
           if index > 0 {
               index -= 1
           }
           disablingTextfields(index)
           textFieldArr[index].becomeFirstResponder()
           textFieldArr[index].text = ""
           return
       }
    }
}
