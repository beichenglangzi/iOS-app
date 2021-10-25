//
//  EditDetailViewController.swift
//  resume_builder
//
//  Created by Ricky  Feig on 3/31/21.
//

import UIKit
import CoreData

class EditDetailViewController: UIViewController {
    @IBOutlet weak var editView: UIView!
    @IBOutlet weak var header: UITextField!
    @IBOutlet weak var desc: UITextView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var addBullet: UIButton!
    
    var parentVC: DetailedCategoryViewController!
    let defaultBullet: String = "     \u{2023}  "
    var resDetail: Detail?
    var resCategory: Category?
    var pos: Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makePretty()
    }
    
    @IBAction func save(_ sender: Any) {
        //update tableview in parent
        parentVC.resItems[pos].title = header.text ?? ""
        parentVC.resItems[pos].descriptor = desc.text ?? ""
        parentVC.tableView.reloadData()
        
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
        //get rid of the alert
        self.dismiss(animated: true, completion: {})
    }
   
    @IBAction func discard(_ sender: Any) {
        //update tableview in parent
        parentVC.resItems.remove(at: pos)
        parentVC.tableView.reloadData()
        
        //delete from core data
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let del: NSManagedObject = resDetail! as NSManagedObject
        print("pulled del \(del)")
        managedContext.delete(del)
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        self.dismiss(animated: true, completion: {})
    }
    
    @IBAction func addBullet(_ sender: Any) {
        desc.text = desc.text + "\n" + defaultBullet
    }
    
    func makePretty()
    {
        //Set Text
        header.text = resDetail?.title
        desc.text = resDetail?.descriptor
        
        //makes pretty
        editView.layer.cornerRadius = 8.0
        editView.layer.borderWidth = 3.0
        editView.layer.borderColor = UIColor.gray.cgColor
        
        header.layer.cornerRadius = 8.0
        header.layer.borderWidth = 0.5
        header.layer.borderColor = UIColor.darkGray.cgColor
        
        desc.layer.cornerRadius = 8.0
        desc.layer.borderWidth = 0.5
        desc.layer.borderColor = UIColor.darkGray.cgColor
        //set the text boxes
        
    }

    
}
