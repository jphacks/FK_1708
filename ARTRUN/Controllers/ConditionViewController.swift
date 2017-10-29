//
//  ConditionViewController.swift
//  ARTRUN
//
//  Created by Atsushi Otsubo on 2017/10/28.
//  Copyright © 2017年 NEMUINGO. All rights reserved.
//

import UIKit

class ConditionViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var prefPickerView: UIPickerView!
    let prefList = ["福岡県", "熊本県", "大分県", "長崎県", "佐賀県", "宮崎県","鹿児島県"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prefPickerView.delegate = self
        searchButton.setTitle("検索", for: .normal)
        searchButton.titleLabel?.font = UIFont(name: "HiraginoSans-W7", size: 30)
        searchButton.layer.masksToBounds = true
        searchButton.backgroundColor =  UIColor(red: 0.960, green: 0.722, blue: 0.325, alpha: 1)
        searchButton.setTitleColor(UIColor.white, for: .normal)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //コンポーネントの個数を返すメソッド
    func numberOfComponents(in prefPickerView: UIPickerView) -> Int {
        return 1
    }
    
    //PickerViewに表示する行数を返す
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return prefList.count
    }
    
    //Picker Viewに表示する値を返す
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return prefList[row]
    }
   
    @IBAction func courseSearchButtonTapped(_ sender: Any) {
        // コース一覧画面を開く
        let storyboard: UIStoryboard = self.storyboard!
        let nextView = storyboard.instantiateViewController(withIdentifier: "CourseSelectView")
        self.navigationController?.pushViewController(nextView, animated: true)
    }
}
