//
//  ChatTableViewCell.swift
//  BoyFriend
//
//  Created by 谢馆长 on 2018/10/11.
//  Copyright © 2018年 谢馆长. All rights reserved.
//

import UIKit

class ChatTableViewCell: UITableViewCell {

    @IBOutlet weak var headImage: UIImageView!
    @IBOutlet weak var bubleView: UIView!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var bubleViewWidth: NSLayoutConstraint!
    
    var model:Conversation?{
        didSet{
            contentLabel.text = model?.content
            headImage.image = UIImage(named: (model?.headImage)!)
            if let startDate = model?.time{
                timeLabel.text = startDate.dateToString()
            }
            if let bubbleWidth = model?.bubbleWidth{
                bubleViewWidth.constant = CGFloat(bubbleWidth)
            }
            
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        bubleView.layer.cornerRadius = 15;
        bubleView.layer.shadowColor = UIColor.gray.cgColor
        bubleView.layer.shadowOffset = CGSize(width: 5, height: 5)
        bubleView.layer.shadowOpacity = 0.3
        bubleView.layer.shadowRadius = 8;
        
        headImage.layer.cornerRadius = 25;
        headImage.layer.shadowColor = UIColor.gray.cgColor
        headImage.layer.shadowOffset = CGSize(width: 5, height: 5)
        headImage.layer.shadowOpacity = 1
        headImage.layer.shadowRadius = 10;
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
