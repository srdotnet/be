//
//  TabBarViewController.swift
//  BEINIT
//
//  Created by Dominic Granito on 29/12/2016.
//  Copyright © 2016 UniProgy s.r.o. All rights reserved.
//

import Photos

class TabBarViewController: UITabBarController, UITabBarControllerDelegate
{
    @IBOutlet var vtabBar:UITabBar!
    @IBOutlet var miniPlayerView:UIView!
    @IBOutlet var videoTitleLbl:MarqueeLabel!
    @IBOutlet var videoArtistLbl:UILabel!
    @IBOutlet var videoThumbnailImageView:UIImageView!
    @IBOutlet var backgroundImageView:UIImageView!
    @IBOutlet var seekBar:UISlider!
    @IBOutlet var playButton:UIButton!
    
    var animator:ARNTransitionAnimator!
    var playerVC:PlayerViewController!
    let site=Config.shared.site()
    let storyBoard=UIStoryboard(name:"Main", bundle:nil)
    
    override func viewDidLoad()
    {
        seekBar.setThumbImage(UIImage(), for:.normal)
        
        var y:CGFloat=0
        
        if UIScreen.main.bounds.height>667
        {
            y=view.frame.size.height-133
        }
        else
        {
            y=view.frame.size.height-99
        }
        
        miniPlayerView.frame=CGRect(x:0, y:y, width:view.frame.size.width, height:50)
        view.addSubview(miniPlayerView)
        miniPlayerView.isHidden=true
        
        getPermissions()
        
        NotificationCenter.default.addObserver(self, selector:#selector(goToChannels), name:Notification.Name("goToChannels"), object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(hideMiniPlayer), name:Notification.Name("hideMiniPlayer"), object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(goToDownloads), name:Notification.Name("goToDownloads"), object:nil)
    }
    
    override func viewWillAppear(_ animated:Bool)
    {
        UIApplication.shared.setStatusBarHidden(false, with:.slide)
    }
    
    @IBAction func play()
    {
        if playerVC.player?.playbackState == .playing
        {
            playerVC.player?.pause()
            
            playButton?.setImage(UIImage(named:"miniplay"), for:.normal)
        }
        else
        {
            playerVC.player?.play()
            
            playButton?.setImage(UIImage(named:"minipause"), for:.normal)
        }
    }
    
    func hideMiniPlayer()
    {
        miniPlayerView.isHidden=true
    }
    
    func updateSeekBar()
    {
        if let player=playerVC.player
        {
            seekBar.maximumValue=Float(playerVC.player!.duration)
            seekBar.value=Float(player.currentPlaybackTime)
        }
        
        if playerVC.player?.playbackState == .playing
        {
            playButton?.setImage(UIImage(named:"minipause"), for:.normal)
        }
        else
        {
            playButton?.setImage(UIImage(named:"miniplay"), for:.normal)
        }
    }
        
    func updateMiniPlayerWithStream(_ stream:Stream)
    {
        miniPlayerView.isHidden=false
        
        videoTitleLbl.text=stream.title
        videoArtistLbl.text=stream.user.name
        videoThumbnailImageView.sd_setImage(with:URL(string:"\(site)/thumb/\(stream.id).jpg"), placeholderImage:UIImage(named:"stream"))
        backgroundImageView.sd_setImage(with:URL(string:"\(site)/thumb/\(stream.id).jpg"))
    }
    
    func configure(_ stream:Stream)
    {
        setupAnimator()
        updateMiniPlayerWithStream(stream)
        tapMiniPlayerButton()
    }
    
    func goToDownloads(notification:Notification)
    {
        let vc=storyBoard.instantiateViewController(withIdentifier:"OfflineViewController") as! OfflineViewController
        vc.stream=notification.object as? Stream
        
        let navigationController=self.viewControllers![self.selectedIndex] as! UINavigationController
        navigationController.pushViewController(vc, animated:true)
    }
    
    func goToChannels(notification:Notification)
    {
        let vc=storyBoard.instantiateViewController(withIdentifier:"UserViewControllerId") as! UserViewController
        vc.user=notification.object as? User
        
        let navigationController=self.viewControllers![self.selectedIndex] as! UINavigationController
        navigationController.pushViewController(vc, animated:true)
    }
    
    @IBAction func tapMiniPlayerButton()
    {
        let value=UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey:"orientation")

        present(playerVC, animated:true)
    }
    
    func tabBarController(_ tabBarController:UITabBarController, shouldSelect viewController:UIViewController)->Bool
    {
        let tabViewControllers=tabBarController.viewControllers
        let fromIndex=tabViewControllers?.index(of:tabBarController.selectedViewController!)
        
        UserDefaults.standard.set(fromIndex!, forKey:"previousTab")
        
        return true
    }
    
    func setupAnimator()
    {
        let animation=MusicPlayerTransitionAnimation(rootVC:self, playerVC:playerVC)
        
        animation.completion={isPresenting in
            
            if isPresenting
            {
                let modalGestureHandler=TransitionGestureHandler(targetVC:self, direction:.bottom)
                modalGestureHandler.registerGesture(self.playerVC.view)
                modalGestureHandler.panCompletionThreshold=15.0
                self.animator.registerInteractiveTransitioning(.dismiss, gestureHandler:modalGestureHandler)
            }
            else
            {
                self.setupAnimator()
            }
        }
        
        let gestureHandler=TransitionGestureHandler(targetVC:self, direction:.top)
        gestureHandler.registerGesture(miniPlayerView)
        gestureHandler.panCompletionThreshold=15.0
        
        animator=ARNTransitionAnimator(duration:0.5, animation:animation)
        animator.registerInteractiveTransitioning(.present, gestureHandler:gestureHandler)
        
        playerVC.transitioningDelegate=animator
    }
    
    func getPermissions()
    {
        if NSClassFromString("PHPhotoLibrary") != nil
        {
            PHPhotoLibrary.requestAuthorization{(status)->Void in}
        }
        
        if UserContainer.shared.logged().subscription==""||UserContainer.shared.logged().subscription=="free"
        {
            viewControllers?.remove(at:2)
        }
        else
        {
            if AVCaptureDevice.responds(to:#selector(AVCaptureDevice.requestAccess(forMediaType:completionHandler:)))
            {
                AVCaptureDevice.requestAccess(forMediaType:AVMediaTypeVideo, completionHandler:{(granted)->Void in})
            }
            
            if(AVAudioSession.sharedInstance().responds(to:#selector(AVAudioSession.requestRecordPermission(_:))))
            {
                AVAudioSession.sharedInstance().requestRecordPermission({(granted:Bool)->Void in})
            }
        }
    }
}
