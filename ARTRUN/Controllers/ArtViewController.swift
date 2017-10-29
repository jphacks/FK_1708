//
//  ArtViewController.swift
//  ARTRUN
//
//  Created by Atsushi Otsubo on 2017/10/29.
//  Copyright © 2017年 NEMUINGO. All rights reserved.
//
/*
 * お絵かき画面
 * 特徴的な機能：
 * GoogleMap上にお絵かきできる機能
 * 描いた絵の情報をAWSへPOSTで投げる機能
 *
 */

import UIKit
import GoogleMaps

class ArtViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var totalDistanceInMeters: Int = 0
    
    @IBOutlet weak var artMapView: GMSMapView!
    @IBOutlet weak var postButton: UIButton!
    
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
    
    @IBAction func postButtonTapped(_ sender: Any) {
        let addressAlert = UIAlertController(title: "Create Route", message: "Connect locations with a route:", preferredStyle: UIAlertControllerStyle.alert)
        
        addressAlert.addTextField { (textField) -> Void in
            textField.placeholder = "タイトル："
        }
        
        let createRouteAction = UIAlertAction(title: "Create Route", style: UIAlertActionStyle.default) { (alertAction) -> Void in
            
            let title = (addressAlert.textFields![0] as UITextField).text
            let urlString = "https://ae3u9y4vff.execute-api.ap-northeast-1.amazonaws.com/Prod/add"
            let request = NSMutableURLRequest(url: URL(string: urlString)!)
            
            request.httpMethod = "POST"
            request.addValue("application/text", forHTTPHeaderField: "Content-Type")
            
            var pointsObj = Array<Any>()
            for coursePoint in self.coursePointArray {
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
        totalDistanceInMeters = totalDistanceInMeters + Int(GMSGeometryLength(path)) // 距離を計算
        let polyline = GMSPolyline(path: path)
        polyline.spans = [GMSStyleSpan(style: GMSStrokeStyle.solidColor(UIColor.red) )]
        polyline.strokeWidth = 3.0 //線の太さ
        polyline.map = artMapView //線を描画
        polyline.isTappable = true
    }
    
    /* マップがタップされた時に呼ばれるオーバーライドメソッド */
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        coursePointArray.append((Double(coordinate.latitude), Double(coordinate.longitude)))
        if (coursePointArray.count >= 2) {
            drawLine()
        } else {
            createMarkers(coordinate: coordinate, color: UIColor.green)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
