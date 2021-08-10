//
//  ActionSheetView.swift
//  GUActionSheet
//
//  Created by lijia xu on 8/10/21.
//

import UIKit

protocol ActionSheetViewDelegate: AnyObject {
    func ActionSheetViewShouldDismiss()
}


class ActionSheetView: UIView {
    // MARK: - View Visual Properties
    private let blurViewAlpha: CGFloat = 0.99
    
    // MARK: - View Layout Base Constants
    private let nonPhoneWidthInFloat: CGFloat = 375
    private let maxHeightInPX: CGFloat = 400
    
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
    
    // MARK: - ActionSheetViewmodel
    struct ActionSheetVM {
        let actionSheetTitle: String
        let listingData: [(image: UIImage, title: String)]
        
        init( name: String, dataToDisplay: (image: UIImage, title: String) ) {
            self.actionSheetTitle = name
            self.listingData = [dataToDisplay]
            
        }
        
        init( name: String, dataToDisplay: [(image: UIImage, title: String)] ) {
            self.actionSheetTitle = name
            self.listingData = dataToDisplay
        }
        
    }///End Of ActionSheetVM
        
    
    // MARK: - Delegates
    
    
    // MARK: - Views
    private lazy var blurView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.backgroundColor = .gray
        blurEffectView.alpha = blurViewAlpha
    
        return blurEffectView
    }()
    
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.separatorStyle = .none
        
        return tableView
    }()
    
    private lazy var textView: UILabel = {
        let label = UILabel()
        
        return label
    }()
    
    
    // MARK: -
    private let viewModel: ActionSheetVM
    weak var delegate: ActionSheetViewDelegate?
    
    // MARK: - View LifeCycle
    init(viewModel: ActionSheetVM, parentViewFrame: CGRect) {
        self.viewModel = viewModel
        super.init(frame: parentViewFrame)
        
        
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


// MARK: - General Helper
extension ActionSheetView {
    
    
    
}///End Of General Helper


// MARK: - Convertion Helper CGFloat
fileprivate extension CGFloat {
    func converToPXValue() -> CGFloat {
        let currentDeviceScale: CGFloat = UIScreen.main.scale
        return self * currentDeviceScale
    }
}

// MARK: - Layout Helper UIView
fileprivate extension UIView {
    
    func anchor(top: NSLayoutYAxisAnchor? = nil,
                left: NSLayoutXAxisAnchor? = nil,
                bottom: NSLayoutYAxisAnchor? = nil,
                right: NSLayoutXAxisAnchor? = nil,
                paddingTop: CGFloat = 0,
                paddingLeft: CGFloat = 0,
                paddingBottom: CGFloat = 0,
                paddingRight: CGFloat = 0,
                width: CGFloat? = nil,
                height: CGFloat? = nil) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        
        if let left = left {
            leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }
        
        if let right = right {
            rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }
        
        if let width = width {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if let height = height {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
    func centerX(inView view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    func centerY(inView view: UIView, leftAnchor: NSLayoutXAxisAnchor? = nil,
                 paddingLeft: CGFloat = 0, constant: CGFloat = 0) {
        
        translatesAutoresizingMaskIntoConstraints = false
        centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: constant).isActive = true
        
        if let left = leftAnchor {
            anchor(left: left, paddingLeft: paddingLeft)
        }
    }
    
    func setDimensions(height: CGFloat, width: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: height).isActive = true
        widthAnchor.constraint(equalToConstant: width).isActive = true
    }

}///End Of UIView Extension
