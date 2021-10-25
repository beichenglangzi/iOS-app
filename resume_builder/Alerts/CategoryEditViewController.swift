//
//  CategoryEditViewController.swift
//  resume_builder
//
//  Created by Jeffrey Hutto on 4/14/21.
//

import UIKit
import CoreData

class CategoryEditViewController: UIViewController {
    
    @IBOutlet weak var EditCategory: UIView!
    @IBOutlet weak var txt: UITextField!
    var parentVC: ResumeOverviewViewController?
    var selectedCat: Category?
    var pos: Int = 0
    
    @IBAction func SaveButton(_ sender: Any) {
        parentVC?.categories[pos].title = txt.text ?? ""
        parentVC?.tableView.reloadData()
        
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
    
    @IBAction func OkButton(_ sender: Any) {
        self.dismiss(animated: true, completion: {})
    }
    
    override func viewDidLoad() {
        txt.text = selectedCat?.title
        makePretty()
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    func makePretty()
    {
        //Set Text
    
        
        //makes pretty
        EditCategory.layer.cornerRadius = 8.0
        EditCategory.layer.borderWidth = 3.0
        EditCategory.layer.borderColor = UIColor.gray.cgColor
        
        EditCategory.layer.cornerRadius = 8.0
        EditCategory.layer.borderWidth = 0.5
        EditCategory.layer.borderColor = UIColor.darkGray.cgColor
        //set the text boxes
        
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
