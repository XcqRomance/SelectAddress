//
//  LocationManager.h
//  SelectAddress
//
//  Created by Xcq on 16/5/8.
//  Copyright © 2016年 YiXue. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocationManager : NSObject

+ (LocationManager *)shareLocationManager; 

/**
 *  开始定位
 */
- (void)startLocation;
/**
 *  停止定位
 */
- (void)stopLocation;
/**
 *  判断是否授权开启定位
 */
- (BOOL)isAuthorizeOpenLocation;


@end
