//
//  ViewController.swift
//  TableViewAVPlayer
//
//  Created by Payal Gupta on 28/02/19.
//  Copyright © 2019 Payal Gupta. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    //MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: Properties
    private var urls = [
        "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
        "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
        "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
        "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4",
        "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4",
        "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4",
        "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4",
        "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4",
        "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4",
        "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4",
        "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/VolkswagenGTIReview.mp4",
        "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WeAreGoingOnBullrun.mp4",
        "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WhatCarCanYouGetForAGrand.mp4"
    ]
    
    //MARK: Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.appEnteredFromBackground(_:)),
                                               name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.appEnteredToBackground),
                                               name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.playSingleVideo()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.playSingleVideo(pauseAll: true)
    }
}

// MARK: - UITableViewDataSource Methods
extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.urls.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! VideoCell
        cell.configure(with: self.urls[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate Methods
extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? VideoCell {
            cell.playerLayer?.player?.pause()
            cell.playerLayer?.player = nil
        }
    }
}

// MARK: - UIScrollViewDelegate Methods
extension ViewController {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.playSingleVideo()
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.playSingleVideo()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.playSingleVideo()
    }
}

// MARK: - Background Handling Methods
private extension ViewController {
    @objc func appEnteredToBackground() {
        self.playSingleVideo(pauseAll: true)
    }
    
    @objc func appEnteredFromBackground(_ notification: NSNotification) {
        self.playSingleVideo()
    }
}

// MARK: - Video Play Handling Methods
private extension ViewController {
    func playSingleVideo(pauseAll: Bool = false) {
        if let visibleCells = self.tableView.visibleCells as? [VideoCell], !visibleCells.isEmpty {
            if pauseAll {
                visibleCells.forEach { $0.playerLayer?.player?.pause() }
            } else {
                var maxHeightRequired: Int = 50
                var cellToPlay: VideoCell?
                
                visibleCells.reversed().forEach { (cell) in
                    let cellBounds = self.view.convert(cell.videoView.frame, from: cell.videoView)
                    let visibleCellHeight = Int(self.view.frame.intersection(cellBounds).height)
                    
                    if visibleCellHeight >= maxHeightRequired {
                        maxHeightRequired = visibleCellHeight
                        cellToPlay = cell
                    }
                }
                
                visibleCells.forEach { (cell) in
                    if cell === cellToPlay {
                        cell.playerLayer?.player?.play()
                    } else {
                        cell.playerLayer?.player?.pause()
                    }
                }
            }
        }
    }
}
