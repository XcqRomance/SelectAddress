//
//  AddressResultTableViewController.h
//  SelectAddress
//
//  Created by Xcq on 16/5/8.
//  Copyright © 2016年 YiXue. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddressResultTableViewController : UITableViewController
@property (nonatomic, strong)NSArray *dataList; // 详细地址 ， 显示在cell的title上
@property (nonatomic, strong)NSArray *districtList; // 搜索回调的区
@property (nonatomic, strong)NSArray *cityList; // 搜索回调的市
@end
