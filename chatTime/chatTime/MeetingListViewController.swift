//
//  FirstViewController.swift
//  chatTime
//
//  Created by 陈静 on 14-9-21.
//  Copyright (c) 2014年 Team chatTime. All rights reserved.
//

import UIKit
import CoreLocation

class MeetingListViewController: UIViewController, ResponseHandler{

    // master view
    @IBOutlet var masterView: UIView!
   
    // view ports
    @IBOutlet weak var stackView: UIView!
    
    @IBOutlet weak var knobControlView: UIView!
    // -- end view ports
    
    // global vars
    
    var lastPositionIndex :Int = 0
    
    var images: [UIImage] = []
    var imageViews : [UIImageView] = []
    
    var imageCache = Dictionary<Int, UIImage>()
    
    var pageNum = 0
    // UI每十个image一个page，用pageNum做分页，每次到底就刷新一次view，前后使用pageNumMapping做cache
    // 到第一页的时候再往前做refresh
    var meetings: [Meeting]! = []
    
    var knobControl : IOSKnobControl!
    
    var photoMap : [ NSNumber: Int] = Dictionary<NSNumber, Int>()
    
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    
    var isFirstRequest = true
    
    var isInitCall = true
    
    var refreshing = false
    
    var refreshingFinished = true
    
//    var currentIndex : Int = 0
    
    // -- end global vars
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        showSpinner()
        refreshing = true
        sendInitRequest()

    }
    
    func showSpinner(){
        masterView.addSubview(spinner)
        spinner.center = masterView.center
        spinner.startAnimating()
    }
    
    func hideSpinner(){
        spinner.stopAnimating()
        spinner.removeFromSuperview()
    }
    
    
    func sendInitRequest(){
        let initRequest = Utils.getRequest("getMeetingList")!
        let location: CLLocation = getLocation()
        initRequest.setParamValue("longitude", value: location.coordinate.longitude.description)
        initRequest.setParamValue("latitude", value: location.coordinate.latitude.description)
        initRequest.setParamValue("pagenum", value: String(pageNum))
        
        RequestHelper.sendRequest(initRequest, delegate: self)
    }
    
    func getLocation() -> CLLocation{
        //TODO use real data
        return CLLocation(latitude: CLLocationDegrees(0), longitude: CLLocationDegrees(0))
    }
    
    func initSubview(){
        // load images
        // TODO async
        // send init request to get the first 10 meetings
        
        //        images.append(UIImage(named: "item1")!)
        //        images.append(UIImage(named: "item2")!)
        //        images.append(UIImage(named: "item3")!)
        //        images.append(UIImage(named: "item4")!)
        
        let radius :Int = 800
        knobControl = getKnobControl(knobControlView, radius)
        
        // move to init
        //        for i in 0..<images.count{
        //            setImageAtIndex(knobControl, index: UInt(i), image: images[i])
        //        }
        
        knobControl.addTarget(self, action: "knobPositionChanged:", forControlEvents: UIControlEvents.ValueChanged)
        
        resetKnobControl(knobControl, positions: positions)
//        knobPositionChanged(knobControl)
        
        // initialize all other properties based on initial control values
        updateKnobProperties()
        
        //--------------------------------------------------
        //knob view finished
        
        //stack view starts
        let gesture = UITapGestureRecognizer(target: self, action: "handleTap:")
        stackView.addGestureRecognizer(gesture)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func handlePan(recognizer:UIPanGestureRecognizer) {
        let translation = recognizer.translationInView(stackView)
        
        if ( recognizer.state == UIGestureRecognizerState.Changed){
            //println("change")
        }
        if ( recognizer.state == UIGestureRecognizerState.Ended){
            //println("end")
            let x = translation.x
            
            if (abs(x) > 50)
            {
                let direction = abs(x) / x
                println("direction", direction)
                let nextIndex:Int = lastPositionIndex - Int(direction)
                
                println("move")
//                self.currentIndex = nextIndex
                let nextCandidate = animateStack(nextIndex, direction:direction)
                knobControl.positionIndex = nextCandidate
                lastPositionIndex = nextCandidate
                
            }
        }
    }
    
    func animateStack(nextIndex:Int, direction:CGFloat) -> Int
    {
        print("positionIndex")
        println(knobControl.positionIndex)
        print("last pos:")
        println(lastPositionIndex)
        
        println("nextIndex", nextIndex)
        let translationX = direction * 100
        
        if (nextIndex < 0 && pageNum == 0)
        {
            //TODO refresh
            println("TODO refresh from animate stack")
            refreshing = true
            loadAbsolutePage(0)
            return lastPositionIndex
        }
        
        if ( nextIndex < 0 && pageNum > 0){
            println("loading prev page from animate stack")
            loadRelativePage(-1)
            return lastPositionIndex
        }
        
        if (lastPositionIndex >= imageViews.count - 1 && direction < 0)
        {
            //TODO load more
            println("TODO load more")
            loadRelativePage(1)
            return lastPositionIndex
        }
        
        
        var theView: UIImageView = imageViews[lastPositionIndex]
        
        var thePrevView: UIImageView = imageViews[nextIndex]
        
        
        let indexForTopImage: Int = lastPositionIndex
        let indexForBottonImage: Int = nextIndex
        
        for view in imageViews
        {
            view.layer.zPosition = 0
        }
        
        if (direction < 0)
        {
            
            let topImageView = imageViews[indexForTopImage]
            topImageView.layer.zPosition = 2
            topImageView.transform = CGAffineTransformIdentity
            
            let bottomImageView = imageViews[indexForBottonImage]
            bottomImageView.layer.zPosition = 1
            bottomImageView.transform = CGAffineTransformIdentity
        }
        else //
        {
            
            let topImageView = imageViews[indexForBottonImage]
            topImageView.layer.zPosition = 2
            topImageView.alpha = 0.0
            topImageView.transform = CGAffineTransformMakeTranslation(-translationX, 0)
            
            let bottomImageView = imageViews[indexForTopImage]
            bottomImageView.layer.zPosition = 1
        }
        
        if (direction < 0)
        {
            UIView.animateWithDuration(0.5,
                delay: 0,
                options: UIViewAnimationOptions.CurveEaseInOut ,
                animations: {
                    theView.alpha = 0;
                    theView.transform = CGAffineTransformMakeTranslation(translationX, 0)
                }, completion: nil
            )
        }
        else
        {
            UIView.animateWithDuration(0.5,
                delay: 0,
                options: UIViewAnimationOptions.CurveEaseInOut ,
                animations: {
                    thePrevView.alpha = 1.0;
                    thePrevView.transform = CGAffineTransformIdentity
                }, completion: nil
            )
            
        }
        
        return nextIndex
    }
    
    
    func loadRelativePage(offset : Int){
        pageNum = pageNum + offset
        lastPositionIndex = 0
        clearKnobImage(knobControl)
        knobControl.positionIndex = 0
        sendInitRequest()
    }

    func loadAbsolutePage(_pageNum: Int){
        pageNum = _pageNum
        lastPositionIndex = 0
        clearKnobImage(knobControl)
        knobControl.positionIndex = 0
        sendInitRequest()
    }
    
    func setupStack(stackView: UIView, images: [UIImage])
    {
        for view in stackView.subviews {
            view.removeFromSuperview()
        }
        var zPositionIndex: CGFloat = 2
        for i in 0..<images.count{
            imageViews[i].layer.zPosition = zPositionIndex
            zPositionIndex = zPositionIndex - 1
            imageViews[i].center = stackView.center
            stackView.addSubview(imageViews[i])
        }
    
    }
    
    
    func setImages(knobControl: IOSKnobControl, images: [UIImage]) {
        knobControl.setImage(nil, forState: UIControlState.Normal)
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: knobControl.bounds.width, height: knobControl.bounds.height), false, 0)
        // CG context used across many calls
        var context = UIGraphicsGetCurrentContext()
        
        CGContextSetFillColorWithColor(context, UIColor.clearColor().CGColor)
        
        let imageX = knobControl.bounds.width/2
        let imageY = knobControl.bounds.height/2
        
        //center of knobControl
        let drawPoint = CGPoint(x:imageX,y:imageY)
        
        // angle between every image
        let angle :Double = M_PI * 2 / Double(positions)
        
        // strangely knobControl like to place the 0 index at bottom of the image, not top.
        // use offset to put the image into the right place, so the first image we place is at index 0
        let offset : Double = (angle / 2.0) - (angle * (Double(positions)/2.0))
        
        for index in 0..<images.count{
            drawImageWithRotation(context, image:images[index], rotation:CGFloat(Double(index) * angle + offset), point:drawPoint)
        }
        
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        knobControl.setImage(newImage, forState: UIControlState.Normal)
        knobControl.upper = Float((Double(images.count) - 0.51)  * angle + offset)
    }
    
    func setImageAtIndex(knobControl: IOSKnobControl, index: UInt, image: UIImage)
    {
        // using bounds is essential to get the correct size for the image, see frame vs. bounds in ios
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: knobControl.bounds.width, height: knobControl.bounds.height), false, 0)
//        
        knobControl.setImage(nil, forState: UIControlState.Normal)
        knobControl.setImage(nil, forState: UIControlState.Highlighted)
        knobControl.setImage(nil, forState: UIControlState.Disabled)
        knobControl.setImage(nil, forState: UIControlState.Selected)
//        var originalImage : UIImage! = knobControl.imageForState(UIControlState.Normal)
//        if (originalImage != nil){
//            originalImage!.drawAtPoint(CGPointMake(0, 0))
//        }
        
        
        // CG context used across many calls
        var context = UIGraphicsGetCurrentContext()
        
        CGContextSetFillColorWithColor(context, UIColor.clearColor().CGColor)
        
        let imageX = knobControl.bounds.width/2
        let imageY = knobControl.bounds.height/2
        
        //center of knobControl
        let drawPoint = CGPoint(x:imageX,y:imageY)
        
        // angle between every image
        let angle :Double = M_PI * 2 / Double(positions)
        
        // strangely knobControl like to place the 0 index at bottom of the image, not top.
        // use offset to put the image into the right place, so the first image we place is at index 0
        let offset : Double = (angle / 2.0) - (angle * (Double(positions)/2.0))
        
        drawImageWithRotation(context, image:image, rotation:CGFloat(Double(index) * angle + offset), point:drawPoint)
        
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        knobControl.setImage(newImage, forState: UIControlState.Normal)
        
    }
    
    //Util function to draw image in a circle
    func drawImageWithRotation (context: CGContext, image: UIImage, rotation: CGFloat, point: CGPoint)
    {
        let yOffset = CGFloat(20)
        CGContextSaveGState(context)
        //translate to center
        CGContextTranslateCTM(context, point.x, point.y)
        
        CGContextRotateCTM(context, rotation)
        
        
        image.drawAtPoint(CGPoint(x:-image.size.width/2, y: yOffset - point.y))
        CGContextRestoreGState(context)
    }
    
    func knobPositionChanged(sender: IOSKnobControl)
    {
        println("in knobPositionChanged")
        // display both the position and positionIndex properties
        let index = sender.positionIndex
        
        if ( lastPositionIndex != index ){
            // moved to a new index, update stack view
            if (lastPositionIndex >= imageViews.count - 1 && (lastPositionIndex - index) < 0)
            {
                // useless after added the upper bound for knob control position
//                //TODO load more
//                println("TODO load more")
//                println(sender.positionIndex)
//                println(sender.position)
            } else {
                let nextCandidate = animateStack(index, direction: CGFloat(lastPositionIndex - index))
                
                println(sender.positionIndex)
                println(sender.position)
                lastPositionIndex = nextCandidate
            }
            
            
        } else {
            // same position
            // reload when index = 0 and pageNum = 0, when not initializing(avoid infinite loop)
            // and when not during an on-going reloading process ( avoid infinite loop )
            if index == 0 && pageNum == 0 && !isInitCall && !refreshing{
                
                println("TODO refresh from knob position changed")
                refreshing = true
                loadAbsolutePage(0)
                refreshing = false
            } else if index == images.count - 1 {
            // load next page if index hits the last image index
                println("loading more")
                loadRelativePage(1)
                sendInitRequest()
            } else if ( index == 0 && pageNum > 0 && !refreshing){
                // load prev page
                println("loading prev page")
                loadRelativePage(-1)
            }
        }
    }
    
    func resetKnobControl(knobControl:IOSKnobControl, positions: UInt)
    {
        // angle between every image
        let angle :Double = M_PI * 2 / Double(positions)
        
        // strangely knobControl like to place the 0 index at bottom of the image, not top.
        // use offset to put the image into the right place, so the first image we place is at index 0
        let offset : Double = (angle / 2.0) - (angle * (Double(positions)/2.0))
        knobControl.setPosition(Float(offset), animated: false)
        knobControl.setImage(nil, forState: UIControlState.Normal)
        
    }
    
    // MARK: Internal methods
    func updateKnobProperties() {
        /*
        * Using exponentiation avoids compressing the scale below 1.0. The
        * slider starts at 0 in middle and ranges from -1 to 1, so the
        * time scale can range from 1/e to e, and defaults to 1.
        */
        knobControl.positions = positions
        knobControl.position = knobControl.position
    }
    
    @IBAction func unwindToMainScreen(segue: UIStoryboardSegue)
    {
    }

    
    func handleResponse(operation: AFHTTPRequestOperation, responseObject : AnyObject!){
        println("response")
        
        let url = operation.request.description
        println(url)
        
        let parts = url.pathComponents
        let parentReqString = parts[PARENT_REQ_COMPONENT_IDX]
        let reqString = parts[CHILD_REQ_COMPONENT_IDX]
        
        let parser = DDURLParser(URLString: url)
        
        if ( parentReqString == "meeting" && reqString.hasPrefix("getMeetingList"))
        {
            
            if (isFirstRequest){
                // first time request came back, need to populate views
                initSubview()
                isFirstRequest = false
            }
            
            let dict = responseObject as NSDictionary
            let json = JSONValue(dict)
            println(json.description)
            
            let meetingList = json["meetingList"].array!
            
            if (meetingList.count == 0){
                //TODO alert zero count, remind to refresh
            }
            
            populateMeetingContent(meetingList)
            
            hideSpinner()
            
            knobControl.position = knobControl.position
        }
        
        if (parentReqString == "user" && reqString.hasPrefix("getPhoto"))
        {
            // update photo
            let index = photoMap[parser.valueForVariable("picId").toInt()!]
            
        }
        refreshing = false
        refreshingFinished = true
        isInitCall = false
    }
    

    func populateMeetingContent(meetingList: [JSONValue]){
        initImages(meetingList.count)
        for meetingData in meetingList{
            let theMeeting = Meeting(data: meetingData)
            meetings.append(theMeeting)
            loadMeetingImage(theMeeting)
        }
    }
    

    func initImages(count: Int){
        images = [UIImage](count: count, repeatedValue: Utils.getPlaceholderImageLarge())
        imageViews = [UIImageView](count: count, repeatedValue: UIImageView())
        for i in 0..<imageViews.count{
            imageViews[i] = UIImageView(image: Utils.getPlaceholderImageLarge())
        }
    }
    
    
    func loadMeetingImage(meeting: Meeting){
        if let ownerId = meeting.ownerID?.integerValue
        {
            let photoIndex = meeting.pageNum! * itemsPerPage + meeting.index!
            
            photoMap[ownerId] = photoIndex
            
            if ( imageCache[ownerId] == nil){
                let picRequest = Utils.getRequest("getPicture")!
                picRequest.setParamValue("id", value: ownerId.description)
                println(picRequest.getURL()?.description)
                println(photoIndex)
                imageViews[meeting.index!].setImageWithURLRequest(picRequest.getURLRequest(), placeholderImage: Utils.getPlaceholderImageLarge(),
                    success:{ (request: NSURLRequest!, response: NSHTTPURLResponse!, image: UIImage!) -> Void in
                        self.images[meeting.index!] = image
                        self.imageViews[meeting.index!].image = image
                        self.imageCache[ownerId] = image
                        self.reloadImage()
                        println("on success with image")
                        println(photoIndex)
                        if ( request != nil ){
                            println(request.description)
                        }
                    }, failure:{
                        (request: NSURLRequest!, response: NSHTTPURLResponse!, error: NSError!) -> Void in
                        println("failed to load image")
                    }
                )
            } else {
                let image: UIImage = imageCache[ownerId]!
                self.images[meeting.index!] = image
                self.imageViews[meeting.index!].image = image
                self.reloadImage()
            }
        }
        else
        {
            println("ERROR: owner photo id not available: \(meeting.meetingId)")
        }
    }
    
    
    func reloadImage(){
        // images and imageViews should be consistent
        // move to init
        clearKnobImage(knobControl)
        
        setImages(knobControl, images: self.images)
        
        setupStack(stackView, images: images)
        
    }
    
    func clearKnobImage(knobControl: IOSKnobControl){
//        UIGraphicsBeginImageContextWithOptions(CGSize(width: knobControl.bounds.width, height: knobControl.bounds.height), false, 0)
//        var context = UIGraphicsGetCurrentContext()
//
//        CGContextSetFillColorWithColor(context, UIColor.clearColor().CGColor)
//
//        let newImage = UIGraphicsGetImageFromCurrentImageContext()
//        
//        UIGraphicsEndImageContext()
//        
//        knobControl.setImage(newImage, forState: UIControlState.Normal)
        knobControl.setImage(nil, forState: UIControlState.Normal)
    }
    
    func handleFailure(operation: AFHTTPRequestOperation, responseObject : AnyObject!){
        //TODO
        println("Failure")
        
        let dict = responseObject as NSDictionary
        let json = JSONValue(dict)
        let status = json["status"].string!
        let alert = UIAlertView()
        println(messages["error"])
        //        alert.title = messages["error"].string!
        alert.message = messages[status].string
        alert.addButtonWithTitle(messages["ok"].string!)
        alert.show()
    }
    
    
    func handleError(operation: AFHTTPRequestOperation, error: NSError!){
        println("Error")
        //TODO
        let status = "networkError"
        let alert = UIAlertView()
        println(messages["error"])
        //        alert.title = messages["error"].string!
        alert.message = messages[status].string
        alert.addButtonWithTitle(messages["ok"].string!)
        alert.show()
    }
}

