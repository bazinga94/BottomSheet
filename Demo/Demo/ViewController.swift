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
		present(bottomSheet, animated: true, completion: nil)	// BottomSheet을 그냥 view controller present 하듯 사용하는 방법 찾기..! animated를 true로 주면 이상함...
	}

	@IBAction func showFlexibleBottomSheet(_ sender: Any) {
		let storyBoard: UIStoryboard! = UIStoryboard(name: "Main", bundle: nil)
		let vc = storyBoard.instantiateViewController(withIdentifier: "FlexibleSheet") as! FlexibleSampleViewController
		let bottomSheet = BottomSheet.init(childViewController: vc, dim: true, noAddBottomSafeArea: true)
		bottomSheet.delegate = self
		present(bottomSheet, animated: true, completion: nil)
	}

	@IBAction func showChangeableBottomSheet(_ sender: Any) {
		let storyBoard: UIStoryboard! = UIStoryboard(name: "Main", bundle: nil)
		let vc = storyBoard.instantiateViewController(withIdentifier: "TableViewSheet") as! TableViewSampleViewController
		let bottomSheet = BottomSheet.init(childViewController: vc, initialHeight: 300, maxHeight: 600, dim: true, isTapDismiss: true, delegate: nil)
		present(bottomSheet, animated: true, completion: nil)
	}

	override func viewDidLoad() {
		super.viewDidLoad()
	}
}

extension ViewController: BottomSheetDelegate {
	func bottomSheetDidDismiss(_ bottomSheet: BottomSheet) {
		print("Flexible BottomSheet Dismiss")
//		let vc = UIViewController()
//		vc.view.backgroundColor = .blue
//		self.present(vc, animated: true, completion: nil)
	}
}
