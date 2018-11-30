//
//  TypingTableViewCell.swift
//  BoyFriend
//
//  Created by 谢馆长 on 2018/10/20.
//  Copyright © 2018年 谢馆长. All rights reserved.
//

import UIKit

class TypingTableViewCell: UITableViewCell {

    @IBOutlet weak var headImage: UIImageView!
    @IBOutlet weak var bubleView: UIView!
    @IBOutlet weak var gifImage: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bubleView.layer.cornerRadius = 8;
        bubleView.layer.shadowColor = UIColor.gray.cgColor
        bubleView.layer.shadowOffset = CGSize(width: 5, height: 5)
        bubleView.layer.shadowOpacity = 0.3
        bubleView.layer.shadowRadius = 6;
        
        headImage.layer.cornerRadius = 25;
        headImage.layer.shadowColor = UIColor.gray.cgColor
        headImage.layer.shadowOffset = CGSize(width: 3, height: 3)
        headImage.layer.shadowOpacity = 1
        headImage.layer.shadowRadius = 8;
        
        
        
        gifImage.animate(withGIFNamed: "typing")
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
