//
//  SeeMoreViewController.swift
//  BEINIT
//
//  Created by Ankit Garg on 5/9/17.
//  Copyright © 2017 Cedricm Video. All rights reserved.
//

class SeeMoreViewController: BaseViewController
{
    @IBOutlet var tableView:UITableView!
    
    var TBVC:TabBarViewController!
    var t:String!
    var q:String!
    var users:[User]=[]
    var streams:[Stream]=[]
        
    override func viewWillAppear(_ animated:Bool)
    {
        self.title="\"\(q!)\" in \(t!)".uppercased()
        navigationController?.isNavigationBarHidden=false
        
        if t=="videos"
        {
            StreamConnector().searchMoreStreams(q, searchMoreStreamsSuccess, searchFailure)
        }
        else
        {
            StreamConnector().searchMoreOthers(q, t, searchMoreOthersSuccess, searchFailure)
        }
    }
    
    func tableView(_ tableView:UITableView, heightForRowAtIndexPath indexPath:IndexPath)->CGFloat
    {
        if t=="videos"
        {
            return 80
        }
        else
        {
            return 70
        }
    }

    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int)->Int
    {
        if t=="videos"
        {
            return streams.count
        }
        else
        {
            return users.count
        }
    }

    func tableView(_ tableView:UITableView, cellForRowAtIndexPath indexPath:IndexPath)->UITableViewCell
    {
        if t=="videos"
        {
            let cell=tableView.dequeueReusableCell(withIdentifier:"StreamCell", for:indexPath) as! SearchStreamCell
            let stream=streams[indexPath.row]
            cell.update(stream)
            
            cell.dotsButton.tag=indexPath.row
            cell.dotsButton.addTarget(self, action:#selector(dotsButtonTapped), for:.touchUpInside)
            
            cell.selectedBackgroundView=SelectedCellView().create()
            
            return cell
        }
        else
        {
            let cell=tableView.dequeueReusableCell(withIdentifier:"PeopleCell", for:indexPath) as! PeopleCell
            
            let user=users[indexPath.row]
            
            cell.userImageView.sd_setImage(with:user.avatarURL(), placeholderImage:UIImage(named:"profile"))
            cell.usernameLabel.text=user.name
            cell.likesLabel.text="\(user.followers) FOLLOWERS - \(user.desc)"
            
            cell.selectedBackgroundView=SelectedCellView().create()
            
            return cell
        }
    }

    func tableView(_ tableView:UITableView, didSelectRowAtIndexPath indexPath:IndexPath)
    {
        tableView.deselectRow(at:indexPath, animated:true)
        
        if t=="videos"
        {
            let playerVC=storyBoard.instantiateViewController(withIdentifier:"PlayerViewController") as! PlayerViewController
            
            playerVC.stream=streams[indexPath.row]
            playerVC.TBVC=TBVC
            
            TBVC.playerVC=playerVC
            TBVC.configure(streams[indexPath.row])
        }
        else
        {
            let vc=storyBoard.instantiateViewController(withIdentifier:"UserViewControllerId") as! UserViewController
            vc.user=users[indexPath.row]
            navigationController?.pushViewController(vc, animated:true)
        }
    }

    func searchMoreStreamsSuccess(streams:[Stream])
    {
        self.streams=streams
        
        tableView.reloadData()
    }
    
    func searchMoreOthersSuccess(users:[User])
    {
        self.users=users
        
        tableView.reloadData()
    }
    
    func searchFailure(error:NSError)
    {
        handleError(error)
    }
    
    func dotsButtonTapped(sender:UIButton)
    {
        let vc=storyBoard.instantiateViewController(withIdentifier:"PopUpViewController") as! PopUpViewController
        vc.stream=streams[sender.tag]
        present(vc, animated:true)
    }
}
