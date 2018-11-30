//
//  PhotoTableViewCell.swift
//  BoyFriend
//
//  Created by 谢冠章 on 2018/10/18.
//  Copyright © 2018年 谢馆长. All rights reserved.
//

import UIKit

typealias showImage = (String) -> Void
class PhotoTableViewCell: UITableViewCell {

    
    @IBOutlet weak var photoWidth: NSLayoutConstraint!
    @IBOutlet weak var photoHeight: NSLayoutConstraint!
    @IBOutlet weak var photoView: UIImageView!
    var tapImage:showImage?
    var imageName = ""{
        didSet{
            if imageName.count > 0{
                photoView.image = UIImage(named: imageName)
            }
            
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        let tap = UITapGestureRecognizer(target: self, action: #selector(imageTaped))
        photoView.addGestureRecognizer(tap)
    }
    @objc func imageTaped(){
        
        if let imageDidTaped = tapImage{
            imageDidTaped(imageName)
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
