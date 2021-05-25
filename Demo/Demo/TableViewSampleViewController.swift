//
//  TableViewSampleViewController.swift
//  Demo
//
//  Created by Jongho Lee on 2021/05/19.
//  Copyright © 2021 JH. All rights reserved.
//

import UIKit

class BottomSheetTableView: UITableView {
	override func layoutSubviews() {
		if (self.window == nil) {
			return
		}
		super.layoutSubviews()
	}
}

class TableViewSampleViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	@IBOutlet weak var tableView: BottomSheetTableView!
	weak var delegate: ChangeableScrollContentsDelegate?

	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.delegate = self
		tableView.dataSource = self
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 10
	}

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 60
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "SampleTableViewCell", for: indexPath) as! SampleTableViewCell
		cell.indexLabel.text = String(indexPath.row)
		return cell
	}
}

extension TableViewSampleViewController: ChangeableBottomSheetWithScrollView {
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		delegate?.contentsScrollViewDidScroll(scrollView)
	}

	func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		delegate?.contentsScrollViewDidEndDragging(scrollView, willDecelerate: decelerate)
	}
}
