//
//  VideosViewController.swift
//  BEINIT
//
//  Created by Ankit Garg on 3/9/17.
//  Copyright © 2017 Cedricm Video. All rights reserved.
//

class VideosViewController: BaseViewController
{
    var vType:Int!
    var TBVC:TabBarViewController!
    var favouriteStreams:[NSManagedObject]!
    let site=Config.shared.site()
        
    override func viewDidLoad()
    {
        if vType==1
        {
            self.title="FAVOURITE VIDEOS"
        }

        TBVC=tabBarController as! TabBarViewController
        
        favouriteStreams=SongManager.getFavourites(vType)
    }
    
    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int)->Int
    {
        return favouriteStreams.count
    }
    
    func tableView(_ tableView:UITableView, cellForRowAtIndexPath indexPath:IndexPath)->UITableViewCell
    {
        let cell=tableView.dequeueReusableCell(withIdentifier:"RecentStreamCell") as! RecentStreamCell
        
        cell.streamNameLabel.text=favouriteStreams![indexPath.row].value(forKey: "streamTitle") as? String
        cell.userLabel.text=favouriteStreams![indexPath.row].value(forKey: "streamUserName") as? String
        cell.playImageView.sd_setImage(with:URL(string:"\(site)/thumb/\(favouriteStreams![indexPath.row].value(forKey:"streamID") as! Int).jpg"), placeholderImage:UIImage(named:"stream"))
        
        cell.dotsButton.tag=indexPath.row
        cell.dotsButton.addTarget(self, action:#selector(dotsButtonTapped), for:.touchUpInside)
        
        cell.selectedBackgroundView=SelectedCellView().create()
        
        return cell
    }
    
    func dotsButtonTapped(sender:UIButton)
    {
        let vc=storyBoard.instantiateViewController(withIdentifier:"PopUpViewController") as! PopUpViewController
        vc.stream=makeStreamClassObject(sender.tag)
        present(vc, animated:true)
    }
    
    func tableView(_ tableView:UITableView, didSelectRowAtIndexPath indexPath:IndexPath)
    {
        tableView.deselectRow(at:indexPath, animated:true)
        
        let playerVC=storyBoard.instantiateViewController(withIdentifier:"PlayerViewController") as! PlayerViewController
        
        playerVC.stream=makeStreamClassObject(indexPath.row)
        playerVC.TBVC=TBVC
        
        TBVC.playerVC=playerVC
        TBVC.configure(makeStreamClassObject(indexPath.row))
    }
    
    func makeStreamClassObject(_ row:Int)->Stream
    {
        let user=User()
        
        user.name=favouriteStreams[row].value(forKey:"streamUserName") as! String
        user.id=favouriteStreams[row].value(forKey:"streamUserID") as! Int
        
        let stream=Stream()
        
        stream.id=favouriteStreams[row].value(forKey:"streamID") as! Int
        stream.title=favouriteStreams[row].value(forKey:"streamTitle") as! String
        stream.streamHash=favouriteStreams[row].value(forKey:"streamHash") as! String
        stream.videoID=favouriteStreams[row].value(forKey:"streamKey") as! String
        stream.user=user
        
        return stream
    }
}
