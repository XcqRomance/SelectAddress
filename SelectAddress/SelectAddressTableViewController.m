//
//  SelectAddressTableViewController.m
//  SelectAddress
//
//  Created by Xcq on 16/5/8.
//  Copyright © 2016年 YiXue. All rights reserved.
//

#import "SelectAddressTableViewController.h"
#import "AddressResultTableViewController.h"

@interface SelectAddressTableViewController () <UISearchResultsUpdating, UISearchBarDelegate, BMKSuggestionSearchDelegate>
@property (nonatomic, strong)NSArray *dataList; // 详细地址 ， 显示在cell的title上

// 搜索控制器，ios8开始替代 UISearchDisplayController
@property (nonatomic, strong)UISearchController *searchVc;
@property (nonatomic, strong)AddressResultTableViewController *resultVc;

@property (nonatomic, strong)BMKSuggestionSearch *searcher; // 检索对象
@end

@implementation SelectAddressTableViewController

#pragma mark - lazy load
- (NSArray *)dataList {
    if (!_dataList) {
        _dataList = [NSArray array];
    }
    return _dataList;
}

- (AddressResultTableViewController *)resultVc {
    if (!_resultVc) {
        _resultVc = [[AddressResultTableViewController alloc] init];
    }
    return _resultVc;
}

- (UISearchController *)searchVc {
    if (!_searchVc) {
        _searchVc = [[UISearchController alloc] initWithSearchResultsController:self.resultVc];
        _searchVc.searchResultsUpdater = self;
        _searchVc.dimsBackgroundDuringPresentation = NO; // 点击背景时，取消激活
        _searchVc.searchBar.placeholder = @"请输入选择地址";
        _searchVc.searchBar.delegate = self;
        _searchVc.searchBar.returnKeyType = UIReturnKeyDone;
    }
    return _searchVc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"选择地址"; 
    self.tableView.backgroundColor = [UIColor colorWithRed:231.0/255 green:231.0/255 blue:231.0/255 alpha:1];
    self.tableView.tableHeaderView = self.searchVc.searchBar;
    self.tableView.tableFooterView = [[UIView alloc] init]; 
    self.definesPresentationContext = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSearchBarText:) name:@"UpdateSearchBarText" object:nil];
}

- (void)updateSearchBarText:(NSNotification *)notif {
    self.searchVc.searchBar.text = notif.userInfo[@"text"];
    [[NSNotificationCenter defaultCenter] postNotificationName:UITextFieldTextDidChangeNotification object:nil]; 
}

//不使用时将delegate设置为 nil
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    _searcher.delegate = nil;
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
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@%@",self.resultVc.cityList[indexPath.row],self.resultVc.districtList[indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.searchVc.searchBar.text = self.dataList[indexPath.row];
    self.searchVc.active = YES; 
}

#pragma mark - UISearchResultsUpdating
// 此方法必须实现，当搜索框成为第一响应者的时候将会调用
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    //初始化检索对象
    _searcher =[[BMKSuggestionSearch alloc]init];
    _searcher.delegate = self;
    BMKSuggestionSearchOption *option = [[BMKSuggestionSearchOption alloc] init];
    NSLog(@"[[NSUserDefaults standardUserDefaults] valueForKey:UserCurrentCity]%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"UserCurrentCity"]);
    option.cityname = [[NSUserDefaults standardUserDefaults] valueForKey:@"UserCurrentCity"];
    option.keyword  = self.searchVc.searchBar.text;
    BOOL flag = [_searcher suggestionSearch:option];
    if(flag)
    {
        NSLog(@"建议检索发送成功1");
    }
    else
    {
        NSLog(@"建议检索发送失败1");
    }
}

#pragma mark - UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    self.dataList = [NSArray arrayWithObject:searchBar.text];
    [self.tableView reloadData];
    self.searchVc.active = NO;
}

#pragma mark - BMKSuggestionSearchDelegate
- (void)onGetSuggestionResult:(BMKSuggestionSearch*)searcher result:(BMKSuggestionResult*)result errorCode:(BMKSearchErrorCode)error{
    if (error == BMK_SEARCH_NO_ERROR) {
        //在此处理正常结果 
        self.resultVc.cityList = result.cityList;
        self.resultVc.districtList = result.districtList;
        self.resultVc.dataList = result.keyList;
        [self.resultVc.tableView reloadData]; 
    }
    else {
        NSLog(@"抱歉，未找到结果");
    }
}

@end
