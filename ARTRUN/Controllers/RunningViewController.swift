//
//  RunningViewController.swift
//  ARTRUN
//
//  Created by Atsushi Otsubo on 2017/10/28.
//  Copyright © 2017年 NEMUINGO. All rights reserved.
//

import UIKit
import GoogleMaps

class RunningViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet weak var runMapView: GMSMapView!
    
    enum TravelModes: Int {
        case driving
        case walking
        case bicycling
    }
    
    var locationManager = CLLocationManager()
    var didFindMyLocation = false
    var mapTasks = MapTasks()
    var locationMarker: GMSMarker!
    var originMarker: GMSMarker!
    var destinationMarker: GMSMarker!
    var coursePolyline: GMSPolyline!
    var markersArray: Array<GMSMarker> = []
    var travelMode = TravelModes.walking
    
    
    var id: Int!
    var coursePointArray: Array<(Double, Double)> = []
    
    // 総距離
    var totalDistanceInMeters: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let course = appDelegate.courses[id]
        coursePointArray = course.coursePointArray
//        coursePointArray.append((33.542087, 130.460736))
//        coursePointArray.append((33.522087, 130.500736))
//        coursePointArray.append((33.56087, 130.480736))
//        coursePointArray.append((33.522087, 130.480736))
//        coursePointArray.append((33.562087, 130.500736))
//        coursePointArray.append((33.542087, 130.460736))
        
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        let camera = GMSCameraPosition.camera(withLatitude: 33.50, longitude: 130.50, zoom: 6.0)
        
        runMapView.camera = camera
        runMapView.delegate = self
        
        startNavigation()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func startNavigation() {
        if (self.coursePolyline) != nil {
            self.clearRoute()
        }
        
        for i in 0..<coursePointArray.count-1 {
            let origin = "\(coursePointArray[i].0),\(coursePointArray[i].1)"
            let destination = "\(coursePointArray[i+1].0),\(coursePointArray[i+1].1)"
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                print("ルート検索")
                self.mapTasks.getDirections(origin: origin, destination: destination, waypoints: nil, travelMode: self.travelMode, completionHandler: { (status, success) -> Void in
                    if success {
                        self.configureMapAndMarkersForRoute()
                        self.drawRoute()
                        self.displayRouteInfo()
                    }
                    else {
                        print(status)
                    }
                })
            }
        }
    }
    
    func configureMapAndMarkersForRoute() {
        runMapView.camera = GMSCameraPosition.camera(withTarget: mapTasks.originCoordinate, zoom: 9.0)
        
        originMarker = GMSMarker(position: self.mapTasks.originCoordinate)
        originMarker.map = self.runMapView
        originMarker.icon = GMSMarker.markerImage(with: UIColor.green)
        originMarker.title = self.mapTasks.originAddress
        
        destinationMarker = GMSMarker(position: self.mapTasks.destinationCoordinate)
        destinationMarker.map = self.runMapView
        destinationMarker.icon = GMSMarker.markerImage(with: UIColor.red)
        destinationMarker.title = self.mapTasks.destinationAddress
        
    }
    
    func drawRoute() {
        let route = mapTasks.overviewPolyline["points"] as! String
        
        let path: GMSPath = GMSPath(fromEncodedPath: route)!
        coursePolyline = GMSPolyline(path: path)
        coursePolyline.spans = [GMSStyleSpan(style: GMSStrokeStyle.solidColor(UIColor.red) )]
        coursePolyline.strokeWidth = 3.0 //線の太さ
        coursePolyline.map = runMapView
        
    }
    
    
    func displayRouteInfo() {
        totalDistanceInMeters += Int(mapTasks.totalDistanceInMeters)
        print("距離：" + String(totalDistanceInMeters) + "m") //+ mapTasks.totalDuration)
    }
    
    
    func clearRoute() {
        originMarker.map = nil
        destinationMarker.map = nil
        coursePolyline.map = nil
        
        originMarker = nil
        destinationMarker = nil
        coursePolyline = nil
        
        if markersArray.count > 0 {
            for marker in markersArray {
                marker.map = nil
            }
            markersArray.removeAll(keepingCapacity: false)
        }
        
        totalDistanceInMeters = 0
    }
    
    /*
     func recreateRoute() {
     if let polyline = coursePolyline {
     clearRoute()
     
     mapTasks.getDirections(origin: mapTasks.originAddress, destination: mapTasks.destinationAddress, waypoints: waypointsArray, travelMode: travelMode, completionHandler: { (status, success) -> Void in
     
     if success {
     self.configureMapAndMarkersForRoute()
     self.drawRoute()
     self.displayRouteInfo()
     }
     else {
     print(status)
     }
     })
     }
     }
     */
    
    /* マップがタップされた時 */
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        //        if let polyline = coursePolyline {
        //            let positionString = String(format: "%f", coordinate.latitude) + "," + String(format: "%f", coordinate.longitude)
        //            waypointsArray.append(positionString)
        //
        //            recreateRoute()
        //        }
    }
    
}
