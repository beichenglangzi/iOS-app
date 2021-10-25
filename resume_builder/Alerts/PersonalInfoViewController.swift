//
//  PersonalInfoViewController.swift
//  resume_builder
//
//  Created by Ricky  Feig on 4/22/21.
//

import UIKit

class PersonalInfoViewController: UIViewController {

    @IBOutlet weak var titleBox: UITextField!
    @IBOutlet weak var nameBox: UITextField!
    @IBOutlet weak var homeBox: UITextField!
    @IBOutlet weak var emailBox: UITextField!
    @IBOutlet weak var phoneBox: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var dontSaveButton: UIButton!
    @IBOutlet weak var alertView: UIView!
    
    @IBOutlet weak var height: NSLayoutConstraint!
    var parentVC: MainViewController!
    var pos: Int = 0
    var newResume: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makePretty()
    }
    
    @IBAction func save(_ sender: Any) {
        
        
        //update resume
        if (!titleBox.text!.isEmpty) {
            parentVC.resume[pos].title = titleBox.text
        }
        if (!nameBox.text!.isEmpty) {
            parentVC.resume[pos].name = nameBox.text
        }
        if (!homeBox.text!.isEmpty) {
            parentVC.resume[pos].homeAddress = homeBox.text
        }
        if (!emailBox.text!.isEmpty) {
            parentVC.resume[pos].emailAddress = emailBox.text
        }
        if (!phoneBox.text!.isEmpty) {
            parentVC.resume[pos].phoneNumber = phoneBox.text
        }
        
        //save updates
        //update coredata
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        parentVC.tableView.reloadData()
        self.dismiss(animated: true, completion: {})
    }
    
    @IBAction func dontSave(_ sender: Any) {
        self.dismiss(animated: true, completion: {})
    }
    
    
    func makePretty()
    {        
        //make it pretty
        alertView.layer.cornerRadius = 8.0
        alertView.layer.borderWidth = 3.0
        alertView.layer.borderColor = UIColor.gray.cgColor
        
        //set hegiht
        height.constant = CGFloat(saveButton.frame.height * 10)
        
        //set the text fields
        if (newResume) {
            titleBox.placeholder = "Resume Name"
            nameBox.placeholder = "Name"
            homeBox.placeholder = "Mailing Address"
            emailBox.placeholder = "Email Address"
            phoneBox.placeholder = "Phone Number"
        }else {
            titleBox.placeholder = parentVC.resume[pos].title
            nameBox.placeholder = parentVC.resume[pos].name
            homeBox.placeholder = parentVC.resume[pos].homeAddress
            emailBox.placeholder = parentVC.resume[pos].emailAddress
            phoneBox.placeholder = parentVC.resume[pos].phoneNumber
        }
    }
}
