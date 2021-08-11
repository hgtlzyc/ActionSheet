//
//  BaseViewController.swift
//  GUActionSheet
//
//  Created by lijia xu on 8/10/21.
//

import UIKit

class BaseViewController: UIViewController {

    private var actionSheetView: ActionSheetView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func showActionSheetTapped(_ sender: Any) {
        let actionSheetVM = ActionSheetVM(
                                        title:"Select Organization",
                                dataToDisplay: [( UIImage(), "test" )]
                            )

        actionSheetView = ActionSheetView(viewModel: actionSheetVM,
                                          parentViewFrame: view.frame,
                                          delegate: self)
        view.addSubview(actionSheetView!)
        
    }///End Of showActionSheetTapped


}///End Of BaseViewController

// MARK: - ActionSheetViewDelegate
extension BaseViewController: ActionSheetViewDelegate {

    func ActionSheetViewShouldDismiss() {
        guard let actionView = actionSheetView else { return }
        actionView.removeFromSuperview()
    }

}///End Of ActionSheetViewDelegate
