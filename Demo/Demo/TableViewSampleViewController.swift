//
//  TableViewSampleViewController.swift
//  Demo
//
//  Created by Jongho Lee on 2021/05/19.
//  Copyright © 2021 JH. All rights reserved.
//

import UIKit


class TableViewSampleViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	@IBOutlet weak var tableView: UITableView!
	weak var delegate: ChangeableScrollContentsDelegate?

	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.delegate = self
		tableView.dataSource = self
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 10
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "SampleTableViewCell", for: indexPath) as! SampleTableViewCell
		cell.indexLabel.text = String(indexPath.row)
		return cell
	}
}

extension TableViewSampleViewController: ChangeableBottomSheetWithTableView {
//	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//
//		if let bottomSheet = bottomSheet, bottomSheet.isExpand, tableView.contentOffset.y > 0 {
//			return false
//		}
//		return true
//	}

	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		delegate?.contentsScrollViewDidScroll(scrollView)
//		if let bottomSheet = bottomSheet {
//			if !bottomSheet.isExpand || scrollView.contentOffset.y <= 0 {
//				scrollView.setContentOffset(.zero, animated: false)
//			}
//		}
	}

	func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		delegate?.contentsScrollViewDidEndDragging(scrollView, willDecelerate: decelerate)
	}
}
