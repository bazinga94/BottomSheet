//
//  JH-BottomSheet.swift
//  BottomSheet
//
//  Created by Jongho Lee on 2021/03/04.
//  Copyright © 2021 JH. All rights reserved.
//

import UIKit

// MARK: - ADAMBottomSheet의 dismiss로직을 수행하는 listener
protocol DismissListenerDelegate: AnyObject {
	func onDismiss()
}

class BaseViewController: UIViewController { }

extension BaseViewController: UIGestureRecognizerDelegate {
	// MARK: - UIGestureRecognizer가 동시에 발생할 때, 모두 허용 할지 판단
	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//		if let tableView = bottomSheetTableView, tableView.contentOffset.y <= 0 { // 바텀시트 테이블 상단에서 스크롤시 dismiss
//			return true
//		}
//		if self.children.count != 0, let transferView = self.children[0] as? TransferViewController {	// Home의 이체 Modal
//			if let tableView = transferView.transferSearchViewController.bottomSheetTableView, tableView.contentOffset.y <= 0, !transferView.transferSearchContainerView.isHidden { // Modal 상단부분, 내부 테이블 뷰의 제스쳐 허용(테이블 상단에서 스크롤시 모달 dismiss)
//				return true
//			}
//		}
//		if let transferView = self as? TransferViewController, let tableView = transferView.transferSearchViewController.bottomSheetTableView {	// 조회의 이체 Modal
//			if tableView.contentOffset.y <= 0, !transferView.transferSearchContainerView.isHidden { // Modal 상단부분, 내부 테이블 뷰의 제스쳐 허용(테이블 상단에서 스크롤시 모달 dismiss)
//				return true
//			}
//		}
		return false
	}
}

extension BaseViewController: UIScrollViewDelegate {
	// MARK: - 바텀시트의 tableview는 상단 bounce를 막는다
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
//		if let tableView = bottomSheetTableView, tableView.contentOffset.y <= 0 {
//			tableView.contentOffset = CGPoint.zero // this is to disable tableview bouncing at top.
//		}
	}
}

class ADAMBottomSheet: UIViewController {
	private var childViewController: BaseViewController! 		// 바텀 시트에 들어갈 view들의 종류가 다양해서 나중에는 다양한 childViewController를 사용 할 것 같음
	private let containerView = UIView()					// childViewController가 들어갈 컨테이너 뷰
	private var shadowView = UIImageView()					// 바텀시트 상단의 그림자 뷰
	private let backgroundView = UIView()					// 바텀시트 백그라운드 뷰
	private let shadowViewHeight: CGFloat = 40 				// bottom sheet 상단 그림자뷰 높이
	private var dimColor: UIColor!							// 백그라운드 dim color
	private var dim: Bool = true							// 백그라운드 dim 여부
	private var noAddBottomSafeArea: Bool = false			// 바텀시트 높이 계산시, bottomSafeArea를 고려하지 않습니다.
	var sheetHeight: CGFloat = 0							// 바텀시트 높이
	var topConstraint: NSLayoutConstraint = NSLayoutConstraint.init()			// 바텀시트의 컨테이너뷰 top constraint
	var heightConstraint: NSLayoutConstraint = NSLayoutConstraint.init()		// 바텀시트의 컨테이너뷰 height constraint
	var isKeyboardShow: Bool = false 						// 키보드가 등장한 상태인지 확인
	var modalType: ModalType = .fixed 						// 공통가이드의 Modal Type 구분
	var availablePanning: Bool = true						// panning 가능 여부
	var isTapDismiss: Bool = true 							// 백그라운드 뷰 터치시 dismiss 되는지 여부
	var isInvestModal: Bool = false 						// 투자 조회 화면 modal 구분 변수
	var showCompletion: CommonFuncType? 					// 바텀시트를 show 할때 수행 할 closure
	var moreSheetHeight: CGFloat?							// view height 보다 sheetHeight가 클때 그 차이 값
	weak var dismissListener: DismissListenerDelegate? 		// dismiss 되었을때 로직을 수행 할 handler
	typealias CommonFuncType =  ( () -> Void )				// callback 함수 typealias

	enum ModalType {
		case fixed 		// Modal 높이 고정
		case flexible 	// Modal 높이 유동적(bottomSheetContentView의 높이)
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

	// MARK: - bottom sheet initializer, child view controller를 container view로 사용한다.
	/// bottom sheet initializer(높이 고정)
	/// - Parameters:
	///   - childViewController: bottom sheet의 container view에 들어갈 view controller
	///   - height: bottom sheet 높이
	///   - dim: background dim 처리 확인
	///   - isTapDismiss: background가 tap으로 dismiss 되는지 확인
	///   - isInvestModal: 투자조회 modal에서 사용되는지 확인
	///   - dismissListener: bottom sheet가 dismiss 될때 수행되는 리스너, 해당 리스너는 dismissSheet의 completion handler 보다 우선순위가 낮음
	init(childViewController: BaseViewController, height: CGFloat, dim: Bool, isTapDismiss: Bool = true, availablePanning: Bool = true, isInvestModal: Bool = false, dismissListener: DismissListenerDelegate? = nil) {
		super.init(nibName: nil, bundle: nil)
		self.childViewController = childViewController
		self.sheetHeight = height + getBottomSafeAreaInsets()
		self.dim = dim
		self.dimColor = (dim) ? UIColor(white: 0, alpha: 0.5) : UIColor.clear
		self.isTapDismiss = isTapDismiss
		self.availablePanning = availablePanning
		self.isInvestModal = isInvestModal
		self.dismissListener = dismissListener
		self.modalPresentationStyle = .overFullScreen
		self.modalType = .fixed
	}

	/// bottom sheet initializer(높이 유동적)
	/// - Parameters:
	///   - childViewController: bottom sheet의 container view에 들어갈 view controller(bottomSheetContentView가 정의되어야 한다)
	///   - dim: background dim 처리 확인
	///   - isTapDismiss: background가 tap으로 dismiss 되는지 확인
	///   - isInvestModal: 투자조회 modal에서 사용되는지 확인
	///   - dismissListener: bottom sheet가 dismiss 될때 수행되는 리스너, 해당 리스너는 dismissSheet의 completion handler 보다 우선순위가 낮음
	///   - noAddBottomSafeArea: bottomSafeArea를 Height 계산시 고려하지 않습니다.
	init(childViewController: BaseViewController, dim: Bool, isTapDismiss: Bool = true, availablePanning: Bool = true, isInvestModal: Bool = false, dismissListener: DismissListenerDelegate? = nil, noAddBottomSafeArea: Bool = false) {
		super.init(nibName: nil, bundle: nil)
		self.childViewController = childViewController
		self.dim = dim
		self.dimColor = (dim) ? UIColor(white: 0, alpha: 0.5) : UIColor.clear
		self.isTapDismiss = isTapDismiss
		self.availablePanning = availablePanning
		self.isInvestModal = isInvestModal
		self.dismissListener = dismissListener
		self.modalPresentationStyle = .overFullScreen
		self.modalType = .flexible
		self.noAddBottomSafeArea = noAddBottomSafeArea
	}

	// MARK: - bottom sheet view의 container view 와 child view controller의 view UI를 setting
	public override func viewDidLoad() {
		super.viewDidLoad()
		self.view.backgroundColor = .clear
		setupContainerView()
		setupShadowImageView()
		setupBarImageView()
		setupBackgroundView()
		setupChildViewController()
		setupGestureRecognizer()
		setupContainerHeight()
		self.view.layoutIfNeeded()
	}

	// MARK: - bottom sheet 등장 애니메이션, constraint를 조정하고 배경 dimm을 준다.
	public override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		sheetAppearAnimation(completion: showCompletion)
	}

	private func sheetAppearAnimation(completion: CommonFuncType? = nil) {
		topConstraint.constant = -self.sheetHeight
		UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: {
			// 호출 Interaction: 올라올 때 빠르게 시작해서 점점 속도가 주는 형태
			self.view.backgroundColor = self.dimColor
			self.view.layoutIfNeeded()
		}, completion: { _ in
			if let completion = completion {
				completion()
			}
		})
	}

	// MARK: - bottom sheet 상단에 shadow 이미지 붙이기
	private func setupShadowImageView() {
//		let shadowImage = UIImage.init(named: "commonBgBottomPopupShadow")
//		shadowView = UIImageView.init(image: shadowImage)
//		if isInvestModal {
//			setTintColorImageView([shadowView], color: UIColor(named: "INVEST_HEADER_COLOR"))
//		}

		self.view.addSubview(shadowView)
		self.view.sendSubviewToBack(shadowView)
		shadowView.translatesAutoresizingMaskIntoConstraints = false
		shadowView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
		shadowView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
		shadowView.bottomAnchor.constraint(equalTo: self.containerView.topAnchor).isActive = true
		shadowView.heightAnchor.constraint(equalToConstant: shadowViewHeight).isActive = true
	}

	// MARK: - bottom sheet 상단에 bar 이미지 붙이기
	private func setupBarImageView() {
		guard availablePanning else { // panning이 불가능할 때에는 bar 이미지 없음
			return
		}

		// color, image set
//		let barImage = UIImage.init(named: "commonBgBottomBar")
//		let barView = UIImageView.init(image: barImage)
		let barView = UIImageView.init()
//		let barColor = isInvestModal ? UIColor(named: "INVEST_BAR_COLOR") : UIColor(named: "GRAY_216_COLOR") // DarkMode 대응 색상 적용
//		setTintColorImageView([barView], color: barColor)

		// constraint set
		shadowView.addSubview(barView)
		barView.translatesAutoresizingMaskIntoConstraints = false
		barView.topAnchor.constraint(equalTo: shadowView.topAnchor, constant: 30).isActive = true
		barView.centerXAnchor.constraint(equalTo: shadowView.centerXAnchor).isActive = true
		barView.widthAnchor.constraint(equalToConstant: shadowViewHeight).isActive = true
	}

	// MARK: - bottom sheet의 container view의 초기 layout을 setting(바닥에서 나오기 전)
	private func setupContainerView() {
		self.view.addSubview(self.containerView)
		self.containerView.translatesAutoresizingMaskIntoConstraints = false
		containerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
		containerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
		heightConstraint = containerView.heightAnchor.constraint(equalToConstant: self.sheetHeight) // 바텀시트 높이를 동적으로 변화를 주기 위해
		topConstraint = containerView.topAnchor.constraint(equalTo: self.view.bottomAnchor) // top constraint는 애니메이션을 주기 위하여 따로 변수를 선언해서 사용
		heightConstraint.isActive = true
		topConstraint.isActive = true
	}

	// MARK: - child view controller를 현재 view controller의 자식 view로 추가 하고 해당 view를 container view와 동일하게 setting
	private func setupChildViewController() {
		self.addChild(self.childViewController)
		self.containerView.addSubview(self.childViewController.view)

		self.childViewController.view.translatesAutoresizingMaskIntoConstraints = false
		self.childViewController.view.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor).isActive = true
		self.childViewController.view.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor).isActive = true
		self.childViewController.view.topAnchor.constraint(equalTo: self.containerView.topAnchor).isActive = true
		self.childViewController.view.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor).isActive = true
		self.childViewController.view.layoutIfNeeded()
	}

	// MARK: - dimm 효과를 주고 tap시 dismiss가 될 공간을 setting, 해당 뷰 tap시 dismiss가 될 수 있게 한다.
	private func setupBackgroundView() {
		self.view.addSubview(backgroundView)

		backgroundView.translatesAutoresizingMaskIntoConstraints = false
		backgroundView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
		backgroundView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
		backgroundView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
		backgroundView.bottomAnchor.constraint(equalTo: self.shadowView.topAnchor).isActive = true
		self.view.layoutIfNeeded()

		backgroundView.backgroundColor = .clear
	}

	// MARK: - 바텀시트 높이가 유동적인 경우 높이를 계산한다
	private func setupContainerHeight() {
		if modalType == .flexible {
//			var contentViewHeight = childViewController.bottomSheetContentView?.frame.size.height ?? 0
			let maxHeight = self.view.bounds.height - UIApplication.shared.statusBarFrame.height
//			if contentViewHeight > maxHeight - 20 { // view 최대 높이보다 큰 경우, 최대높이 & scroll, image size : 20
//				moreSheetHeight = contentViewHeight - maxHeight
//				contentViewHeight = maxHeight - 20
//			}
//			sheetHeight = noAddBottomSafeArea ? contentViewHeight : contentViewHeight + getBottomSafeAreaInsets()
			heightConstraint.constant = sheetHeight
		}
	}

	// MARK: - Gesture Recognizer 등록
	private func setupGestureRecognizer() {
		if isTapDismiss {
			let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapBackgroundView))
			backgroundView.addGestureRecognizer(tapGestureRecognizer) // background tap gesture 등록
		}
		if availablePanning {
			let shadowViewGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGesture(_:)))
			shadowView.isUserInteractionEnabled = true
			shadowView.addGestureRecognizer(shadowViewGestureRecognizer) // bar, title 영역 gesture 추가
			let containerViewGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGesture(_:)))
			containerViewGestureRecognizer.delegate = childViewController
			containerView.addGestureRecognizer(containerViewGestureRecognizer) // bottom sheet 전체 영역 gesture 추가
		}
	}

	// MARK: - UITapGestureRecognizer의 selector에 인자로 줄 objc 함수
	@objc func tapBackgroundView() {
		self.dismissSheet()
	}

	// MARK: Bottom Sheet를 show
	/// Bottom Sheet를 show
	/// - Parameters:
	///   - presentView: Bottom Sheet를 띄우는 UIViewController
	///   - completion: UIViewController present 함수의 completion handler
	public func show(presentView: UIViewController, completion: CommonFuncType? = nil) {
		self.showCompletion = completion
		presentView.present(self, animated: false, completion: nil)
	}

	// MARK: - bottom sheet를 dismiss
	/**
	bottom sheet dismiss
	- Parameter: view의 dismiss closure
	*/
	public func dismissSheet(completion: CommonFuncType? = nil) {
		self.topConstraint.constant = getBottomSafeAreaInsets() + shadowViewHeight
		self.childViewController.view.endEditing(true) // dismiss시 UITextField end editing

		UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: {
			// 종료 Interaction: 내려갈 때 빠르게 시작해서 점점 속도가 줄면서 사라지는 형태
			self.view.layoutIfNeeded()
			self.view.backgroundColor = UIColor.clear
		}, completion: { _ in
			self.dismiss(animated: false) {
				guard let completion = completion else { // completion 함수가 없으면 dismiss listener의 onDismiss 로직 수행
					self.dismissListener?.onDismiss()
					return
				}
				completion()
			}
		})
	}

	/// bottom sheet 높이를 변경
	/// - Parameter height: 변경 할 높이
	public func resizeSheet(height: CGFloat) {
		topConstraint.constant = -height
		heightConstraint.constant = height
		sheetHeight = height
		UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: {
			self.view.layoutIfNeeded()
		})
	}

	// MARK: pan gesture 로직 구현
	@objc func panGesture(_ gesture: UIPanGestureRecognizer) {
		isKeyboardShow ? keyboardPanGesture(gesture) : defaultPanGesture(gesture)
	}

	// MARK: 기본 pan gesture 로직 구현
	private func defaultPanGesture(_ gesture: UIPanGestureRecognizer) {
		let point = gesture.translation(in: gesture.view) // panning위치

		let maxHeight = sheetHeight
		var newHeight = sheetHeight - point.y // 실시간으로 변하는 bottom sheet 높이

		if newHeight > maxHeight {
			newHeight = maxHeight
		}

		if gesture.state == .began {
			self.view.endEditing(true)
		} else if gesture.state == .cancelled || gesture.state == .failed { // gesture가 중간에 중단되거나 recognizer가 일치 하지 않는 경우
			dismissSheet()
		} else if gesture.state == .ended { // gesture가 종료된 경우
			let velocity = gesture.velocity(in: self.view).y // 종료 시 panning 속도 확인
			if velocity > 2000 { // flicking이 아래로 발생한 경우
				dismissSheet()
			} else if velocity < -1000 { // flicking이 위로 발생한 경우
				sheetAppearAnimation()
			} else if newHeight <= maxHeight/2 { // 절반 이상 panning된 경우
				dismissSheet()
			} else { // 절반 이하로 panning된 경우
				sheetAppearAnimation()
			}
		} else if gesture.state == .changed { // gesture가 진행 중
			topConstraint.constant = -newHeight
			self.view.backgroundColor = (dim) ? UIColor(white: 0, alpha: 0.5 * (newHeight/maxHeight)) : UIColor.clear
		}
	}

	// MARK: 키보드가 발생한 경우 pan gesture 로직 구현
	private func keyboardPanGesture(_ gesture: UIPanGestureRecognizer) {
		if gesture.state == .began {	// 이체 "받는사람" 바텀시트에서만 panning이 발생할때 키보드를 내려주자
			self.view.endEditing(true)
		} else if gesture.state == .cancelled || gesture.state == .failed { // gesture가 중간에 중단되거나 recognizer가 일치 하지 않는 경우
			dismissSheet()
		} else if gesture.state == .ended { // gesture가 종료된 경우
			let velocity = gesture.velocity(in: self.view).y // 종료 시 panning 속도 확인
			if isKeyboardShow && velocity > 3000 {
				dismissSheet()
				isKeyboardShow = false
				return
			}
		}
	}
}
