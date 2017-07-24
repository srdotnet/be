//
//  HomeViewController.swift
//  Streamini
//
//  Created by Ankit Garg on 9/8/16.
//  Copyright © 2016 UniProgy s.r.o. All rights reserved.
//

class HomeViewController: BaseViewController
{
    @IBOutlet var itemsTbl:UITableView?
    @IBOutlet var errorView:ErrorView!
    @IBOutlet var activityView:ActivityIndicatorView!
    @IBOutlet var headerView:GSKStretchyHeaderView!
    
    var categoryNamesArray=NSMutableArray()
    var categoryIDsArray=NSMutableArray()
    var allCategoryItemsArray=NSMutableArray()
    var timer:Timer?
    let site=Config.shared.site()
    
    override func viewDidLoad()
    {
        NotificationCenter.default.addObserver(self, selector:#selector(updateUI), name:Notification.Name("refreshAfterBlock"), object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(updateUI), name:Notification.Name("status"), object:nil)
        
        itemsTbl?.addSubview(headerView)
        
        updateUI()
    }
    
    func updateUI()
    {
        let appDelegate=UIApplication.shared.delegate as! AppDelegate
        
        if appDelegate.reachability.isReachable
        {
            errorView.isHidden=true
            activityView.isHidden=false
            
            view.bringSubview(toFront:activityView)
            StreamConnector().homeStreams(successStreams, failureStream)
        }
        else
        {
            itemsTbl!.isHidden=true
            activityView.isHidden=true
            errorView.update("No Internet Connection", "user")
        }
    }
    
    func reload()
    {
        let appDelegate=UIApplication.shared.delegate as! AppDelegate
        
        if appDelegate.reachability.isReachable
        {
            errorView.isHidden=true
            
            StreamConnector().homeStreams(successStreams, failureStream)
        }
        else
        {
            itemsTbl!.isHidden=true
            errorView.update("No Internet Connection", "user")
        }
    }
    
    override func viewWillAppear(_ animated:Bool)
    {
        navigationController?.isNavigationBarHidden=true
        
        timer=Timer.scheduledTimer(timeInterval:15, target:self, selector:#selector(reload), userInfo:nil, repeats:true)
    }
    
    override func viewWillDisappear(_ animated:Bool)
    {
        //timer!.invalidate()
    }
    
    func tableView(_ tableView:UITableView, heightForRowAtIndexPath indexPath:IndexPath)->CGFloat
    {
        return (view.frame.size.width-25)/2+85
    }

    func tableView(_ tableView:UITableView, heightForHeaderInSection section:Int)->CGFloat
    {
        return 200
    }
    
    func tableView(_ tableView:UITableView, viewForHeaderInSection section:Int)->UIView?
    {
        let headerView=UIView(frame:CGRect(x:0, y:0, width:tableView.frame.size.width, height:60))
        headerView.backgroundColor=UIColor(red:18/255, green:19/255, blue:21/255, alpha:1)
        
        let titleLbl=UILabel(frame:CGRect(x:10, y:10, width:view.frame.size.width-20, height:180))
        
        if(allCategoryItemsArray.count>0)
        {
            titleLbl.text=(categoryNamesArray[section] as AnyObject).uppercased
        }
        
        titleLbl.font=UIFont.systemFont(ofSize:24)
        titleLbl.textColor=UIColor(red:190/255, green:142/255, blue:64/255, alpha:1)
        titleLbl.layer.borderColor=UIColor(red:190/255, green:142/255, blue:64/255, alpha:1).cgColor
        titleLbl.layer.borderWidth=1
        titleLbl.textAlignment = .center
        
        let categoryImageView=UIImageView(frame:CGRect(x:0, y:0, width:view.frame.size.width, height:200))
        categoryImageView.sd_setImage(with:URL(string:"\(site)/media/bg_\(categoryIDsArray[section]).png"))
        
        let tapGesture=UITapGestureRecognizer(target:self, action:#selector(headerTapped))
        headerView.addGestureRecognizer(tapGesture)
        headerView.tag=section
        
        headerView.addSubview(categoryImageView)
        headerView.addSubview(titleLbl)
        
        return headerView
    }
    
    func headerTapped(gestureRecognizer:UITapGestureRecognizer)
    {
        let vc=storyBoard.instantiateViewController(withIdentifier:"CategoriesViewController") as! CategoriesViewController
        vc.categoryName=categoryNamesArray[gestureRecognizer.view!.tag] as? String
        vc.categoryID=categoryIDsArray[gestureRecognizer.view!.tag] as? Int
        navigationController?.pushViewController(vc, animated:true)
    }
    
    func numberOfSectionsInTableView(_ tableView:UITableView)->Int
    {
        return categoryNamesArray.count
    }
    
    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int)->Int
    {
        return 1
    }
    
    func tableView(_ tableView:UITableView, cellForRowAtIndexPath indexPath:IndexPath)->UITableViewCell
    {
        let cell=tableView.dequeueReusableCell(withIdentifier:"cell") as! CategoryRow
        
        if(allCategoryItemsArray.count>0)
        {
            cell.TBVC=tabBarController as! TabBarViewController
            cell.oneCategoryItemsArray=allCategoryItemsArray[indexPath.section] as! NSArray
            cell.sectionTitle=categoryNamesArray[indexPath.section] as? String
        }
        
        return cell
    }
    
    func tableView(_ tableView:UITableView, willDisplayCell cell:UITableViewCell, forRowAtIndexPath indexPath:IndexPath)
    {
        let cell=cell as! CategoryRow
        
        cell.reloadCollectionView()
    }
    
    func successStreams(data:NSDictionary)
    {
        errorView.isHidden=true
        activityView.isHidden=true
        
        categoryNamesArray=NSMutableArray()
        categoryIDsArray=NSMutableArray()
        allCategoryItemsArray=NSMutableArray()
        
        let categories=data["data"] as! NSArray
        
        for i in 0 ..< categories.count
        {
            let category=categories[i] as! NSDictionary
            
            let categoryName=category["category_name"] as! String
            let categoryID=category["category_id"] as! Int
            
            categoryNamesArray.add(categoryName)
            categoryIDsArray.add(categoryID)
            
            let videos=category["videos"] as! NSArray
            
            let oneCategoryItemsArray=NSMutableArray()
            
            for j in 0 ..< videos.count
            {
                let video=videos[j] as! NSDictionary
                
                let videoID=video["id"] as! Int
                let streamKey=video["streamkey"] as! String
                let vType=video["vtype"] as! Int
                let videoTitle=video["title"] as! String
                let videoHash=video["hash"] as! String
                let lon=video["lon"] as! Double
                let lat=video["lat"] as! Double
                let city=video["city"] as! String
                let ended=video["ended"] as? String
                let viewers=video["viewers"] as! Int
                let tviewers=video["tviewers"] as! Int
                let rviewers=video["rviewers"] as! Int
                let likes=video["likes"] as! Int
                let rlikes=video["rlikes"] as! Int
                
                let user=video["user"] as! NSDictionary
                
                let userID=user["id"] as! Int
                let userName=user["name"] as! String
                let userAvatar=user["avatar"] as? String
                
                let oneUser=User()
                
                oneUser.id=UInt(userID)
                oneUser.name=userName
                oneUser.avatar=userAvatar
                
                let oneVideo=Stream()
                oneVideo.id=UInt(videoID)
                oneVideo.vType=vType
                oneVideo.videoID=streamKey
                oneVideo.title=videoTitle
                oneVideo.streamHash=videoHash
                oneVideo.lon=lon
                oneVideo.lat=lat
                oneVideo.city=city
                
                if let e=ended
                {
                    oneVideo.ended=NSDate(timeIntervalSince1970:Double(e)!)
                }
                
                oneVideo.viewers=UInt(viewers)
                oneVideo.tviewers=UInt(tviewers)
                oneVideo.rviewers=UInt(rviewers)
                oneVideo.likes=UInt(likes)
                oneVideo.rlikes=UInt(rlikes)
                oneVideo.user=oneUser
                
                oneCategoryItemsArray.add(oneVideo)
            }
            
            allCategoryItemsArray.add(oneCategoryItemsArray)
        }
        
        itemsTbl!.reloadData()
        itemsTbl!.isHidden=false
    }
    
    func failureStream(error:NSError)
    {
        activityView.isHidden=true
        errorView.update("An error occured", "user")
    }
}
