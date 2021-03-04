//
//  Utility.swift
//  BottomSheet
//
//  Created by Jongho Lee on 2021/03/04.
//  Copyright © 2021 JH. All rights reserved.
//

import UIKit

// MARK: - Keywindow 반환
func getKeyWindow() -> UIWindow? {
	var window: UIWindow?
	if #available(iOS 13.0, *) {
		window = UIApplication.shared.windows.filter { $0.isKeyWindow }.first
	} else {
		window = UIApplication.shared.keyWindow
	}
	return window
}

// MARK: - Bottom SafeAreaInsets을 반환하는 함수
/// Bottom SafeAreaInsets을 반환하는 함수
func getBottomSafeAreaInsets() -> CGFloat {
	let bottomSafeArea: CGFloat = getKeyWindow()?.safeAreaInsets.bottom ?? 0 // iOS 11 이상에서만 값을 가져온다.
	return bottomSafeArea
}
