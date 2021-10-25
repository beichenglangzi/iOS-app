//
//  ViewController.swift
//  resume_builder
//
//  Created by Sonia Grzywocz on 3/5/21.
//

import UIKit
import CoreData


class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, UITableViewDragDelegate, UITableViewDropDelegate {
    
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var tableView: UITableView!
    
    let defaultCategories : [String] = ["Awards", "Skills", "Work Experience","Education"]
    var resume: [Resume] = []
    var selectedIndex: Int = 0
    var selectedRes: Resume?
  
  
    
override func viewDidLoad() {
    super.viewDidLoad()
    tableView.delegate = self
    tableView.dataSource = self
    tableView.dragDelegate = self
    tableView.dropDelegate = self
    tableView.dragInteractionEnabled = true
    
    tableView.register(ResumeSetCollectionCell.self, forCellReuseIdentifier: "Cell")
    navBar.title = "Blazer Resume Builder"
    getResumeFromDB()

    let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
    longPressGesture.minimumPressDuration = 0.5
    self.tableView.addGestureRecognizer(longPressGesture)
}
    
//
    @IBAction func newResume(_ sender: Any) {
  
          guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
              return
          }
  
          let managedContext = appDelegate.persistentContainer.viewContext
  
          let entity = NSEntityDescription.entity(forEntityName: "Resume", in: managedContext)!
  
          let res = NSManagedObject(entity: entity, insertInto: managedContext) as! Resume
        
        let todaysDate = NSDate()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let DateInFormat = dateFormatter.string(from: todaysDate as Date)
        res.title = "New Resume: " + DateInFormat
  
          
  
          //add default categories to the new resume
        for (i,c) in defaultCategories.enumerated() {
            let entity1 = NSEntityDescription.entity(forEntityName: "Category", in: managedContext)!
            let cat = NSManagedObject(entity: entity1, insertInto: managedContext) as! Category
            cat.title = c
            cat.type = c
            cat.resume = res
            cat.arrayPosition = Int16(i)
        }
  
  
          do {
              try managedContext.save()
              resume.append(res) // check here
              tableView.reloadData()
          } catch let error as NSError {
              print("Could not save. \(error), \(error.userInfo)")
          }
        launchPersonalInfo(newResume: true, pos: resume.count-1)
  
      }
    
    
 
    //alert for delete all button
    
    @IBAction func createAlert(){
        
        let alert = UIAlertController(title: "Delete all?", message: "All items will be deleted immediately. You can't undo this action", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: {_ in
            alert.dismiss(animated: true, completion: {})
            self.handleDeleteAll()
        }))
        self.present(alert, animated: true)
        

    }
    
    
    func handleDeleteAll() {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}

        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Resume")
        do {
            resume = try managedContext.fetch(fetchRequest) as? [Resume] ?? []
        } catch let error as NSError {
            print("Could not fetch, \(error), \(error.userInfo)")
        }
        
        for res:Resume in resume {
            managedContext.delete(res)
            resume.removeAll()
            tableView.reloadData()
        }
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
        }
        
        tableView.dataSource = self
    }
    
    
    
    
    /*
     function that launches the whole resume view on long click gesture
     */
    @objc func handleLongPress(longPressGesture: UILongPressGestureRecognizer) {
        //find out where the long press is
        let p = longPressGesture.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: p)
        if longPressGesture.state == UIGestureRecognizer.State.began {
        selectedIndex = indexPath?.row ?? 0
        launchWholeResume()
        }
    }
    
    /*
//     This function loads all the content from the database as a start so that it is visible on the screen
//     */

    func getResumeFromDB() {

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }

        let managedContext = appDelegate.persistentContainer.viewContext

        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Resume")

        do {
            resume = try managedContext.fetch(fetchRequest) as? [Resume] ?? []
            resume.sort(by: { $0.arrayPosition > $1.arrayPosition })
        } catch let error as NSError  {
            print("Could not fetch, \(error). \(error.userInfo) ")
        }

        //ensuring the content changes are being saved
        if managedContext.hasChanges {
            do {
                try managedContext.save()
            } catch {
                let nserror = error as NSError
                fatalError("Error updagin the content \(nserror), \(nserror.userInfo)")
            }
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resume.count
    
    }
    
//delete on swipe starts here
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete") {_,_,_ in
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            let managedContext = appDelegate.persistentContainer.viewContext
            let res = self.resume[indexPath.row]
            managedContext.delete(res)
            
            do{
                try managedContext.save()
            }
            catch let error{
                print("Could not save Deletion \(error)")
            }

            self.resume.remove(at: indexPath.row)
            tableView.reloadData()
        }
        let rename = UIContextualAction(style: .normal, title: "Edit"){_,_,_ in
            self.launchPersonalInfo(newResume: false, pos: indexPath.row)
        }
        let swipeAction = UISwipeActionsConfiguration(actions: [delete, rename])
        swipeAction.performsFirstActionWithFullSwipe = false
        return swipeAction
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {

        return true
    }
    
    
 
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ResumeSetCollectionCell
        cell.backgroundColor = UIColor.white
        cell.label.text = resume[indexPath.row].title
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       let vc = self.storyboard?.instantiateViewController(identifier: "overview") as! ResumeOverviewViewController
        vc.parentVC = self
        vc.resume = resume[indexPath.row]
        self.show(vc, sender: self)

 }
    
    func launchPersonalInfo(newResume: Bool, pos: Int) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let alert = sb.instantiateViewController(identifier: "PersonalInfoViewController") as! PersonalInfoViewController
        alert.parentVC = self
        alert.pos = pos
        alert.modalPresentationStyle = .overCurrentContext
        alert.newResume = newResume
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func launchWholeResume() {
        /*
         THIS WILL OPEN THE VIEW OF THE WHOLE RESUME. BEFORE CALLING IT MAKE SURE THAT selectedRes IS SET TO THE RIGHT VALUE
         
         selectedRes = resume[indexPath.row]
         launchWholeResume()
         
         */
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let resView = sb.instantiateViewController(identifier: "WholeResumeView") as! WholeResumeView
        resView.resume = resume[selectedIndex]
        self.show(resView, sender: self)
    }

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    //DRAG AND DROP CODE!!!!!
    //Returns drag delegate
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let dragItem = UIDragItem(itemProvider: NSItemProvider())
        dragItem.localObject = resume[indexPath.row]
        return [ dragItem ]
    }
    //What to do on a drop
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // Update the model
        let mover = resume.remove(at: sourceIndexPath.row)
        resume.insert(mover, at: destinationIndexPath.row)
        //assign new positions
        for (i, res) in resume.enumerated() {
            res.arrayPosition = Int16(resume.count - i)
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
    //Enables dropping
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        
    }
} // end of the class







