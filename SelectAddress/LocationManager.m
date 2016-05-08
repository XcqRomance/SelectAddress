//
//  LocationManager.m
//  SelectAddress
//
//  Created by Xcq on 16/5/8.
//  Copyright © 2016年 YiXue. All rights reserved.
//

#import "LocationManager.h"

@interface LocationManager() <BMKLocationServiceDelegate, BMKGeoCodeSearchDelegate, UIAlertViewDelegate>
@property (nonatomic, strong)BMKLocationService *locService; // 定位对象
@property (nonatomic, strong)BMKGeoCodeSearch *geoSearcher; // 地理编码对象
@end

@implementation LocationManager

+ (LocationManager *)shareLocationManager {

    static LocationManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[LocationManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        //初始化BMKLocationService
        _locService = [[BMKLocationService alloc]init];
        _locService.delegate = self;
        // 设定定位的最小更新距离(米)，更新频率。默认为kCLDistanceFilterNone
        _locService.distanceFilter = 100.0f;
        // 设定定位精度。默认为kCLLocationAccuracyBest。
        _locService.desiredAccuracy = kCLLocationAccuracyNearestTenMeters; // 定位精度10m
        
        _geoSearcher = [[BMKGeoCodeSearch alloc] init];
        _geoSearcher.delegate = self;
    }
    return self;
}

//不使用时将delegate设置为 nil
//-(void)viewWillDisappear:(BOOL)animated
//{
//    _geoSearcher.delegate = nil;
//}

- (void)startLocation {
    if ([self isAuthorizeOpenLocation]) { // 已经授权定位
        //启动LocationService
        [_locService startUserLocationService];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"定位服务未开启" message:@"请在设置中开启定位服务" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"去设置", nil];
        [alert show];
    }
    
}

- (void)stopLocation {
    [_locService stopUserLocationService];
}

- (BOOL)isAuthorizeOpenLocation {
    if ([CLLocationManager locationServicesEnabled] &&
        ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways
         || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse)) {
        return YES;
    }
    return NO; 
}

#pragma mark - BMKLocationServiceDelegate
//实现相关delegate 处理位置信息更新
//处理方向变更信息
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation
{
//    NSLog(@"heading is %@",userLocation.heading);
}
//处理位置坐标更新
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    //    NSLog(@"didUpdateUserLocation lat %f,long %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
    
    //发起反向地理编码检索
    CLLocationCoordinate2D pt = (CLLocationCoordinate2D){userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude};
    BMKReverseGeoCodeOption *reverseGeoCodeSearchOption = [[BMKReverseGeoCodeOption alloc] init];
    reverseGeoCodeSearchOption.reverseGeoPoint = pt;
    BOOL flag = [_geoSearcher reverseGeoCode:reverseGeoCodeSearchOption];
    
    if(flag)
    {
        NSLog(@"反geo检索发送成功");
    }
    else
    {
        NSLog(@"反geo检索发送失败"); 
    }
}

#pragma mark - BMKGeoCodeSearchDelegate
//  接收反向地理编码结果
-(void) onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:
(BMKReverseGeoCodeResult *)result
                        errorCode:(BMKSearchErrorCode)error{
    if (error == BMK_SEARCH_NO_ERROR) {
        //      在此处理正常结果
        NSLog(@"%@--%@",result.addressDetail.city, result.address);
        
        if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"UserCurrentAddress"] isEqualToString:result.address]) { // 用户当前位置与沙河存储位置相同
            // 关闭定位服务LocationService
            [self stopLocation];
        } else {
            [[NSUserDefaults standardUserDefaults] setValue:result.addressDetail.city forKey:@"UserCurrentCity"];  // 将用户城市位置存储，以便后面进行设置地址时的city
            [[NSUserDefaults standardUserDefaults] setValue:result.address forKey:@"UserCurrentAddress"];
        }        
    }
    else {
        [self startLocation];
        NSLog(@"抱歉，未找到结果");
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"%ld",(long)buttonIndex); 
    if (buttonIndex == 1) { // 去设置
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        } 
    }
}

@end
