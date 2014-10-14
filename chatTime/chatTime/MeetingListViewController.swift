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
    
    var images: [UIImage]! = []
    var imageViews : [UIImageView]! = []
    
    var pageNum = 0
    // UI每十个image一个page，用pageNum做分页，每次到底就刷新一次view，前后使用pageNumMapping做cache
    // 到第一页的时候再往前做refresh
    var meetings: [Meeting]! = []
    
    var knobControl : IOSKnobControl!
    
    var photoMap : [ NSNumber: Int] = Dictionary<NSNumber, Int>()
    
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    
    var isFirstRequest = true
    
//    var currentIndex : Int = 0
    
    // -- end global vars
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        showSpinner()
        
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
        knobPositionChanged(knobControl)
        
        // initialize all other properties based on initial control values
        updateKnobProperties()
        
        //--------------------------------------------------
        //knob view finished
        
        //stack view starts
        
        
        // move to init
        //        setupStack(stackView, images: images)
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
        
        if (nextIndex < 0)
        {
            //TODO refresh
            println("TODO refresh")
            return lastPositionIndex
        }
        
        if (lastPositionIndex >= images.count - 1 && direction < 0)
        {
            //TODO load more
            println("TODO load more")
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

    
    func setupStack(stackView: UIView, images: [UIImage])
    {
        var zPositionIndex: CGFloat = 2
        for image in images{
            let imageView = UIImageView(image: image)
            imageViews.append(imageView)
            imageView.layer.zPosition = zPositionIndex
            zPositionIndex = zPositionIndex - 1
            imageView.center = stackView.center
            stackView.addSubview(imageView)
        }
        
        
        let gesture = UITapGestureRecognizer(target: self, action: "handleTap:")
        stackView.addGestureRecognizer(gesture)
    }
    
    func setImageAtIndex(knobControl: IOSKnobControl, index: UInt, image: UIImage)
    {
        // using bounds is essential to get the correct size for the image, see frame vs. bounds in ios
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: knobControl.bounds.width, height: knobControl.bounds.height), false, 0)
        
        var originalImage : UIImage! = knobControl.imageForState(UIControlState.Normal)
        if (originalImage != nil){
            originalImage!.drawAtPoint(CGPointMake(0, 0))
        }
        
        
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
        // display both the position and positionIndex properties
        let index = sender.positionIndex
        
        if ( lastPositionIndex != index ){
//            self.currentIndex = sender.positionIndex
            let nextCandidate = animateStack(sender.positionIndex, direction: CGFloat(lastPositionIndex - index))
            
            println(sender.positionIndex)
            println(sender.position)
            lastPositionIndex = nextCandidate

        } else if index == 0 {
            println("TODO refresh")
            // TODO refresh
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
            }
            
            let dict = responseObject as NSDictionary
            let json = JSONValue(dict)
            println(json.description)
            
            let meetingList = json["meetingList"].array!
            
            populateMeetingContent(meetingList)
            
            hideSpinner()
        }
        
        if (parentReqString == "user" && reqString.hasPrefix("getPhoto"))
        {
            // update photo
            let index = photoMap[parser.valueForVariable("picId").toInt()!]
            
        }
    }
    

    func populateMeetingContent(meetingList: [JSONValue]){
        for meetingData in meetingList{
            let theMeeting = Meeting(data: meetingData)
            meetings.append(theMeeting)
            loadMeetingImage(theMeeting)
        }
    }
    
    
    func loadMeetingImage(meeting: Meeting){
        if let ownerId = meeting.ownerID?.integerValue
        {
            let photoIndex = meeting.pageNum! * itemsPerPage + meeting.index!
            
            photoMap[ownerId] = photoIndex
            
            let picRequest = Utils.getRequest("getPicture")!
            picRequest.setParamValue("id", value: ownerId.description)
            imageViews[photoIndex].setImageWithURL(picRequest.getURL())
        }
        else
        {
            println("ERROR: owner photo id not available: \(meeting.meetingId)")
        }
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

