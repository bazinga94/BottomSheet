//
//  ViewController.swift
//  Demo
//
//  Created by Jongho Lee on 2021/03/04.
//  Copyright © 2021 JH. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
	@IBAction func showFixedBottomSheet(_ sender: Any) {
		let vc = UIViewController()
		vc.view.backgroundColor = .red
		let bottomSheet = BottomSheet.init(childViewController: vc, height: 300, dim: true)
		bottomSheet.show(presentView: self)
	}

	@IBAction func showFlexibleBottomSheet(_ sender: Any) {
		let storyBoard: UIStoryboard! = UIStoryboard(name: "Main", bundle: nil)
		let vc = storyBoard.instantiateViewController(withIdentifier: "FlexibleSheet") as! FlexibleSampleViewController
		let bottomSheet = BottomSheet.init(childViewController: vc, dim: true, noAddBottomSafeArea: true)
//		bottomSheet.show(presentView: self)
		let navigationController = UINavigationController(rootViewController: bottomSheet)
//		navigationController.isNavigationBarHidden = true
		bottomSheet.showByNavi(presentView: self, navigationController: navigationController)
	}

	@IBAction func showChangeableBottomSheet(_ sender: Any) {
		let storyBoard: UIStoryboard! = UIStoryboard(name: "Main", bundle: nil)
		let vc = storyBoard.instantiateViewController(withIdentifier: "TableViewSheet") as! TableViewSampleViewController
		let bottomSheet = BottomSheet.init(childViewController: vc, initialHeight: 300, maxHeight: 600, dim: true, isTapDismiss: true, dismissListener: nil)
		bottomSheet.show(presentView: self)
	}

	override func viewDidLoad() {
		super.viewDidLoad()
	}
}
