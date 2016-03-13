//
//  ChannelCell.swift
//  scifitv
//
//  Created by Gabe Kangas on 2/22/16.
//  Copyright © 2016 Gabe Kangas. All rights reserved.
//

import Foundation
import UIKit

class ChannelCell: UICollectionViewCell {
    let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(imageView)
        
        imageView.topAnchor.constraintEqualToAnchor(contentView.topAnchor).active = true
        imageView.bottomAnchor.constraintEqualToAnchor(contentView.bottomAnchor).active = true
        imageView.leadingAnchor.constraintEqualToAnchor(contentView.leadingAnchor).active = true
        imageView.trailingAnchor.constraintEqualToAnchor(contentView.trailingAnchor).active = true
        imageView.adjustsImageWhenAncestorFocused = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}