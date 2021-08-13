# ActionSheet
one of my take home assessement for an interview
<br />
 - Programmatic UI
 - UIKit
 - Adaptive to different devices and contents


![](https://github.com/hgtlzyc/ActionSheet/blob/156da85b32d95bd73b9ef6eea4488c1f8cc80103/ActionSheetRecording.gif)

Code Snippet:
<br />
```swift 

 //Action View Related Properties
 private var actionSheetView: ActionSheetView?
 private var allowsMultiSelect: Bool = false
 private var infoProvider: [ActionSheetDisplayable] = []
 private var userSelected: [ActionSheetDisplayable] = []

 // MARK: - ActionSheetViewModel
 struct ActionSheetInfo: ActionSheetDisplayable{
     let imageURL: String
     let title: String
     var isSelected: Bool

 }

 // MARK: - Action Sheet View Sample Usage
 let actionSheetVM = ActionSheetVM(
     title: titleString,
     dataToDisplay: infoProvider,
     allowsMultiSelect: allowsMultiSelect
 )

 actionSheetView = ActionSheetView(viewModel: actionSheetVM,
                                   delegate: self,
                                   inFrame: view.frame,
                                   showDebugPrint: true)

 guard let actionSheetView = actionSheetView else {
     print("unexpected case in \(#function)")
     return
 }

 view.addSubview(actionSheetView)
 
  
// MARK: - Action Sheet View Delegate
extension BaseViewController: ActionSheetViewDelegate {
    
    func ActionSheetViewActionUpdated(_ actionSheetViewMode: ActionSheetVM) {
        let actionSheetInfos = actionSheetViewMode.infoArray
        infoProvider = actionSheetViewMode.infoArray
        
        let selectedInfos = actionSheetInfos.filter{ $0.isSelected }
        
        logTextView.text = nil
        userSelected = []
        
        selectedInfos.forEach{ info in
            logTextView.text = logTextView.text.appending("\n \(info.title) ")
            userSelected.append(info)
        }
        
        if selectedInfos.count > 0 && actionSheetViewMode.allowsMultiSelect == false {
            dismissActionSheet()
        }
        
    }///End Of ActionSheetViewActionUpdated
    
    func ActionSheetViewRequestedDismiss() {
        dismissActionSheet()
    }

    func dismissActionSheet(){
        guard let actionSheet = actionSheetView else {
            print("unexpected case in \(#function)")
            return
        }
        
        logTextView.text = logTextView.text.appending("\n User selected \(userSelected.count) company")
        
        UIView.animate(withDuration: 0.2) {
            actionSheet.alpha = 0.0
        } completion: { _ in
            actionSheet.removeFromSuperview()
            self.actionSheetView = nil
        }
        
    }

}///End Of ActionSheetViewDelegate
        

```
 
