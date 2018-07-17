//
//  DynamsoftBarcodeReader.h
//  DynamsoftBarcodeSDK
//
//  Created by Dynamsoft on 2018/6/7.
//  Copyright © 2018 Dynamsoft. All rights reserved.
//

#import <UIKit/UIKit.h>


static NSString* _Nonnull const DBRErrorDomain = @"com.dynamsoft.barcodereader.error";

// Define error code of DynamsoftBarcodeReader.
typedef NS_ENUM(NSInteger, DBRErrorCode) {
    // Unknown error.
    DBRErrorCode_Unknown                    = -10000,
    // Not enough memory to perform the operation.
    DBRErrorCode_No_Memory                  = -10001,
    // Null pointer.
    DBRErrorCode_Null_Pointer               = -10002,
    // The license is invalid.
    DBRErrorCode_License_Invalid            = -10003,
    // The license has expired.
    DBRErrorCode_License_Expired            = -10004,
    // The file to decode is not found.
    DBRErrorCode_File_Not_Found             = -10005,
    // The file type is not supported.
    DBRErrorCode_Filetype_Not_Supported     = -10006,
    // The BPP(Bits per pixel) is not supported.
    DBRErrorCode_BPP_Not_Supported          = -10007,
    // The index is invalid.
    DBRErrorCode_Index_Invalid              = -10008,
    // The barcode format is invalid.
    DBRErrorCode_Barcode_Format_Invalid     = -10009,
    // The parameters' value of input region  is invalid.
    DBRErrorCode_Custom_Region_Invalid      = -10010,
    // The maximum barcode number is invalid.
    DBRErrorCode_Max_Barcode_Number_Invalid = -10011,
    // Failed to read the image.
    DBRErrorCode_Image_Read_Failed          = -10012,
    // Failed to read the TIFF image.
    DBRErrorCode_TIFF_Read_Failed           = -10013,
    // The QR Code license is invalid.
    DBRErrorCode_QR_License_Invalid         = -10016,
    // The 1D Barcode license is invalid.
    DBRErrorCode_1D_Lincese_Invalid         = -10017,
    // The PDF417 barcode license is invalid.
    DBRErrorCode_PDF417_License_Invalid     = -10019,
    // The DATAMATRIX barcode license is invalid.
    DBRErrorCode_Datamatrix_License_Invalid = -10020,
    // Failed to read the PDF file.
    DBRErrorCode_PDF_Read_Failed            = -10021,
    // The PDF DLL is missing.
    DBRErrorCode_PDF_DLL_Missing            = -10022,
    // The page number is invalid.
    DBRErrorCode_Page_Number_Invalid        = -10023,
    // The custom size is invalid.
    DBRErrorCode_Custom_Size_Invalid        = -10024,
    //The custom module size is invalid.
    DBRErrorCode_Custom_Modulesize_Invalid  = -10025,
    // Recognition timeout.
    DBRErrorCode_Recognition_Timeout        = -10026,
    // Failed to parse the JSON string.
    DBRErrorCode_Json_Parse_Failed          = -10030,
    // The value type is invalid.
    DBRErrorCode_Json_Type_Invalid          = -10031,
    // The key is invalid.
    DBRErrorCode_Json_Key_Invalid           = -10032,
    // The value is invalid or out of range.
    DBRErrorCode_Json_Value_Invalid         = -10033,
    // The mandatory key "Name" is missing.
    DBRErrorCode_Json_Name_Key_Missing      = -10034,
    // The value of the key "Name" is duplicated.
    DBRErrorCode_Json_Name_Value_Duplicated = -10035,
    // The value of the key "Name" is invalid.
    DBRErrorCode_Template_Name_Invalid      = -10036,
    // The name reference is invalid.
    DBRErrorCode_Json_Name_Reference_Invalid = -10037,
    // The parameter value is invalid or out of range.
    DBRErrorCode_Parameter_Value_Invalid    = -10038,
    //The domain of your current site does not match the domain bound in the current product key.
    DBRErrorCode_Domain_Not_Matched         = -10039
};

// Describes types of barcodes.
typedef NS_OPTIONS(NSInteger, BarcodeType) {
    // Code 39
    BarcodeTypeCODE39     = 1 << 0,
    // Code 128
    BarcodeTypeCODE128    = 1 << 1,
    // Code 93
    BarcodeTypeCODE93     = 1 << 2,
    // Codebar
    BarcodeTypeCODABAR    = 1 << 3,
    // Interleaved 2 of 5
    BarcodeTypeITF        = 1 << 4,
    // EAN-13
    BarcodeTypeEAN13      = 1 << 5,
    // EAN-8
    BarcodeTypeEAN8       = 1 << 6,
    // UPC-A
    BarcodeTypeUPCA       = 1 << 7,
    // UPC-E
    BarcodeTypeUPCE       = 1 << 8,
    // Industrial 2 of 5
    BarcodeTypeINDUSTRIAL = 1 << 9,
    // PDF417
    BarcodeTypePDF417     = 1 << 25,
    // QR CODE
    BarcodeTypeQRCODE     = 1 << 26,
    // Datamatrix
    BarcodeTypeDATAMATRIX = 1 << 27,
    // All OneD types
    BarcodeTypeONED       = BarcodeTypeCODE39 | BarcodeTypeCODE128 |
                            BarcodeTypeCODE93 | BarcodeTypeCODABAR |
                            BarcodeTypeITF    | BarcodeTypeEAN13   |
                            BarcodeTypeEAN8   | BarcodeTypeUPCA    |
                            BarcodeTypeUPCE   | BarcodeTypeINDUSTRIAL,
    // All supported formats
    BarcodeTypeALL        = BarcodeTypeONED   | BarcodeTypePDF417  |
                            BarcodeTypeQRCODE | BarcodeTypeDATAMATRIX
};

/**
 Describes the image pixel format.
 
 - ImagePixelTypeBinary: 0:Black, 1:White
 - ImagePixelTypeBinaryInverted: 0:White, 1:Black
 - ImagePixelTypeGrayScaled: 8bit gray
 - ImagePixelTypeNV21: NV21
 - ImagePixelTypeRGB_565: 16bits
 - ImagePixelTypeRGB_555: 16bits
 - ImagePixelTypeRGB_888: 24bits
 - ImagePixelTypeARGB_8888: 32bits
 */
typedef NS_ENUM(NSInteger, ImagePixelType) {
    ImagePixelTypeBinary,
    ImagePixelTypeBinaryInverted,
    ImagePixelTypeGrayScaled,
    ImagePixelTypeNV21,
    ImagePixelTypeRGB_565,
    ImagePixelTypeRGB_555,
    ImagePixelTypeRGB_888,
    ImagePixelTypeARGB_8888
};

/**
 Describes the extended result type
 
 - ResultTextTypeStandardText: Specifies the standard text, i.e. the barcode value.
 - ResultTextTypeRawText: Specifies the raw text, which means the text included start/stop characters, check digits, etc.
 - ResultTextTypeCandidateText: Specifies all the candidate text, i.e. all of the standard text results decoded from the barcode.
 - ResultTextTypePartialText: Specifies the partial Text, i.e. some parts of the text result decoded from the barcode.
 */
typedef NS_ENUM(NSInteger, ResultTextType) {
    ResultTextTypeStandardText,
    ResultTextTypeRawText,
    ResultTextTypeCandidateText,
    ResultTextTypePartialText
};

/**
 Describes the stage when the results are returned.
 
 - TerminateStatusPrelocalized: Prelocalized
 - TerminateStatusLocalized: Localized
 - TerminateStatusRecognized: Recognized
 */
typedef NS_ENUM(NSInteger, TerminateStatus) {
    TerminateStatusPrelocalized,
    TerminateStatusLocalized,
    TerminateStatusRecognized
};

/**
 Text filter mode.
 
 - TextFilterDisable: Disable text filter.
 - TextFilterEnable: Enable text filter.
 */
typedef NS_ENUM(NSInteger, TextFilter) {
    TextFilterDisable = 1,
    TextFilterEnable  = 2
};

/**
 Region predetection mode.
 
 - RegionPredetectionDisable: Disable region predetection.
 - RegionPredetectionEnable: Enable region predetection.
 */
typedef NS_ENUM(NSInteger, RegionPredetection) {
    RegionPredetectionDisable = 1,
    RegionPredetectionEnable  = 2
};

/**
 Barcode invert mode.
 
 - BarcodeInvertDarkOnLight: Dark barcode region on light background.
 - BarcodeInvertLightOnDark: Light barcode region on dark background.
 */
typedef NS_ENUM(NSInteger, BarcodeInvert) {
    BarcodeInvertDarkOnLight,
    BarcodeInvertLightOnDark
};

/**
 Color image convert mode.
 
 - ColorImageConvertAuto: Process input image as its original colour space.
 - ColorImageConvertGrayScale: Convert colour images to grayscale before processing.
 */
typedef NS_ENUM(NSInteger, ColourImageConvert) {
    ColourImageConvertAuto,
    ColourImageConvertGrayScale
};

/*--------------------------------------------------------------------*/

/**
 The struct representing barcode reader settings.
 */
@interface PublicSettings: NSObject

/**
 The name of the ImageParameters object, which is also the template name.
 */
@property (nonatomic, nonnull) NSString* name;

/**
 Sets the maximum amount of time (in milliseconds) it should spend searching for a barcode per page.
 @remark It does not include the time taken to load/decode an image (Tiff, PNG, etc) from disk into memory.
 */
@property (nonatomic, assign) NSInteger timeout;

/**
 Sets the output image resolution.
 */
@property (nonatomic, assign) NSInteger PDFRasterDPI;

/**
 Sets if active text filter mode in barcodes searching.
 */
@property (nonatomic, assign) TextFilter textFilter;

/**
 Sets if active region predetection mode in barcode searching.
 */
@property (nonatomic, assign) RegionPredetection regionPredetection;

/**
 Sets the priority of localization algorithms.
 */
@property (nonatomic, nonnull) NSString* localizationAlgorithmPriority;

/**
 Sets which types of barcode to be read.
 */
@property (nonatomic, assign) NSInteger barcodeTypeID;

/**
 Sets the sensitivity for texture detection.
 */
@property (nonatomic, assign) NSInteger textureDetectionSensitivity;

/**
 Sets the blurriness of the barcode.
 */
@property (nonatomic, assign) NSInteger deblurLevel;

/**
 The degree of anti-damage of the barcode, which decides the numbers of localization algorithm used.
 */
@property (nonatomic, assign) NSInteger antiDamageLevel;

/**
 Sets the maximum image dimension (in pixels) to localize barcode on the full image.
 */
@property (nonatomic, assign) NSInteger maxDimOfFullImageAsBarcodeZone;

/**
 Sets the maximum number of barcodes to read.
 */
@property (nonatomic, assign) NSInteger maxBarcodeCount;

/**
 The ink colour for barcodes search.
 */
@property (nonatomic, assign) BarcodeInvert barcodeInvert;

/**
 Sets the threshold value of the image shrinking.
 @remark The image will be shrinked if the shorter edge size is larger than the given value.
 */
@property (nonatomic, assign) NSInteger scaleDownThreshold;

/**
 Sets the sensitivity used for gray equalization.
 @remark The higher the value, the more likely gray equalization will be activated.
 */
@property (nonatomic, assign) NSInteger grayEqualizationSensitivity;

/**
 For 2D barcodes with a large module size there might be a vacant area in the position detection
 pattern after binarization which may result in a decoding failure. Setting this to true will
 fill in the vacant area with black and may help to decode it successfully.
 
 1 - enable, 0 - disable;
 */
@property (nonatomic, assign) NSInteger enableFillBinaryVacancy;

/**
 Sets if convert coloured images to grayscale.
 */
@property (nonatomic, assign) ColourImageConvert colourImageConvert;

/**
 
 */
@property (nonatomic, nonnull) NSString* reserved;

/**
 Sets the expected number of barcodes to read for each region of the image.
 */
@property (nonatomic, assign) NSInteger expectedBarcodeCount;


/**
 
 */
@property (nonatomic, assign) NSInteger binarizationBlockSize;

@end

/*--------------------------------------------------------------------*/

/**
 Stores the extended result including the format, the bytes, etc.
 */
@interface ExtendedResult: NSObject

/**
 Extended result type.
 */
@property (nonatomic, assign) ResultTextType resultType;

/**
 Barcode type.
 */
@property (nonatomic, assign) BarcodeType barcodeType;

/**
 The confidence of the result.
 */
@property (nonatomic, assign) NSInteger confidence;

/**
 The content in a byte array.
 */
@property (nonatomic, nullable) NSData* bytes;

@end

/*--------------------------------------------------------------------*/

/**
 Stores the localization result including the boundary, the angle, the page number, the region name, etc.
 */
@interface LocalizationResult: NSObject

/**
 The stage of localization result.
 */
@property (nonatomic, assign) TerminateStatus terminateStatus;

/**
 Barcode type. Only OneD/QRCode/PDF417/DataMatrix.
 */
@property (nonatomic, assign) BarcodeType barcodeType;

/**
 The angle of a barcode. Values range from 0 to 360.
 */
@property (nonatomic, assign) NSInteger angle;

/**
 The vetices' (x,y) coordinates information of the barcode region.
 */
@property (nonatomic, nullable) NSArray* resultPoints;

/**
 The barcode module size (the minimum bar width in pixel).
 */
@property (nonatomic, assign) NSInteger moduleSize;

/**
 The page number the barcode located in. The index is 0-based.
 */
@property (nonatomic, assign) NSInteger pageNumber;

/**
 The region name the barcode located in.
 */
@property (nonatomic, nullable) NSString* regionName;

/**
 The region name the barcode located in.
 */
@property (nonatomic, nullable) NSString* documentName;

/**
 The extended result array.
 */
@property (nonatomic, nullable) NSArray<ExtendedResult*>* extendedResults;

@end

/*--------------------------------------------------------------------*/

/**
 Stores the text result including the format, the text, the bytes, the localization result etc.
 */
@interface TextResult : NSObject

/**
 The barcode format.
 */
@property (nonatomic, assign) BarcodeType barcodeFormat;

/**
 The barcode text.
 */
@property (nonatomic, nullable) NSString* barcodeText;

/**
 The barcode content in a byte array.
 */
@property (nonatomic, nullable) NSData* barcodeBytes;

/**
 The corresponding localization result.
 */
@property (nonatomic, nullable) LocalizationResult* localizationResult;

@end

/*--------------------------------------------------------------------*/

@interface DynamsoftBarcodeReader : NSObject

/**
 Stores the license used in DynamsoftBarcodeReader.
 */
@property (nonatomic, nonnull) NSString* license;

/**
 Initialization of DynamsoftBarcodeReader.
 @remark If you initialize DynamsoftBaroceReader by this method without license, the decoding results maybe unreliable.
 
 @return The instance of DynamsoftBarcodeReader.
 */
- (instancetype _Nonnull)init;


/**
 Initialization of DynamsoftBarcodeReader with license.
 
 @param license The license key.
 @return The instance of DynamsoftBarcodeReader.
 */
- (instancetype _Nonnull)initWithLicense:(NSString* _Nonnull)license NS_DESIGNATED_INITIALIZER;

/**
 Append parameter template from a JSON string.
 
 @param content The settings file contents.
 @param error On input, a pointer to an error object. If an error occurs, this pointer is set to an actual error object containing the error information. You may specify nil for this parameter if you do not want the error information.
 */
- (void)appendParameterTemplateWithContent:(NSString* _Nonnull)content
                                     error:(NSError* _Nullable * _Nullable)error;

/**
 Append parameter template from a JSON file.
 
 @param fileName Template file path.
 @param error On input, a pointer to an error object. If an error occurs, this pointer is set to an actual error object containing the error information. You may specify nil for this parameter if you do not want the error information.
 */
- (void)appendParameterTemplateFromFile:(NSString* _Nonnull)fileName
                                  error:(NSError* _Nullable * _Nullable)error;

/**
 Decodes barcode from an image file encoded as a base64 string.
 
 @param base64 A base64 encoded string that represents an image.
 @param templateName The template name.
 @param error On input, a pointer to an error object. If an error occurs, this pointer is set to an actual error object containing the error information. You may specify nil for this parameter if you do not want the error information.
 @return All barcodes have been read. If no barcode is read, an array with length 0 will be returned
 */
- (NSArray<TextResult*>* _Nullable)decodeBase64:(NSString* _Nonnull)base64
                                   withTemplate:(NSString* _Nonnull)templateName
                                          error:(NSError* _Nullable * _Nullable)error;

/**
 Decodes barcode from an image file in memory.
 
 @param image The image file bytes in memory.
 @param templateName The template name.
 @param error On input, a pointer to an error object. If an error occurs, this pointer is set to an actual error object containing the error information. You may specify nil for this parameter if you do not want the error information.
 @return All barcodes have been read. If no barcode is read, an array with length 0 will be returned
 */
- (NSArray<TextResult*>* _Nullable)decodeImage:(UIImage* _Nonnull)image
                                  withTemplate:(NSString* _Nonnull)templateName
                                         error:(NSError* _Nullable * _Nullable)error;

/**
 Decdoes barcode frome an image raw buffer.
 
 @param buffer The image raw buffer
 @param width The width of the image buffer
 @param height The height of the iamge buffer
 @param stride The stride width(also called scan width) of the image buffer
 @param format The pixel format of the image buffer
 @param templateName The template name.
 @param error On input, a pointer to an error object. If an error occurs, this pointer is set to an actual error object containing the error information. You may specify nil for this parameter if you do not want the error information.
 @return All barcodes have been read. If no barcode is read, an array with length 0 will be returned
 */
- (NSArray<TextResult*>* _Nullable)decodeBuffer:(NSData* _Nonnull)buffer
                                      withWidth:(NSInteger)width
                                         height:(NSInteger)height
                                         stride:(NSInteger)stride
                                         format:(ImagePixelType)format
                                   templateName:(NSString* _Nonnull)templateName
                                          error:(NSError* _Nullable * _Nullable)error;

/**
 Decodes barcode in a specified image file with its path.
 
 @param name The local path of the file.
 @param templateName The template name.
 @param error On input, a pointer to an error object. If an error occurs, this pointer is set to an actual error object containing the error information. You may specify nil for this parameter if you do not want the error information.
 @return All barcodes have been read. If no barcode is read, an array with length 0 will be returned
 */
- (NSArray<TextResult*>* _Nullable)decodeFileWithName:(NSString* _Nonnull)name
                                         templateName:(NSString* _Nonnull)templateName
                                                error:(NSError* _Nullable * _Nullable)error;

/**
 Get all barcode localization results, which contains all localization information of both recognized barcodes and unrecogniazed barcodes.
 
 @param error On input, a pointer to an error object. If an error occurs, this pointer is set to an actual error object containing the error information. You may specify nil for this parameter if you do not want the error information.
 @return All barcodes have been localized. If no barcodes is localized, an array with length 0 will be returned
 */
- (NSArray<LocalizationResult*>* _Nullable)allLocalizationResults:(NSError* _Nullable * _Nullable)error;

/**
 Gets all parameter template name.
 
 @return All template names.
 */
- (NSArray<NSString*>* _Nullable)allParameterTemplateNames;

/**
 Sets the template setting with a template name.
 
 @param templateName The template name.
 @param error On input, a pointer to an error object. If an error occurs, this pointer is set to an actual error object containing the error information. You may specify nil for this parameter if you do not want the error information.
 @return The struct of template setting.
 */
- (PublicSettings* _Nullable)templateSettingsWithName:(NSString* _Nonnull)templateName
                                                error:(NSError* _Nullable * _Nullable)error;

/**
 Load parameter settings from a JSON string.
 
 @param content A JSON string that represents the content of the settings.
 @param error On input, a pointer to an error object. If an error occurs, this pointer is set to an actual error object containing the error information. You may specify nil for this parameter if you do not want the error information.
 */
- (void)loadSettingsWithContent:(NSString* _Nonnull)content
                          error:(NSError* _Nullable * _Nullable)error;

/**
 Loads parameter settings from a JSON file.
 
 @param fileName The path of the setting file.
 @param error On input, a pointer to an error object. If an error occurs, this pointer is set to an actual error object containing the error information. You may specify nil for this parameter if you do not want the error information.
 */
- (void)loadSettingsFromFile:(NSString* _Nonnull)fileName
                       error:(NSError* _Nullable * _Nullable)error;

/**
 Sets the template setting with a struct.
 
 @param settings The struct of template setting.
 @param error  On input, a pointer to an error object. If an error occurs, this pointer is set to an actual error object containing the error information. You may specify nil for this parameter if you do not want the error information.
 */
- (void)setTemplateSettings:(PublicSettings* _Nonnull)settings
                      error:(NSError* _Nullable * _Nullable)error;

@end
