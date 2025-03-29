//
//  ViewController.swift
//  WeatherApp
//
//  Created by User on 2025-03-27.
//

import UIKit;
import CoreLocation;

class ViewController: UIViewController, UITextFieldDelegate {
    
    let API_KEY: String = "187719b8c7b14698b73213800252703";
    var weatherArray: Array<Weather>? = Array();
    var locationManager: CLLocationManager?;
    var latlng: String = "";
    var searchQuery = "";
    
    @IBOutlet weak var textFieldOutlet: UITextField!
    
    
    
    @IBOutlet weak var temperatureLabel: UILabel!
    
    @IBOutlet weak var cityLabel: UILabel!
    
    @IBOutlet weak var conditionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad();
        textFieldOutlet.delegate = self;
        locationManager = CLLocationManager();
        locationManager?.delegate = self;
        locationManager?.requestWhenInUseAuthorization();
        if let locationMgr = locationManager {
            locationMgr.requestLocation();
            
            if latlng != "" {
                searchLatLng();
            }
        }
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        print("in text field");
        switch textField.tag {
        case 0:
            print("got text field");
            if let value = textField.text {
                searchQuery = value;
            }
            
        default:
            print("nothing");
        }
    }
    
    @IBAction func onCitiesButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "homeToCitiesSegue", sender: self);
    }
    
    @IBAction func onSearchButtonPressed(_ sender: UIButton) {
        if (searchQuery != "") {
            let url = getUrl(search: searchQuery);
            let uRLSession = URLSession(configuration: .default);
            
            //setup the datatask in the url session thread
            let dataTask = uRLSession.dataTask(with: url, completionHandler: jokeCompletionHandler(data:response:error:));
            
            //run the datatask
            dataTask.resume();
            searchQuery = "";
            textFieldOutlet.text = "";
        }
    }
    
    
    func searchLatLng() {
        let url = getUrl(search: self.latlng);
        let uRLSession = URLSession(configuration: .default);
        
        
        //setup the datatask in the url session thread
        let dataTask = uRLSession.dataTask(with: url, completionHandler: jokeCompletionHandler(data:response:error:));

        //run the datatask
        dataTask.resume();
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "homeToCitiesSegue" {
            let destination = segue.destination as! CitiesViewController;
            destination.city = "London";
        }
    }
    
    func getUrl(search: String) -> URL {
        //endpoint
        let baseUrl = "https://api.weatherapi.com/v1";
        let document = "/current.json";
        let queryParam = "q=\(search)";
        let keyParam = "key=187719b8c7b14698b73213800252703";
        let endPoint = "\(baseUrl)\(document)?\(queryParam)&\(keyParam)";
        
        //url object
        let url: URL? = URL(string: endPoint);
        return url!;
    }
    
    
    func jokeCompletionHandler(data: Data?, response: URLResponse?, error: Error?) {
            
            //filter out where error does not exist
            if (error == nil) {
                
                //filter out where data has a value
                if (data != nil) {
                    
                    //stringify the data in the response
                    let dataString: String? = String(data: data!, encoding: .utf8);
                    
                    //if stringify is successfully done
                    if dataString != nil {
                        print("\(dataString!)");
                        
                        let weather = parseJson(data: data!);
                    }
                    else {
                        //print if data stringifying failed
                        print("No data string");
                    }
                }
                else {
                    //print if data is nil in the response
                    print("No data received");
                }
            }
            else {
                //print if there is an error returned by the completion handler
                print(error!);
            }
        }
    
    //function that parses Data object into the full Decodable object
    func parseJson(data: Data) -> Weather? {
        let decoder = JSONDecoder();
        
        var weather: Weather?;
        
        do {
            weather = try decoder.decode(Weather.self, from: data);
            DispatchQueue.main.async {
                if let weatherObject = weather {
                    self.weatherArray?.append(weatherObject);
                    print("\(self.weatherArray?.count)");
                    self.temperatureLabel.text = "\(weatherObject.current.heatindex_c)";
                    self.conditionLabel.text = "\(weatherObject.current.condition.text)";
                    self.cityLabel.text = "\(weatherObject.location.name)";
                }
            }
        }
        catch {
            print(error);
        }
        
        return weather;
    }

}




extension ViewController: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            print("Not determined");
        case .denied:
            print("Denied");
        case .restricted:
            print("Restricted");
        case .authorizedAlways:
            print("Authorized Always");
        case .authorizedWhenInUse:
            print("Authorized when in use");
        default:
            print("Default");
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let lat = location.coordinate.latitude;
            let long = location.coordinate.longitude;
            print("Latitude \(lat) Longitude \(long)")
            DispatchQueue.main.async {
                self.latlng = "\(lat),\(long)";
                self.searchLatLng();
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print("Error fetching location \(error)");
    }
    
}














