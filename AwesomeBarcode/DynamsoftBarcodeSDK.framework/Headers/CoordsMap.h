//
//  InputParasOfCoordsMapFunction.h
//  DynamsoftBarcodeSDK
//
//  Created by Dynamsoft on 27/07/2018.
//  Copyright © 2018 Dynamsoft. All rights reserved.
//

#ifndef CoordsMapFunction_h
#define CoordsMapFunction_h

#import <UIKit/UIKit.h>
#import "DynamsoftBarcodeReader.h"

@interface BarcodeRecogResultForCordsMap: NSObject

@property (nonatomic, copy) NSString* barcodeText;
//int Pts[4][2];
@property (nonatomic, copy) NSArray* Pts;

@property (nonatomic, assign) int barcodeFormat;

@end

@interface ParametersOfCoordsMapFunction: NSObject

@property (nonatomic, copy) NSArray<BarcodeRecogResultForCordsMap*>* barcodeRecogResultOfImg1;

@property (nonatomic, copy) NSArray<BarcodeRecogResultForCordsMap*>* barcodeRecogResultOfImg2;

@property (nonatomic, assign) CGPoint domainOfImg1;

@property (nonatomic, assign) CGPoint domainOfImg2;

@property (nonatomic, assign) float lengthThreshold;

- (instancetype)init;

- (int)coordinationMap:(NSMutableArray<BarcodeRecogResultForCordsMap*>*)mapResult isAllCodeMapped:(bool*)isAllCodeMapped;

@end

#endif
