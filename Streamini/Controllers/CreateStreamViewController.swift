//
//  LiveStreamViewController.swift
//  Streamini
//
//  Created by Vasily Evreinov on 29/06/15.
//  Copyright (c) 2015 Evghenii Todorov. All rights reserved.
//

import AVFoundation
import CoreLocation

class CreateStreamViewController: BaseViewController, UITextFieldDelegate, LocationManagerDelegate, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource
{
    @IBOutlet var previewView: UIView!
    @IBOutlet var darkPreviewView: UIView!
    @IBOutlet var nameTextView: UITextView!
    @IBOutlet var nameTextViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var connectingIndicator: UIActivityIndicatorView!
    @IBOutlet var connectingLabel: UILabel!
    @IBOutlet var goLiveButtonBottom: NSLayoutConstraint! // 240
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var categoryPicker: UIPickerView!
    @IBOutlet var categoryLabelWidthConstraint: NSLayoutConstraint!
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var locationLabelWidthConstraint: NSLayoutConstraint!
    @IBOutlet var categoryPickerConstraint: NSLayoutConstraint!
    @IBOutlet var closeButton: UIButton!
    @IBOutlet var goLiveButton: UIButton!
    @IBOutlet var trashButton: UIButton!
    
    var stream: Stream?
    let camera = Camera()
    var keyboardHandler: CreateStreamKeyboardHandler?
    var textViewHandler: GrowingTextViewHandler?
    var categories = [Category]()
    var selectedCategory = Category()
    var keep = 0
    var user: User?
        
    @IBAction func trashTapped(_ sender: AnyObject)
    {
        if(keep == 0)
        {
            keep = 1;
            trashButton.setImageTintColor(UIColor(white: 0.5, alpha: 1.0), for: UIControlState.normal)
        } else {
            keep = 0;
            trashButton.setImageTintColor(UIColor(white: 1.0, alpha: 1.0), for: UIControlState.normal)
        }
    }
    
    @IBAction func liveStreamButtonPressed(_ sender: AnyObject) {
        let data = NSMutableDictionary(objects: [nameTextView.text, selectedCategory.id, keep], forKeys: ["title" as NSCopying, "category" as NSCopying, "keep" as NSCopying])
        
        if let pm = LocationManager.shared.currentPlacemark {
            data["lon"]  = pm.location!.coordinate.longitude
            data["lat"]  = pm.location!.coordinate.latitude
            data["city"] = pm.locality
        }
        
        connectingIndicator.startAnimating()
        connectingLabel.isHidden=false
        goLiveButton.isHidden=true
        
        if AmazonTool.isAmazonSupported() {
            StreamConnector().create(data, createStreamSuccess, createStreamFailure)
        } else {
            let filename = "screenshot.jpg"
            let screenshotData = UIImageJPEGRepresentation(camera.captureStillImage()!, 1.0)!
          
            StreamConnector().createWithFile(filename, screenshotData as NSData, data, createStreamSuccess, createStreamFailure)
        }
    }
    
    func showModal()
    {
        //let alert=SCLAlertView()
        let appearance = SCLAlertView.SCLAppearance(
            kTitleFont: UIFont(name: "HelveticaNeue", size: 20)!,
            kTextFont: UIFont(name: "HelveticaNeue", size: 14)!,
            kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
            showCloseButton: false
        )
        
        let alert = SCLAlertView(appearance: appearance)
        alert.addButton("Upgrade", target:self, selector:Selector("firstButton"))
        alert.addButton("Cancel")
        {
            self.tabBarController?.selectedIndex=UserDefaults.standard.integer(forKey:"previousTab")
            LocationManager.shared.stopMonitoringLocation()
        }
    
        //alert.showCustom("PREMIUM FEATURE", subTitle:"Get unlimited live streams with BEINIT.")
        alert.showSuccess("PREMIUM FEATURE", subTitle:"Get unlimited live streams with BEINIT.")
    }
    
    @IBAction func closeButtonPressed()
    {
        UIApplication.shared.setStatusBarHidden(false, with:.fade)
        
        self.tabBarController?.selectedIndex=UserDefaults.standard.integer(forKey:"previousTab")
        
        LocationManager.shared.stopMonitoringLocation()
        
        camera.stop()
    }
    
    func createStreamSuccess(_ stream:Stream)
    {
        self.stream = stream
        
        LocationManager.shared.stopMonitoringLocation()
        
        camera.start(stream.streamHash, streamId: stream.id)
        
        if AmazonTool.isAmazonSupported() {
            let screenshot = camera.captureStillImage()!
            let filename = "\(user!.id)-\(stream.id)-screenshot.jpg"
            AmazonTool.shared.uploadImage(screenshot, name: filename)
        }
        //let imageView =  UIImage(named: filename)
//        if WXApi.isWXAppInstalled()
//        {
//            let screenshot = camera.captureStillImage()!
//            let filename = "\(UserContainer.shared.logged().id)-\(stream.id)-screenshot.jpg"
//            let videoObject=WXVideoObject()
//            videoObject.videoUrl="http://conf.cedricm.com/\(stream.streamHash)/\(stream.id)"
//            
//            let message=WXMediaMessage()
//            message.title=stream.title
//            message.description=stream.user.name
//            message.mediaObject=videoObject
//            message.setThumbImage(screenshot)
//            
//            let req=SendMessageToWXReq()
//            req.message=message
//            req.scene=1
//            
//            WXApi.sendReq(req)
//        }

        //let twitter = SocialToolFactory.getSocial("Twitter")!
        //let url = "\(Config.shared.twitter().tweetURL)/\(stream.streamHash)/\(stream.id)"
        //twitter.post(user!.name, live: URL(string: url)!)
        
        self.performSegue(withIdentifier:"CreateStreamToLiveStream", sender:self)
    }
    
    func createStreamFailure(_ error:NSError)
    {
        handleError(error)
        connectingIndicator.stopAnimating()
        connectingLabel.isHidden=true
        goLiveButton.isHidden=false
    }
    
    func categoriesSuccess(_ cats:[Category])
    {
        self.categories = cats
        if(cats.count > 0) {
            self.selectedCategory = cats[0]
            updateCategory()
        }
        categoryPicker.reloadAllComponents()
    }
    
    func categoriesFailure(_ error:NSError)
    {
        handleError(error)
    }
    
    // MARK: - LocationManagerDelegate
    
    func locationDidChanged(_ currentLocation: CLLocationCoordinate2D?, locality: String) {
        // Set location text
        locationLabel.text = locality
        
        // Set width constraint corresponds to the locality string lenght
        let size = locationLabel.sizeThatFits(locationLabel.bounds.size)
        locationLabelWidthConstraint.constant = size.width + 10
        locationLabel.backgroundColor = .white
        self.view.layoutIfNeeded()
    }
    
    func configureView()
    {
        // Configure "go live" button
        let goLiveButtonText = NSLocalizedString("go_live_button", comment: "")
        goLiveButton.setTitle(goLiveButtonText, for: UIControlState.normal)
        
        // Configure NameTextView
        var nameTextViewFrame = nameTextView.frame
        nameTextViewFrame.size.height = 36.0
        nameTextView.frame = nameTextViewFrame
        
        // GrowingTextViewHandler resizes NameTextView according to input text
        self.textViewHandler = GrowingTextViewHandler(textView: nameTextView, withHeightConstraint: nameTextViewHeightConstraint)
        textViewHandler!.updateMinimumNumber(ofLines: 1, andMaximumNumberOfLine: 6)
        textViewHandler!.setText("", withAnimation: false)
        
        // Set placeholder for NameTextView
        nameTextView.tintColor = .white
        let placeholderText = NSLocalizedString("stream_name_placeholder", comment: "")
        applyPlaceholderStyle(nameTextView, placeholderText: placeholderText)
        
        // Configure connecting label
        let connectingLabelText = NSLocalizedString("connecting_stream_label", comment: "")
        connectingLabel.text = connectingLabelText
        
        keyboardHandler = CreateStreamKeyboardHandler(view: view, constraint: goLiveButtonBottom, pickerConstraint: categoryPickerConstraint)
        
        // Category label
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(CreateStreamViewController.categoryTapped(_:)))
        categoryLabel.addGestureRecognizer(tapGesture)
        categoryLabel.isUserInteractionEnabled = true
        categoryLabel.textColor = .white
        self.categoryPicker.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        // connect category picker
        self.categoryPicker.delegate = self
        self.categoryPicker.dataSource = self
        
        trashButton.setImageTintColor(UIColor(white: 1.0, alpha: 1.0), for: UIControlState.normal)
        trashButton.setImageTintColor(UIColor(white: 1.0, alpha: 1.0), for: UIControlState.highlighted)
    }
    
    func updateCategory()
    {
        let text = String(format: "%@: %@", NSLocalizedString("category", comment: ""), selectedCategory.name);
        categoryLabel.textColor = .white
        categoryLabel.text = text;
        // Set width constraint corresponds to the locality string lenght
        let size = categoryLabel.sizeThatFits(categoryLabel.bounds.size)
        categoryLabelWidthConstraint.constant = size.width + 10
        categoryLabel.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.view.layoutIfNeeded()
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        configureView()
        
        LocationManager.shared.delegate = self
        LocationManager.shared.startMonitoringLocation()
        
        StreamConnector().categories(categoriesSuccess, categoriesFailure)
    }
    
    override func viewWillAppear(_ animated:Bool)
    {
        nameTextView.becomeFirstResponder()
        
        self.navigationController!.setNavigationBarHidden(true, animated:false)
        (tabBarController as! TabBarViewController).miniPlayerView.isHidden=true
        super.viewWillAppear(animated)
        keyboardHandler!.register()
        
        UIApplication.shared.setStatusBarHidden(true, with:.none)
        
//        user=UserContainer.shared.logged()
//        
//        if user!.subscription=="free"||user!.subscription==""
//        {
//            showModal()
//        }
    }
    
    override func viewDidAppear(_ animated:Bool)
    {
        camera.setup(previewView)
        darkPreviewView.layer.addDarkGradientLayer()
    }
    
    override func viewWillDisappear(_ animated:Bool)
    {
        keyboardHandler!.unregister()
    }
    
    override func viewDidDisappear(_ animated:Bool)
    {
        connectingIndicator.stopAnimating()
        connectingLabel.isHidden=true
        goLiveButton.isHidden=false
    }
    
    override func prepare(for segue:UIStoryboardSegue, sender:Any?)
    {
        if let sid = segue.identifier
        {
            if sid == "CreateStreamToLiveStream"
            {
                let controller = segue.destination as! LiveStreamViewController
                controller.camera = camera
                controller.stream = stream
            }
        }
    }
    
    func moveCursorToStart(_ textView: UITextView)
    {
        DispatchQueue.main.async(execute: {
            textView.selectedRange = NSMakeRange(0, 0);
        })
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView.textColor == UIColor(white: 1.0, alpha: 0.5)
        {
            // move cursor to start
            moveCursorToStart(textView)
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        textView.text = textView.text.handleEmoji()
        self.textViewHandler!.resizeTextView(withAnimation: true)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        var updatedText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        updatedText = updatedText.handleEmoji()
        
        // Seach for new lines. Don't alow user to insert new lines in stream title
        let newLineRange: Range? = updatedText.rangeOfCharacter(from:CharacterSet.newlines)
        
        let shouldEdit = (updatedText.characters.count < 80) && (newLineRange == nil)
        if !shouldEdit {
            return false
        }
        
        if updatedText.isEmpty {
            let placeholderText = NSLocalizedString("stream_name_placeholder", comment: "")
            applyPlaceholderStyle(textView, placeholderText: placeholderText)
            moveCursorToStart(textView)
            return false
        }
        
        // Remove placeholder text if it is shown
        if nameTextView.textColor == UIColor(white: 1.0, alpha: 0.5) && !text.isEmpty {
            nameTextView.text = ""
            applyNonPlaceholderStyle(textView)
            return true
        }
        
        return true
    }
    
    func applyPlaceholderStyle(_ aTextview:UITextView, placeholderText:String)
    {
        // make it look (initially) like a placeholder
        aTextview.textColor = UIColor(white: 1.0, alpha: 0.5)
        aTextview.text = placeholderText
    }
    
    func applyNonPlaceholderStyle(_ aTextview:UITextView)
    {
        // make it look like normal text instead of a placeholder
        aTextview.textColor = .white
        aTextview.alpha = 1.0
    }
    
    deinit
    {
        camera.stop()
    }
    
    func categoryTapped(_ sender:UITapGestureRecognizer)
    {
        nameTextView.resignFirstResponder()
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.categoryPickerConstraint.constant = 0.0
            self.goLiveButtonBottom.constant = 216.0 + 10.0
            self.view.layoutIfNeeded()
        })
    }
    
    func numberOfComponents(in pickerView:UIPickerView)->Int
    {
        return 1
    }
    
    func pickerView(_ pickerView:UIPickerView, numberOfRowsInComponent component:Int)->Int
    {
        return categories.count
    }
    
    func pickerView(_ pickerView:UIPickerView, titleForRow row:Int, forComponent component:Int)->String?
    {
        return categories[row].name
    }
    
    func pickerView(_ pickerView:UIPickerView, didSelectRow row:Int, inComponent component:Int)
    {
        self.selectedCategory=categories[row]
        updateCategory()
    }
}
