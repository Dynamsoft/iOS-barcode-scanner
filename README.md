# (swift) DynamsoftBarcodeReaderDemo

## Installation

1.To install DynamsoftBarcodeReaderDemo, simply add the following line to your Podfile:

```ruby
pod 'DynamsoftBarcodeReader'
```

2.Make sure `Your Project Target -> Build Settings -> Search Paths -> Frameworks Search Paths` and `Linking -> Other Linker Flags`, this can lead to problems with the CocoaPods installation, The following command is modified to the corresponding content please.
```bash
Frameworks Search Paths = "${PODS_ROOT}/DynamsoftBarcodeReader"
Other Linker Flags = -framework "DynamsoftBarcodeReader"
```


## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## License Agreement
https://www.dynamsoft.com/Products/barcode-reader-license-agreement.aspx

