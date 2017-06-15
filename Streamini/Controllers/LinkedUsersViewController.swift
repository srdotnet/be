//
//  LinkedUsersViewController.swift
//  Streamini
//
//  Created by Vasily Evreinov on 06/08/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

class LinkedUsersViewController: BaseViewController, UserStatisticsDelegate, StreamSelecting,UserSelecting {
    @IBOutlet weak var selectorView: SelectorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyLabel: UILabel!
    
    var dataSource: UserStatisticsDataSource?
    var profileDelegate: ProfileDelegate?
    var TBVC:TabBarViewController!
    
    func userDidSelected(_ user:User)
    {
        let vc=storyBoard.instantiateViewController(withIdentifier: "UserViewControllerId") as! UserViewController
        vc.user=user
        navigationController?.pushViewController(vc, animated:true)
    }
    
    func configureView()
    {
        tableView.tableFooterView=UIView()
        emptyLabel.text=NSLocalizedString("table_no_data", comment:"")
        
        tableView.addPullToRefresh
        {()->Void in
            self.dataSource!.reload()
        }

        tableView.addInfiniteScrolling
        {()->Void in
            self.dataSource!.fetchMore()
        }
    }
    
    override var supportedInterfaceOrientations:UIInterfaceOrientationMask
    {
        return .portrait
    }
    
    override var shouldAutorotate:Bool
    {
        return false
    }
    
    override func viewDidLoad()
    {
        configureView()
    }
    
    func streamDidSelected(_ stream:Stream)
    {
        let modalVC=storyBoard.instantiateViewController(withIdentifier: "ModalViewController") as! ModalViewController
        
        let streamsArray=NSMutableArray()
        streamsArray.add(stream)
        
        modalVC.streamsArray=streamsArray
        modalVC.TBVC=TBVC
        
        TBVC.modalVC=modalVC
        TBVC.configure(stream)
    }
    
    func openPopUpForSelectedStream(_ stream:Stream)
    {
        let vc=storyBoard.instantiateViewController(withIdentifier:"PopUpViewController") as! PopUpViewController
        vc.stream=stream
        present(vc, animated:true, completion:nil)
    }

    func reload()
    {
        
    }

    func recentStreamsDidSelected(_ userId: UInt) {
        tableView.showsPullToRefresh     = false
        tableView.showsInfiniteScrolling = false
        selectorView.selectSection(0)
        self.dataSource = RecentStreamsDataSource(userId: userId, tableView: tableView)
        dataSource!.streamSelectedDelegate = self
        dataSource!.profileDelegate = profileDelegate
        dataSource!.clean()
        dataSource!.reload()
    }
    
    func followersDidSelected(_ userId: UInt) {
        tableView.showsPullToRefresh     = true
        tableView.showsInfiniteScrolling = true
        selectorView.selectSection(1)
        self.dataSource = FollowersDataSource(userId: userId, tableView: tableView)
        dataSource!.profileDelegate = profileDelegate
        dataSource!.userSelectedDelegate=self
        dataSource!.clean()
        dataSource!.reload()
    }
    
    func followingDidSelected(_ userId:UInt)
    {
        tableView.showsPullToRefresh     = true
        tableView.showsInfiniteScrolling = true
        selectorView.selectSection(2)
        self.dataSource = FollowingDataSource(userId: userId, tableView: tableView)
        dataSource!.profileDelegate = profileDelegate
        dataSource!.userSelectedDelegate=self
        dataSource!.clean()        
        dataSource!.reload()
    }
}
