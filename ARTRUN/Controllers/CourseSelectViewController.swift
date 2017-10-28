//
//  CourseSelectViewController.swift
//  ARTRUN
//
//  Created by Atsushi Otsubo on 2017/10/28.
//  Copyright © 2017年 NEMUINGO. All rights reserved.
//

import UIKit

class CourseSelectViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // コースのタイトル
    let courceTitles = ["ナスカの地上絵", "ネコ2", "イヌ1", "イヌ2"]
    // 走者数
    let courceRunners = [5, 2, 1, 2]
    // 距離
    let courceDistances = [100, 2, 1, 2.4]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        navigationItem.title = "ランニング選択"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// セルの個数を指定するデリゲートメソッド（必須）
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courceTitles.count
    }
    
    /// セルに値を設定するデータソースメソッド（必須）
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルを取得する
        let cell: CourseTableViewCell = tableView.dequeueReusableCell(withIdentifier: "CourseCell", for: indexPath as IndexPath) as! CourseTableViewCell
        
        // セルに表示する値を設定する
        cell.setCell(imageName: "", courseTitle: courceTitles[indexPath.row], courseRunner: courceRunners[indexPath.row], courseDistance: courceDistances[indexPath.row])
        
        return cell
    }
    
    /// セルが選択された時に呼ばれるデリゲートメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("セル番号：\(indexPath.row)")
        let storyboard: UIStoryboard = UIStoryboard(name: "Run", bundle: nil)
        let nextView = storyboard.instantiateInitialViewController()!
        
        self.navigationController?.pushViewController(nextView, animated: true)
    }
}
