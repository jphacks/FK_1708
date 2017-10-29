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
    @IBOutlet weak var artMapView: GMSMapView!
    
    var coursePointArray: Array<(Double, Double)> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "絵を描く"
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
            // create button タップ時
            let title = (addressAlert.textFields![0] as UITextField).text
            let course = AppDelegate.Course(title: title!, distance: 10, coursePointArray: self.coursePointArray)
            //            self.appDelegate.courses.append(course)
            
            //Post
            let urlString = "https://ae3u9y4vff.execute-api.ap-northeast-1.amazonaws.com/Prod/add"
            let request = NSMutableURLRequest(url: URL(string: urlString)!)
            
            request.httpMethod = "POST"
            request.addValue("application/text", forHTTPHeaderField: "Content-Type")
            
            
            
            var pointsObj = Array<Any>()
            for coursePoint in course.coursePointArray {
                var point = Dictionary<String, Any>()
                point["lat"] = coursePoint.0
                point["lng"] = coursePoint.1
                pointsObj.append(point)
            }
            
            var courseObj = Dictionary<String, Any>()
            courseObj["title"] = title
            courseObj["description"] = "description"
            courseObj["distance"] = 10.5
            courseObj["runner_count"] = 0
            courseObj["image_url"] = "https://s3-ap-northeast-1.amazonaws.com/jphacks2017/image/map.jpg"
            courseObj["author"] = "author"
            courseObj["center_lat"] = 33.378527018372452
            courseObj["center_lng"] = 130.40318291634321
            courseObj["point"] = pointsObj
            courseObj["prefecture"] = "fukuoka"
            
            var jsonObj = Dictionary<String, Any>()
            jsonObj["data"] = courseObj
            
            var json: String = ""
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: jsonObj, options: [])
                json = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
            } catch {
                print("Error!: \(error)")
            }
            
            let strData = json.data(using: String.Encoding.utf8)
            request.httpBody = strData
            
            // use NSURLSessionDataTask
            let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {data, response, error in
                if (error == nil) {
                    let result = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!
                    print(result)
                } else {
                    print("error")
                }
            })
            task.resume()
            
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
        
        // 線を引く
        let polyline = GMSPolyline(path: path)
        polyline.spans = [GMSStyleSpan(style: GMSStrokeStyle.solidColor(UIColor.red) )]
        polyline.strokeWidth = 3.0 //線の太さ
        polyline.map = artMapView //線を描画
        polyline.isTappable = true
        //        polyline.title = "1"
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        coursePointArray.append((Double(coordinate.latitude), Double(coordinate.longitude)))
        if (coursePointArray.count >= 2) {
            createMarkers(coordinate: coordinate, color: UIColor.green)
            drawLine()
        } else {
            createMarkers(coordinate: coordinate, color: UIColor.red)
        }
    }
}
