//
//  GameAnswerTableViewCell.swift
//  BoyFriend
//
//  Created by dbd on 2018/11/29.
//  Copyright © 2018 谢馆长. All rights reserved.
//

import UIKit

class GameAnswerTableViewCell: UITableViewCell {

    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var bgView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        if highlighted == true {
            bgView.backgroundColor = UIColor.rgb(255, green: 242, blue: 202)
        }else{
            bgView.backgroundColor = UIColor.white
        }
    }

}
