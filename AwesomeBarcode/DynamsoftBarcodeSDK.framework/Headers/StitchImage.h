//
//  StitchImage.h
//  DynamsoftBarcodeSDK+ImageFilter
//
//  Created by Dynamsoft on 19/08/2018.
//  Copyright © 2018 Dynamsoft. All rights reserved.
//

#ifndef StitchImage_h
#define StitchImage_h
#import <UIKit/UIKit.h>
#import "DynamsoftBarcodeReader.h"

//@interface BMPFmt: NSObject
//
//@property (nonatomic,assign) int width;
//
//@property (nonatomic,assign) int height;
//
//@property (nonatomic,assign) int bitCnt;
//
//@property (nonatomic,assign) int clrUsed;
//
//@property (nonatomic,nullable) NSData* palette;
//
//@property (nonatomic,assign) int imgData;
//
//@property (nonatomic,nullable) NSData* imageData;
//
//-(instancetype)init;
//
//@end



@interface BuffInfOfImg: NSObject

//@property (nonatomic,nullable) NSData* buffer;

@property (nonatomic,nullable) unsigned char *imageBytes;

@property (nonatomic,assign) int width;

@property (nonatomic,assign) int height;

@property (nonatomic,assign) int stride;

@property (nonatomic,assign) ImagePixelType format;

-(instancetype)initWithUIImage:(UIImage*) image;

@end



@interface BarcodeRecogResult4StitchImg: NSObject

@property (nonatomic, copy) NSString* barcodeText;
//int Pts[4][2];
@property (nonatomic, copy) NSArray* Pts;

@property (nonatomic, assign) int barcodeFormat;

@end



@interface ParametersOfStitchImagesFun: NSObject

@property (nonatomic,retain) BuffInfOfImg* bInfOfImg;

@property (nonatomic, copy) NSArray<BarcodeRecogResult4StitchImg*>* barcodeRecogResultOfImg;

@property (nonatomic, assign) CGPoint domainOfImg;

@property (nonatomic, assign) float lengthThreshold;

@end



@interface StitchImage:NSObject

-(instancetype)init;

-(int) stitchImg:(NSArray<ParametersOfStitchImagesFun*>*)inputPrs MapResult:(NSMutableArray<BarcodeRecogResult4StitchImg*>*)mapResult resultImg: (UIImage* _Nullable * _Nullable)img;

//-(int) stitchImg:(UIImage*)outputImage ByteSize:(int*)byteSize width:(int*)width height:(int*)height MapResult:(NSMutableArray<BarcodeRecogResult*>*)mapResult;
//
//-(int) stitchImg:(NSData*)outputBuffer ByteSize:(int*)byteSize w:(int*)width h:(int*)height MapResult:(NSMutableArray<BarcodeRecogResult*>*)mapResult;

@end

#endif /* StitchImage_h */
