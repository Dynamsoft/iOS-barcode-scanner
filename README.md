# (swift) DynamsoftBarcodeReaderDemo

## Installation

1.To install DynamsoftBarcodeReaderDemo, simply add the following line to your Podfile:

```ruby
pod 'DynamsoftBarcodeReader'
```

2.The `your project name [Debug]` target overrides the `FRAMEWORK_SEARCH_PATHS` build setting defined in `Pods/Target Support Files/Pods-testOc/Pods-xxx.debug.xcconfig`. This can lead to problems with the CocoaPods installation, The following command is modified to the corresponding content please.

```
FRAMEWORK_SEARCH_PATHS = "${SRCROOT}/Pods/DynamsoftBarcodeReader"
HEADER_SEARCH_PATHS = "${SRCROOT}/Pods/DynamsoftBarcodeReader/DynamsoftBarcodeReader.framework/Headers"
```


## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## License Agreement
https://www.dynamsoft.com/Products/barcode-reader-license-agreement.aspx#javascript

