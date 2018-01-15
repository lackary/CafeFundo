//
//  MapViewController.swift
//  CafeFundo
//
//  Created by lackary on 2017/11/5.
//  Copyright © 2017年 LackaryApp. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation

class PlaceViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var mapKitView: MKMapView!
    @IBOutlet weak var storeTableView: UITableView!
    
    var refresher: UIRefreshControl!
    
    //let search_geo_radius_url = "https://192.168.0.104/cafefundo/search/v1/radius"
    let search_geo_radius_url = "https://cafefundo.appspot.com/cafefundo/search/v1/radius"
    
    var locationManager: CLLocationManager = CLLocationManager()
    var currentAnnotaion = MKPointAnnotation()
    var startLocation: CLLocation!
    var latestlocation: CLLocation!
    
    let latitudeDelta = 0.005
    let longitudeDelta = 0.005
    
    var counter = 0
    
    var imageArray = [UIImage?]()
    var storeArray = [Store]()
    var storesNum = 0
    var cachedImages = [String: UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        // CoreLocation
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        startLocation = nil
        
        // MapKit
        mapKitView.delegate = self
        mapKitView.mapType = .standard
        mapKitView.showsUserLocation = true
        mapKitView.showsScale = true
        mapKitView.showsCompass = true
        mapKitView.showsTraffic = true
        mapKitView.showsBuildings = true
        mapKitView.showsPointsOfInterest = true
        // mapKitView.showAnnotations(mapKitView.annotations, animated: true)
        mapKitView.isZoomEnabled = true
        
        //addBottomSheetView()
        
        storeTableView.delegate = self
        storeTableView.dataSource = self
        /*
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "pull to refresh")
        
        self.storeTableView.addSubview(refresher)
        */
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        locationManager.startUpdatingLocation()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        locationManager.stopUpdatingLocation()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.storesNum
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //print(indexPath.row)
        let cell = tableView.dequeueReusableCell(withIdentifier: "StoreCell", for: indexPath)
        //cell.textLabel?.text = "Section \(indexPath.section) Row \(indexPath.row)"
        cell.textLabel?.text = self.storeArray[indexPath.row].name
        let avgRating = getAvgRating(store: self.storeArray[indexPath.row])
        let postionLocation = CLLocation(latitude: self.storeArray[indexPath.row].location![1], longitude: self.storeArray[indexPath.row].location![0])
        let distance = latestlocation.distance(from: postionLocation)
        let detailString = String(format: "%.2f", avgRating) + "-" + String(format: "%.0f", distance) + "m"
        cell.detailTextLabel?.text = detailString
        cell.imageView?.image = UIImage(data:self.storeArray[indexPath.row].picture!)
        return cell
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        latestlocation = locations[locations.count - 1]
        
        if startLocation == nil {
            startLocation = latestlocation
        }
        if startLocation != nil {
            let distance = latestlocation.distance(from: startLocation)
            if startLocation == latestlocation {
                getStoreAround(location: latestlocation)
                
                //self.refresher.endRefreshing()
            }
            else if distance >= 500 {
                getStoreAround(location: latestlocation)
                startLocation = latestlocation
                self.storeTableView.reloadData()
                // self.refresher.endRefreshing()
            }
        }
        
        
        // 顯示地圖範圍大小
        let currentLocationSpan: MKCoordinateSpan = MKCoordinateSpanMake(latitudeDelta, longitudeDelta)
        // 設置地圖顯示的範圍與中心點座標
        //let center:CLLocation = CLLocation(latitude: latestlocation.coordinate.latitude, longitude: //latestlocation.coordinate.longitude)
        let currentRegion:MKCoordinateRegion = MKCoordinateRegion(center: latestlocation.coordinate,span: currentLocationSpan)
        mapKitView.setRegion(currentRegion, animated: true)
        
        //標示大頭針
        currentAnnotaion.coordinate = latestlocation.coordinate
        currentAnnotaion.title = "我的位置"
        currentAnnotaion.subtitle = "現在的位置"
        
        mapKitView.addAnnotation(currentAnnotaion)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error \(error)")
    }
    
    func getStoreAround(location: CLLocation){
        var para = [String: Any]()
        para = [
            "data": [
                "longitude": Double(location.coordinate.longitude),
                "latitude": Double(location.coordinate.latitude),
                "radius": 500,
                "type": "meter"
            ]
        ]
        getStoreInfo(url: search_geo_radius_url, parameter: para)
        //getJsonFormUrl(url: search_geo_radius_url, parameter: para)
    }
    
    func getDataFromUrl(request: URLRequest, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: request) { (data:Data?, response:URLResponse?, error:Error?) in
            completion(data, response, error)
            }.resume()
    }
    func getStoreInfo(url: String, parameter: Dictionary<String, Any>) {
        var request = URLRequest(url:URL(string:url)!)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameter, options: [])
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        getDataFromUrl(request: request) { (data, response, error) in
            if error != nil {
                print("Error \(String(describing: error))")
            } else {
                guard let data = data else { return }
                do {
                    //Decode retrived data with JSONDecoder and assing type of Article object
                    let result = try JSONDecoder().decode(CafeStoreResult.self, from: data)
                    self.storesNum = result.number
                    print("the store number: ", result.number)
                    self.storeArray = result.data
                } catch let jsonError {
                    print(jsonError)
                }
                DispatchQueue.main.sync {
                    for index in 0...self.storesNum-1 {
                        self.setAnnotation(store: self.storeArray[index])
                        self.storeArray[index].picture = UIImagePNGRepresentation(UIImage(named: "ic_local_cafe_36pt")!)
                        if self.storeArray[index].pictureUrl != nil {
                            self.downloadImage(url: self.storeArray[index].pictureUrl!, row: index)
                        }
                    }
                    print("finish")
                    //self.storeTableView.reloadData()
                }
            }
         }
    }

    func getAvgRating(store: Store) -> Double {
        
        var count = 0.0
        var totalRating = 0.0
        var avgRating = 0.0
        if store.wifi != 0.0 {
            totalRating += store.wifi!
            count += 1.0
        }
        if store.seat != 0.0 {
            totalRating += store.seat!
            count += 1.0
        }
        if store.quiet != 0.0 {
            totalRating += store.quiet!
            count += 1.0
        }
        if store.tasty != 0.0 {
            totalRating += store.tasty!
            count += 1.0
        }
        if store.cheap != 0.0 {
            totalRating += store.cheap!
            count += 1.0
        }
        if store.music != 0.0 {
            totalRating += store.music!
            count += 1.0
        }
        if count != 0 {
            avgRating = totalRating / count
        }
        
        return avgRating
    }
    
    
    
    func downloadImage(url: String, row: Int) {
        var request = URLRequest(url:URL(string:url)!)
        request.httpMethod = "GET"
        getDataFromUrl(request: request) { (data, response, error) in
            // if responseData is not null...
            if error != nil {
                print("error")
            } else {
                // execute in UI thread
                self.storeArray[row].picture = data
                DispatchQueue.main.sync {
                    self.storeTableView.reloadData()
                }
            }
        }
    }
    
    func setAnnotation(store: Store ){
        let postionLocation = CLLocation(latitude: store.location![1], longitude: store.location![0])
        //標示大頭針
        let storeAnnotaion = MKPointAnnotation()
        storeAnnotaion.coordinate = postionLocation.coordinate
        storeAnnotaion.title = store.name
        //currentAnnotaion.subtitle = "現在的位置"
        mapKitView.addAnnotation(storeAnnotaion)
    }
}
