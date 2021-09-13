//
//  TableViewController.swift
//  OnTheMap
//
//  Created by Han Hlaing Moe on 07/09/2021.
//

import UIKit

class TableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    private var refreshControl = UIRefreshControl()
    
    // MARK: -Variables/Constants
    
    let identifierFindLocation = "findLocation"
    // MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.refreshControl = refreshControl
        // Pull to refresh
        refreshControl.addTarget(self, action: #selector(getStudentLocations), for: .valueChanged)
        view.addSubview(activityIndicator)
        activityIndicator.bringSubviewToFront(view)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshData(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == identifierFindLocation {

            if let destinationVC = segue.destination as? FindLocationViewController {
                let updateStudentInfo = sender as? (Bool, [StudentInformation])
                destinationVC.updatePin = updateStudentInfo?.0
                destinationVC.studentArray = updateStudentInfo?.1
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func refreshData(_ sender: Any) {
        getStudentLocations()
    }
    
    @IBAction func addNewPin(_ sender: Any) {
        checkAndAddPin()
    }
    
    // MARK: - Private methods
    
    func checkAndAddPin() {
        
        activityIndicator.startAnimating()
        // fetch login student location from server
        UdacityClient.getStudentLocation(singleStudent: true, completion: handleStudentLocationsResponse(singleStudent:data:error:))
    }
    
    @objc func getStudentLocations() {
        
        activityIndicator.startAnimating()
        // fetch student locations from server
        UdacityClient.getStudentLocation(singleStudent: false, completion: handleStudentLocationsResponse(singleStudent:data:error:))
    }
    
    func handleStudentLocationsResponse(singleStudent:Bool,data: [StudentInformation]?, error:Error?) {
        
        activityIndicator.stopAnimating()
        if let error = error {
            showErrorAlert("Error in getting locations", error.localizedDescription )
        } else {
            
            if singleStudent {
                
                if let data = data {
                    // Existing user
                    showAddPinConfirmAlert(data: data)
                } else {
                    // New user
                    performSegue(withIdentifier: identifierFindLocation,  sender: (false, []))
                }
            } else {
                
                if let data = data {
                    // stored data in StudentInformationModel
                    StudentInformationModel.studentData = data.sorted(by: {$0.updatedAt > $1.updatedAt})
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    refreshControl.endRefreshing()
                } else {
                    showErrorAlert("No data!", "There is not data to display")
                }
            }
        }
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //go to url
        guard let url = URL(string: StudentInformationModel.studentData[indexPath.row].mediaURL) else {
            self.showErrorAlert("Can't Open URL","URL not valid or student did not provide it")
            return
        }
        
        UIApplication.shared.open(url, options: [:]){ success in
            guard success == true else {
                self.showErrorAlert("Can't Open URL","URL not valid or student did not provide it")
                return
            }
        }
    }
    
}
