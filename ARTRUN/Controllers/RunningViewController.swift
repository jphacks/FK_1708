//
//  RunningViewController.swift
//  ARTRUN
//
//  Created by Atsushi Otsubo on 2017/10/28.
//  Copyright © 2017年 NEMUINGO. All rights reserved.
//
/*
 * ランニング画面
 * 特徴的な機能：Google Maps Apiを用いて経路検索
 *
 */

import UIKit
import GoogleMaps

class RunningViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet weak var runMapView: GMSMapView!
    @IBOutlet weak var panelView: UIView!
    enum TravelModes: Int {
        case driving
        case walking
        case bicycling
    }
    enum PanelModes: Int {
        case confirm
        case running
        case pausing
        case finish
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
    var panelMode = PanelModes.confirm
    
    var listId: Int!
    var coursePointArray: Array<(Double, Double)> = []
    var totalDistanceInMeters: Int = 0
    
    // JSON受け取り用の構造体
    var courseData: CourseData!
    struct CourseData: Codable {
        struct Course: Codable {
            struct Point: Codable {
                var lat:Double
                var lng:Double
            }
            var id:Int
            var title = ""
            var description = ""
            var distance:Double
            var runner_count:Int
            var image_url = ""
            var author = ""
            var center_lat: Double
            var center_lng: Double
            var point: [Point]
        }
        var data: Course
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        let camera = GMSCameraPosition.camera(withLatitude: 33.50, longitude: 130.50, zoom: 6.0) // デフォルトのマップ位置を取得
        runMapView.camera = camera
        runMapView.delegate = self
        
        // AWSよりコース情報を取得
        let urlString = "https://pqqwfnd9kk.execute-api.ap-northeast-1.amazonaws.com/Prod/detail?id=\(listId)"
        let request = NSMutableURLRequest(url: NSURL(string: urlString)! as URL)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data_, response, error in
            if (error == nil) {
                let result = NSString(data: data_!, encoding: String.Encoding.utf8.rawValue)!
                print(result)
                let jsonData = result.data(using: String.Encoding.utf8.rawValue) // Data型に変換
                let jsonDecoder = JSONDecoder()
                do {
                    self.courseData = try jsonDecoder.decode(CourseData.self, from: jsonData!) // デコード
                    
                    for i in 0..<self.courseData.data.point.count {
                        self.coursePointArray.append((self.courseData.data.point[i].lat, self.courseData.data.point[i].lng))
                    }
                    
                    DispatchQueue.main.async {
                        self.displayPanel() // 確認画面の表示
                        self.startCalcRoute() // ルート検索, 描画
                    }
                } catch DecodingError.keyNotFound(let key, let context) {
                    print("keyNotFound: \(key): \(context)")
                } catch {
                    print("\(error.localizedDescription)")
                }
            } else {
                print("error")
            }
        })
        task.resume()
    }
    
    func startCalcRoute() {
        if (self.coursePolyline) != nil {
            self.clearRoute()
        }
        
        for i in 0..<coursePointArray.count-1 {
            let origin = "\(coursePointArray[i].0),\(coursePointArray[i].1)"
            let destination = "\(coursePointArray[i+1].0),\(coursePointArray[i+1].1)"
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { // GoogleMapApiへの接続制限対策のため一定時間待機
                self.mapTasks.getDirections(origin: origin, destination: destination, waypoints: nil, travelMode: self.travelMode, completionHandler: { (status, success) -> Void in
                    if success {
                        self.configureMapAndMarkersForRoute()
                        self.drawRoute()
                        self.calcTotalDistance()
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
    
    func calcTotalDistance() {
        totalDistanceInMeters += Int(mapTasks.totalDistanceInMeters)
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
    
    /* マップがタップされた時 */
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) { }
    
    /* 確認画面の表示 */
    func displayPanel() {
        // TODO: クリア
        
        // 表示
        let screenWidth = UIScreen.main.bounds.size.width
        switch panelMode {
        case .confirm:
            let titleLabel: UILabel = UILabel(frame:CGRect(x:0,y:0,width:screenWidth,height:40))
            titleLabel.text = courseData.data.title // appDelegate.courses[].title
            titleLabel.font = UIFont(name: "HiraginoSans-W7", size: 22)
            titleLabel.textColor = UIColor.black
            titleLabel.shadowColor = UIColor.gray
            titleLabel.textAlignment = NSTextAlignment.center
            
            let distancelabel1: UILabel = UILabel(frame:CGRect(x:0,y:40,width:screenWidth,height:20))
            distancelabel1.text = "距離"
            distancelabel1.font = UIFont(name: "HiraginoSans-W3", size: 14)
            distancelabel1.textColor = UIColor.gray
            distancelabel1.textAlignment = NSTextAlignment.center
            
            let distancelabel2: UILabel = UILabel(frame:CGRect(x:0,y:60,width:screenWidth,height:40))
            distancelabel2.text = "\(courseData.data.distance) km" // "\(appDelegate.courses[id].distance/1000) km"
            distancelabel2.font = UIFont(name: "HiraginoSans-W7", size: 22)
            distancelabel2.textColor = UIColor.black
            distancelabel2.textAlignment = NSTextAlignment.center
            
            let runninngStartButton: UIButton = UIButton(frame:CGRect(x:0,y:100,width:screenWidth,height:70))
            runninngStartButton.setTitle("スタート", for: .normal)
            runninngStartButton.titleLabel?.font = UIFont(name: "HiraginoSans-W7", size: 22)
            runninngStartButton.layer.masksToBounds = true
            runninngStartButton.backgroundColor =  UIColor(red: 0.960, green: 0.722, blue: 0.325, alpha: 1)
            panelView.addSubview(titleLabel)
            panelView.addSubview(distancelabel1)
            panelView.addSubview(distancelabel2)
            panelView.addSubview(runninngStartButton)
            
        case .running:
            let pauseButton: UIButton = UIButton(frame:CGRect(x:0,y:0,width:screenWidth/2,height:170))
            pauseButton.setTitle("一時停止", for: .normal)
            pauseButton.titleLabel?.font = UIFont(name: "HiraginoSans-W7", size: 22)
            pauseButton.layer.masksToBounds = true
            pauseButton.backgroundColor =  UIColor(red: 0.960, green: 0.722, blue: 0.325, alpha: 1)
            
            let finishButton: UIButton = UIButton(frame:CGRect(x:screenWidth/2,y:0,width:screenWidth,height:170))
            finishButton.setTitle("終了", for: .normal)
            finishButton.titleLabel?.font = UIFont(name: "HiraginoSans-W7", size: 22)
            finishButton.layer.masksToBounds = true
            finishButton.backgroundColor =  UIColor(red: 0.960, green: 0.722, blue: 0.325, alpha: 1)
            panelView.addSubview(pauseButton)
            panelView.addSubview(finishButton)
            
        case .pausing:
            let continueButton: UIButton = UIButton(frame:CGRect(x:0,y:0,width:screenWidth/2,height:170))
            continueButton.setTitle("続きから", for: .normal)
            continueButton.titleLabel?.font = UIFont(name: "HiraginoSans-W7", size: 22)
            continueButton.layer.masksToBounds = true
            continueButton.backgroundColor =  UIColor(red: 0.960, green: 0.722, blue: 0.325, alpha: 1)
            
            let finishButton: UIButton = UIButton(frame:CGRect(x:screenWidth/2,y:0,width:screenWidth,height:170))
            finishButton.setTitle("終了", for: .normal)
            finishButton.titleLabel?.font = UIFont(name: "HiraginoSans-W7", size: 22)
            finishButton.layer.masksToBounds = true
            finishButton.backgroundColor =  UIColor(red: 0.960, green: 0.722, blue: 0.325, alpha: 1)
            panelView.addSubview(continueButton)
            panelView.addSubview(finishButton)
            
        case .finish: break
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
