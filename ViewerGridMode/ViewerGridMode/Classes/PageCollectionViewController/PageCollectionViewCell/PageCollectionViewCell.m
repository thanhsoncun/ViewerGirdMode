//
//  PageCollectionViewCell.m
//  ViewerGridMode
//
//  Created by Son Pham on 7/2/18.
//  Copyright © 2018 ThanhSon. All rights reserved.
//

#import "PageCollectionViewCell.h"


@interface PageCollectionViewCell () <UIGestureRecognizerDelegate>

@property (nonatomic) UIPanGestureRecognizer *panGesture;
@property (nonatomic) UIRotationGestureRecognizer *rotationGesture;

@property (nonatomic) BOOL interactionInProgress;

@end


@implementation PageCollectionViewCell {
    CGFloat currentScale;
    CGAffineTransform transformDefault;
    CGAffineTransform transformZoom;
    CGAffineTransform transformRotate;
    CGAffineTransform transformMove;
    
    BOOL _shouldCompleteTransition;
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self configGesture];
}




#pragma mark - ConfigGesture

- (void)configGesture {
    
    [self.imv setUserInteractionEnabled:YES];
    
    // remove gestures
    [self removeGestureRecognizer:_panGesture];
    [self removeGestureRecognizer:_pinchGesture];
//    [self removeGestureRecognizer:_rotationGesture];
    
//    [self.imv removeGestureRecognizer:_panGesture];
//    [self.imv removeGestureRecognizer:_pinchGesture];
//    [self.imv removeGestureRecognizer:_rotationGesture];
    
    // add gesture
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGestureRecognizer:)];
    self.panGesture.delegate = self;
    self.panGesture.minimumNumberOfTouches = 2;
    self.panGesture.maximumNumberOfTouches = 2;
    
    self.pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    self.pinchGesture.delegate = self;
    
    currentScale = 1;
    
    self.rotationGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotateGestureRecognizer:)];
    self.rotationGesture.delegate = self;
    
    [self addGestureRecognizer:self.pinchGesture];
    [self addGestureRecognizer:self.panGesture];
    
//    [self.imv addGestureRecognizer:self.pinchGesture];
//    [self.imv addGestureRecognizer:self.panGesture];
    //[self.imv addGestureRecognizer:self.rotationGesture];
}

- (void)setEnableGesture:(BOOL)enableGesture {
    [self.pinchGesture setEnabled:enableGesture];
    [self.panGesture setEnabled:enableGesture];
    [self.rotationGesture setEnabled:enableGesture];
}

#pragma mark - Handler Gesture

- (void)handlePinch:(UIPinchGestureRecognizer*)gestureRecognizer {
    
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan: {
            NSLog(@"%f",gestureRecognizer.velocity);
            if (gestureRecognizer.scale < 1 && gestureRecognizer.velocity < 0) {
                if (!_interactionInProgress ) {
                    if (_delegate && [_delegate respondsToSelector:@selector(pageCollectionViewCell:dismissViewController:)]) {
                        [_delegate pageCollectionViewCell:self dismissViewController:self.indexPage];
                    }
                    _interactionInProgress = YES;
                }
                
            }
        }
            break;
            
        case UIGestureRecognizerStateChanged: {
            
            if (gestureRecognizer.scale < 3 && gestureRecognizer.scale > 0.4) {
                [gestureRecognizer view].transform = CGAffineTransformScale(CGAffineTransformIdentity, gestureRecognizer.scale, gestureRecognizer.scale);
                
                if (_interactionInProgress == YES) {
                    if (_interactionInProgress && gestureRecognizer.scale < 1) {
                        CGFloat fraction = fabs((1 - gestureRecognizer.scale) / 0.4);
                        fraction = fminf(fmaxf(fraction, 0.0), 0.7);
                        _shouldCompleteTransition = (fraction > 0.5);
                        if (fraction >= 1.0)
                            fraction = 0.99;
                        
                        if (_delegate && [_delegate respondsToSelector:@selector(pageCollectionViewCell:updateInteractiveTransition:)]) {
                            [_delegate pageCollectionViewCell:self updateInteractiveTransition:fraction];
                        }

                    }
                }
            } else {
                if (gestureRecognizer.scale <= 0.4) {
                    [self setEnableGesture:NO];
                }
            }
        }
            break;
            
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded: {
            NSLog(@"______");
            currentScale = [gestureRecognizer scale];
            [self animationEndGesture];
            
        }
            break;
        default:
            break;
    }
    
}

- (void)handlePanGestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer {
    
    CGPoint pointGesture = [gestureRecognizer translationInView: gestureRecognizer.view];
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan: {
            
        }
            break;
            
        case UIGestureRecognizerStateChanged: {
            transformMove = CGAffineTransformTranslate([gestureRecognizer view].transform, pointGesture.x, pointGesture.y);
            [gestureRecognizer view].transform = transformMove;
        }
            break;
            
        case UIGestureRecognizerStateEnded: {
            
        }
            break;
            
        default:
            break;
    }
}

- (void)handleRotateGestureRecognizer:(UIRotationGestureRecognizer *)gestureRecognizer {
    
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan: {
            
        }
            break;
            
        case UIGestureRecognizerStateChanged: {
            CGFloat rotate = [gestureRecognizer rotation];
            
            transformDefault = CGAffineTransformRotate([gestureRecognizer view].transform, rotate);
            [gestureRecognizer view].transform = transformDefault;
        }
            break;
            
        case UIGestureRecognizerStateEnded: {
            
        }
            break;
            
        default:
            break;
    }
}

- (void)animationEndGesture {
    
    if (_shouldCompleteTransition) {
        _shouldCompleteTransition = NO;
        _interactionInProgress = NO;
        if (_delegate && [_delegate respondsToSelector:@selector(pageCollectionViewCell:finishInteractiveTransition:)]) {
            [_delegate pageCollectionViewCell:self finishInteractiveTransition:YES];
        }
        
    } else {
        
        if (_delegate && [_delegate respondsToSelector:@selector(pageCollectionViewCell:finishInteractiveTransition:)]) {
            [_delegate pageCollectionViewCell:self finishInteractiveTransition:NO];
        }
        
        UIView *currentView = self.pinchGesture.view;
        _interactionInProgress = NO;
        
        [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:0.8 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self setEnableGesture:NO];
            currentView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            [self setEnableGesture:YES];
            //[self.view removeGestureRecognizer:_panGestureVC];
        }];
    }
    

}

#pragma mark - TransitionControllerGestureTarget

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    if (([gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]] || gestureRecognizer == self.panGesture || gestureRecognizer == self.rotationGesture)
        &&([otherGestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]] || otherGestureRecognizer == self.panGesture || otherGestureRecognizer == self.rotationGesture)) {
        return YES;
    }
    
    return NO;
}

@end
