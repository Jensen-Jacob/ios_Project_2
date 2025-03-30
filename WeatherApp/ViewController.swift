//
//  ViewController.swift
//  WeatherApp
//
//  Created by User on 2025-03-27.
//

import UIKit;
import CoreLocation;

class ViewController: UIViewController, UITextFieldDelegate {
    
    // API Key for WeatherAPI
    let API_KEY: String = "187719b8c7b14698b73213800252703";
    
    // Holds the current weather data
    var currentWeather: Weather?;
    
    // Array to store weather history (for displaying past weather searches)
    var weatherArray: Array<Weather>? = Array();
    
    // Location manager to get the user's current location
    var locationManager: CLLocationManager?;
    
    // Latitude and longitude string (used for searching by coordinates)
    var latlng: String = "";
    
    // Search query string (used for searching by city name)
    var searchQuery = "";
    
    // Outlets for UI elements
    @IBOutlet weak var celsiusButton: UIButton!
    @IBOutlet weak var fahrenheitButton: UIButton!
    @IBOutlet weak var textFieldOutlet: UITextField!
    @IBOutlet weak var imageOutlet: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var conditionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        // Set the textFieldOutlet's delegate to this view controller
        textFieldOutlet.delegate = self;
        
        // Initialize the location manager
        locationManager = CLLocationManager();
        locationManager?.delegate = self;
        
        // Request permission to use location services
        locationManager?.requestWhenInUseAuthorization();
        
        // Request the user's current location
        if let locationMgr = locationManager {
            locationMgr.requestLocation();
        }
    }
    
    // Action when the "Navigator" button is pressed
    @IBAction func onNavigatorButtonPressed(_ sender: UIButton) {
        searchLatLng(); // Search by latitude and longitude
    }
    
    // Action when the "Fahrenheit" button is pressed
    @IBAction func onFahrenheitButtonPressed(_ sender: UIButton) {
        // Display temperature in Fahrenheit if available
        if let value = currentWeather?.current.heatindex_f {
            temperatureLabel.text = "\(value)";
        }
    }
    
    // Action when the "Celsius" button is pressed
    @IBAction func onCelsiusButtonPressed(_ sender: UIButton) {
        // Display temperature in Celsius if available
        if let value = currentWeather?.current.heatindex_c {
            temperatureLabel.text = "\(value)";
        }
    }
    
    // Updates the search query as the text field value changes
    func textFieldDidChangeSelection(_ textField: UITextField) {
        switch textField.tag {
        case 0:
            if let value = textField.text {
                searchQuery = value; // Store the search query
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
    
    // Action when the "Cities" button is pressed
    @IBAction func onCitiesButtonPressed(_ sender: UIButton) {
        // Segue to the cities view (for showing past searches)
        performSegue(withIdentifier: "homeToCitiesSegue", sender: self);
    }
    
    // Action when the "Search" button is pressed
    @IBAction func onSearchButtonPressed(_ sender: UIButton) {
        // Only search if the search query is not empty
        if (searchQuery != "") {
            let url = getUrl(search: searchQuery); // Get the search URL for the query
            let uRLSession = URLSession(configuration: .default);
            
            // Setup a data task in the URL session thread to fetch weather data
            let dataTask = uRLSession.dataTask(with: url, completionHandler: requestCompletionHandler(data:response:error:));
            
            // Run the data task
            dataTask.resume();
            
            // Reset search query and text field after the search
            searchQuery = "";
            textFieldOutlet.text = "";
        }
    }
    
    // Searches for weather data using latitude and longitude
    func searchLatLng() {
        let url = getUrl(search: self.latlng); // Get the URL for the lat/lng search
        let uRLSession = URLSession(configuration: .default);
        
        // Setup a data task in the URL session thread to fetch weather data
        let dataTask = uRLSession.dataTask(with: url, completionHandler: requestCompletionHandler(data:response:error:));

        // Run the data task
        dataTask.resume();
    }
    
    // Prepares for segue to CitiesViewController to display weather history
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "homeToCitiesSegue" {
            let destination = segue.destination as! CitiesViewController;
            if let array = weatherArray {
                destination.weatherHistory = array; // Pass the weather history to the next view
            }
        }
    }
    
    // Returns the URL used to fetch weather data based on the search query
    func getUrl(search: String) -> URL {
        let baseUrl = "https://api.weatherapi.com/v1";
        let document = "/current.json";
        let queryParam = "q=\(search)"; // Search query parameter (city name or lat/lng)
        let keyParam = "key=\(API_KEY)"; // API key parameter
        let endPoint = "\(baseUrl)\(document)?\(queryParam)&\(keyParam)";
        
        // Return the constructed URL
        let url: URL? = URL(string: endPoint);
        return url!;
    }
    
    // Completion handler for the URL session data task to process the response
    func requestCompletionHandler(data: Data?, response: URLResponse?, error: Error?) {
        // Check for errors
        if (error == nil) {
            // Check if data exists in the response
            if (data != nil) {
                // Convert the data to a string for logging/debugging
                let dataString: String? = String(data: data!, encoding: .utf8);
                
                // Log the response data
                if dataString != nil {
                    print("\(dataString!)");
                    
                    // Parse the JSON data into a Weather object
                    let weather = parseJson(data: data!);
                } else {
                    print("No data string");
                }
            } else {
                print("No data received");
            }
        } else {
            print(error!); // Log any errors from the request
        }
    }
    
    // Parses the received JSON data into a Weather object
    func parseJson(data: Data) -> Weather? {
        let decoder = JSONDecoder();
        var weather: Weather?;
        
        do {
            // Decode the JSON data into a Weather object
            weather = try decoder.decode(Weather.self, from: data);
            
            // Update the UI on the main thread
            DispatchQueue.main.async {
                if let weatherObject = weather {
                    self.weatherArray?.append(weatherObject); // Add the new weather data to history
                    self.currentWeather = weatherObject; // Set the current weather
                    
                    // Update the UI labels and image
                    self.temperatureLabel.text = "\(weatherObject.current.heatindex_c)";
                    self.conditionLabel.text = "\(weatherObject.current.condition.text)";
                    self.cityLabel.text = "\(weatherObject.location.name)";
                    
                    // Update the weather icon
                    let config = UIImage.SymbolConfiguration(paletteColors: [.systemBlue, .systemOrange]);
                    self.imageOutlet.preferredSymbolConfiguration = config;
                    self.imageOutlet.image = UIImage(systemName: "cloud.rain");
                }
            }
        }
        catch {
            print(error); // Log any errors during JSON parsing
        }
        
        return weather;
    }
}

// CLLocationManagerDelegate extension for location services
extension ViewController: CLLocationManagerDelegate {
    
    // Handles changes in location authorization status
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
    
    // Updates location information when location is fetched
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let lat = location.coordinate.latitude;
            let long = location.coordinate.longitude;
            print("Latitude \(lat) Longitude \(long)")
            
            // Update latlng and initiate search using coordinates
            DispatchQueue.main.async {
                self.latlng = "\(lat),\(long)";
                self.searchLatLng();
            }
        }
    }
    
    // Handles location fetching errors
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print("Error fetching location \(error)");
    }
}
