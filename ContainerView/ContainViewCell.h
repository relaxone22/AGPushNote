//
//  ContainViewCell.h
//  AGPushNote_Example
//
//  Created by tonyliu on 2015/3/5.
//  Copyright (c) 2015年 Aviel Gross. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContainViewCell : UITableViewCell

@property (strong,nonatomic) IBOutlet UILabel *iconLabel;
@property (strong,nonatomic) IBOutlet UILabel *msgLabel;
@property (strong,nonatomic) IBOutlet UIButton *removeBtn;

@end
