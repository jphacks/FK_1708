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
    var routePolyline: GMSPolyline!
    var markersArray: Array<GMSMarker> = []
    // var waypointsArray: Array<String> = []
    var travelMode = TravelModes.walking
    
    var routePointArray: Array<(Double, Double)> = []
    //var routeStartPoint: (Double, Double) = (0,0)
    //var routeEndPoint: (Double, Double) = (0,0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        routeStartPoint = (33.50, 130.50)
        //        routeEndPoint = (33.50, 130.50)
        routePointArray.append((33.542087, 130.460736))
        routePointArray.append((33.522087, 130.500736))
        routePointArray.append((33.56087, 130.480736))
        routePointArray.append((33.522087, 130.480736))
        routePointArray.append((33.562087, 130.500736))
        routePointArray.append((33.542087, 130.460736))
        
        
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
        if let polyline = self.routePolyline {
            self.clearRoute()
            // self.waypointsArray.removeAll(keepingCapacity: false)
        }
        
        //let origin = "\(routeStartPoint.0),\(routeStartPoint.1)"
        // let destination = "\(routeEndPoint.0),\(routeEndPoint.1)"
        // var waypointsArray: Array<String> = []
        
        for i in 0..<routePointArray.count-1 {
            let origin = "\(routePointArray[i].0),\(routePointArray[i].1)"
            let destination = "\(routePointArray[i+1].0),\(routePointArray[i+1].1)"
            // waypointsArray.append( "\(routePoint.0),\(routePoint.1)")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                
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
        
        
        //        if routePointArray.count > 0 {
        //            for routePoint in routePointArray {
        //                let lat: Double = routePoint.0
        //                let lng: Double = routePoint.1
        //
        //                let marker = GMSMarker(position: CLLocationCoordinate2DMake(lat, lng))
        //                marker.map = runMapView
        //                marker.icon = GMSMarker.markerImage(with: UIColor.purple)
        //
        //                markersArray.append(marker)
        //            }
        //        }
    }
    
    func drawRoute() {
        let route = mapTasks.overviewPolyline["points"] as! String
        
        let path: GMSPath = GMSPath(fromEncodedPath: route)!
        routePolyline = GMSPolyline(path: path)
        routePolyline.map = runMapView
    }
    
    
    func displayRouteInfo() {
        print("距離：" + mapTasks.totalDistance + ", 時間：" + mapTasks.totalDuration)
        //        lblInfo.text = mapTasks.totalDistance + "\n" + mapTasks.totalDuration
    }
    
    
    func clearRoute() {
        originMarker.map = nil
        destinationMarker.map = nil
        routePolyline.map = nil
        
        originMarker = nil
        destinationMarker = nil
        routePolyline = nil
        
        if markersArray.count > 0 {
            for marker in markersArray {
                marker.map = nil
            }
            
            markersArray.removeAll(keepingCapacity: false)
        }
    }
    
    /*
     func recreateRoute() {
     if let polyline = routePolyline {
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
        //        if let polyline = routePolyline {
        //            let positionString = String(format: "%f", coordinate.latitude) + "," + String(format: "%f", coordinate.longitude)
        //            waypointsArray.append(positionString)
        //
        //            recreateRoute()
        //        }
    }
    
}
