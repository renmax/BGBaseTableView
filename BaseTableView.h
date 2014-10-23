//
//  BaseTableView.h
//  WeIBo
//
//  Created by mac on 14-10-22.
//  Copyright (c) 2014年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"

@class BaseTableView;

@protocol BaseTableViewFreshDelegate <NSObject>

@optional
//下拉事件
- (void)refreshDown:(BaseTableView *)tableView;

//上拉事件
- (void)refreshUp:(BaseTableView *)tableView;

//选中单元格事件
- (void)didSelectedRowAtIndexPath:(BaseTableView *)tableView indexPath :(NSIndexPath *)indexpath;

@end

@interface BaseTableView : UITableView <EGORefreshTableHeaderDelegate,UITableViewDelegate,UITableViewDataSource>{
    
    EGORefreshTableHeaderView *_refreshTableView;
    BOOL _reloading;
    UIButton *_moreButton;
}

@property (nonatomic,retain)NSArray *data;
@property (nonatomic,assign)id refreshDelegate;

//是否有更多数据（下一页）
@property (nonatomic,assign)BOOL isMore;
//是否需要下拉刷新
@property (nonatomic,assign)BOOL refreshHeaderView;

//收起下拉
- (void)doneLoadingTableViewData;

//双击home键，显示下拉加载
- (void)showRefreshHeader;

@end
