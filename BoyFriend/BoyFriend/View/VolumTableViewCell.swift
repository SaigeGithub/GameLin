//
//  VolumTableViewCell.swift
//  BoyFriend
//
//  Created by dbd on 2018/10/19.
//  Copyright © 2018年 谢馆长. All rights reserved.
//

import UIKit

class VolumTableViewCell: UITableViewCell {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var headImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
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
