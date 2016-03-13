//
//  ChannelSelectionViewController.swift
//  scifitv
//
//  Created by Gabe Kangas on 2/22/16.
//  Copyright © 2016 Gabe Kangas. All rights reserved.
//

import Foundation
import UIKit
import AFNetworking
import MediaPlayer
import TVServices
import SDWebImage
import AVKit

class ChannelSelectionViewController: UIViewController {
    var collectionView: UICollectionView!
    var channels: [Channel]?
    
    override func viewDidLoad() {
        navigationController?.navigationBarHidden = true
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSizeMake(450, 450)
        layout.minimumInteritemSpacing = 50
        layout.minimumLineSpacing = 70
        layout.headerReferenceSize = CGSizeMake(200, 150)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.registerClass(ChannelCell.self, forCellWithReuseIdentifier: "ChannelCell")
        collectionView.registerClass(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "Header")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor(patternImage: UIImage(named: "starsbackground")!)
        view.addSubview(collectionView)
        
        collectionView.contentInset = UIEdgeInsetsMake(70, 100, 70, 100)

        updateViewConstraints()
        getChannels()
    }
    
    private var didSetupConstraints = false
    override func updateViewConstraints() {
        if !didSetupConstraints {
            collectionView.topAnchor.constraintEqualToAnchor(view.topAnchor).active = true
            collectionView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor).active = true
            collectionView.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor).active = true
            collectionView.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor).active = true
            didSetupConstraints = true
        }
        super.updateViewConstraints()
    }
    
    func getChannels() {
        guard let infoPlist = NSBundle.mainBundle().infoDictionary else {
            return
        }
        
        guard let channelPearSettings = infoPlist["ChannelPear"] as? Dictionary<String, AnyObject> else {
            return
        }
        
        guard let user = channelPearSettings["User"] as? String else {
            assertionFailure("You must provide a User ID in Info.plist")
            return
        }
        
        guard let password = channelPearSettings["Password"] as? String else {
            assertionFailure("You must provide a Password in Info.plist")
            return
        }
        
        if user == "" || password == "" {
            assertionFailure("You must provide a Username and Password in Info.plist")
        }
        
        // https://channelpear.com/api/v1/library
        let manager = AFHTTPSessionManager()
        manager.requestSerializer.setAuthorizationHeaderFieldWithUsername(user, password: password)
        let url = "https://channelpear.com/api/v1/library"
        manager.GET(url, parameters: nil, progress: nil, success: { (task, data) -> Void in
            if let data = data as? [NSDictionary] {
                self.channels = data.map({ return Channel(title: $0.valueForKey("title") as! String, image: $0.valueForKey("image") as! String, url: $0.valueForKey("url") as! String, description: $0.valueForKey("description") as! String) })
            }
            self.collectionView.reloadData()
            }) { (task, error) -> Void in
                print(error)
        }
    }
}

extension ChannelSelectionViewController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let channels = channels {
            let channel = channels[indexPath.item]
            let vc = AVPlayerViewController()
            
            vc.player = AVPlayer(URL: NSURL(string: channel.url)!)
            vc.player?.play()
            
            self.navigationController?.pushViewController(vc, animated: true)
            vc.view.backgroundColor = UIColor(patternImage: UIImage(named: "starsbackground")!)
        }
    }
}

extension ChannelSelectionViewController: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let channels = channels {
            return channels.count
        }
        
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ChannelCell", forIndexPath: indexPath) as! ChannelCell
        
        if let channels = channels {
            let channel = channels[indexPath.item]
            cell.imageView.sd_setImageWithURL(NSURL(string: channel.image))
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "Header", forIndexPath: indexPath)
        let label = UILabel()
        label.text = "Channels"
        label.textColor = UIColor(white: 0.7, alpha: 0.8)
        label.frame = CGRectMake(0, 0, 500, 150)
        label.font = UIFont.systemFontOfSize(100)
        view.addSubview(label)
        return view
    }
}

struct Channel {
    var title: String
    var image: String
    var url: String
    var description: String
}