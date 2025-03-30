//
//  CitiesViewController.swift
//  WeatherApp
//
//  Created by User on 2025-03-27.
//

import UIKit

class CitiesViewController: UIViewController {
    
    @IBOutlet weak var tableViewOutlet: UITableView!
    var weatherHistory: [Weather] = [];

    override func viewDidLoad() {
        super.viewDidLoad();
        tableViewOutlet.dataSource = self;
        tableViewOutlet.delegate = self;
    }
    @IBAction func onBackButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil);
    }
    

}




extension CitiesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        weatherHistory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "weatherCell", for: indexPath);
        let weather = weatherHistory[indexPath.row];
        var contentConfig = cell.defaultContentConfiguration();
        contentConfig.text = weather.location.name;
        contentConfig.secondaryText = String(weather.current.heatindex_c);
        contentConfig.image = UIImage(systemName: "cloud");
        cell.contentConfiguration = contentConfig;
        return cell;
    }
    
}




extension CitiesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("List item clicked at \(indexPath.row)");
        tableView.deselectRow(at: indexPath, animated: true);
        //items.remove(at: indexPath.row);
        //tableView.deleteRows(at: [indexPath], with: .automatic);
        let cell = tableView.cellForRow(at: indexPath);
        
        let isChecked = cell?.accessoryType == .checkmark;
        if isChecked {
            cell?.accessoryType = .none;
        }
        else {
            cell?.accessoryType = .checkmark;
        }
    }
}
