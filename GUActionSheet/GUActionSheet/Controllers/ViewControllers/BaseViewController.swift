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
            title: "Select Organization",
            dataToDisplay: [
                ActionSheetInfo(image: UIImage(systemName: "doc")!, title: "test Title", isSelected: true),
                ActionSheetInfo(image: UIImage(systemName: "doc.fill")!, title: "test Title", isSelected: false)
            ],
            allowsMultiSelect: false
        )

        actionSheetView = ActionSheetView(viewModel: actionSheetVM,
                                          delegate: self,
                                          inFrame: view.frame)
        
        guard let actionSheetView = actionSheetView else {
            print("unexpected case in \(#function)")
            return
        }
        view.addSubview(actionSheetView)
        
    }///End Of showActionSheetTapped


}///End Of BaseViewController

// MARK: - ActionSheetViewDelegate
extension BaseViewController: ActionSheetViewDelegate {
    func ActionSheetViewRequestedDismiss() {
        guard let actionSheet = actionSheetView else {
            print("unexpected case in \(#function)")
            return
        }
        UIView.animate(withDuration: 0.2) {
            actionSheet.alpha = 0.0
        } completion: { _ in
            actionSheet.removeFromSuperview()
            self.actionSheetView = nil
        }
       
    }

    //handle the user selections
    func ActionSheetViewActionUpdated(_ actionSheetInfos: [ActionSheetInfo] ) {
        
        actionSheetInfos.forEach { info in
            print(info.title,info.isSelected)
        }
        
    }

}///End Of ActionSheetViewDelegate

