//
//  DetailEditViewController.swift
//  resume_builder
//
//  Created by Ricky  Feig on 3/17/21.
//

import UIKit
import CoreData

class NewDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tbvHeight: NSLayoutConstraint!
    @IBOutlet weak var alertViewHeight: NSLayoutConstraint!
    @IBOutlet weak var instruction: UILabel!
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    var parentVC: DetailedCategoryViewController!
    var resDetail: Detail?
    var resCategory: Category?
    var prompts: [String] = []
    var bulletPoints: [String] = []
    let defaultBullet: String = "     \u{2023}  "
    var pos: Int = 0
    var titleTerms: Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickPrompts()
        makePretty()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return prompts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: EditDetailCell = self.tableView.dequeueReusableCell(withIdentifier: "editCell") as! EditDetailCell
        
        // set the text from the data model
        cell.txtField.placeholder = prompts[indexPath.row]
        
        return cell
    }
    
    //save edits to DB
    @IBAction func save(_ sender: Any) {
        var newTitle: String = ""
        var newDesc: String = ""
        var term = 0
        var p: Int = 0;

        for cell in tableView.visibleCells{
            let c:EditDetailCell = cell as! EditDetailCell
            if (c.txtField?.text?.count ?? 0 > 0) {
                if (term < titleTerms) {
                    newTitle.append((c.txtField?.text)!)
                    newTitle.append(", ")
                }else {
                    if (p < bulletPoints.count){
                        newDesc.append(bulletPoints[p])
                    }else {
                        newDesc.append(defaultBullet)
                    }
                    newDesc.append((c.txtField?.text)!)
                    newDesc.append("\n")
                    p+=1
                }
            }
            term = term+1
        }
        
        //update tableview in parent
        if (newTitle.count > 2) {
            let stringEnd = newTitle.index(newTitle.endIndex, offsetBy: -3)
            let titleTxt = newTitle[...stringEnd]
            print("Position is " + String(pos))
            parentVC.resItems[pos].title = String(titleTxt)
        }
        if (newDesc.count > 1) {
            let stringEnd = newDesc.index(newDesc.endIndex, offsetBy: -2)
            let descText = newDesc[...stringEnd]
            parentVC.resItems[pos].descriptor = String(descText)
        }
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
    
    @IBAction func deleteItem(_ sender: Any) {
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
    
    func makePretty()
    {
        instruction.text = "Fill out any relevant fields"
        
        //makes pretty
        let a = UIScreen.main.bounds.height
        let b = saveButton.frame.size.height * 1.5
        let c = (prompts.count + 4)
        //let h = (UIScreen.main.bounds.height - saveButton.frame.size.height * (prompts.count + 1) * 1.5)/2
        let h = (a - b*CGFloat(c)) / 2
        print("height is " ,h)
        alertViewHeight.constant = h
        tbvHeight.constant = CGFloat(44 * prompts.count)
        self.tableView.separatorColor = UIColor.white
        //tbViewBottom.constant = CGFloat(20 * prompts.count)
        alertView.layer.cornerRadius = 8.0
        alertView.layer.borderWidth = 3.0
        alertView.layer.borderColor = UIColor.gray.cgColor
        //set the text boxes
        
    }

    func pickPrompts() {
        let type : String = resCategory?.type ?? ""
        
        if (type == "Education") {
            prompts = ["Name of Institution" , "Graduation Year / Years Attended" , "Degree / Certification" , "GPA" , "Minors"]
            bulletPoints = [defaultBullet + "Degree in ", defaultBullet + "GPA: ", defaultBullet + "Minor in "]
            titleTerms = 2;
        }
        else if (type == "Work Experience") {
            prompts = ["Position Title" , "Employer" , "Dates of Employment" , "Location", "Responsibility 1", "Responsibility 2"]
            titleTerms = 4
        }
        else if (type == "Skills") {
            prompts = ["Fluent/Proficient/Experienced in Language/Software/Tool etc"]
            titleTerms = 1
        }
        else if (type == "Awards") {
            prompts = ["Award Title" , "Year Recieved"]
            titleTerms = 2
        }
        else {
            prompts = ["Title" , "Dates", "Location", "Description 1", "Description 2"]
            titleTerms = 3
        }
    }
    
    
    
}

