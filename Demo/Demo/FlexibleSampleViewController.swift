//
//  FlexibleSampleViewController.swift
//  Demo
//
//  Created by Jongho Lee on 2021/05/19.
//  Copyright © 2021 JH. All rights reserved.
//

import UIKit

class FlexibleSampleViewController: UIViewController, FlexibleBottomSheetDelegate {
	@IBOutlet weak var bottomSheetContentView: UIView!		// 바텀시트(BottomSheet)의 높이를 유동적으로 관리하고 싶을때 생성하여 outlet 연결 필요
	@IBAction func closeBottomSheet(_ sender: Any) {
//		bottomSheet?.dismissSheet()
		dismiss(animated: false, completion: nil)
	}

	@IBAction func navigationPush(_ sender: Any) {
		let storyBoard: UIStoryboard! = UIStoryboard(name: "Main", bundle: nil)
		let vc = storyBoard.instantiateViewController(withIdentifier: "TableViewSheet") as! TableViewSampleViewController
//		self.navigationController?.pushViewController(vc, animated: true)
		if let navigationController = bottomSheet?.presentingViewController as? UINavigationController {
			navigationController.pushViewController(vc, animated: true)
		}
	}
}
