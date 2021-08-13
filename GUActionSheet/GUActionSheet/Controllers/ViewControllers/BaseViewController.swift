//
//  BaseViewController.swift
//  GUActionSheet
//
//  Created by lijia xu on 8/10/21.
//

import UIKit
import Combine

class BaseViewController: UIViewController {
    
    @IBOutlet weak var logTextView: UITextView!
    
    @IBOutlet weak var numberOfSampleDataLabel: UILabel!
    @IBOutlet weak var numberOfSamplesDataPicker: UIPickerView!
    @IBOutlet weak var shouldAllowMultiSelectSwitch: UISwitch!
    
    //Demo Related
    private let pickOptions: [Int] = Array( (1...20) )
    private var targetDemoNumbers: Int = 3
    private var subscriptions = Set<AnyCancellable>()
    private let shouldUpdateInfoProvider = PassthroughSubject<Int,Never>()
    
    //Action View Related
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
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        numberOfSamplesDataPicker.delegate = self
        numberOfSamplesDataPicker.dataSource = self
    
        setupViews()
        
        subscribeInfoProviderShouldChange()
        shouldUpdateInfoProvider.send(3)
    }
    
    @IBAction func shouldAllowMultiSelectToggleChanged(_ sender: UISwitch) {
        allowsMultiSelect = sender.isOn
    }
    
    @IBAction func showActionSheetTapped(_ sender: Any) {
        let optionsCount = infoProvider.count
        let titleString = optionsCount > 4 ? "Select From \(optionsCount) Organizations" : "Select Organization"
        
        // MARK: - Action Sheet View Usage
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
        
    }///End Of showActionSheetTapped

}///End Of BaseViewController


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
        
        UIView.animate(withDuration: 0.3) {
            actionSheet.alpha = 0.0
        } completion: { _ in
            actionSheet.removeFromSuperview()
            self.actionSheetView = nil
        }
        
    }

}///End Of ActionSheetViewDelegate


// MARK: - Picker View Delegate
extension BaseViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(row + 1)"
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        pickOptions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        shouldUpdateInfoProvider.send(pickOptions[row])
    }

}///End Of Picker View Delegate

// MARK: - Demo helper, rushed
extension BaseViewController {
    
    func setupViews() {
        numberOfSamplesDataPicker.selectRow( 2 , inComponent: 0, animated: true)
        shouldAllowMultiSelectSwitch.isOn = false
        logTextView.text = nil
    }
    
    func subscribeInfoProviderShouldChange(){
        //In case user selects too fast in the picker view
        shouldUpdateInfoProvider
            .debounce(for: .seconds(0.2), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] targetCount in
                self?.numberOfSampleDataLabel.text = "generate \(targetCount) sample data"
                self?.setupInfoProviderData(targetCount)
            }
            .store(in: &subscriptions)
    }
    
    func setupInfoProviderData(_ target: Int) {
        infoProvider = generateDataToDisplay(totalCount: target)
    }
    
    func generateDataToDisplay(totalCount: Int) -> [ActionSheetInfo] {
        let demoImageIndexPool: Set<Int> = [1,2,3,4,5,6,7,8,9]
        let demoCompanyNamesPool: Set<String> = ["Good Day", "Next Time", "Happy"]
        
        return (1...totalCount).map { n in
            let randomInt = demoImageIndexPool.randomElement()!
            let randomName = demoCompanyNamesPool.randomElement()!
            
            return ActionSheetInfo(imageURL: demoURLStringGenerator(index: randomInt),
                            title: randomName + " \(n)",
                            isSelected: false
            )
        }
        
    }
    
    func demoURLStringGenerator(index: Int) -> String{
        return "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(index).png"
    }
    
}///End Of Demo Helper
