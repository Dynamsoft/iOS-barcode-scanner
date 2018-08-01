//
//  InputParasOfCoordsMapFunction.h
//  DynamsoftBarcodeSDK
//
//  Created by Dynamsoft on 27/07/2018.
//  Copyright © 2018 Dynamsoft. All rights reserved.
//

#ifndef InputParasOfCoordsMapFunction_h
#define InputParasOfCoordsMapFunction_h

#import <UIKit/UIKit.h>
#import "DynamsoftBarcodeReader.h"

@interface BarcodeRecogResult: NSObject

@property (nonatomic, copy) NSString* barcodeText;
//int Pts[4][2];
@property (nonatomic, copy) NSArray* Pts;

@end


@interface BuffInfOfImg:NSObject

@property (nonatomic,nullable) NSData* buffer;

@property (nonatomic,assign) int width;

@property (nonatomic,assign) int height;

@property (nonatomic,assign) int stride;

@property (nonatomic,assign) ImagePixelType format;

-(instancetype)initWithUIImage:(UIImage*) image;

@end


@interface ParametersOfCoordsMapFunction: NSObject

@property (nonatomic,retain) BuffInfOfImg* bInfoImage1;

@property (nonatomic,retain) BuffInfOfImg* bInfoImage2;

@property (nonatomic, assign) CGPoint domainOfImg1;

@property (nonatomic, assign) CGPoint domainOfImg2;

@property (nonatomic, copy) NSArray<BarcodeRecogResult*>* barcodeRecogResultOfImg1;

@property (nonatomic, copy) NSArray<BarcodeRecogResult*>* barcodeRecogResultOfImg2;

@property (nonatomic, assign) float lengthThreshold;

- (instancetype)init;

- (int)coordinationMap:(NSMutableArray<BarcodeRecogResult*>*)mapResult isAllCodeMapped:(bool*)isAllCodeMapped;

-(int) stitchImg:(UIImage*)outputImage ByteSize:(int*)byteSize width:(int*)width height:(int*)height MapResult:(NSMutableArray<BarcodeRecogResult*>*)mapResult;

-(int) stitchImg:(NSData*)outputBuffer ByteSize:(int*)byteSize w:(int*)width h:(int*)height MapResult:(NSMutableArray<BarcodeRecogResult*>*)mapResult;

- (void) deleteStitchedImg:(NSData* _Nonnull)image;

@end

#endif /* InputParasOfCoordsMapFunction_h */
