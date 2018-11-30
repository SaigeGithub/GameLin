//
//  SettingTableViewCell.swift
//  BoyFriend
//
//  Created by 谢冠章 on 2018/10/18.
//  Copyright © 2018年 谢馆长. All rights reserved.
//

import UIKit

class SettingTableViewCell: UITableViewCell {

    
    @IBOutlet weak var notificationSwitch: UISwitch!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var headImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        bgView.layer.borderWidth = 1
        bgView.layer.borderColor = UIColor.groupTableViewBackground.cgColor
        bgView.layer.shadowColor = UIColor.gray.cgColor
        bgView.layer.shadowOffset = CGSize(width: 10, height: 10)
        bgView.layer.shadowOpacity = 0.3
        bgView.layer.shadowRadius = 10
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        contentView.backgroundColor = UIColor.white
        if selected == true {
            bgView.backgroundColor = UIColor.rgb(255, green: 242, blue: 202)
        }else{
            bgView.backgroundColor = UIColor.white
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        contentView.backgroundColor = UIColor.white
        if highlighted == true {
            bgView.backgroundColor = UIColor.rgb(255, green: 242, blue: 202)
        }else{
            bgView.backgroundColor = UIColor.white
        }
    }

}
