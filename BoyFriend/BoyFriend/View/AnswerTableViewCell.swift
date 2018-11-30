//
//  AnswerTableViewCell.swift
//  BoyFriend
//
//  Created by 谢馆长 on 2018/10/14.
//  Copyright © 2018年 谢馆长. All rights reserved.
//

import UIKit

class AnswerTableViewCell: UITableViewCell {

    
    @IBOutlet weak var imageV: UIImageView!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var answerLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        setShadow(sender: bgView)
    }

    func setShadow(sender:UIView){
        
        sender.layer.cornerRadius = 10;
        sender.layer.shadowColor = UIColor.gray.cgColor
        sender.layer.shadowOffset = .zero
        sender.layer.shadowOpacity = 0.5;
        sender.layer.shadowRadius = 5;
        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected == true{
            imageV.isHidden = false
            
        }else{
            imageV.isHidden = true
        }
        
        contentView.backgroundColor = UIColor.clear
        backgroundView?.backgroundColor = UIColor.white
        backgroundColor = UIColor.white
        
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
       contentView.backgroundColor = UIColor.clear
        

    }
    

}
