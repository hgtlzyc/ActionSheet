//
//  ActionSheetView.swift
//  GUActionSheet
//
//  Created by lijia xu on 8/10/21.
//

import UIKit

// MARK: - ActionSheetViewmodel
struct ActionSheetVM {
    let actionSheetTitle: String
    let listingData: [(image: UIImage, title: String)]
    
    init(title: String, dataToDisplay: (UIImage, String) ) {
        self.actionSheetTitle = title
        self.listingData = [(dataToDisplay.0, dataToDisplay.1)]
        
    }
    
    init(title: String, dataToDisplay: [(UIImage, String)] ) {
        self.actionSheetTitle = title
        self.listingData = dataToDisplay.map{ (image: $0.0, title: $0.1 ) }
    }
    
}///End Of ActionSheetVM

protocol ActionSheetViewDelegate: AnyObject {
    func ActionSheetViewShouldDismiss()
    func userSelected(index: Int)
}

extension ActionSheetViewDelegate {
    func userSelected(index: Int) {
        print(index)
    }
}

class ActionSheetView: UIView {
    // MARK: - View Visual Properties
    private var blurViewAlpha: CGFloat
    
    // MARK: - View Layout Guideline Constants
    private let nonPhoneWidthInFloat: CGFloat = 375
    private let maxActionSheetHeightInFloat: CGFloat = 400
    
    //Table View Related
    private let actionTableViewRowHeight: CGFloat = 110
    private let tableViewTopToContainerTop: CGFloat = 75
    
    //Other Components
    private let indicatorViewHeight: CGFloat = 6
    private let titleTextFontSize: CGFloat = 18
    
    // MARK: - View Visual Constants
    private let actionSheetCornerRadiusFloat: CGFloat = 20
    private let topIndicatorViewGrayAlpha: CGFloat = 0.6
    
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
    
    // MARK: -
    private let viewModel: ActionSheetVM
    weak var delegate: ActionSheetViewDelegate?
    
    // MARK: - View Lifecycle
    init(viewModel: ActionSheetVM,
         parentViewFrame: CGRect,
         delegate: ActionSheetViewDelegate,
         withBlur: CGFloat = 0.6 ) {
        
        self.viewModel = viewModel
        self.delegate = delegate
        self.blurViewAlpha = withBlur
        
        super.init(frame: parentViewFrame)
        
        setupViews()
        
    }///End Of Init
    
    // MARK: - Tap on the blur view will call this method
    @objc func shoulDismissActionSheet() {

        checkDelegateAssigned()?.ActionSheetViewShouldDismiss()
        
    }///End Of shouldDismissActionSheet
    
    
    // MARK: - Required
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}///End Of ActionSheetView

// MARK: - ActionSheetTableViewRelated
extension ActionSheetView: UITableViewDataSource, UITableViewDelegate {
    
    func setupTableView() {
        tableView.rowHeight = actionTableViewRowHeight
        tableView.alwaysBounceVertical = false
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.separatorStyle = .none
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.listingData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.backgroundColor = .red
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}///End Of TableViewRelated

// MARK: - ViewLayout Setup
extension ActionSheetView {
    
    // MARK: - Setup Views
    private func setupViews(){
        //base blur view related
        addSubview(blurView)
        blurView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(shoulDismissActionSheet) )
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
