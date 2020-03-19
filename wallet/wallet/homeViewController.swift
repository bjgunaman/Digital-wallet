//
//  loginViewController.swift
//  wallet
//
//  Created by Brandon Jones Gunaman on 10/18/19.
//  Copyright © 2019 Brandon Jones Gunaman. All rights reserved.
//

import UIKit

class homeViewController: UIViewController , UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate{
    
    @IBOutlet var addAccount: UIButton!
    @IBOutlet var accountsDisplay: UITableView!
    @IBOutlet var totalAmt: UILabel!
    @IBOutlet var userName: UITextField!
    var tempAccount = Account()
    var sentIndex: Int = 0
    var wallet = Wallet()
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.accountsDisplay.dataSource = self
        self.accountsDisplay.delegate = self
        self.userName.delegate = self
        print("Bye")
        Api.user { response, error in
            //taking in response
            guard let responseVar = response else {
                print("response is nil")
                return
            }
            //init wallet
            self.wallet = Wallet.init(data: responseVar, ifGenerateAccounts :false)
            
            //formatting and setting totalAmt text
            let stringTotalAmount  = String(format: "%0.02f",self.wallet.totalAmount)
            self.totalAmt.text = "Total Amount: $\(stringTotalAmount)"
            
            //checking if wallet has a username
            if let username = self.wallet.userName {
                self.userName.text = username
            } else {
                self.userName.text = self.wallet.phoneNumber
            }
            
            //reloading table view
            self.accountsDisplay.reloadData();
            self.accountsDisplay.isUserInteractionEnabled = true
        }
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false

        view.addGestureRecognizer(tap)

        // Do any additional setup after loading the view.
    }
    //updating username
    @IBAction func updateUserName(_ sender: Any) {
        //checking if username is valid
        guard let newName = userName.text else {
            print("new name wrong")
            return
        }
        //setting name in api
        Api.setName(name: newName) { response, error in
            if let errorCode = error?.code {
                print("error in setname: \(errorCode)")
                return
            }
        }
        return
    }
    //MARK: textField delegate implementation
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true 
    }
    //MARK: table view data source implementation
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.wallet.accounts.count
    }
      
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //setting up each cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .default, reuseIdentifier: "cell")
        let name = wallet.accounts[indexPath.row].name
        let amount =  String(format: "%0.02f",wallet.accounts[indexPath.row].amount)
        cell.textLabel?.text = "\(name) : $\(amount)"
        return cell
    }
    
    //logging out
    @IBAction func logoutAction(_ sender: Any) {
        //segue to login view
        self.performSegue(withIdentifier: "unwindToLoginView", sender: self)
    }
    
    //segueing to account verfication view controller
    func segueToAccount(account: Account) {
        print("indexPath")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "accountViewController")
        let verifyCode = vc as! accountViewController
        self.navigationController?.pushViewController(verifyCode,animated: true)
    }
    
    //MARK: table view delegate implementation
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        sentIndex = indexPath.row
        self.performSegue(withIdentifier: "accountSegue", sender: self)
        
    }
    
    // to send variables from the current view controller to the next
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "accountSegue" {
            if let destinationVC = segue.destination as? accountViewController {
                destinationVC.index = self.sentIndex
                destinationVC.wallet = self.wallet
                destinationVC.updateAccountView = updateAccountView
            }
        } 
    }

    //pop up for add account
    @IBAction func addingAccountPopUp(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "accNamePopUp")
        let popUpVc = vc as! accPopUpViewController
        popUpVc.wallet = self.wallet
        popUpVc.updateAccountView = updateAccountView
        self.addChild(popUpVc)
        popUpVc.view.frame = self.view.frame
        self.view.addSubview(popUpVc.view)
        popUpVc.didMove(toParent: self)
        

    }
    //callback function to reload table view and total amount after account data is changed
    func updateAccountView() -> () {
        print("Called")
        totalAmt.text = "Total Amount: $\(String(format: "%0.02f", self.wallet.totalAmount))"
        accountsDisplay.reloadData()
    }
}
