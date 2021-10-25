//
//  ResumeOverviewViewController.swift
//  resume_builder
//
//  Created by Sonia Grzywocz on 3/5/21.
//

import UIKit
import CoreData

class ResumeOverviewViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, UITableViewDragDelegate, UITableViewDropDelegate {
    
    var parentVC: MainViewController?
    var resume: Resume?
    var selectedRes: Resume?
    var selectedCat: Category?
    var categories: [Category] = []
    public var category: Category?
    var detail: Detail?
    public var resItems: [Detail] = []
    let cellReuseIdentifier = "cell"
    @IBOutlet weak var Cell: UIView!
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // this populates the table view with data.
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath as IndexPath) as! ResumeCategoryCell
        cell.catCell?.layer.cornerRadius = 8.0
        cell.catCell?.layer.borderColor = UIColor.black.cgColor
        cell.catCell?.layer.borderWidth = 2.0
        cell.becomeFirstResponder()
        cell.title.text = categories[indexPath.row].title
        
        var narry = (categories[indexPath.row].detail?.allObjects)! as NSArray as! [Detail]
        narry.sort(by: { $0.arrayPosition > $1.arrayPosition })
        var arr: [String] = []
        for detel in narry{
            arr.append(detel.title!)
        }
        for views in cell.stackView.arrangedSubviews {
                    views.removeFromSuperview()
                }
        let wow = arr.joined(separator: ("\n"))
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
        label.textAlignment = NSTextAlignment.left
        label.text = wow
        label.numberOfLines = 0
        label.lineBreakMode = .byTruncatingTail
        cell.stackView.addArrangedSubview(label)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            self.selectedCat = self.categories[indexPath.row]
            let vc = self.storyboard?.instantiateViewController(identifier: "detail") as! DetailedCategoryViewController
            vc.parentVC = self
            vc.category = self.selectedCat
            self.show(vc, sender: self)
           
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellSpace = 120
        let strings: Int = categories[indexPath.row].detail!.count
        if (strings > 1){
            let lines = strings
            return CGFloat(cellSpace + lines*20)
        } else{
            return CGFloat(cellSpace)
        }
    }
    // this screen will provide the brief overview of the resume user created
    
    //segue for data
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is DetailedCategoryViewController{
            if let vc = segue.destination as? DetailedCategoryViewController{
                vc.title = selectedCat?.title
            }
        }
    }
    //swipe to edit and delete
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete") {_,_,_ in
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                            return
                        }
                        let managedContext = appDelegate.persistentContainer.viewContext
            let cat = self.categories[indexPath.row]
                        managedContext.delete(cat)
                        do{
                            try managedContext.save()
                        }
                        catch let error{
                            print("Could not save Deletion \(error)")
                        }
            self.categories.remove(at: indexPath.row)
                        tableView.reloadData()
                    }
        let rename = UIContextualAction(style: .normal, title: "Edit"){_,_,_ in
            let pos = indexPath.row
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let alert = sb.instantiateViewController(identifier: "CategoryEditViewController") as! CategoryEditViewController
            alert.parentVC = self
            alert.selectedCat = self.categories[pos]
            alert.pos = pos
            alert.modalPresentationStyle = .overCurrentContext
            self.present(alert, animated: true, completion: nil)
        }
        let swipeAction = UISwipeActionsConfiguration(actions: [delete, rename])
        swipeAction.performsFirstActionWithFullSwipe = false
        return swipeAction
    }
    
    func setup(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.dragDelegate = self
        tableView.dropDelegate = self
        tableView.dragInteractionEnabled = true
        
        getCategoriesFromDB()
        getDetailsfromDB2()
               
        if let r = resume{
            navBar.title = r.title
            print("yes")
        }
        else{
            navBar.title = "categories"
            print("NOOOO")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.reloadData()
        setup()
        
    }
    //added this to reload the tableview after going to edit the details
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        print("reloaded")
        tableView.reloadData()
    }

    
    func getCategoriesFromDB() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Category")

        fetchRequest.predicate = NSPredicate(format: "resume = %@", self.resume!)
        do {
            categories = try managedContext.fetch(fetchRequest) as? [Category] ?? []
            categories.sort(by: { $0.arrayPosition > $1.arrayPosition })
            print("found \(categories.count) results" )
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }

    @IBAction func newCategory(_ sender: UIButton) {
    // add new category
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Category", in: managedContext)!
        let category = NSManagedObject(entity: entity, insertInto: managedContext) as! Category
        category.title = "New Category"
        category.resume = self.resume
        category.detail = self.category?.detail
        category.arrayPosition = Int16(-1*categories.count)
        do {
            try managedContext.save()
            categories.append(category)
            tableView.reloadData()
        }catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }

    }
    
    func getDetailsfromDB2() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        print("Details!!!!!!")
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Detail")
        do {
            resItems = try managedContext.fetch(fetchRequest) as? [Detail] ?? []
        } catch let error as NSError  {
            print("Could not fetch, \(error). \(error.userInfo) ")
        }
    }
    
    
    
    //DRAG AND DROP CODE!!!!!
    //Returns drag delegate
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let dragItem = UIDragItem(itemProvider: NSItemProvider())
        dragItem.localObject = categories[indexPath.row]
        return [ dragItem ]
    }
    //What to do on a drop
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // Update the model
        let mover = categories.remove(at: sourceIndexPath.row)
        categories.insert(mover, at: destinationIndexPath.row)
        //assign new positions
        for (i, cat) in categories.enumerated() {
            cat.arrayPosition = Int16(categories.count - i)
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
    
}
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
