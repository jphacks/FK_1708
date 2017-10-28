//
//  MapTasks.swift
//  ARTRUN
//
//  Created by Atsushi Otsubo on 2017/10/28.
//  Copyright © 2017年 NEMUINGO. All rights reserved.
//

import UIKit
import GoogleMaps

class MapTasks: NSObject {
    let baseURLDirections = "https://maps.googleapis.com/maps/api/directions/json?"
    
    var selectedRoute: Dictionary<AnyHashable, Any>!
    var overviewPolyline: Dictionary<AnyHashable, Any>!
    var originCoordinate: CLLocationCoordinate2D!
    var destinationCoordinate: CLLocationCoordinate2D!
    var originAddress: String!
    var destinationAddress: String!
    
    var totalDistanceInMeters: UInt = 0
    var totalDistance: String!
    var totalDurationInSeconds: UInt = 0
    var totalDuration: String!
    
    override init() {
        super.init()
    }
    
    
    func getDirections(origin: String!, destination: String!, waypoints: Array<String>!, travelMode: RunningViewController.TravelModes!, completionHandler: @escaping ((_ status: String,_ success: Bool) -> Void)) {
        if let originLocation = origin {
            if let destinationLocation = destination {
                var directionsURLString = baseURLDirections + "origin=" + originLocation + "&destination=" + destinationLocation
                //directionsURLString = directionsURLString.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
                
                if let routeWaypoints = waypoints {
                    directionsURLString += "&waypoints=optimize:true"
                    
                    for waypoint in routeWaypoints {
                        directionsURLString += "|" + waypoint
                    }
                }
                
                if (travelMode) != nil {
                    var travelModeString = ""
                    
                    switch travelMode.rawValue {
                    case RunningViewController.TravelModes.walking.rawValue:
                        travelModeString = "walking"
                        
                    case RunningViewController.TravelModes.bicycling.rawValue:
                        travelModeString = "bicycling"
                        
                    default:
                        travelModeString = "driving"
                    }
                    
                    
                    directionsURLString += "&mode=" + travelModeString
                }
                
                
                
                print("directionsURLString:")
                print(directionsURLString)
                directionsURLString = directionsURLString.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
                print("addingPercentEncoded:")
                print(directionsURLString)
                let directionsURL: URL = URL(string: directionsURLString)!
                
                DispatchQueue.global().async {
                    DispatchQueue.main.async {
                        
                        let directionsData = try! Data(contentsOf: directionsURL)
                        
                        //                        var error: NSError?
                        
                        let dictionary: Dictionary<AnyHashable, Any> = try! JSONSerialization.jsonObject(with: directionsData, options: JSONSerialization.ReadingOptions.mutableContainers) as! Dictionary<AnyHashable, Any>
                        
                        // jsonObject(with: directionsData!, options: JSONSerialization.ReadingOptions.mutableContainers, nil) as
                        let status = dictionary["status"] as! String
                        
                        if status == "OK" {
                            self.selectedRoute = (dictionary["routes"] as! Array<Dictionary<AnyHashable, Any>>)[0] as Dictionary<NSObject, AnyObject>
                            self.overviewPolyline = self.selectedRoute["overview_polyline"] as! Dictionary<AnyHashable, Any>
                            //                                    self.selectedRoute("")
                            
                            let legs = self.selectedRoute["legs"] as! Array<Dictionary<AnyHashable, Any>>
                            
                            let startLocationDictionary = legs[0]["start_location"] as! Dictionary<AnyHashable, Any>
                            self.originCoordinate = CLLocationCoordinate2DMake(startLocationDictionary["lat"] as! Double, startLocationDictionary["lng"] as! Double)
                            
                            let endLocationDictionary = legs[legs.count - 1]["end_location"] as! Dictionary<AnyHashable, Any>
                            self.destinationCoordinate = CLLocationCoordinate2DMake(endLocationDictionary["lat"] as! Double, endLocationDictionary["lng"] as! Double)
                            
                            self.originAddress = origin// legs[0]["start_address"] as! String
                            self.destinationAddress = destination//legs[legs.count - 1]["end_address"] as! String
                            
                            self.calculateTotalDistanceAndDuration()
                            
                            completionHandler(status, true)
                        }
                        else {
                            completionHandler(status, false)
                        }
                        //                        }
                    }
                }
            }
            else {
                completionHandler("Destination is nil.", false)
            }
        }
        else {
            completionHandler("Origin is nil", false)
        }
    }
    
    func calculateTotalDistanceAndDuration() {
        let legs = self.selectedRoute["legs"] as! Array<Dictionary<AnyHashable, Any>>
        
        totalDistanceInMeters = 0
        totalDurationInSeconds = 0
        
        for leg in legs {
            totalDistanceInMeters += (leg["distance"] as! Dictionary<AnyHashable, Any>)["value"] as! UInt
            totalDurationInSeconds += (leg["duration"] as! Dictionary<AnyHashable, Any>)["value"] as! UInt
        }
        
        
        let distanceInKilometers: Double = Double(totalDistanceInMeters / 1000)
        totalDistance = "Total Distance: \(distanceInKilometers) Km"
        
        
        let mins = totalDurationInSeconds / 60
        let hours = mins / 60
        let days = hours / 24
        let remainingHours = hours % 24
        let remainingMins = mins % 60
        let remainingSecs = totalDurationInSeconds % 60
        
        totalDuration = "Duration: \(days) d, \(remainingHours) h, \(remainingMins) mins, \(remainingSecs) secs"
    }
    
}

