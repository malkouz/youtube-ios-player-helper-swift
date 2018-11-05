//
//  ViewController.swift
//  Example
//
//  Created by Moayad Al kouz on 7/23/18.
//  Copyright © 2018 Moayad Al kouz. All rights reserved.
//

import UIKit
import youtube_ios_player_helper_swift

class ViewController: UIViewController {

   private var playerView: PlayerView!
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        return .portrait
    }
    
    override var shouldAutorotate: Bool{
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playerView = UINib(nibName: "PlayerView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? PlayerView
        playerView.videoId = "ie8JQLLisao"
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addPlayerView()
    }
    
    private func addPlayerView(){
        self.view.addSubview(playerView)
        playerView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 240)
        playerView.autoresizingMask = .flexibleWidth
    }
    
    
    
    


}
