//
//  CourseSelectViewController.swift
//  ARTRUN
//
//  Created by Atsushi Otsubo on 2017/10/28.
//  Copyright © 2017年 NEMUINGO. All rights reserved.
//

import UIKit

class CourseSelectViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var appDelegate = UIApplication.shared.delegate as! AppDelegate
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "ランニング選択"
        // courses = appDelegate.courses
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /* セルの個数を指定するデリゲートメソッド */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appDelegate.courses.count
    }
    
    /* セルに値を設定するデータソースメソッド */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルを取得
        let cell: CourseTableViewCell = tableView.dequeueReusableCell(withIdentifier: "CourseCell", for: indexPath as IndexPath) as! CourseTableViewCell
        
        // セルに表示する値を設定
        // TODO:JSONで取得して来た値に書き換える (現在はAppDelegateのcourses変数に保存した値を使用)
        cell.setCell(imageName: "course.png", courseTitle: appDelegate.courses[indexPath.row].title, courseRunner: 100, courseDistance: Double(appDelegate.courses[indexPath.row].distance) / 1000)
        
        // cell.setCell(imageName: courceImages[indexPath.row], courseTitle: courceTitles[indexPath.row], courseRunner: courceRunners[indexPath.row], courseDistance: courceDistances[indexPath.row])
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
