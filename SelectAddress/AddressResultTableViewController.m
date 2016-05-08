//
//  AddressResultTableViewController.m
//  SelectAddress
//
//  Created by Xcq on 16/5/8.
//  Copyright © 2016年 YiXue. All rights reserved.
//

#import "AddressResultTableViewController.h"

@interface AddressResultTableViewController ()

@end

@implementation AddressResultTableViewController

#pragma mark - lazy load
- (NSArray *)dataList {
    if (!_dataList) {
        _dataList = [NSArray array];
    }
    return _dataList;
}

- (NSArray *)districtList {
    if (!_districtList) {
        _districtList = [NSArray array];
    }
    return _districtList;
}

- (NSArray *)cityList {
    if (!_cityList) {
        _cityList = [NSArray array];
    }
    return _cityList;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupConfig];
    
}

- (void)setupConfig {
    self.tableView.backgroundColor = [UIColor colorWithRed:231.0/255 green:231.0/255 blue:231.0/255 alpha:1];
    self.tableView.tableFooterView = [[UIView alloc] init];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UITableViewCell"];
    }
    cell.textLabel.text = self.dataList[indexPath.row];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@%@",self.cityList[indexPath.row],self.districtList[indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateSearchBarText" object:nil userInfo:@{@"text":self.dataList[indexPath.row]}]; 
}

@end
