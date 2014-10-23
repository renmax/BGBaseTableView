//
//  BaseTableView.m
//  WeIBo
//
//  Created by mac on 14-10-22.
//  Copyright (c) 2014年 mac. All rights reserved.
//

#import "BaseTableView.h"

@implementation BaseTableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
    }
    return self;
}

- (void)awakeFromNib {
    [self initView];
}

- (void)initView {
    
    //创建下拉刷新控件
    _refreshTableView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f,- self.bounds.size.height, self.frame.size.width, self.bounds.size.height)];
    _refreshTableView.delegate = self;
    
    self.delegate = self;
    self.dataSource = self;
    
    self.refreshHeaderView = YES;
    self.isMore = YES;
    
    
    _moreButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    _moreButton.backgroundColor = [UIColor clearColor];
    _moreButton.frame = CGRectMake(0, 0, kDeviceWidth, 40);
    
    [_moreButton setTitle:@"上拉加载更多..." forState:UIControlStateNormal];
    [_moreButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_moreButton.titleLabel setFont:[UIFont systemFontOfSize:16.0f]];
    _moreButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_moreButton addTarget:self action:@selector(loadMoreData) forControlEvents:UIControlEventTouchUpInside];
    _moreButton.hidden = YES;
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicator.frame =CGRectMake(90, 10, 20, 20);
    [indicator stopAnimating];
    indicator.tag = 101;
    [_moreButton addSubview:indicator];
    
    self.tableFooterView = _moreButton;
}

- (void)loadMoreData {
    [_moreButton setTitle:@"加载中.." forState:UIControlStateNormal];
    UIActivityIndicatorView *indictor = (UIActivityIndicatorView*)[_moreButton viewWithTag:101];
    [indictor startAnimating];
    
    //调用上拉协议方法
    if ([self.refreshDelegate respondsToSelector:@selector(refreshUp:)]) {
        [self.refreshDelegate refreshUp:self];
    }
}

- (void)setIsMore:(BOOL)isMore {
    _isMore = isMore;
    if (isMore) {
       [_moreButton setTitle:@"上拉加载更多..." forState:UIControlStateNormal];
        
    }else {
        [_moreButton setTitle:@"没有更多数据了" forState:UIControlStateNormal];
        _moreButton.enabled = NO;
    }
    
    UIActivityIndicatorView *indictor = (UIActivityIndicatorView*)[_moreButton viewWithTag:101];
    [indictor stopAnimating];
}

- (void)setRefreshHeaderView:(BOOL)refreshHeaderView {
    _refreshHeaderView = refreshHeaderView;
    if (_refreshHeaderView) {
        [self addSubview:_refreshTableView];
    }else {
        [_refreshTableView removeFromSuperview];
    }
}

- (void)setData:(NSArray *)data {
    if (_data != data) {
        [_data release];
        _data = [data retain];
    }
    
    if (_data.count == 0) {
        _moreButton.hidden = YES;
    }else {
        _moreButton.hidden = NO;
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.refreshDelegate respondsToSelector:@selector(didSelectedRowAtIndexPath:indexPath :)]) {
        [self.refreshDelegate didSelectedRowAtIndexPath:self indexPath:indexPath];
    }
   
}

#pragma mark Data Source Loading / Reloading Methods

/**
 *  下拉控件相关方法
 */

- (void)showRefreshHeader {
    [_refreshTableView refreshLoading:self];
}

- (void)reloadTableViewDataSource{
	_reloading = YES;
}

- (void)doneLoadingTableViewData{
	_reloading = NO;
	[_refreshTableView egoRefreshScrollViewDataSourceDidFinishedLoading:self];
}

#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	
	[_refreshTableView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	[_refreshTableView egoRefreshScrollViewDidEndDragging:scrollView];
	
    
//    NSLog(@"偏移量： %f",scrollView.contentOffset.y);
//    NSLog(@"内容高度: %f",scrollView.contentSize.height);
    
    
    //上拉tableView超出内容的高度
    float h = scrollView.contentOffset.y+scrollView.height - scrollView.contentSize.height;
    
    //上拉距离80，且有更多数据的时候才loadMoreData(isMore == YES)
    if (h > 80 && _isMore) {
        [self loadMoreData];
    }
    
    UIActivityIndicatorView *indictor = (UIActivityIndicatorView *)[_moreButton viewWithTag:101];
   
    if ([_moreButton.titleLabel.text isEqualToString:@"没有更多数据了"]) {
        [indictor stopAnimating];
    }
    
}


#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods
//下拉到一定距离，手指放开时调用
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	
	[self reloadTableViewDataSource];
    
    //调用代理对象，协议方法
    if ([self.refreshDelegate respondsToSelector:@selector(refreshDown:)]) {
        [self.refreshDelegate refreshDown:self];
    }
    
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
	return _reloading; // should return if data source model is reloading
	
}

//取得下拉刷新的时间
- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [NSDate date]; // should return date data source was last changed
	
}


@end
