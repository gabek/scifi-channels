//
//  ChannelSelectionViewController.swift
//  scifitv
//
//  Created by Gabe Kangas on 2/22/16.
//  Copyright © 2016 Gabe Kangas. All rights reserved.
//

import Foundation
import UIKit
import PureLayout
import AFNetworking
import MediaPlayer
import TVServices
import SDWebImage
import AVKit

class ChannelSelectionViewController: UIViewController {
    var collectionView: UICollectionView!
    
    var channels: [Channel]?
    
    override func viewDidLoad() {
        let testView = UIView(frame: CGRect(x: 50, y: 50, width: 50, height: 50))
        testView.backgroundColor = UIColor.greenColor()
        view.addSubview(testView)
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSizeMake(430, 430)
        layout.minimumInteritemSpacing = 50
        layout.minimumLineSpacing = 50
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.registerClass(ChannelCell.self, forCellWithReuseIdentifier: "ChannelCell")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor(patternImage: UIImage(named: "starsbackground")!)
        view.addSubview(collectionView)
        
        collectionView.contentInset = UIEdgeInsetsMake(70, 70, 70, 70)
        getChannels()
        
        updateViewConstraints()
    }
    
    private var didSetupConstraints = false
    override func updateViewConstraints() {
        if !didSetupConstraints {
            collectionView.autoPinEdgesToSuperviewEdges()
            didSetupConstraints = true
        }
        super.updateViewConstraints()
    }
    
    // https://channelpear.com/api/v1/library
    func getChannels() {
        let manager = AFHTTPSessionManager()
        manager.requestSerializer.setAuthorizationHeaderFieldWithUsername("30666", password: "sec_4c66c73ca5603151b1d569aa94ed2db2c18a303caba3168ac9c140c8cad02d1a")
        let url = "https://channelpear.com/api/v1/library"
        manager.GET(url, parameters: nil, progress: nil, success: { (task, data) -> Void in
            if let data = data as? [NSDictionary] {
                self.channels = data.map({ return Channel(title: $0.valueForKey("title") as! String, image: $0.valueForKey("image") as! String, url: $0.valueForKey("url") as! String, description: $0.valueForKey("description") as! String) })
            }
            print(self.channels)
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
    
}

struct Channel {
    var title: String
    var image: String
    var url: String
    var description: String
}