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
    
    init(_ name: String, dataToDisplay: (UIImage, String) ) {
        self.actionSheetTitle = name
        self.listingData = [(dataToDisplay.0, dataToDisplay.1)]
        
    }
    
    init(_ name: String, dataToDisplay: [(UIImage, String)] ) {
        self.actionSheetTitle = name
        self.listingData = dataToDisplay.map{ (image: $0.0, title: $0.1 ) }
    }
    
}///End Of ActionSheetVM

protocol ActionSheetViewDelegate: AnyObject {
    func ActionSheetViewShouldDismiss()
}

class ActionSheetView: UIView {
    // MARK: - View Visual Properties
    private var blurViewAlpha: CGFloat
    
    // MARK: - View Layout Base Constants
    private let nonPhoneWidthInFloat: CGFloat = 375
    private let maxHeightInPX: CGFloat = 400
    
    private let actionSheetCornerRadiusFloat: CGFloat = 30
    
    // MARK: - Coumpted Layout properties
    private lazy var actionSheetWidth: CGFloat = {
        let deviceIdiom = UIDevice.current.userInterfaceIdiom
        switch deviceIdiom {
        case .phone:
            return frame.width
        default:
            return nonPhoneWidthInFloat.converToPXValue()
        }
        
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
        container.layer.cornerRadius = actionSheetCornerRadiusFloat.converToPXValue()
        
        return container
    }()
    
    
    private lazy var textView: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.separatorStyle = .none
        
        return tableView
    }()
    
    
    
    // MARK: -
    private let viewModel: ActionSheetVM
    weak var delegate: ActionSheetViewDelegate?
    
    // MARK: - View LifeCycle
    init(viewModel: ActionSheetVM,
         parentViewFrame: CGRect,
         delegate: ActionSheetViewDelegate,
         withBlur: CGFloat = 0.5 ) {
        
        self.viewModel = viewModel
        self.delegate = delegate
        self.blurViewAlpha = withBlur
        
        super.init(frame: parentViewFrame)
        
        addSubview(blurView)
        blurView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor)
        let tap = UITapGestureRecognizer(target: self, action: #selector(shoulDismissActionSheet) )
        blurView.addGestureRecognizer(tap)
        
        setupTableView()
        
    }///End Of Init
    
    @objc func shoulDismissActionSheet() {
        guard let delegate = delegate else {
            //Just in case the init changed
            print("""
                Please assign delegate to the ActionSheetView
                to handle Dismiss
                """)
            return
        }
        
        delegate.ActionSheetViewShouldDismiss()
        
    }///End Of shouldDismissActionSheet
    
    func setupTableView() {
        //tableView.register(<#T##cellClass: AnyClass?##AnyClass?#>, forCellReuseIdentifier: <#T##String#>)
    }
    
    // MARK: - Required
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}///End Of ActionSheetView

// MARK: - TableViewRelated
extension ActionSheetView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
}///End Of TableViewRelated


// MARK: - Convertion Helper CGFloat
fileprivate extension CGFloat {
    
    func converToPXValue() -> CGFloat {
        let currentDeviceScale: CGFloat = UIScreen.main.scale
        return self * currentDeviceScale
    }
    
}


