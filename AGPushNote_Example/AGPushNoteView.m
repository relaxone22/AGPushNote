//
//  IAAPushNoteView.m
//  TLV Airport
//
//  Created by Aviel Gross on 1/29/14.
//  Copyright (c) 2014 NGSoft. All rights reserved.
//

#import "AGPushNoteView.h"

#define APP [UIApplication sharedApplication].delegate
#define PUSH_VIEW [AGPushNoteView sharedPushView]

#define SHOW_ANIM_DUR 0.5
#define HIDE_ANIM_DUR 0.35

static const NSString *currContainerViewKey                      = @"currContainerViewKey";
static const NSString *inVCKey                                   = @"inVCKey";
static const NSString *pushNoteDidAppearKey                      = @"pushNoteDidAppearKey";
static const NSString *pushNoteDidDisappearKey                   = @"pushNoteDidDisappearKey";

@interface AGPushNoteView()

@property (strong, nonatomic) NSTimer *closeTimer;
@property (strong, nonatomic) NSMutableArray *pendingPushArr;
@property (assign, nonatomic) PushViewShowStyle showStyle;
@property (assign, nonatomic) NSTimeInterval closePushSec;

@end


@implementation AGPushNoteView

//Singleton instance
static AGPushNoteView *_sharedPushView;

+ (instancetype)sharedPushView
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedPushView = [[AGPushNoteView alloc] init];
    });
    
    return _sharedPushView ? :nil;
}

#pragma mark - Lifecycle (of sort)
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:APP.window.frame];
    
    self.layer.zPosition = MAXFLOAT;
    self.backgroundColor = [UIColor clearColor];
    self.multipleTouchEnabled = NO;
    self.exclusiveTouch = YES;
    
    return self;
}

+ (void)resetShowStyle:(PushViewShowStyle)showStyle
      withClosePushSec:(NSNumber*)closePushSecNumber {
    PUSH_VIEW.showStyle = showStyle;
    
    if(closePushSecNumber) {
        PUSH_VIEW.closePushSec = [closePushSecNumber doubleValue];
    }
}

+ (void)showWithUIView:(UIView *)containerView
                  inVc:(UIViewController*)vc
      appearCompletion:(completionBlk)didAppearBlk
   disappearCompletion:(completionBlk)didDisappearBlk; {
    
    NSMutableDictionary *propertyDic = [NSMutableDictionary dictionary];
    
    if(containerView) {
        propertyDic[currContainerViewKey] = containerView;
    }
    if(vc) {
        propertyDic[inVCKey] = vc;
    }
    if(didAppearBlk) {
        propertyDic[pushNoteDidAppearKey] = didAppearBlk;
    }
    if(didDisappearBlk) {
        propertyDic[pushNoteDidDisappearKey] = didDisappearBlk;
    }

    if(containerView) {
        
        [PUSH_VIEW.pendingPushArr addObject:propertyDic];
        
        APP.window.windowLevel = UIWindowLevelStatusBar;
        [PUSH_VIEW addSubview:containerView];
        PUSH_VIEW.frame = [PUSH_VIEW pushViewOrignY:NO];
        
        [APP.window addSubview:PUSH_VIEW];
        
        //Show
        [UIView animateWithDuration:SHOW_ANIM_DUR delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            PUSH_VIEW.frame = [PUSH_VIEW pushViewOrignY:YES];
        } completion:^(BOOL finished) {
            if(didAppearBlk) {
                didAppearBlk();
            }
        }];
        
        //Start timer (Currently not used to make sure user see & read the push...)
        if(PUSH_VIEW.closePushSec) {
            PUSH_VIEW.closeTimer = [NSTimer timerWithTimeInterval:PUSH_VIEW.closePushSec
                                                           target:self
                                                         selector:@selector(close)
                                                         userInfo:nil
                                                          repeats:NO];
            [[NSRunLoop currentRunLoop] addTimer:PUSH_VIEW.closeTimer forMode:NSRunLoopCommonModes];
        }
    }
}


- (void)close {
   
    [PUSH_VIEW.closeTimer invalidate];
    
    [UIView animateWithDuration:HIDE_ANIM_DUR delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        PUSH_VIEW.frame = [PUSH_VIEW pushViewOrignY:YES];
    } completion:^(BOOL finished) {
        id lastObj = [self.pendingPushArr lastObject];
        [PUSH_VIEW handlePendingPushJumpWitCompletion:lastObj[pushNoteDidDisappearKey]];
    }];
}

#pragma mark - Private Pending push managment
- (void)handlePendingPushJumpWitCompletion:(void (^)(void))completion {
    id lastObj = [self.pendingPushArr lastObject]; //Get myself
    if (lastObj) {
        [self.pendingPushArr removeObject:lastObj]; //Remove me from arr
        lastObj = [self.pendingPushArr lastObject]; //Maybe get pending push
        
        if (lastObj) { //If got something - remove from arr, - than show it.
            
            [self.pendingPushArr removeObject:lastObj];
            NSMutableDictionary *propertyDic =(NSMutableDictionary*)lastObj;
            [AGPushNoteView showWithUIView:propertyDic[currContainerViewKey]
                                      inVc:propertyDic[inVCKey]
                          appearCompletion:propertyDic[pushNoteDidAppearKey]
                       disappearCompletion:propertyDic[pushNoteDidDisappearKey]];
        } else {
            APP.window.windowLevel = UIWindowLevelNormal;
        }
    }
}

- (NSMutableArray *)pendingPushArr {
    _pendingPushArr = _pendingPushArr ? :[[NSMutableArray alloc] init];
    return _pendingPushArr;
}

- (CGRect)pushViewOrignY:(BOOL)isShow {
    
    CGRect f = PUSH_VIEW.frame;
    CGRect inViewFrame = APP.window.frame;
    
    if(!isShow) {
        
        if(PUSH_VIEW.showStyle == PushViewUpShowStyle) {
            f.origin.y = inViewFrame.origin.y - PUSH_VIEW.frame.size.height;
        }
        else if(PUSH_VIEW.showStyle == PushViewDownShowStyle) {
            f.origin.y = (inViewFrame.origin.y + inViewFrame.size.height);
        }
    }
    else {
        if(PUSH_VIEW.showStyle == PushViewUpShowStyle) {
            f.origin.y = inViewFrame.origin.y;
        }
        else if(PUSH_VIEW.showStyle == PushViewDownShowStyle) {
            f.origin.y = (inViewFrame.origin.y + inViewFrame.size.height) - PUSH_VIEW.frame.size.height;
        }
    }
    return f;
}

-(id)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    id hitView = [super hitTest:point withEvent:event];
    if (hitView == self)
        return nil;
    else
        return hitView;
}


@end
