//
//  ViewController.swift
//  Swift-DB-Demo
//
//  Created by Paramswar on 23/01/17.
//  Copyright © 2017 MTPL. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet var viewContainer: UIView!
    
    var arrNotesList = NSMutableArray()
    var arrFilesList = NSArray()
    var bEdit = Bool()
    var nSelectedIndex = Int()
    
    @IBOutlet var tableNotes: UITableView!
    @IBOutlet var txtNotes : UITextField!

    //MARK:- VIEW CONTROLLER LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        bEdit = false
        viewContainer.isHidden = true

        let strFolder = getFolderPath()
        arrFilesList = try! FileManager.default.contentsOfDirectory(atPath: strFolder) as NSArray
        print(arrFilesList)
        
        // only run if statement is arrFilesList.count>0
        if arrFilesList.count>0
        {
            viewContainer.isHidden = false
            for i in stride(from: 0, to: arrFilesList.count, by: 1)
            {
                do {
                    // Read file content
                    let strPath = strFolder.appending("/note\(i).txt")
                    let contentFromFile = try NSString(contentsOfFile: strPath, encoding: String.Encoding.utf8.rawValue)
                    print(contentFromFile)
                    arrNotesList.add(contentFromFile)
                }
                catch let error as NSError {
                    print("An error took place: \(error)")
                }
                
                tableNotes.register(TblCustomCell.self, forCellReuseIdentifier: "TblCustomCell")
                self.tableNotes.delegate = self
                self.tableNotes.dataSource = self
                self.tableNotes.reloadData()
            }
        }
        
    }

    override func viewWillAppear(_ animated: Bool)
    {
//        self.getStudentData()
 
    }
    
    //MARK:- SQLITE OPERATION BLOCK
    @IBAction func btnSave(_ sender: Any) {
        let dmInfo : DMNewsInfo = DMNewsInfo ()
        dmInfo.RollNo = "786"
        dmInfo.Name = "Params"
        dmInfo.Marks = "70"
        
        let isInserted = ModelManager.getInstance().addStudentData(dmInfo)
        
        if isInserted {
            Util.invokeAlertMethod("", strBody: "Record Inserted successfully.", delegate: nil)
        } else {
            Util.invokeAlertMethod("", strBody: "Error in inserting record.", delegate: nil)
        }
        
        
    }
    
    @IBAction func btnDisplay(_ sender: Any) {
        
        self.getStudentData()
    }

    //MARK: Other methods
    func getStudentData()
    {
        var getStudentData = NSMutableArray()
        getStudentData = ModelManager.getInstance().getAllStudentData()
        print("getStudentData==\(getStudentData)")
        
        var i = 0 as Int
        while i < getStudentData.count
        {
            let student:DMNewsInfo = getStudentData.object(at: i) as! DMNewsInfo
            print("Name==\(student.Name)")
            print("Marks==\(student.Marks)")
            print("RollNo==\(student.RollNo)")
            i = i + 1
        }
        
        

    }
    //MARK:- TABLE VIEW DATASOURCE METHODS
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrNotesList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        print(arrNotesList)
        let cell = self.tableNotes.dequeueReusableCell(withIdentifier: "notesCell", for: indexPath as IndexPath) as! TblCustomCell
        cell.lblNotes.text = self.arrNotesList [indexPath.row] as? String
        cell.btnEditAction .addTarget(self, action: #selector(btnEditAction), for: .touchDown)
        cell.btnEditAction.tag = indexPath.row
        
        cell.btnDeleteAction .addTarget(self, action: #selector(btnDeleteAction), for: .touchDown)
        cell.btnDeleteAction.tag = indexPath.row
        return cell;
    }
    
 //MARK:- Notes Block Operation
    
    func getFolderPath() -> String {
        
        let arrDocDir = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let strFolder = arrDocDir[0].appending("/MyNotesList")
        
        if !FileManager.default.fileExists(atPath: strFolder)
        {
            do    {
                try FileManager.default.createDirectory(atPath: strFolder, withIntermediateDirectories: true, attributes: nil)
            }
            catch {
                print(error.localizedDescription)
            }
        }
        
        return strFolder

    }
    
    @IBAction func btnEditAction(_ sender: Any)
    {
        bEdit = true
        let button = sender as! UIButton
        let btnSelectIndex = button.tag
        nSelectedIndex = btnSelectIndex
        print("edited Index: \(btnSelectIndex)")
        txtNotes.text = arrNotesList[btnSelectIndex] as? String;
    }
    @IBAction func btnDeleteAction(_ sender: Any)
    {
        bEdit = false
        let button = sender as! UIButton
        let btnSelectIndex = button.tag
        nSelectedIndex = btnSelectIndex
        print("Deleted Index: \(nSelectedIndex)")

        let strFolder = getFolderPath()
        
        do {
            let strDeletedFile = strFolder.appending("/note\(nSelectedIndex).txt")
            try FileManager.default.removeItem(atPath: strDeletedFile)
            arrNotesList .removeObject(at: btnSelectIndex)
            let arrFilsList = try! FileManager.default.contentsOfDirectory(atPath: strFolder) as NSArray
            
            for i in stride(from: 0, to: arrFilsList.count, by: 1)
            {
                if i >= nSelectedIndex{
                    do {
                        let documentDirectory = URL(fileURLWithPath: strFolder)

                        let originPath = documentDirectory.appendingPathComponent("note\(i + 1).txt")
                        print(originPath)
                        let destinationPath = documentDirectory.appendingPathComponent("note\(i).txt")
                        print(destinationPath)
                        
                        try FileManager.default.moveItem(at: originPath, to: destinationPath)
                    } catch {   print(error)  }
                }
            }
            self.tableNotes.reloadData()
            
        } catch let error as NSError
        {
            print(error.debugDescription)
        }
        
        
        

    }
    @IBAction func btnSubmitAction(_ sender: Any)
    {
        print(nSelectedIndex)
        var strFolder = getFolderPath()
        strFolder = strFolder.appending("/note\(nSelectedIndex).txt")

        if bEdit == true
        {
            arrNotesList .replaceObject(at: nSelectedIndex, with: txtNotes.text!)
        }
        else
        {
            if !FileManager.default.fileExists(atPath: strFolder)
            {
                arrNotesList .add(txtNotes.text!)
            }
        }
        
        do  {
            try txtNotes.text?.write(toFile: strFolder, atomically: true, encoding: String.Encoding.utf8)
            self.tableNotes.delegate = self
            self.tableNotes.dataSource = self
            self.tableNotes.reloadData()
        }
        catch let err as NSError{ print(err.description)}

    }
    
    
    @IBAction func btnAddAction(_ sender: Any) {
        viewContainer.isHidden = false
        bEdit = false
        txtNotes.text! = ""
        let strFolder = getFolderPath()
        nSelectedIndex = try! FileManager.default.contentsOfDirectory(atPath: strFolder).count - 1
        print(nSelectedIndex)

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

