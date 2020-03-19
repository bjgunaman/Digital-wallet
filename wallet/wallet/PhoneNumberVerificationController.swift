//
//  PhoneNumberVerificationController.swift
//  wallet
//
//  Created by Brandon Jones Gunaman on 10/6/19.
//  Copyright © 2019 Brandon Jones Gunaman. All rights reserved.
//

import UIKit
import PhoneNumberKit

class PhoneNumberVerificationController: UIViewController{

    @IBOutlet var sendVerification: UIButton!
    @IBOutlet var instruction: UILabel! //instruction label
    @IBOutlet var phoneNumberField: PhoneNumberTextField! //phonenumber input text field
    @IBOutlet var isNumberValidMessage: UILabel! //displays error message
    var formattedNumber: String = ""
    @IBOutlet var loadingIndicator: UIActivityIndicatorView!

    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //hide activity indicator
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.stopAnimating()
        prefill()
        //handles tapping anywhere to dismiss keyboard
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action: #selector(dismissKeyboard))

        view.addGestureRecognizer(tap)
    }
    //for logout
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {

    }
    //prefill
    func prefill() {
        guard let formattedNumber = Storage.phoneNumberInE164 else {
            print("no number in storage")
            return
        }
        let mySubstring = formattedNumber.suffix(10)
        phoneNumberField.text = String(mySubstring)
        return
    }
    
    //function to segue to verificationCodeViewController
    func segueToVerify() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "verificationViewController")
        let verifyCode = vc as! verificationCodeViewController
        verifyCode.formattedNumber = self.formattedNumber
        self.navigationController?.pushViewController(verifyCode, animated: true)
    }
    //disabling user interaction
    func disableUserInteraction() {
        phoneNumberField.isUserInteractionEnabled = false
        sendVerification.isUserInteractionEnabled = false
        
    }
    //enabling user interaction
    func enableUserInteraction() {
        phoneNumberField.isUserInteractionEnabled = true
        sendVerification.isUserInteractionEnabled = true
    }
    
    //controls activity indicator
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
    

    //handles action where user presses the "send verification" button
    //validates number input, stores them and displays the appropriate message
    @IBAction func submitNumber() {
        let phoneNumberKit = PhoneNumberKit()
        //validates input number
        do {
            let inputNumber: String = phoneNumberField.text ?? " "
            var constant = 0 //stores number of non numeric characters
            //checks if input  number is empty
            
            if inputNumber == "" {
                isNumberValidMessage.textColor = UIColor.red
                isNumberValidMessage.text = "Input Field is Empty"
                return
            }
            //checks if input number is too long or too shorti
            if(inputNumber.count != 14) {
                if(inputNumber.contains("(")) {
                    constant+=1
                }
                if(inputNumber.contains(")")) {
                    constant+=1
                }
                if(inputNumber.contains("-")) {
                    constant+=1
                }
                if(inputNumber.contains(" ")) {
                    constant+=1
                }
                if inputNumber.count - constant > 10 {
                    isNumberValidMessage.textColor = UIColor.red
                    isNumberValidMessage.text = "Number Input Too Long"
                    return
                }
                else {
                    isNumberValidMessage.textColor = UIColor.red
                    isNumberValidMessage.text = "Number Input Too Short"
                    return
                    
                }
            }
            let phoneNumber = try phoneNumberKit.parse(inputNumber, withRegion: "US")
            self.formattedNumber = phoneNumberKit.format(phoneNumber, toType: .e164)
            // sending verification code
            loadingAnimation()
            if Storage.authToken != nil, Storage.phoneNumberInE164 == self.formattedNumber {
                // This user is the last successfully logged in user.
                self.performSegue(withIdentifier: "homeSegue", sender: nil)
                loadingAnimation()
                return
            }
            Api.sendVerificationCode(phoneNumber: self.formattedNumber) { response, error in
                //if there is an error
                if let errorCode = error?.code, let errorMessage = error?.message {
                    if errorCode == "invalid_phone_number" || errorCode == "incorrect_code" || errorCode == "code_expired" {
                        self.isNumberValidMessage.text = errorMessage
                        self.loadingAnimation()
                        return
                    } else if errorCode == "codes_sent_rate_limit"  {
                        self.isNumberValidMessage.text = "Sent 5 times limit reached. Try again tomorrow"
                        self.loadingAnimation()
                        return
                    } else {
                        self.isNumberValidMessage.text = "Error Processing Code"
                        self.loadingAnimation()
                    }

                } else {
                    self.isNumberValidMessage.textColor = UIColor.green
                    self.isNumberValidMessage.text = "Verification code sent to: \(self.formattedNumber)"
                    self.segueToVerify()
                    self.loadingAnimation()
                   
                }
                
            }
        } catch {
            print("Generic parser error")
            isNumberValidMessage.textColor = UIColor.red
            isNumberValidMessage.text = "Number is Invalid"
            
        }
    }
    
    
    
    
}

