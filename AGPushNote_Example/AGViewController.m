//
//  AGViewController.m
//  AGPushNote_Example
//
//  Created by Aviel Gross on 4/29/14.
//  Copyright (c) 2014 Aviel Gross. All rights reserved.
//

#import "AGViewController.h"
#import "AGPushNoteView.h"
#import "ContainerView.h"


@interface AGViewController ()

@end

@implementation AGViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)pushNowAction:(UIButton *)sender {
    UIView *containView =  [[ContainerView alloc]initWithFrame:CGRectMake(0, 0, 200, 50)];
    
    [AGPushNoteView resetShowStyle:PushViewUpShowStyle withClosePushSec:nil];
    [AGPushNoteView showWithUIView:containView inVc:self appearCompletion:nil disappearCompletion:nil
    ];
    

}

@end
