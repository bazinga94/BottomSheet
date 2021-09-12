# BottomSheet

![Swift](https://img.shields.io/badge/Swift-5.0-orange.svg)
[![Swift Package Manager](https://img.shields.io/badge/SPM-supported-DE5C43.svg?style=flat)](https://swift.org/package-manager/)
[![CocoaPods Version](https://img.shields.io/cocoapods/v/JHBottomSheet.svg?style=flat)](http://cocoapods.org/pods/JHBottomSheet)
[![License](https://img.shields.io/cocoapods/l/JHBottomSheet.svg?style=flat)](http://cocoapods.org/pods/JHBottomSheet)
[![Platforms](https://img.shields.io/badge/platform-iOS-lightgrey.svg)](http://cocoapods.org/pods/JHBottomSheet)
[![Swift Version](https://img.shields.io/badge/Swift-4.2~-F16D39.svg?style=flat)](https://developer.apple.com/swift)

💫 Elegant bottom sheet(modal) by swift

<!-- ![](gif/Demo.gif) -->
<center><img src="https://github.com/bazinga94/BottomSheet/blob/main/gif/Demo.gif" width="250" height="600"></center>

## Try it

Explore the [BottomSheet Demo](https://github.com/bazinga94/BottomSheet-Demo) or clone the repository. 

## Installation

### Swift Package Manager

* <a href="https://guides.cocoapods.org/using/using-cocoapods.html" target="_blank">CocoaPods</a>:

```ruby
pod 'JHBottomSheet', '~> 1.0.1'
```

* <a href="https://swift.org/package-manager/" target="_blank">Swift Package Manager</a>:

```swift
dependencies: [
  .package(url: "https://github.com/bazinga94/BottomSheet.git", .exact("1.0.1")),
],
```

## Usage

Include the UIViewController to be presented in the BottomSheet initializer. After that, you can use it like presenting and dismissing UIViewController.

```swift
let bottomSheet = BottomSheet.init(childViewController: yourViewController, height: 500)
present(bottomSheet, animated: true, completion: nil)
```

If you adopt the BottomSheetFlexible protocol and want to present the bottom sheet as much as the size of the view, you don't need to include the height.

```swift
public protocol BottomSheetFlexible: AnyObject {
	var bottomSheetContentView: UIView! { get set }
}
```

## Authors

[Jongho Lee](https://github.com/bazinga94)

## License

<b>BottomSheet</b> is released under a MIT License. See LICENSE file for details.
