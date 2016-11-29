//
//  MapViewController.swift
//  ShareGroupLocation
//
//  Created by Duy Huynh Thanh on 11/12/16.
//  Copyright © 2016 Duy Huynh Thanh. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import AFNetworking
import Firebase
import FirebaseDatabase

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: UIView!
    @IBOutlet weak var memberCollectionView: UICollectionView!
    
    
    var groupKey = "111"
    var memberLocationArray = [User]()
    
    
    
    var map:GMSMapView!
    var visibleRegion:GMSVisibleRegion!
    var bounds:GMSCoordinateBounds!
    var locationManager = CLLocationManager()
    var placesClient:GMSPlacesClient!
    var path:GMSMutablePath!
    var markerArray:[GMSMarker] = []
    var suggestedPlaces:[GMSMarker] = []
    var polylineArray:[GMSPolyline] = []
    var destinationMarker = GMSMarker()
    
    var isGettingDirection = false
    var currentZoom:Float = 15
    
    var colorArray:[UIColor] = [UIColor(colorLiteralRed: 255, green: 99, blue: 99, alpha: 1),
                                UIColor(colorLiteralRed: 99, green: 255, blue: 99, alpha: 1),
                                UIColor(colorLiteralRed: 99, green: 99, blue: 255, alpha: 1),
                                UIColor(colorLiteralRed: 255, green: 0, blue: 99, alpha: 1),
                                UIColor(colorLiteralRed: 255, green: 99, blue: 255, alpha: 1),
                                UIColor(colorLiteralRed: 99, green: 255, blue: 255, alpha: 1),
                                UIColor(colorLiteralRed: 255, green: 255, blue: 255, alpha: 1),
                                UIColor(colorLiteralRed: 99, green: 99, blue: 99, alpha: 1),
                                UIColor(colorLiteralRed: 200, green: 200, blue: 200, alpha: 1),
                                UIColor(colorLiteralRed: 100, green: 100, blue: 100, alpha: 1),
                                UIColor(colorLiteralRed: 50, green: 50, blue: 50, alpha: 1),
                                UIColor(colorLiteralRed: 150, green: 150, blue: 150, alpha: 1),
                                UIColor(colorLiteralRed: 50, green: 100, blue: 150, alpha: 1),
                                UIColor(colorLiteralRed: 200, green: 250, blue: 50, alpha: 1),
                                UIColor(colorLiteralRed: 250, green: 200, blue: 150, alpha: 1),
                                UIColor(colorLiteralRed: 200, green: 150, blue: 100, alpha: 1),
                                UIColor(colorLiteralRed: 150, green: 100, blue: 50, alpha: 1),
                                UIColor(colorLiteralRed: 100, green: 50, blue: 250, alpha: 1),
                                UIColor(colorLiteralRed: 50, green: 150, blue: 250, alpha: 1),
                                UIColor(colorLiteralRed: 200, green: 200, blue: 0, alpha: 1)]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Provide API Key
        GMSPlacesClient.provideAPIKey("AIzaSyCTSY4bjXkhCD92Bw-yIT9boj4EnXl9Z74")
        GMSServices.provideAPIKey("AIzaSyCTSY4bjXkhCD92Bw-yIT9boj4EnXl9Z74")
        
        placesClient = GMSPlacesClient.shared()
        
        memberCollectionView.delegate = self
        memberCollectionView.dataSource = self
        
        // Request permission
        self.locationManager.requestAlwaysAuthorization()
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.allowsBackgroundLocationUpdates = true
        self.locationManager.allowDeferredLocationUpdates(untilTraveled: 50, timeout: 30)
        self.locationManager.startUpdatingLocation()
        
        // Implement Map
        let width = self.view.frame.width
        let height = self.view.frame.height - 20
        let camera = GMSCameraPosition.camera(withLatitude: (locationManager.location?.coordinate.latitude)!, longitude: (locationManager.location?.coordinate.longitude)!, zoom: currentZoom)
        map = GMSMapView.map(withFrame: CGRect(x: 0, y: 0, width: width, height: height), camera: camera)
        map.delegate = self
        map.isMyLocationEnabled = true
        map.settings.myLocationButton = true
        map.settings.compassButton = true
        mapView.insertSubview(map, at: 0)
        
        markerArray = [GMSMarker]()
        visibleRegion = map.projection.visibleRegion()
        
        path = GMSMutablePath()
        bounds = GMSCoordinateBounds()
        
        // Move my location button
        map.padding = UIEdgeInsetsMake(0, 0, 100, 0)
        
        getAndDrawAllMembers(groupKey: groupKey)
        
        //listenChangeLocation(groupKey: groupKey)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func onShowAllMarkers(_ sender: UIButton) {
        zoomToFit()
    }

    func getAndDrawAllMembers(groupKey:String) {
        let userRef = DataService().REF_USERS.queryOrdered(byChild: "groups/111").queryEqual(toValue: "TRUE")
        
        userRef.observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
            for child in snapshot.children {
                if let child = child as? FIRDataSnapshot {
                    let user = User(snapshot: child)
                    
                    self.memberLocationArray.append(user)
                }
                
            }
            
            var i = 0
            for item in self.memberLocationArray {
                
                self.viewMarker(latitude: CLLocationDegrees(item.location_lat)!, longtitude: CLLocationDegrees(item.location_long)!, title: String(item.userName), map: self.map, memberIndex: i)
                self.getDirection(latSource: Float((self.locationManager.location?.coordinate.latitude)!), longSource: Float((self.locationManager.location?.coordinate.longitude)!), latDes: Float(item.location_lat)!, longDes: Float(item.location_long)!, memberIndex: i)
                i += 1
            }
            
            self.zoomToFit()
            self.memberCollectionView.reloadData()
        }
    }
    
    func zoomToFit() {
        self.path.removeAllCoordinates()
        self.path.add(CLLocationCoordinate2D(latitude: (locationManager.location?.coordinate.latitude)!, longitude: (locationManager.location?.coordinate.longitude)!))
        for item in markerArray {
            self.path.add(item.position)
        }
        bounds = GMSCoordinateBounds(path: self.path)
        map.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 30))
    }
    
    func getDirection(latSource:Float, longSource:Float, latDes:Float, longDes:Float, memberIndex:Int) {
        isGettingDirection = true
        
        let urlString = "http://maps.googleapis.com/maps/api/directions/json?origin=\(latSource),\(longSource)&destination=\(latDes),\(longDes)&mode=driving"
        let request = URLRequest(url: URL(string: urlString)!)
        let path = GMSMutablePath()
        var destLatitudeArray = [Float]()
        var destLongitudeArray = [Float]()
        
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate: nil,
            delegateQueue: OperationQueue.main
        )
        
        let task:URLSessionDataTask = session.dataTask(with: request) { (data:Data?, urlResponse:URLResponse?, error:Error?) in
            if let data = data {
                let json = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary
                if let json = json {
                    let stepArray = json.value(forKeyPath: "routes.legs.steps") as! NSArray
                    
                    let array = stepArray[0] as! NSArray
                    let array2 = array[0] as! [NSDictionary]
                    
                    destLatitudeArray.append(latSource)
                    destLongitudeArray.append(longSource)
                    
                    for step in array2 {
                        let desLat = step.value(forKeyPath: "end_location.lat") as! Float
                        let desLong = step.value(forKeyPath: "end_location.lng") as! Float
                        
                        destLatitudeArray.append(desLat)
                        destLongitudeArray.append(desLong)
                    }
                    
                    let distance = ((json.value(forKeyPath: "routes.legs.distance.text") as! NSArray)[0] as! NSArray)[0] as! String
                    let duration = ((json.value(forKeyPath: "routes.legs.duration.text") as! NSArray)[0] as! NSArray)[0] as! String
                    self.markerArray[memberIndex].snippet = distance + ", " + duration
                }
                
                for i in 0..<destLatitudeArray.count {
                    path.addLatitude(CLLocationDegrees(destLatitudeArray[i]), longitude: CLLocationDegrees(destLongitudeArray[i]))
                }
                
                let polyline = GMSPolyline(path: path)
                polyline.strokeColor = self.colorArray[memberIndex < self.colorArray.count ? memberIndex : 0]
                polyline.strokeWidth = 2
                polyline.map = self.map
                self.polylineArray.append(polyline)
            }
            else {
                print("Get Direction Error!")
            }
            
            self.isGettingDirection = false
        }
        task.resume()
    }
    
    func viewMarker(latitude:CLLocationDegrees, longtitude:CLLocationDegrees, title:String, map:GMSMapView, memberIndex:Int) {
        let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: latitude, longitude: longtitude))
        marker.title = title
        marker.snippet = "Lat:\(latitude), Long:\(longtitude)"
        marker.appearAnimation = kGMSMarkerAnimationPop
        let iconView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        iconView.image = UIImage(named: "default_user")
        
        if memberLocationArray[memberIndex].profilePicUrl != "" {
            iconView.setImageWith(URL(string: memberLocationArray[memberIndex].profilePicUrl)!)
        }
        
        iconView.layer.masksToBounds = true
        iconView.layer.cornerRadius = 15
        marker.iconView = iconView
        markerArray.append(marker)
        
        let polyline = GMSPolyline()
        polyline.strokeColor = self.colorArray[memberIndex < self.colorArray.count ? memberIndex : 0]
        polyline.strokeWidth = 2
        polyline.map = self.map
        self.polylineArray.append(polyline)
        
        marker.map = map
    }
    
    func moveCamera(location:CLLocation) {
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: currentZoom)
        self.map.animate(to: camera)
    }
    
    func viewNearByPlaces(latitude:CLLocationDegrees, longtitude:CLLocationDegrees) {
        let urlString = "https://maps.googleapis.com/maps/api/place/search/json?location=\(latitude),\(longtitude)&types=atm%7Ccafe&radius=200&sensor=true&key=AIzaSyCTSY4bjXkhCD92Bw-yIT9boj4EnXl9Z74"
        let request = URLRequest(url: URL(string: urlString)!)
        
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate: nil,
            delegateQueue: OperationQueue.main
        )
        
        let task:URLSessionDataTask = session.dataTask(with: request) { (data:Data?, urlResponse:URLResponse?, error:Error?) in
            if let data = data {
                let json = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary
                if let json = json {
                    let stepArray = json.value(forKeyPath: "results") as! [NSDictionary]
                    
                    for step in stepArray {
                        let lat = step.value(forKeyPath: "geometry.location.lat") as! Float
                        let lng = step.value(forKeyPath: "geometry.location.lng") as! Float
                        let name = step.value(forKeyPath: "name") as! String
                        let iconUrl = step.value(forKeyPath: "icon") as! String
                        
                        let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(lng)))
                        marker.title = name
                        marker.appearAnimation = kGMSMarkerAnimationPop
                        let iconView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
                        iconView.setImageWith(URL(string: iconUrl)!)
                        marker.iconView = iconView
                        marker.map = self.map
                        self.suggestedPlaces.append(marker)
                    }
                }
            }
            else {
                print("Get Near By Place Error!")
            }
        }
        task.resume()
    }
    
    @IBAction func onSearchPlace(_ sender: UIButton) {
        viewNearByPlaces(latitude: map.camera.target.latitude, longtitude: map.camera.target.longitude)
    }
    
    @IBAction func onDismiss(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension MapViewController: GMSMapViewDelegate, CLLocationManagerDelegate {
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        //print(position)
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        print("Tapped on \(marker.title)")
        return false
    }
    
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        print("Long press on x \(coordinate.latitude) and y \(coordinate.longitude)")
        
        if isGettingDirection {
            return
        }
        
        if polylineArray.count > 0 {
            for i in 0...polylineArray.count - 1 {
                polylineArray[i].map = nil
            }
            polylineArray.removeAll()
        }
        
        getDirection(latSource: Float((locationManager.location?.coordinate.latitude)!), longSource: Float((locationManager.location?.coordinate.longitude)!), latDes: Float(coordinate.latitude), longDes: Float(coordinate.longitude), memberIndex: memberLocationArray.count - 1)
        
        var i = 0
        for item in markerArray {
            getDirection(latSource: Float(item.position.latitude), longSource: Float(item.position.longitude), latDes: Float(coordinate.latitude), longDes: Float(coordinate.longitude), memberIndex: i)
            i += 1
        }
        
        let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude))
        marker.title = "Destination"
        marker.appearAnimation = kGMSMarkerAnimationPop
        let iconView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        iconView.image = UIImage(named: "destination")
        marker.iconView = iconView
        marker.map = map
        destinationMarker.map = nil
        destinationMarker = marker
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        map.animate(toZoom: currentZoom)
        return false
    }
}

extension MapViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memberLocationArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = memberCollectionView.dequeueReusableCell(withReuseIdentifier: "MemberCollectionViewCell", for: indexPath) as! MemberCollectionViewCell
        
        if memberLocationArray[indexPath.row].profilePicUrl != "" {
            cell.imageView.setImageWith(URL(string: memberLocationArray[indexPath.row].profilePicUrl)!)
        }
        
        cell.nameLabel.text = memberLocationArray[indexPath.row].userName
        cell.tag = indexPath.row
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        map.selectedMarker = markerArray[indexPath.row]
        
        moveCamera(location: CLLocation(latitude: CLLocationDegrees(self.memberLocationArray[indexPath.row].location_lat)!, longitude: CLLocationDegrees(self.memberLocationArray[indexPath.row].location_long)!))
    }
}
