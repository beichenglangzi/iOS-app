//
//  DetailedCategoryViewController.swift
//  resume_builder
//
//  Created by Sonia Grzywocz on 3/5/21.
//

import UIKit
import CoreData

class DetailedCategoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, UITableViewDragDelegate, UITableViewDropDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var navBar: UINavigationItem!
    
    var parentVC: ResumeOverviewViewController?
    public var category: Category?
    public var resItems: [Detail] = []
    let cellReuseIdentifier = "cell"
    
    
    /*
     This screen will provide the detailed information provided for each category
     */

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // SET UP TABLE VIEW
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.separatorColor = UIColor.white
        tableView.dragDelegate = self
        tableView.dropDelegate = self
        tableView.dragInteractionEnabled = true
        //Pull the relevant category data and set up the navbar
        if let cat = category {
            //navBar.title = cat.title
            getDetailsFromDB()
            navBar.title = cat.title
        }
        else {
            navBar.title = "new resume category"
            print("nope")
        }
        
        //Set up long press recognizer for table
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.longPress(_:)))
        longPressGesture.delegate = self
        self.tableView.addGestureRecognizer(longPressGesture)
        
    }
    
    // Return tablview Size
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resItems.count
    }
    //Build table view cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ResumeDetailCell = self.tableView.dequeueReusableCell(withIdentifier: "cell") as! ResumeDetailCell
        // make it look pretty
        cell.wrapper?.layer.cornerRadius = 8.0
        cell.wrapper?.layer.borderColor = UIColor.black.cgColor
        cell.wrapper?.layer.borderWidth = 2.0
        cell.becomeFirstResponder()
        // set the text from the data model
        cell.title?.text = resItems[indexPath.row].title
        cell.desc?.text = resItems[indexPath.row].descriptor
        
        return cell
    }
    //Set up what happnes when you tap on an entry
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let pos: Int = indexPath.row
        print("You tapped cell number \(pos).")
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let tSpace = 60 //+ 20 * Int(resItems[indexPath.row].title!.count / 40)
        let str: String = resItems[indexPath.row].descriptor ?? ""
        if (str.count > 1) {
            let numLines = str.components(separatedBy: "\n").count
            return CGFloat(tSpace + numLines*15)
        }else {
            return CGFloat(tSpace)
        }
    }
    
    //Add a new detail to resume
    @IBAction func addDetail(_ sender: Any) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Detail", in: managedContext)!
        let detail = NSManagedObject(entity: entity, insertInto: managedContext) as! Detail
        detail.title = "New " + String(category?.title ?? "Detail")
        detail.category = self.category
        detail.descriptor = ""
        detail.resume = self.category?.resume
        do {
            try managedContext.save()
            resItems.append(detail)
            tableView.reloadData()
            print("I did a thing")
        }catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
        //Launch New Item View
        let pos = resItems.count-1
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let alertVC = sb.instantiateViewController(identifier: "NewDetailViewController") as! NewDetailViewController
        alertVC.parentVC = self
        alertVC.resDetail = resItems[pos]
        alertVC.resCategory = category
        alertVC.pos = pos
        alertVC.modalPresentationStyle = .overCurrentContext
        self.present(alertVC, animated: true, completion: nil)
    }
    
    
    func editDetail(pos: Int) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let alertVC = sb.instantiateViewController(identifier: "EditDetailViewController") as! EditDetailViewController
        alertVC.parentVC = self
        alertVC.resDetail = resItems[pos]
        alertVC.resCategory = category
        alertVC.pos = pos
        alertVC.modalPresentationStyle = .overCurrentContext
        self.present(alertVC, animated: true, completion: nil)
    }
    
    // fethces all resume items in the matching category.
    func getDetailsFromDB() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Detail")

        fetchRequest.predicate = NSPredicate(format: "category = %@", self.category!)
        do {
            resItems = try managedContext.fetch(fetchRequest) as? [Detail] ?? []
            print("found \(resItems.count) results" )
            resItems.sort(by: { $0.arrayPosition > $1.arrayPosition })
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    @IBAction func longPress(_ sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizer.State.began {
            let touchPoint = sender.location(in: tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                editDetail(pos: indexPath.row)            }
        }
    }
    
    //Drag and drop delegates to allow drag and drop reorder
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let dragItem = UIDragItem(itemProvider: NSItemProvider())
        dragItem.localObject = resItems[indexPath.row]
        return [ dragItem ]
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // Update the model
        let mover = resItems.remove(at: sourceIndexPath.row)
        resItems.insert(mover, at: destinationIndexPath.row)
        //assign new positions
        for (i, details) in resItems.enumerated() {
            details.arrayPosition = Int16(resItems.count - i)
        }
        
        //save new positions
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        
    }

}

