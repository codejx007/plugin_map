//
//  CommonUtility.h
//  SearchV3Demo
//
//  Created by zw on 14-12-22.
//  Copyright (c) 2014年 zw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchAPI.h>

#import "LineDashPolyline.h"


@interface CommonUtility : NSObject

+ (CLLocationCoordinate2D *)coordinatesForString:(NSString *)string
                                 coordinateCount:(NSUInteger *)coordinateCount
                                      parseToken:(NSString *)token;

+ (MAPolyline *)polylineForCoordinateString:(NSString *)coordinateString;

+ (MATagPolyline *)tagPolylineForCoordinateString:(NSString *)coordinateString;

+ (MATagPolyline *)tagPolylineForLine:(MAPolyline *)stepPolyline lastPolyline:(MAPolyline *)lastPolyline;

+ (MAPolyline *)polylineForStep:(AMapStep *)step;

+ (MAPolyline *)polylineForBusLine:(AMapBusLine *)busLine;

+ (NSArray *)polylinesForWalking:(AMapWalking *)walking;

+ (NSArray *)polylinesForSegment:(AMapSegment *)segment;

+ (NSArray *)polylinesForPath:(AMapPath *)path;

+ (NSArray *)polylinesForTransit:(AMapTransit *)transit;


+ (MAMapRect)unionMapRect1:(MAMapRect)mapRect1 mapRect2:(MAMapRect)mapRect2;

+ (MAMapRect)mapRectUnion:(MAMapRect *)mapRects count:(NSUInteger)count;

+ (MAMapRect)mapRectForOverlays:(NSArray *)overlays;


+ (MAMapRect)minMapRectForMapPoints:(MAMapPoint *)mapPoints count:(NSUInteger)count;

+ (MAMapRect)minMapRectForAnnotations:(NSArray *)annotations;

+ (void)replenishPolylinesForPathWith:(MAPolyline *)stepPolyline
                         lastPolyline:(MAPolyline *)lastPolyline
                            Polylines:(NSMutableArray *)polylines;
@end
