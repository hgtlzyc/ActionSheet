//
//  ActionSheetView.swift
//  GUActionSheet
//
//  Created by lijia xu on 8/10/21.
//

import UIKit


// MARK: - ActionSheetViewmodel
struct ActionSheetInfo {
    let image: UIImage
    let title: String
    var isSelected: Bool = false
}

struct ActionSheetVM {
    let allowsMultiSelect: Bool
    let actionSheetTitle: String
    var listingData: [ActionSheetInfo]
        
    init(title: String, dataToDisplay: [ActionSheetInfo], allowsMultiSelect: Bool = false) {
        self.actionSheetTitle = title
        self.listingData = dataToDisplay
        self.allowsMultiSelect = allowsMultiSelect
    }
    
}///End Of ActionSheetVM

protocol ActionSheetViewDelegate: AnyObject {
    ///NEED to Release the reference to the Action Sheet View
    func ActionSheetViewRequestedDismiss()
    
    func ActionSheetViewActionUpdated(_ actionSheetInfos: [ActionSheetInfo])
        
}

class ActionSheetView: UIView {
    // MARK: - View Visual Properties
    private var blurViewAlpha: CGFloat
    
    // MARK: - View Layout Guideline Constants
    private let nonPhoneWidthInFloat: CGFloat = 375
    private let maxActionSheetHeightInFloat: CGFloat = 400
    
    //Table View Related
    private let actionTableViewRowHeight: CGFloat = 76
    private let tableViewTopToContainerTop: CGFloat = 75
    
    //Other Components
    private let indicatorViewHeight: CGFloat = 6
    private let titleTextFontSize: CGFloat = 18
    
    // MARK: - View Visual Constants
    private let actionSheetCornerRadiusFloat: CGFloat = 20
    private let topIndicatorViewGrayAlpha: CGFloat = 0.5
    
    // MARK: - Coumpted Layout properties
    private lazy var actionSheetWidthInFloat: CGFloat = {
        let deviceIdiom = UIDevice.current.userInterfaceIdiom
        switch deviceIdiom {
        case .phone:
            return frame.width
        default:
            return nonPhoneWidthInFloat
        }
        
    }()
    
    private lazy var bottomSafeAreaHeight: CGFloat = {
        return safeAreaLayoutGuide.layoutFrame.height
    }()
    
    // MARK: - Views
    private lazy var blurView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.backgroundColor = .gray
        blurEffectView.alpha = blurViewAlpha
        
        return blurEffectView
    }()
    
    private lazy var actionSheetContainerView: UIView = {
        let container = UIView()
        container.layer.cornerRadius = actionSheetCornerRadiusFloat
        container.backgroundColor = .systemBackground
        
        return container
    }()
    
    private lazy var indicatorView: UIView = {
        let indicator = UIView()
        indicator.backgroundColor = .gray
        indicator.alpha = topIndicatorViewGrayAlpha
        
        return indicator
    }()
    
    private lazy var titleTextView: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: titleTextFontSize)
        
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        
        return tableView
    }()
    
    // MARK: - Source of truth
    private let actionSheetCellIdentifer = "actionSheetCell"
    
    private var viewModel: ActionSheetVM

    weak var delegate: ActionSheetViewDelegate?
    
    // MARK: - View Lifecycle
    init(viewModel: ActionSheetVM,
         delegate: ActionSheetViewDelegate,
         inFrame: CGRect,
         withBlur: CGFloat = 0.6 ) {
        
        self.viewModel = viewModel
        self.delegate = delegate
        self.blurViewAlpha = withBlur
                
        super.init(frame: inFrame)
        
        setupViews()
        
    }///End Of Init
    
    // MARK: - Tap on the blur view will call this method
    @objc func dismissActionSheet() {
        checkDelegateAssigned()?.ActionSheetViewRequestedDismiss()
    }///End Of dismissActionSheet
    
    
    // MARK: - Required
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}///End Of ActionSheetView

// MARK: - ActionSheetTableViewRelated
extension ActionSheetView: UITableViewDataSource, UITableViewDelegate {
    
    func setupTableView() {
        tableView.rowHeight = actionTableViewRowHeight
        
        //visual
        tableView.alwaysBounceVertical = false
        tableView.separatorStyle = .none
        
        //delegates
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(ActionSheetTableViewCell.self, forCellReuseIdentifier: actionSheetCellIdentifer)

    }///End Of setupTableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.listingData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: actionSheetCellIdentifer, for: indexPath) as? ActionSheetTableViewCell else {
            print("Unexpected case in \(#function)")
            return UITableViewCell()
        }
        
        let actionInfo = viewModel.listingData[indexPath.row]
        
        cell.updateViews(actionInfo, actionTableViewRowHeight)
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedIndex = indexPath.row
        let allowMultiSelection = viewModel.allowsMultiSelect
        
        switch allowMultiSelection{
        case true:
            viewModel.listingData[selectedIndex].isSelected.toggle()
            tableView.reloadRows(at: [indexPath], with: .automatic)
            
        //handle when not allowing multi selection
        case false:
            let currentlyTrueIndexes = viewModel.listingData.enumerated()
                .filter { (n,actionInfo) in
                    actionInfo.isSelected
                }.map { (n,_) in
                    n
                }
            
            currentlyTrueIndexes.forEach { n in
                viewModel.listingData[n].isSelected = false
            }
            
            viewModel.listingData[selectedIndex].isSelected = true
            
            tableView.reloadData()
                
           
            
        }///End Of switch allowMultiSelection
        
    }///End Of didSelectRowAt
    
}///End Of TableViewRelated

// MARK: - ViewLayout Setup
extension ActionSheetView {
    
    // MARK: - Setup Views
    private func setupViews(){
        //base blur view related
        addSubview(blurView)
        blurView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissActionSheet) )
        blurView.addGestureRecognizer(tap)
        
        //action sheet view related
        addSubview(actionSheetContainerView)
        
        //height based on the tableView content or the max allowed
        let estHeightBasedOnTableView = CGFloat(viewModel.listingData.count) * actionTableViewRowHeight + tableViewTopToContainerTop + bottomSafeAreaHeight + titleTextFontSize
        let maxHeightBasedOnTheGuide = maxActionSheetHeightInFloat + bottomSafeAreaHeight
        let targetBaseHeight = min(estHeightBasedOnTableView, maxHeightBasedOnTheGuide)
        
        actionSheetContainerView.setDimensions(
            height: targetBaseHeight + actionSheetCornerRadiusFloat,
            width: actionSheetWidthInFloat
        )
        actionSheetContainerView.anchor(bottom: bottomAnchor, paddingBottom: -actionSheetCornerRadiusFloat )
        actionSheetContainerView.centerX(inView: self)
        
        //indicator view related
        actionSheetContainerView.addSubview(indicatorView)
        indicatorView.centerX(inView: actionSheetContainerView)
        indicatorView.anchor(top: actionSheetContainerView.topAnchor, paddingTop: 15.5)
        indicatorView.setDimensions(height: indicatorViewHeight, width: 56)
        indicatorView.layer.cornerRadius = indicatorViewHeight/2
        
        //title label view related
        actionSheetContainerView.addSubview(titleTextView)
        titleTextView.anchor(top: actionSheetContainerView.topAnchor,
                             left: actionSheetContainerView.leftAnchor,
                             right: actionSheetContainerView.rightAnchor,
                             paddingTop: 37,
                             paddingLeft: 16,
                             paddingRight: 16 )
        
        titleTextView.setDimensions(height: titleTextFontSize)
        titleTextView.text = viewModel.actionSheetTitle
        
        //tableViewRelated
        actionSheetContainerView.addSubview(tableView)
        tableView.anchor(top: actionSheetContainerView.topAnchor,
                         left: actionSheetContainerView.leftAnchor,
                         bottom: actionSheetContainerView.safeAreaLayoutGuide.bottomAnchor,
                         right: actionSheetContainerView.rightAnchor,
                         paddingTop: tableViewTopToContainerTop)
        
        setupTableView()
        
    }///End Of SetupViews
    
}///End Of Extension

// MARK: - Info Helper
extension ActionSheetView {
    private func checkDelegateAssigned() -> ActionSheetViewDelegate? {
        guard let delegate = delegate else {
            //Just in case the init method changed
            print("""
                Please assign delegate to the ActionSheetView
                to handle Dismiss
                """)
            return nil
        }
        
        return delegate
    }
}
