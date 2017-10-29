//
//  CourseTableViewCell.swift
//  ARTRUN
//
//  Created by Atsushi Otsubo on 2017/10/28.
//  Copyright © 2017年 NEMUINGO. All rights reserved.
//

import UIKit

class CourseTableViewCell: UITableViewCell {
    @IBOutlet weak var courseImageView: UIImageView!
    @IBOutlet weak var courseTitleLabel: UILabel!
    @IBOutlet weak var courseRunnerLabel: UILabel!
    @IBOutlet weak var courseDistanceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    /// 画像・タイトル・説明文を設定するメソッド
    func setCell(imageName: String, courseTitle: String, courseRunner: Int, courseDistance: Double) {
        let url = URL(string: imageName)!
        //セット
        let imageData = try? Data(contentsOf: url)
        let image = UIImage(data:imageData!)
        //表示
        courseImageView.image = image

        //courseImageView.image = UIImage(named: imageName)
        
        courseTitleLabel.text = courseTitle
        courseRunnerLabel.text = "走者 : " + String(courseRunner) + "人"
        courseDistanceLabel.text =  "距離 : " + String(courseDistance) + "km"
    }
}
