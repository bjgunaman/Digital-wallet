//
//  accountViewController.swift
//  wallet
//
//  Created by Brandon Jones Gunaman on 11/1/19.
//  Copyright © 2019 Brandon Jones Gunaman. All rights reserved.
//

import UIKit

class accountViewController: UIViewController {
    
    @IBOutlet var accountName: UILabel!
    var wallet = Wallet()
    var index: Int = 0
    var updateAccountView:(() -> ())?
    @IBOutlet var amountDisplay: UILabel!
   
    @IBOutlet var withdrawButton: UIButton!
    @IBOutlet var transferButton: UIButton!
    @IBOutlet var deleteButton: UIButton!
    @IBOutlet var depositButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reloadView()
        
        // Do any additional setup after loading the view.
    }
    //reloads the account amount after update
    func reloadView() {
        accountName.text = wallet.accounts[index].name
        let amount = String(format: "%0.02f",wallet.accounts[index].amount)
        amountDisplay.text = "$\(amount)"
    }
    
    //disabling buttons
    func disableButtons() {
        withdrawButton.isUserInteractionEnabled = false
        depositButton.isUserInteractionEnabled = false
        transferButton.isUserInteractionEnabled = false
        deleteButton.isUserInteractionEnabled = false
        
    }
    
    //enabling Buttons
    func enableButtons() {
        withdrawButton.isUserInteractionEnabled = true
        depositButton.isUserInteractionEnabled = true
        transferButton.isUserInteractionEnabled = true
        deleteButton.isUserInteractionEnabled = true
    }
    
    
    
    //done button press
    @IBAction func done(_ sender: Any) {
        updateAccountView?()
        dismiss(animated: true, completion: nil)
    }
    
    //withdrawing amount
    @IBAction func withdraw(_ sender: Any) {
        self.disableButtons()
        //setting up uialertaction
        let alert = UIAlertController(title: "Withdraw", message: "Please enter the amount you want to Withdraw", preferredStyle: .alert)
        alert.addTextField()
        alert.textFields?[0].keyboardType = UIKeyboardType.numberPad
        alert.addAction(UIAlertAction(title: "Done", style: .default) {(action) in
            //processing user input
            guard let withdrawString = alert.textFields?[0].text else {
                print("withdraw string error")
                return
            }
            guard var withdrawAmount = Double(withdrawString) else {
                print("input not valid")
                return
            }
            //cant draw more than what account contains
            if (withdrawAmount > self.wallet.accounts[self.index].amount) {
                withdrawAmount = self.wallet.accounts[self.index].amount
            }
            Api.withdraw(wallet: self.wallet, fromAccountAt: self.index, amount: withdrawAmount) {
                response, error in
                self.reloadView()
            }
        })
        self.enableButtons()
        
        self.present(alert, animated: true)

    }
    
    //depositing into account
    @IBAction func deposit(_ sender: Any) {
        disableButtons()
        //setting up uialertaction
        let alert = UIAlertController(title: "Deposit", message: "Please enter the amount you want to deposit", preferredStyle: .alert)
        alert.addTextField()
        alert.textFields?[0].keyboardType = UIKeyboardType.numberPad
        alert.addAction(UIAlertAction(title: "Done", style: .default) {(action) in
            //processing user input on how much to deposit
            guard let depositString = alert.textFields?[0].text else {
                print("deposit string error")
                return
            }
            guard let depositAmount = Double(depositString) else {
                print("input not valid")
                return
            }
            Api.deposit(wallet: self.wallet, toAccountAt: self.index, amount: depositAmount) {
                response, error in
                self.reloadView()
            }
        })
        self.present(alert, animated: true)
        self.enableButtons()
    }
    
    //sending variable info from current view controller to the next
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "transferSegue" {
            if let destinationVC = segue.destination as? transferViewController {
                destinationVC.wallet = self.wallet
                destinationVC.index = self.index
                destinationVC.updateSingleAccView = updateSingleAccView
            }
        }
    }
    @IBAction func transfer(_ sender: Any) {
        disableButtons()
        //setting pop up for transfer
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "transferViewController")
        let destinationVC = vc as! transferViewController
        destinationVC.wallet = self.wallet
        destinationVC.index = self.index
        destinationVC.updateSingleAccView = updateSingleAccView
        self.addChild(destinationVC)
        destinationVC.view.frame = self.view.frame
        self.view.addSubview(destinationVC.view)
        destinationVC.didMove(toParent: self)
        enableButtons()
    }
    //callback function to update total account amount shown
    //and table view and total user amount in homeViewController
    func updateSingleAccView() -> () {
        print("Called")
        reloadView()
        self.updateAccountView?()
    }
    
    //delete account
    @IBAction func deleteAcc(_ sender: Any) {
        disableButtons()
        Api.removeAccount(wallet: wallet, removeAccountat: index) {
            response, error in
            if let errorCode = error?.code {
                print("error: \(errorCode)")
                return
            }
            self.updateAccountView?()
            self.dismiss(animated: true, completion: nil)
            self.enableButtons()
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
