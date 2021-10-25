//
//  WholeResumeView.swift
//  resume_builder
//
//  Created by Ricky  Feig on 4/12/21.
//

import UIKit
import CoreData

class WholeResumeView: UIViewController {
    
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var txtField: UITextView!
    @IBOutlet weak var exportButton: UIButton!
    
    var resume: Resume?
    var categories: [Category] = []
    var details: [[Detail]] = []
    let defaultBullet = "\u{2022}  "
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Get the database stuff
        getCatFromDB()
        getDeetFromDB()
        //Set the navbar title
        navBar.title = resume?.title ?? "Generic Resume"
        exportButton.setTitle("Export to PDF", for: .normal)
        //Set the text field
        txtField.attributedText = fillText()
    }
    
    @IBAction func export(_ sender: Any) {
        createPdfFromView(aView: self.view, saveToDocumentsWithFileName: resume?.title ?? "Resume")
    }

    func createPdfFromView(aView: UIView, saveToDocumentsWithFileName fileName: String)
    {
        //saves to documents
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, aView.bounds, nil)
        UIGraphicsBeginPDFPage()

        guard let pdfContext = UIGraphicsGetCurrentContext() else { return }

        aView.layer.render(in: pdfContext)
        UIGraphicsEndPDFContext()
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let docDirectoryPath = paths[0]
            let pdfPath = docDirectoryPath.appendingPathComponent("viewPdf.pdf")
            pdfData.write(to: pdfPath, atomically: true)
            debugPrint(pdfPath)
        
        let alert = UIAlertController(title: "Resume saved at:", message: "\(pdfPath)", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {_ in alert.dismiss(animated: true, completion: {})}))
        self.present(alert, animated: true)

    }
    
    func fillText() -> NSAttributedString{
        let text: NSMutableAttributedString = NSMutableAttributedString()

        //set different styles used
        let nameStyle = [NSAttributedString.Key.font:UIFont(name: "TimesNewRomanPS-BoldMT", size: 21.0)]
        let addressStyle = [NSAttributedString.Key.font:UIFont(name: "TimesNewRomanPSMT", size: 18.0)]
        let categoryStyle = [NSAttributedString.Key.font:UIFont(name: "TimesNewRomanPS-BoldMT", size: 16.0)]
        let detailTitleStyle = [NSAttributedString.Key.font:UIFont(name: "TimesNewRomanPSMT", size: 14.0)]
        let detailBodyStyle =  [NSAttributedString.Key.font:UIFont(name: "TimesNewRomanPSMT", size: 12.0)]
        
        
        
        //Fill in basic info in the Header Styles
        text.append(formatNewLine(body: resume?.name ?? "name", attr: nameStyle as [NSAttributedString.Key : Any]))
        text.append(formatNewLine(body: resume?.homeAddress ?? "home address", attr: addressStyle as [NSAttributedString.Key : Any]))
        text.append(formatNewLine(body: resume?.phoneNumber ?? "phone number", attr: addressStyle as [NSAttributedString.Key : Any]))
        text.append(formatNewLine(body: resume?.emailAddress ?? "email address", attr: addressStyle as [NSAttributedString.Key : Any]))
        text.append(formatNewLine(body: "------------------------------------------", attr: nameStyle as [NSAttributedString.Key : Any]))
        
        //Fill in the categories
        for (i, cat) in categories.enumerated() {
            text.append(formatNewLine(body: cat.title ?? "no category", attr: categoryStyle as [NSAttributedString.Key : Any]))
            for deet in details[i] {
                let deetTitle = deet.title ?? "default tile"
                text.append(formatNewLine(body: defaultBullet + deetTitle, attr: detailTitleStyle as [NSAttributedString.Key : Any]))
                if (deet.descriptor?.count ?? -1 > 0) {
                    text.append(formatNewLine(body: deet.descriptor ?? "", attr: detailBodyStyle as [NSAttributedString.Key : Any]))
                }
            }
            text.append(formatNewLine(body: "" , attr: detailBodyStyle as [NSMutableAttributedString.Key : Any]))
        }
        
        return text
    }
    
    func formatNewLine(body: String, attr :[NSAttributedString.Key:Any]) -> NSAttributedString{
        let str2 = body + "\n"
        return NSAttributedString(string: str2, attributes: attr)
    }
    
    
    func getCatFromDB() {
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
    
    func getDeetFromDB(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Detail")
        var temp: [Detail] = []
        
        
        for cat in categories {
            let resPred = NSPredicate(format: "resume = %@", resume!)
            let catPred = NSPredicate(format: "category = %@", cat)
            let andPredicate = NSCompoundPredicate(type: .and, subpredicates: [resPred, catPred])
            fetchRequest.predicate = andPredicate
            
            do {
                temp = try managedContext.fetch(fetchRequest) as? [Detail] ?? []
                temp.sort(by: { $0.arrayPosition > $1.arrayPosition })
                print("found \(categories.count) results" )
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
            details.append(temp)

        }
        
    }

}
