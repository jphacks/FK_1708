//
//  CourseSelectViewController.swift
//  ARTRUN
//
//  Created by Atsushi Otsubo on 2017/10/28.
//  Copyright © 2017年 NEMUINGO. All rights reserved.
//

import UIKit

class CourseSelectViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var courses: Courses!
    // var runningViewController:RunningViewController!
    // var courses: AppDelegate.Course
    
    // コースのタイトル
    // let courceTitles = ["ナスカの地上絵", "ネコ2", "イヌ1", "イヌ2"]
    // 走者数
    // let courceRunners = [5, 2, 1, 2]
    // 距離
    // let courceDistances = [100, 2, 1, 2.4]
    // コースの画像
    // let courceImages = ["course.png", "course.png", "course.png", "course.png"]
    
    struct Courses: Codable {

//        struct Cource: Codable {
//            var courceTitles = ""
//            var courceRunners:Int
//            var courceDistances:Double
//            var courceImages = ""
//        }
//        let cource: [Cource]
        
        //test用
        struct Cource: Codable {
            var id:Int
            var title = ""
            var description = ""
            var distance:Double
            var runner_count:Int
            var image_url = ""
        }
        let data: [Cource]
        
        var prefecture = ""
        var image = ""
        var sort = ""
    }
  
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "ランニング選択"
        // courses = appDelegate.courses
        // create the url-request
        
        //Getの処理とか
        let urlString = "https://pqqwfnd9kk.execute-api.ap-northeast-1.amazonaws.com/Prod/list"
        let request = NSMutableURLRequest(url: NSURL(string: urlString)! as URL)
        // set the method(HTTP-GET)
        request.httpMethod = "GET"
        // use NSURLSessionDataTask
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            if (error == nil) {
                let result = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!
                //print(result)
                
                //resultをData型に変換
                let jsonData = result.data(using: String.Encoding.utf8.rawValue)
                let jsonDecoder = JSONDecoder()
                
                do {
                    //ここでデコード
                    self.courses = try jsonDecoder.decode(Courses.self, from: jsonData!)
                    DispatchQueue.main.async {
                        // Main Threadで実行する
                        self.tableView.reloadData()
                    }
                    self.courses.data.forEach { cource in
                        print(cource)
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        // TODO:JSONで取得して来た値に書き換える (現在はAppDelegateのcourses変数に保存した値を使用)
        cell.setCell(imageName: self.courses.data[indexPath.row].image_url, courseTitle: self.courses.data[indexPath.row].title, courseRunner: self.courses.data[indexPath.row].runner_count, courseDistance: self.courses.data[indexPath.row].distance)
        return cell
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        runningViewController = segue.destination as! RunningViewController
//    }
//
    /* セルが選択された時に呼ばれるデリゲートメソッド */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("セル番号：\(indexPath.row)")
        // セル番号を渡す
        // runningViewController.id = indexPath.row
        
        // ナビゲーション画面を開く
        let storyboard: UIStoryboard = UIStoryboard(name: "Run", bundle: nil)
        let nextView = storyboard.instantiateInitialViewController() as! RunningViewController
        nextView.id = indexPath.row
        self.navigationController?.pushViewController(nextView, animated: true)
    }
}
