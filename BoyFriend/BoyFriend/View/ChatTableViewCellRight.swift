//
//  ChatTableViewCellRightTableViewCell.swift
//  BoyFriend
//
//  Created by 谢馆长 on 2018/10/13.
//  Copyright © 2018年 谢馆长. All rights reserved.
//

import UIKit

class ChatTableViewCellRight: UITableViewCell {

    @IBOutlet weak var headImage: UIImageView!
    @IBOutlet weak var bubleView: UIView!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var bubleViewWidth: NSLayoutConstraint!
    @IBOutlet weak var shadowView: UIView!
    
    var model:Conversation?{
        didSet{
            contentLabel.text = model?.content
            headImage.image = UIImage(named: (model?.headImage)!)
            if let startDate = model?.time{
                timeLabel.text = startDate.dateToString()
            }
            let width =  (model?.content?.ga_widthForComment(fontSize: 14))! + 35
            if width > UIScreen.main.bounds.size.width - 130{
                bubleViewWidth.constant = UIScreen.main.bounds.size.width - 130
            }else if width < 70{
                bubleViewWidth.constant = 70
            }else{
                let timeWidth = "yyyy-MM-dd hh:mm:ss".ga_widthForComment(fontSize: 12)
                if width < timeWidth{
                    bubleViewWidth.constant = CGFloat(timeWidth)
                }else{
                    bubleViewWidth.constant = CGFloat(width)
                }
                
            }
            
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        bubleView.layer.cornerRadius = 15
        bubleView.layer.shadowColor = UIColor.gray.cgColor
        bubleView.layer.shadowOffset = CGSize(width: -5, height: 5)
        bubleView.layer.shadowOpacity = 0.3
        bubleView.layer.shadowRadius = 8
        
        headImage.layer.cornerRadius = 25
        headImage.layer.masksToBounds = true
        
        shadowView.layer.cornerRadius=25
        shadowView.layer.shadowColor=UIColor.gray.cgColor
        shadowView.layer.shadowOffset=CGSize(width: 5, height: 5)
        shadowView.layer.shadowOpacity=0.5
        shadowView.layer.shadowRadius=5
 
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
