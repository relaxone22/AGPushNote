//
//  IAAPushNoteView.h
//  TLV Airport
//
//  Created by Aviel Gross on 1/29/14.
//  Copyright (c) 2014 NGSoft. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^completionBlk)(void);

typedef NS_ENUM(NSInteger, PushViewShowStyle) {
    PushViewUpShowStyle = 0,
    PushViewDownShowStyle
};

@interface AGPushNoteView : UIView

+ (void)showWithUIView:(UIView *)containerView inVc:(UIViewController*)vc appearCompletion:(completionBlk)didAppearBlk
   disappearCompletion:(completionBlk)didDisappearBlk;

+ (void)resetShowStyle:(PushViewShowStyle)showStyle
      withClosePushSec:(NSNumber*)closePushSecNumber;

@end
