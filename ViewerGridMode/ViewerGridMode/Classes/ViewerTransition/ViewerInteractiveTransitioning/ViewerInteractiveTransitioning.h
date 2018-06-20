//
//  ViewerInteractiveTransitioning.h
//  ViewerGridMode
//
//  Created by Son Pham on 6/18/18.
//  Copyright © 2018 Son Pham. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewerTransition.h"

@interface ViewerInteractiveTransitioning : UIPercentDrivenInteractiveTransition

@property (nonatomic) BOOL interactionInProgress;
@property (nonatomic) BOOL isPresent;
@property (nonatomic) BOOL enableGesture;

- (void)attachToViewController:(UIViewController *)viewController withView:(UIView *)view presentViewController:(UICollectionViewController *)presentViewController;

@end
