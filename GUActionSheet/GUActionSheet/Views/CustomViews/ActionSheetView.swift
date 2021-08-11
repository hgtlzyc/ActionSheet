//
//  ActionSheetView.swift
//  GUActionSheet
//
//  Created by lijia xu on 8/10/21.
//

import UIKit


// MARK: - ActionSheetViewModel
struct ActionSheetInfo {
    let imageURL: String
    let title: String
    var isSelected: Bool
}

struct ActionSheetVM {
    let allowsMultiSelect: Bool
    let actionSheetTitle: String
    var infoArray: [ActionSheetInfo]
        
    init(title: String, dataToDisplay: [ActionSheetInfo], allowsMultiSelect: Bool = false) {
        self.actionSheetTitle = title
        self.infoArray = dataToDisplay
        self.allowsMultiSelect = allowsMultiSelect
    }
    
}///End Of ActionSheetVM

protocol ActionSheetViewDelegate: AnyObject {
    ///NEED to Release the reference to the Action Sheet View
    func ActionSheetViewRequestedDismiss()
    
    func ActionSheetViewActionUpdated(_ actionSheetViewMode: ActionSheetVM)
        
}

class ActionSheetView: UIView {
    
    // MARK: - View Layout Guideline Constants
    private let nonPhoneWidthInFloat: CGFloat = 375
    private let maxActionSheetHeightInFloat: CGFloat = 400
    
    //Table View Related
    private let actionTableViewRowHeight: CGFloat = 76
    private let tableViewTopToContainerTop: CGFloat = 75
    
    //Other Components
    private let indicatorViewHeight: CGFloat = 6
    private let titleTextFontSize: CGFloat = 18
    
    //Animations
    private let blurViewAnimateTime: TimeInterval = 0.3
    
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
        blurEffectView.alpha = 0.0
        
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
    
    private lazy var panAreaContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = true
        
        return view
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
    
    private let blurViewTargetAlpha: CGFloat
    private var containerViewAnimator: UIViewPropertyAnimator?
    
    // MARK: - View Lifecycle
    init(viewModel: ActionSheetVM,
         delegate: ActionSheetViewDelegate,
         inFrame: CGRect,
         withBlur: CGFloat = 0.6 ) {
        
        self.viewModel = viewModel
        self.delegate = delegate
        self.blurViewTargetAlpha = withBlur
                
        super.init(frame: inFrame)
        
        setupViews()
        
    }///End Of Init
    
    // MARK: - Tap on the blur view will call this method
    @objc func dismissActionSheet() {
        delegate?.ActionSheetViewRequestedDismiss()
        
    }///End Of dismissActionSheet
    
    @objc func didPanOnContainer(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .changed:
            guard recognizer.velocity(in: actionSheetContainerView).y > 0 else { return }
            setupContainerViewAnimator()
            startContainerViewAnimation()
            
        default:
            break
            
        }
    }
    
    // MARK: - Required
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}///End Of ActionSheetView

// MARK: - Views Setup
extension ActionSheetView {
    
    // MARK: - Setup Views
    private func setupViews(){
        //base blur view related
        addSubview(blurView)
        blurView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor)
        
        // MARK: - tap gesture
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissActionSheet) )
        blurView.addGestureRecognizer(tap)
        
        //action sheet view related
        addSubview(actionSheetContainerView)
        
        //container view related, height based on the tableView content or the max allowed
        let estHeightBasedOnTableView = CGFloat(viewModel.infoArray.count) * actionTableViewRowHeight + tableViewTopToContainerTop + bottomSafeAreaHeight + titleTextFontSize
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
        
        //panAreaContainerView
        actionSheetContainerView.addSubview(panAreaContainerView)
        panAreaContainerView.centerX(inView: indicatorView)
        panAreaContainerView.centerY(inView: indicatorView)
        panAreaContainerView.setDimensions(height: indicatorViewHeight * 6, width: 56)
        
        
        // MARK: - pan gesture
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPanOnContainer))
        panAreaContainerView.addGestureRecognizer(panGestureRecognizer)
        
        //title label view related
        actionSheetContainerView.addSubview(titleTextView)
        titleTextView.anchor(top: actionSheetContainerView.topAnchor,
                             left: actionSheetContainerView.leftAnchor,
                             right: actionSheetContainerView.rightAnchor,
                             paddingTop: 37,
                             paddingLeft: 16,
                             paddingRight: 16 )
        
        titleTextView.setDimensions(height: titleTextFontSize + 6)
        titleTextView.text = viewModel.actionSheetTitle
        
        //tableViewRelated
        actionSheetContainerView.addSubview(tableView)
        tableView.anchor(top: actionSheetContainerView.topAnchor,
                         left: actionSheetContainerView.leftAnchor,
                         bottom: actionSheetContainerView.safeAreaLayoutGuide.bottomAnchor,
                         right: actionSheetContainerView.rightAnchor,
                         paddingTop: tableViewTopToContainerTop)
        
        setupTableView()
        
        setupblurViewAnimaton()
        
    }///End Of SetupViews
    
}///End Of Extension

// MARK: - ActionSheetTableViewRelated
extension ActionSheetView: UITableViewDataSource, UITableViewDelegate {
    
    func setupTableView() {
        tableView.rowHeight = actionTableViewRowHeight
        
        //visual
        tableView.alwaysBounceVertical = false
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        
        //delegates
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(ActionSheetTableViewCell.self, forCellReuseIdentifier: actionSheetCellIdentifer)

    }///End Of setupTableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.infoArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: actionSheetCellIdentifer, for: indexPath) as? ActionSheetTableViewCell else {
            print("Unexpected case in \(#function)")
            return UITableViewCell()
        }
        
        let actionInfo = viewModel.infoArray[indexPath.row]
        
        cell.updateViews(actionInfo, actionTableViewRowHeight)
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedIndex = indexPath.row
        let allowMultiSelection = viewModel.allowsMultiSelect
        
        switch allowMultiSelection{
        case true:
            viewModel.infoArray[selectedIndex].isSelected.toggle()
            tableView.reloadRows(at: [indexPath], with: .automatic)
            
        //handle when not allowing multi selection
        case false:
            let currentlyTrueIndexes = viewModel.infoArray.enumerated()
                .filter { (n,actionInfo) in
                    actionInfo.isSelected
                }.map { (n,_) in
                    n
                }
            
            currentlyTrueIndexes.forEach { n in
                viewModel.infoArray[n].isSelected = false
            }
            
            viewModel.infoArray[selectedIndex].isSelected = true
            
            tableView.reloadData()
            
        }///End Of switch allowMultiSelection
        
        delegate?.ActionSheetViewActionUpdated(viewModel)
        
    }///End Of didSelectRowAt
    
}///End Of TableViewRelated


// MARK: - Animations Related
extension ActionSheetView {
    
    func setupblurViewAnimaton(){
        
        UIView.animate(withDuration: blurViewAnimateTime) { [weak self] in
            guard let target = self?.blurViewTargetAlpha else { return }
            self?.blurView.alpha = target
        
        } completion: { [weak self] _ in
            guard let target = self?.blurViewTargetAlpha else { return }
            self?.blurView.alpha = target
        }
        
    }
    
    func startContainerViewAnimation(){
        guard containerViewAnimator?.isRunning == false else { return }
        containerViewAnimator?.startAnimation()
    }
    
    func setupContainerViewAnimator() {
        guard containerViewAnimator == nil else { return }
        
        let timingParam = UICubicTimingParameters(animationCurve: .easeOut)
        containerViewAnimator = UIViewPropertyAnimator(duration: blurViewAnimateTime, timingParameters: timingParam)
        
        containerViewAnimator?.addAnimations { [weak self] in
            guard let maxHeight = self?.maxActionSheetHeightInFloat else { return }
            self?.actionSheetContainerView.transform = CGAffineTransform(translationX: 0, y: maxHeight)
            self?.actionSheetContainerView.alpha = 0.0
        }
        
        containerViewAnimator?.addCompletion({ [weak self] _ in
            self?.delegate?.ActionSheetViewRequestedDismiss()
        })
        
    }///End Of setupContainerViewAnimator
    
}///End Of ActionSheetView
