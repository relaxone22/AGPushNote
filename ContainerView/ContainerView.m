//
//  ContainerView.m
//  AGPushNote_Example
//
//  Created by tonyliu on 2015/3/5.
//  Copyright (c) 2015年 Aviel Gross. All rights reserved.
//

#import "ContainerView.h"
#import "MCSwipeTableViewCell.h"

static NSString * cellIdentifier = @"cell";

@interface ContainerView()<UITableViewDelegate, UITableViewDataSource, MCSwipeTableViewCellDelegate>

@property(strong,nonatomic) NSMutableArray *delegateRows;
@property(strong,nonatomic) NSMutableArray *dealRows;
@property(strong,nonatomic) NSMutableArray *backDelegateRows;
@property(strong,nonatomic) NSMutableArray *backDealRows;
@property(strong,nonatomic) NSMutableArray *sections;
@property(strong,nonatomic) MCSwipeTableViewCell *currentCell;
@property(strong,nonatomic) MCSwipeTableViewCell *delegateCell;
@property(strong,nonatomic) MCSwipeTableViewCell *dealCell;
@property(strong,nonatomic) UITableViewCell *penultimateCell;
@end

@implementation ContainerView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame style:UITableViewStylePlain];
    if (self) {
        self.delegate = self;
        self.dataSource = self;
        
        if(!_currentCell){
            _currentCell = [[MCSwipeTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            [self registerClass:[MCSwipeTableViewCell class] forCellReuseIdentifier:cellIdentifier];
        }
        
        _delegateRows = [[NSMutableArray alloc] initWithArray:@[@"1",@"2",@"3"]];
        _dealRows = [[NSMutableArray alloc] initWithArray:@[@"A",@"B",@"C"]];
        _sections = [[NSMutableArray alloc] initWithArray:@[_delegateRows,_dealRows]];
        _backDelegateRows = [[NSMutableArray alloc]init];
        _backDealRows = [[NSMutableArray alloc]init];
    }
    return self;
}

- (void)sizeToFit {
    [super sizeToFit];
    
    if(self.superview) {
        CGRect f = self.bounds;
        f.origin.x = (self.superview.frame.size.width - f.size.width) / 2;
        self.frame = f;
    }
    if(self.contentSize.height != 0.0) {
        CGRect f = self.frame;
        f.size.height = self.contentSize.height;
        
        f.size.width = _currentCell.frame.size.width;
        self.frame = f;
    }
}

#pragma mark - UITableViewDataSource
// number of section(s), now I assume there is only 1 section
- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView {
    [self sizeToFit];
//    self.tableHeaderView = [self forTableHeaderView];
    
    return [_sections count];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIControl *view = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 18)];
    view.backgroundColor = [UIColor blackColor];
    [view addTarget:self action:@selector(headSectionEvent:) forControlEvents:UIControlEventTouchUpInside];
    view.tag = section;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(tableView.frame.size.width*0.7, 5, tableView.frame.size.width*0.3, 18)];
    label.font = [UIFont boldSystemFontOfSize:12];
    
    label.text = @"02/12 13:01:01";
    [label sizeToFit];
    label.textColor = [UIColor orangeColor];
    
    [view addSubview:label];
    return view;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20.0;
}

// number of row in the section, I assume there is only 1 row
- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
    NSMutableArray *rows = [_sections objectAtIndex:section];
    if([rows count] > 0)
        return 1;
    else
        return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = _currentCell.bounds.size.height;
    
    if(_currentCell.tag == YES) {
        height = 0;
    }
    return height;
}

// the cell will be returned to the tableView
- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    _currentCell = [self dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(!_currentCell) {
        _currentCell = [[MCSwipeTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    // iOS 7 separator
    if ([_currentCell respondsToSelector:@selector(setSeparatorInset:)]) {
        _currentCell.separatorInset = UIEdgeInsetsZero;
    }
    
    //set value to cell and use it to judge how to config
    [self setValueCell:_currentCell forRowAtIndexPath:indexPath];
    [self configureCell:_currentCell forRowAtIndexPath:indexPath];
    return _currentCell;
}

#pragma mark - UITableViewDelegate
// when user tap the row, what action you want to perform
- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - TableViewCell
- (void)configureCell:(MCSwipeTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UIView *crossView = [self viewWithImageName:@"cross"];
    UIColor *redColor = [UIColor redColor];
    
    UIView *checkView = [self viewWithImageName:@"check"];
    UIColor *greenColor = [UIColor greenColor];
    
    cell.backgroundColor = [UIColor brownColor];
    cell.defaultColor = [UIColor grayColor];
    cell.delegate = self;
   
    [cell setSwipeGestureWithView:crossView color:redColor mode:MCSwipeTableViewCellModeExit state:MCSwipeTableViewCellState3 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
        NSLog(@"Did swipe \"Cross\" cell");
        [self editCell:cell commitEditingStyle:UITableViewCellEditingStyleDelete];
    }];
    
    NSMutableArray *rows = _sections[indexPath.section];
    UIView *view = [[UIView alloc]initWithFrame:cell.bounds];
    UIColor *color = greenColor;
    if(rows.count > 1) {
        color = [UIColor clearColor];
        cell.defaultColor = [UIColor clearColor];
    } else {
        view = checkView;
        color = greenColor;
        cell.defaultColor = [UIColor grayColor];
    }

    [cell setSwipeGestureWithView:view color:color mode:MCSwipeTableViewCellModeExit state:MCSwipeTableViewCellState1 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
        NSLog(@"Did swipe \"Checkmark\" cell");
        [self editCell:cell commitEditingStyle:UITableViewCellEditingStyleInsert];
    }];

}

-(void)setValueCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.imageView.image = [UIImage imageNamed:@"clock"];
    
    UIControl *imgView = (UIControl*)[self viewWithImageName:@"clock"];
    cell.accessoryView = imgView;
//    [imgView addTarget:self action:@selector(nil) forControlEvents:UIControlEventTouchDown];
    
    
    if(indexPath.section == 0 && [_delegateRows count] > 0) {
        cell.textLabel.text = [_delegateRows lastObject];
        _delegateCell = (MCSwipeTableViewCell*)cell;
    }
    else if(indexPath.section == 1 && [_dealRows count] > 0) {
        cell.textLabel.text = [_dealRows lastObject];
        _dealCell = (MCSwipeTableViewCell*)cell;
    }
}

-(void)editCell:(UITableViewCell *)cell commitEditingStyle:(UITableViewCellEditingStyle)editingStyle {
    NSIndexPath *indexPath = [self indexPathForCell:cell];
    NSMutableArray *rows = _sections[indexPath.section];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        if([rows isEqual: _delegateRows]) {
            [_delegateRows removeAllObjects];
        }
        else if([rows isEqual: _dealRows]) {
            [_dealRows removeAllObjects];
        }
        // Delete the row from the data source.
        [self deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        if(rows.count == 0) {
            [_sections removeObject:rows];
            [self deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        //a row msut have 2 or more rows to reflesh
        [rows removeLastObject];
        if(rows.count >= 1) {
            [self reloadData];
        }
        else {
            [self editCell:cell commitEditingStyle:UITableViewCellEditingStyleDelete];
        }
    }
}
#pragma mark - MCSwipeTableViewCellDelegate


// When the user starts swiping the cell this method is called
- (void)swipeTableViewCellDidStartSwiping:(MCSwipeTableViewCell *)cell {
    NSLog(@"Did start swiping the cell!");
    NSIndexPath *indexPath = [self indexPathForCell:cell];
    NSMutableArray *rows = _sections[indexPath.section];
    if(rows.count >1) {
        _penultimateCell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        _penultimateCell.imageView.image = cell.imageView.image;
        _penultimateCell.textLabel.text = rows[rows.count -2];
        _penultimateCell.backgroundColor = cell.backgroundColor;
        _penultimateCell.tag = 666;
        [cell addSubview:_penultimateCell];
    }
}

// When the user ends swiping the cell this method is called
- (void)swipeTableViewCellDidEndSwiping:(MCSwipeTableViewCell *)cell {
    NSLog(@"Did end swiping the cell!");
    UIView *view = [cell viewWithTag:666];
    if(view) {
        [view removeFromSuperview];
    }

}

// When the user is dragging, this method is called and return the dragged percentage from the border
- (void)swipeTableViewCell:(MCSwipeTableViewCell *)cell didSwipeWithPercentage:(CGFloat)percentage {
    NSLog(@"Did swipe with percentage : %f", percentage);
}

#pragma mark _ Utils
- (UIView *)viewWithImageName:(NSString *)imageName {
    UIImage *image = [UIImage imageNamed:imageName];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.contentMode = UIViewContentModeCenter;
    return imageView;
}

-(UIView *)forTableHeaderView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 15)];
    view.backgroundColor = [UIColor blackColor];
    
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeBtn setTitle:@"關閉" forState:UIControlStateNormal];
    closeBtn.backgroundColor = [UIColor darkGrayColor];
    closeBtn.frame = CGRectMake(view.frame.size.width*0.8, 0, view.frame.size.width*0.15, 15);
    [closeBtn.titleLabel sizeToFit];
    [view addSubview:closeBtn];
    
    UIButton *minimizeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [minimizeBtn setTitle:@"清除" forState:UIControlStateNormal];
    minimizeBtn.backgroundColor = [UIColor darkGrayColor];
    minimizeBtn.frame = CGRectMake(view.frame.size.width*0.05, 0, view.frame.size.width*0.15, 15);
    [minimizeBtn.titleLabel sizeToFit];
    [view addSubview:minimizeBtn];
    
    return view;
}

@end
