//
//  CourseSelectViewController.swift
//  ARTRUN
//
//  Created by Atsushi Otsubo on 2017/10/28.
//  Copyright © 2017年 NEMUINGO. All rights reserved.
//
/*
 * コース選択画面
 * 特徴的な機能：コースをAWSよりJSONで取得
 *
 */

import UIKit

class CourseSelectViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    var courses: Courses!
    
    struct Courses: Codable {
        struct Cource: Codable {
            struct Point: Codable {
                var lat:Double
                var lng:Double
            }
            var id:String
            var title = ""
            var description = ""
            var prefecture = ""
            var distance:Double
            var runner_count:Int
            var image_url = ""
            var author = ""
            var center_lat: Double
            var center_lng: Double
            var point: [Point]
        }
        var data: [Cource]
        
        //        var prefecture = ""
        //        var image = ""
        //        var sort = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "ランニング選択"
        
        // AWSよりコース一覧を取得
        let urlString = "https://ae3u9y4vff.execute-api.ap-northeast-1.amazonaws.com/Prod/list"
        print("urlString=\(urlString)")
        let request = NSMutableURLRequest(url: NSURL(string: urlString)! as URL)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            if (error == nil) {
                let result = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!
                print("result=\(result)")
                let jsonData = result.data(using: String.Encoding.utf8.rawValue) // Data型に変換
                let jsonDecoder = JSONDecoder()
                do {
                    self.courses = try jsonDecoder.decode(Courses.self, from: jsonData!) // デコード
                    DispatchQueue.main.async {
                        self.tableView.reloadData() // テーブルの再読み込みをMainThreadで実行する
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
    
    /* セルの個数を指定するデリゲートメソッド */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(self.courses==nil){
            return 0
        }
        return self.courses.data.count
    }
    
    /* セルに値を設定するデータソースメソッド */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルを取得
        let cell: CourseTableViewCell = tableView.dequeueReusableCell(withIdentifier: "CourseCell", for: indexPath as IndexPath) as! CourseTableViewCell
        
        // セルに表示する値を設定
        cell.setCell(imageName: self.courses.data[indexPath.row].image_url, courseTitle: self.courses.data[indexPath.row].title, courseRunner: self.courses.data[indexPath.row].runner_count, courseDistance: self.courses.data[indexPath.row].distance)
        return cell
    }
    
    /* セルが選択された時に呼ばれるデリゲートメソッド */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // ナビゲーション画面を開く
        let storyboard: UIStoryboard = UIStoryboard(name: "Run", bundle: nil)
        let nextView = storyboard.instantiateInitialViewController() as! RunningViewController
        print("id=\(courses.data[indexPath.row].id)")
        nextView.courseId = courses.data[indexPath.row].id
        self.navigationController?.pushViewController(nextView, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
