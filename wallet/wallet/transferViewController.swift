//
//  transferViewController.swift
//  wallet
//
//  Created by Brandon Jones Gunaman on 11/2/19.
//  Copyright © 2019 Brandon Jones Gunaman. All rights reserved.
//

import UIKit

class transferViewController: UIViewController,UIPickerViewDataSource,UIPickerViewDelegate, UITextFieldDelegate{
    @IBOutlet var accountPicker: UIPickerView!
    
    var wallet = Wallet()
    var index:Int = 0
    var counter = 0
    var accounts = [Account]()
    var transferToIndex = 0
    var updateSingleAccView:(() -> ())?
    
    @IBOutlet var amtToTransfer: UITextField!
   
    @IBOutlet var doneButton: UIButton!
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //setting delegates
        accountPicker.dataSource = self
        accountPicker.delegate = self
        
        //creating temporary account for uipicker
        accounts = wallet.accounts
        accounts.remove(at: index) //removing current account
        accountPicker.reloadAllComponents()
        
        //transparent display
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
    }
    
    
    //after done button is pressed
    @IBAction func donePress(_ sender: Any) {
        //if temp account index is more than index of current account
        if wallet.accounts.count == 1{
            self.view.removeFromSuperview()
            return
        }
        if transferToIndex >= index {
            transferToIndex = transferToIndex + 1
        }
        
        let amt = amtToTransfer.text ?? ""
        var transferAmt = Double(amt) ?? 0.00
        //if trying to transfer more than what account has
        if transferAmt > wallet.accounts[index].amount {
            transferAmt = wallet.accounts[index].amount
        }
        //transfer amount to other account
        Api.transfer(wallet: wallet, fromAccountAt: index, toAccountAt: transferToIndex, amount: transferAmt) {
            response, error in
            if let errorCode = error?.code {
                print("error code = \(errorCode)")
                return
            }
            //update view in account view controller
            self.updateSingleAccView?()
            
        }
        
        self.view.removeFromSuperview()
    }
    
    //MARK : delegates for UIPicker implementation
    //picker view columns
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    //picker view rows
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return accounts.count
    }
    //picker view title
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return accounts[row].name
    }
    //picker view select
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        transferToIndex = row
    }
    
    //MARK: textfield delegates implementation
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        amtToTransfer.resignFirstResponder()
        return true
    }

}
