//
//  VideoCell.swift
//  TableViewAVPlayer
//
//  Created by Payal Gupta on 28/02/19.
//  Copyright © 2019 Payal Gupta. All rights reserved.
//

import UIKit
import AVFoundation

class VideoCell: UITableViewCell {
    //MARK: Outlets
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var playImage: UIImageView!

    //MARK: Properties
    var playerLayer: AVPlayerLayer?
    
    //MARK: Lifecycle Methods
    override func awakeFromNib() {
        super.awakeFromNib()
        let playerLayer = AVPlayerLayer()
        playerLayer.frame = self.videoView.bounds
        playerLayer.videoGravity = .resizeAspect
        self.videoView.layer.insertSublayer(playerLayer, at: 0)
        self.playerLayer = playerLayer
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.playerLayer?.player?.removeObserver(self, forKeyPath: "timeControlStatus")
    }
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "timeControlStatus", let change = change, let newValue = change[NSKeyValueChangeKey.newKey] as? Int, let oldValue = change[NSKeyValueChangeKey.oldKey] as? Int {
            let oldStatus = AVPlayer.TimeControlStatus(rawValue: oldValue)
            let newStatus = AVPlayer.TimeControlStatus(rawValue: newValue)
            if newStatus != oldStatus {
                DispatchQueue.main.async {[weak self] in
                    if let status = newStatus {
                        switch status {
                        case .playing:
                            self?.activityIndicator.stopAnimating()
                            self?.playImage.isHidden = true
                            
                        case .paused:
                            self?.activityIndicator.stopAnimating()
                            self?.playImage.isHidden = false
                            
                        case .waitingToPlayAtSpecifiedRate:
                            self?.activityIndicator.startAnimating()
                            self?.playImage.isHidden = true
                        }
                    }
                }
            }
        }
    }
    
    deinit {
        self.playerLayer?.player?.removeObserver(self, forKeyPath: "timeControlStatus")
    }
    
    //MARK: Internal Methods
    func configure(with url: String) {
        var player = VideoCache.shared.getPlayer(for: url)
        if player == nil {
            player = self.player(with: url)
            if let player = player {
                VideoCache.shared.save(player: player, with: url)
            }
        }
        player?.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
        self.playerLayer?.player = player
    }
    
    //MARK: Private Methods
    private func player(with urlString: String) -> AVPlayer? {
        var player: AVPlayer?
        if let url = URL(string: urlString) {
            let asset = AVAsset(url: url)
            let playerItem = AVPlayerItem(asset: asset)
            player = AVPlayer(playerItem: playerItem)
        }
        return player
    }
}

class VideoCache {
    //MARK: Initializer
    private init() {}
    
    //Shared Object
    static let shared = VideoCache()
    
    //MARK: Private Properties
    private let cache = NSCache<NSString, AVPlayer>()
    
    //MARK: Internal Methods
    func save(player: AVPlayer, with key: String) {
        self.cache.setObject(player, forKey: key as NSString)
    }
    
    func getPlayer(for key: String) -> AVPlayer? {
        return self.cache.object(forKey: key as NSString)
    }
}
