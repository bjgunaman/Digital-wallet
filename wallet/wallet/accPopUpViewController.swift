//
//  accPopUpViewController.swift
//  wallet
//
//  Created by Brandon Jones Gunaman on 11/1/19.
//  Copyright © 2019 Brandon Jones Gunaman. All rights reserved.
//

import UIKit

class accPopUpViewController: UIViewController, UITextFieldDelegate{

    @IBOutlet var userMessage: UILabel!
    @IBOutlet var accName: UITextField!
    var wallet = Wallet()
    var updateAccountView:(() -> ())? // callback function to reload table
    var accountName: String = ""
    var counter = 0
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
           view.endEditing(true)
       }
    //checks uniqueness of an account name
    func checkName() -> Bool{
        accountName = accName.text ?? ""
        var accountNumber = wallet.accounts.count + 1
        //if user left textfield empty
        if (accountName == "") {
            accountName = "Account \(accountNumber)"
        }
        //if only one account
        if(accountNumber == 1) {
            return true
        }
        //loop through accounts array to chck for each name
        for i in 0...(wallet.accounts.count - 1) {
            if(accountName == "Account \(accountNumber)") {
                if(accountName == wallet.accounts[i].name) {
                    //check if new account number is unique
                    while(true) {
                        accountNumber = accountNumber + 1
                        accountName = "Account \(accountNumber)"
                        if checkName2(accountName:accountName) == true {
                            break
                        }
                    }
                }
                
            }
            //check if accountname is unique
            if(accountName == wallet.accounts[i].name) {
                userMessage.text = "Name not unique. Try again"
                return false
            }
        }
        return true
        
    }
    //checks account name for uniqueness
    func checkName2(accountName: String) -> Bool{
        for i in 0...wallet.accounts.count - 1 {
            if accountName == wallet.accounts[i].name {
                return false
            }
        }
        return true
    }
    
    //MARK: implementation of textfield delegate protocol
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        accName.resignFirstResponder()
        return true
    }

    //release pop up after user pressesn done
    @IBAction func releasePopUp(_ sender: Any) {
        //if name not unique
        if(!checkName()) {
            return
        }
        Api.addNewAccount(wallet: wallet, newAccountName: accountName) {
            response, error in
            if let errorCode = error?.code {
                print("error in addNewAccountPopUp: \(errorCode)")
            }
    
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(identifier: "homeViewController")
            let homeVc = vc as! homeViewController
            homeVc.wallet = self.wallet
            self.updateAccountView?()
        
            self.view.removeFromSuperview()
        }
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
