//
//  TableViewController.swift
//  OnTheMap
//
//  Created by Han Hlaing Moe on 07/09/2021.
//

import UIKit

class TableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
    
    // MARK: - Delegate methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StudentInformationModel.studentData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell")!
        
        cell.textLabel?.text = StudentInformationModel.studentData[indexPath.row].firstName + " " + StudentInformationModel.studentData[indexPath.row].lastName
        cell.detailTextLabel?.text = StudentInformationModel.studentData[indexPath.row].mediaURL
        cell.imageView?.image = UIImage(named: "icon_pin")
        
        return cell
    }
    
}
