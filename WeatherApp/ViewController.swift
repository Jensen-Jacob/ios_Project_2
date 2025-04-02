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
    var currentWeather: Weather?;
    var weatherArray: Array<Weather>? = Array();
    var searchArray: Array<Search>? = Array();
    var searchIndex = -1;
    var locationManager: CLLocationManager?;
    var latlng: String = "";
    var searchQuery = "";
    
    @IBOutlet weak var celsiusButton: UIButton!
    
    
    @IBOutlet weak var fahrenheitButton: UIButton!
    
    
    @IBOutlet weak var textFieldOutlet: UITextField!
    
    
    @IBOutlet weak var imageOutlet: UIImageView!
    
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
        }
    }
    
    
    @IBAction func onNavigatorButtonPressed(_ sender: UIButton) {
        searchLatLng();
    }
    
    
    @IBAction func onFahrenheitButtonPressed(_ sender: UIButton) {
        if let value = currentWeather?.current.heatindex_f {
            temperatureLabel.text = "\(value)";
            searchArray![searchIndex].scale = " F";
            searchArray![searchIndex].temperature = value;
        }
    }
    
    
    @IBAction func onCelsiusButtonPressed(_ sender: UIButton) {
        if let value = currentWeather?.current.heatindex_c {
            temperatureLabel.text = "\(value)";
            searchArray![searchIndex].scale = " C";
            searchArray![searchIndex].temperature = value;
        }
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        switch textField.tag {
        case 0:
            if let value = textField.text {
                searchQuery = value;
            }
            
        default:
            print("nothing");
        }
    }
    
    // Handles the return key press event on the text field (initiates search)
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // Dismiss the keyboard
        onSearchButtonPressed(UIButton()) // Initiate search by pressing the search button
        return true
    }
    
    
    @IBAction func onCitiesButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "homeToCitiesSegue", sender: self);
    }
    
    @IBAction func onSearchButtonPressed(_ sender: UIButton) {
        if (searchQuery != "") {
            let url = getUrl(search: searchQuery);
            let urLSession = URLSession(configuration: .default);
            
            //setup the datatask in the url session thread
            let dataTask = urLSession.dataTask(with: url, completionHandler: requestCompletionHandler(data:response:error:));
            
            //run the datatask
            dataTask.resume();
            searchQuery = "";
            textFieldOutlet.text = "";
        }
    }
    
    
    func searchLatLng() {
        let url = getUrl(search: self.latlng);
        let urLSession = URLSession(configuration: .default);
        
        
        //setup the datatask in the url session thread
        let dataTask = urLSession.dataTask(with: url, completionHandler: requestCompletionHandler(data:response:error:));

        //run the datatask
        dataTask.resume();
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "homeToCitiesSegue" {
            let destination = segue.destination as! CitiesViewController;
            if let array = searchArray {
                destination.weatherHistory = array;
            }
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
    
    
    func requestCompletionHandler(data: Data?, response: URLResponse?, error: Error?) {
            
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
                    self.currentWeather = weatherObject;
                    print("\(self.weatherArray?.count)");
                    self.temperatureLabel.text = "\(weatherObject.current.heatindex_c)";
                    self.conditionLabel.text = "\(weatherObject.current.condition.text)";
                    self.cityLabel.text = "\(weatherObject.location.name)";
                    var icon = "";
                    if (weatherObject.current.condition.code == 1003) {
                        icon = "cloud.sun.fill";
                    }
                    else if (weatherObject.current.condition.code == 1240) {
                        icon = "sun.max.fill";
                    }
                    else if (weatherObject.current.condition.code == 1135) {
                        icon = "wind";
                    }
                    else if (weatherObject.current.condition.code == 1000) {
                        icon = "moon.fill";
                    }
                    else if (weatherObject.current.condition.code == 1183) {
                        icon = "cloud.rain";
                    }
                    else {
                        icon = "cloud.fill";
                    }
                    let config = UIImage.SymbolConfiguration(paletteColors: [.systemBlue, .systemOrange]);
                    self.imageOutlet.preferredSymbolConfiguration = config;
                    self.imageOutlet.image = UIImage(systemName: icon);
                    self.searchIndex = self.searchIndex + 1;
                    var search: Search = Search(location: weatherObject.location.name, temperature: weatherObject.current.heatindex_c,scale: " C", iconSystemName: icon);
                    self.searchArray?.append(search);
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














