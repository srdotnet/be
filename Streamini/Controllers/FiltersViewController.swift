//
//  FiltersViewController.swift
//  BEINIT
//
//  Created by Ankit Garg on 4/6/17.
//  Copyright © 2017 Cedricm Video. All rights reserved.
//

class FiltersViewController: UIViewController
{
    @IBOutlet var backgroundImageView:UIImageView?
    
    let menuItemTitlesArray:NSMutableArray=["Custom", "Title", "Artist", "Recently Added"]

    var backgroundImage:UIImage!
        
    override func viewDidLoad()
    {
        backgroundImageView?.image=backgroundImage
    }
    
    @IBAction func closeButtonPressed()
    {
        dismiss(animated: true, completion:nil)
    }
    
    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int)->Int
    {
        return 4
    }
    
    func tableView(_ tableView:UITableView, cellForRowAtIndexPath indexPath:IndexPath)->UITableViewCell
    {
        let cell=tableView.dequeueReusableCell(withIdentifier:"MenuCell") as! MenuCell
        
        cell.menuItemTitleLbl?.text=menuItemTitlesArray[indexPath.row] as? String
        
        return cell
    }
}
