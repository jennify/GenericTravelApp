//
// ItineraryViewController.swift
// =============================


import UIKit
import FoldingCell


@objc(ItineraryViewController)

class ItineraryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate, Dimmable {
    
    // Main views
    let travellersView: TravellersView = TravellersView.newAutoLayoutView()
    let addTravellerButtonContainer: UIView = UIView.newAutoLayoutView()
    let addTravellerButton: UIButton = UIButton.newAutoLayoutView()
    let addTravellerIcon: UIImageView = UIImageView.newAutoLayoutView()
    let tripDetailsView: UIView = UIView.newAutoLayoutView()
    let itineraryTableView: UITableView = UITableView.newAutoLayoutView()
    let calendarView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Horizontal
        return UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
    }()
    
    // State
    let backgroundColor: UIColor = UIColor.fomoBackground()
    var itinerary: Itinerary = Itinerary.generateTestInstance()
    var isNewTrip: Bool = false
    var hideSectionHeaders = false
    var didSetupConstraints = false

    // Cell State
    var cellHeights = [[CGFloat]]()
    var kCloseCellHeight: CGFloat = FoldingTripEventCell.topViewHeight + 8 // equal or greater foregroundView height
    let kOpenCellHeight: CGFloat = FoldingTripEventCell.detailsViewHeight + 8 // equal or greater containerView height

    // Travellers view
    var travellersHeightConstraint: NSLayoutConstraint?
    var tripDetailsViewHeightConstraint: NSLayoutConstraint?
    var overviewViewHeightConstraint: NSLayoutConstraint?
    var currentBannerHeight: CGFloat = 50.0
    var originalBannerHeight: CGFloat = 50.0
    var destinationBannerHeight: CGFloat = 100.0
    
    // Overview view
    let overviewView: UIView = UIView.newAutoLayoutView()
    let cityImageView: UIImageView = UIImageView.newAutoLayoutView()
    var blurView: UIVisualEffectView = UIVisualEffectView.newAutoLayoutView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Cache.itinerary != nil && !isNewTrip {
            self.itinerary = Cache.itinerary!
        } else {
            Cache.itinerary = itinerary
        }
        
        setUpItineraryTableView()
        setUpCalendarView()
        setUpNavigationBar()
        setUpOverview()
    }
    
    func setUpOverview() {
        initScrollView()
        let effect = UIBlurEffect(style: .ExtraLight)
        blurView = UIVisualEffectView(effect: effect)
        cityImageView.image = City.getCoverPhoto(itinerary.tripName!)
        
        cityImageView.addSubview(blurView)
        overviewView.addSubview(cityImageView)
    }
    
    override func loadView() {
        view = UIView()
        
        tripDetailsView.backgroundColor = backgroundColor
        calendarView.backgroundColor = backgroundColor
        travellersView.backgroundColor = backgroundColor
        addTravellerButtonContainer.backgroundColor = backgroundColor

        overviewView.addSubview(travellersView)
        overviewView.addSubview(addTravellerButtonContainer)
        overviewView.addSubview(tripDetailsView)
        overviewView.addSubview(calendarView)
        view.addSubview(overviewView)
        view.addSubview(itineraryTableView)

        addTravellerIcon.image = UIImage(named: "plus")
        addTravellerIcon.image = addTravellerIcon.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        addTravellerButton.setImage(addTravellerIcon.image, forState: .Normal)
        addTravellerButton.tintColor = UIColor.whiteColor()
        addTravellerButton.addTarget(self, action: "onAddTravellerPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        
        addTravellerButtonContainer.addSubview(addTravellerButton)

        view.setNeedsUpdateConstraints()
    }

    override func updateViewConstraints() {
        if (!didSetupConstraints) {
            overviewView.autoPinToTopLayoutGuideOfViewController(self, withInset: 0)
            overviewView.autoPinEdgeToSuperviewEdge(.Left)
            overviewView.autoPinEdgeToSuperviewEdge(.Right)
            overviewViewHeightConstraint = overviewView.autoSetDimension(.Height, toSize: 200).autoIdentify("overviewViewHeight")
            
            travellersView.autoPinEdgeToSuperviewEdge(.Top)
            travellersHeightConstraint = travellersView.autoSetDimension(.Height, toSize: travellersView.faceHeight + 16).autoIdentify("travellersViewHeight")

            travellersView.autoPinToTopLayoutGuideOfViewController(self, withInset: 0)
            travellersView.autoSetDimension(.Height, toSize: travellersView.faceHeight + 16 )

            travellersView.autoPinToTopLayoutGuideOfViewController(self, withInset: 0)
            travellersView.autoSetDimension(.Height, toSize: travellersView.faceHeight + 16 )
            travellersView.autoPinEdgeToSuperviewEdge(.Left)
            travellersView.autoPinEdge(.Right, toEdge: .Left, ofView: addTravellerButtonContainer)

            addTravellerButtonContainer.autoPinToTopLayoutGuideOfViewController(self, withInset: 0)
            addTravellerButtonContainer.autoPinEdgeToSuperviewEdge(.Right)
            addTravellerButtonContainer.autoMatchDimension(.Height, toDimension: .Height, ofView: travellersView)
            addTravellerButton.autoSetDimension(.Height, toSize: 30)
            addTravellerButton.autoSetDimension(.Width, toSize: 30)
            addTravellerButton.autoAlignAxisToSuperviewAxis(.Horizontal)
            addTravellerButton.autoPinEdgeToSuperviewEdge(.Right, withInset: 15)
            
            tripDetailsView.autoPinEdgeToSuperviewEdge(.Left)
            tripDetailsView.autoPinEdgeToSuperviewEdge(.Right)
            tripDetailsViewHeightConstraint = tripDetailsView.autoSetDimension(.Height, toSize: 40).autoIdentify("tripDetailsViewHeight")
            tripDetailsView.autoPinEdge(.Top, toEdge: .Bottom, ofView: travellersView)

            calendarView.autoPinEdgeToSuperviewEdge(.Left)
            calendarView.autoPinEdgeToSuperviewEdge(.Right)
            calendarView.autoSetDimension(.Height, toSize: 70)
            calendarView.autoPinEdge(.Top, toEdge: .Bottom, ofView: tripDetailsView)

            itineraryTableView.autoPinEdge(.Top, toEdge: .Bottom, ofView: calendarView)
            itineraryTableView.autoPinEdgeToSuperviewEdge(.Left)
            itineraryTableView.autoPinEdgeToSuperviewEdge(.Right)
            itineraryTableView.autoPinEdgeToSuperviewEdge(.Bottom)
            itineraryTableView.estimatedRowHeight = 100
            itineraryTableView.rowHeight = UITableViewAutomaticDimension
            
            cityImageView.autoPinEdgesToSuperviewEdges()
            blurView.autoPinEdgesToSuperviewEdges()

            didSetupConstraints = true
        }

        super.updateViewConstraints()
    }

    func setUpNavigationBar() {
        self.title = "Itinerary"
    }

    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if cell is FoldingTripEventCell {
            let foldingCell = cell as! FoldingTripEventCell
            
            if cellHeights[indexPath.section][indexPath.row] == kCloseCellHeight {
                foldingCell.selectedAnimation(false, animated: false, completion:nil)
            } else {
                foldingCell.selectedAnimation(true, animated: false, completion: nil)
            }
        }
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return cellHeights[indexPath.section][indexPath.row]
    }
    
    // Add Traveller
    
    func onAddTravellerPressed(sender: AnyObject) {
        self.performSegueWithIdentifier("friendsSegue", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "friendsSegue" {
            dim(.In, alpha: 0.5, speed: 0.5)
        }
    }
    
    @IBAction func unwindFromPopup(segue: UIStoryboardSegue) {
        dim(.Out, speed: 0.5)
    }
    
    // Itinerary Methods

    func setUpItineraryTableView() {
        
        for dayNum in 0...itinerary.days!.count-1 {
            cellHeights.append([CGFloat]())
            for _ in 0...itinerary.days![dayNum].tripEvents!.count-1 {
                cellHeights[dayNum].append(kCloseCellHeight)
            }
        }
        
        itineraryTableView.delegate = self
        itineraryTableView.dataSource = self
        itineraryTableView.registerClass(TripEventCell.self, forCellReuseIdentifier: "CodePath.Fomo.TripEventCell")
        itineraryTableView.registerClass(DayHeaderCell.self, forHeaderFooterViewReuseIdentifier: "CodePath.Fomo.DayHeaderCell")
        itineraryTableView.registerClass(FoldingTripEventCell.self, forCellReuseIdentifier: "CodePath.Fomo.FoldingTripEventCell")
        itineraryTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        itineraryTableView.backgroundColor = backgroundColor

    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return itinerary.numberDays()
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == itinerary.numberDays() - 1 {
            return itinerary.days![section].tripEvents!.count - 1 + 1
        }
        return itinerary.days![section].tripEvents!.count - 1
    }
    
    func isLastTableViewCell(indexPath: NSIndexPath) -> Bool {
        return indexPath.section == itinerary.numberDays() - 1  && indexPath.row == itinerary.days![indexPath.section - 1].tripEvents!.count - 1
    }
    


    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Check if this is the footer cell.
        if isLastTableViewCell(indexPath) {
            let footer = ItineraryFooter()
            footer.backgroundColor = backgroundColor
            footer.parentVC = self
            return footer
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("CodePath.Fomo.FoldingTripEventCell", forIndexPath: indexPath) as! FoldingTripEventCell
        
        cell.attraction = itinerary.days![indexPath.section].tripEvents![indexPath.row].attraction
        cell.parentView = self.view
        cell.contentView.backgroundColor = backgroundColor
        if !cell.didAwake {
            cell.awakeFromNib()
            cell.didAwake = true
        }

        return cell
    }

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if self.hideSectionHeaders {
            let hiddenSectionHeader = UIView()
            hiddenSectionHeader.backgroundColor = UIColor.clearColor()
            hiddenSectionHeader.alpha = 0.0
            return hiddenSectionHeader
        }
        let cell = tableView.dequeueReusableHeaderFooterViewWithIdentifier("CodePath.Fomo.DayHeaderCell") as! DayHeaderCell
        configureHeaderCell(cell, section: section)
        return cell
    }
    

    func configureHeaderCell(cell: DayHeaderCell, section: Int) {
        cell.dayName.text = "DAY \(section + 1)"
        cell.dayName.font = UIFont(name: "AppleSDGothicNeo-Thin", size: 20)
        cell.contentView.backgroundColor = backgroundColor
    }

    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        itineraryTableView.deselectRowAtIndexPath(indexPath, animated: true)
        if isLastTableViewCell(indexPath) {
            displayTodo("Move to explore page!")
            return
        }
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! FoldingTripEventCell

        var duration = 0.0
        if cellHeights[indexPath.section][indexPath.row] == kCloseCellHeight { // open cell
            cellHeights[indexPath.section][indexPath.row] = kOpenCellHeight
            cell.selectedAnimation(true, animated: true, completion: nil)
            duration = 0.4
        } else {// close cell
            cellHeights[indexPath.section][indexPath.row] = kCloseCellHeight
            cell.selectedAnimation(false, animated: true, completion: nil)
            self.hideSectionHeaders = true
            duration = 0.8

        }
//        tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: true)
        
        UIView.animateWithDuration(duration, delay: 0, options: .CurveEaseOut, animations: { () -> Void in
            tableView.beginUpdates()
            tableView.endUpdates()
        }) {
            (b: Bool) in
            if self.hideSectionHeaders {
                self.hideSectionHeaders = false
                UIView.animateWithDuration(0.3, delay: duration + 5, options: .TransitionCrossDissolve, animations: { () -> Void in
                    self.itineraryTableView.reloadData()
                    
                }, completion: nil)
            }
        }
    }

    // Calendar Methods

    func setUpCalendarView() {
        calendarView.delegate = self
        calendarView.dataSource = self
        calendarView.registerClass(DayCell.self, forCellWithReuseIdentifier: "CodePath.Fomo.DayCell")
        calendarView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itinerary.numberDays() + 1
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CodePath.Fomo.DayCell", forIndexPath: indexPath) as! DayCell
        configureDayCell(cell, indexPath: indexPath)
        return cell
    }

    func configureDayCell(cell: DayCell, indexPath: NSIndexPath) {
        let numberDays = itinerary.numberDays()
        if indexPath.row < numberDays {
            cell.dayNum = indexPath.row + 1
            cell.dayName.text = "\(indexPath.row + 1)"
            cell.dayLabel.text = "DAY"
            cell.additionLabel.text = ""
        } else {
            cell.dayNum = nil
            cell.dayLabel.text = ""
            cell.dayName.text = ""
            cell.additionLabel.text = "+"
        }
        
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row < itinerary.numberDays() {
            let itineraryIndexPath = NSIndexPath(forRow: 0, inSection: indexPath.row)
            itineraryTableView.scrollToRowAtIndexPath(itineraryIndexPath, atScrollPosition: .Top, animated: true)
        } else {
            displayTodo("Add a day")
        }
    }

    func displayTodo(todo: String) {
        let alertController = UIAlertController(title: "Fomo", message:"TODO: \(todo)", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
        presentViewController(alertController, animated: true, completion: nil)
    }
}

extension ItineraryViewController: UIScrollViewDelegate {
    
    func initScrollView() {
        currentBannerHeight = 50
        destinationBannerHeight = 10
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let yOffset = scrollView.contentOffset.y + 44
        if yOffset < 0  {
            currentBannerHeight = originalBannerHeight - yOffset
            
        } else if(yOffset < originalBannerHeight - destinationBannerHeight) {
            currentBannerHeight = originalBannerHeight - yOffset
            
        } else {
            currentBannerHeight = destinationBannerHeight
            
        }
    }
    
    func updateBanner() {
        overviewViewHeightConstraint?.constant = currentBannerHeight
        print(currentBannerHeight)
        self.updateViewConstraints()
//        travellersHeightConstraint?.constant = currentBannerHeight
//        tripDetailsViewHeightConstraint?.constant =
        
    }
}