//
//  ArtViewController.swift
//  ARTRUN
//
//  Created by Atsushi Otsubo on 2017/10/29.
//  Copyright © 2017年 NEMUINGO. All rights reserved.
//

import UIKit
import GoogleMaps

class ArtViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var totalDistanceInMeters: Int = 0
    
    @IBOutlet weak var artMapView: GMSMapView!
    @IBOutlet weak var postButton: UIButton!
    
    /* コース情報
    struct Course {
        var title: String
        var distance: Int
        var coursePointArray: Array<(Double, Double)>
    }
    */

    var coursePointArray: Array<(Double, Double)> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postButton.setTitle("投稿", for: .normal)
        postButton.titleLabel?.font = UIFont(name: "HiraginoSans-W7", size: 30)
        postButton.layer.masksToBounds = true
        postButton.backgroundColor =  UIColor(red: 0.960, green: 0.722, blue: 0.325, alpha: 1)
        postButton.setTitleColor(UIColor.white, for: .normal)
        
        let camera = GMSCameraPosition.camera(withLatitude: 33.50, longitude: 130.50, zoom: 10.0)
        artMapView.camera = camera
        artMapView.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func postButtonTapped(_ sender: Any) {
        let addressAlert = UIAlertController(title: "Create Route", message: "Connect locations with a route:", preferredStyle: UIAlertControllerStyle.alert)
        
        addressAlert.addTextField { (textField) -> Void in
            textField.placeholder = "タイトル："
        }
        
        let createRouteAction = UIAlertAction(title: "Create Route", style: UIAlertActionStyle.default) { (alertAction) -> Void in
            let title = (addressAlert.textFields![0] as UITextField).text
            // let distance = artMapView. google.maps.geometry.spherical.computeLength(polyline.getPath())
            // var distance = GMSGeometryLength(path)
            let course = AppDelegate.Course(title: title!, distance: self.totalDistanceInMeters, coursePointArray: self.coursePointArray) // 距離適当
            
            self.appDelegate.courses.append(course)
        }
        let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.cancel) { (alertAction) -> Void in
            
        }
        
        addressAlert.addAction(createRouteAction)
        addressAlert.addAction(closeAction)
        
        present(addressAlert, animated: true, completion: nil)
    }
    
    func createMarkers(coordinate: CLLocationCoordinate2D, color: UIColor) {
        // runMapView.camera = GMSCameraPosition.camera(withTarget: mapTasks.originCoordinate, zoom: 9.0)
        let marker = GMSMarker(position: coordinate)
        marker.map = self.artMapView
        marker.icon = GMSMarker.markerImage(with: color)
        marker.title = "Point"
    }
    
    func drawLine() {
        // 線を引く準備
        let path = GMSMutablePath()
        for coursePoint in coursePointArray {
            path.add(CLLocationCoordinate2D(latitude: coursePoint.0, longitude: coursePoint.1)) // 線を引く座標をPathに追加
        }
        
        // 距離を計算
        totalDistanceInMeters = totalDistanceInMeters + Int(GMSGeometryLength(path))
        
        // 線を引く
        let polyline = GMSPolyline(path: path)
        // polyline.path?.length(kGMSLengthGeodesic)
        polyline.spans = [GMSStyleSpan(style: GMSStrokeStyle.solidColor(UIColor.red) )]
        polyline.strokeWidth = 3.0 //線の太さ
        polyline.map = artMapView //線を描画
        polyline.isTappable = true
//        polyline.title = "1"
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        coursePointArray.append((Double(coordinate.latitude), Double(coordinate.longitude)))
        if (coursePointArray.count >= 2) {
            // createMarkers(coordinate: coordinate, color: UIColor.green)
            drawLine()
        } else {
            createMarkers(coordinate: coordinate, color: UIColor.green)
        }
    }
}
