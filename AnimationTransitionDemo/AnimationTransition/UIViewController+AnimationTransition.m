//
//  UIViewController+AnimationTransition.m
//  AnimationTransitionDemo
//
//  Created by 宋澎 on 2018/7/13.
//  Copyright © 2018年 宋澎. All rights reserved.
//

#import "UIViewController+AnimationTransition.h"

#import "AnimationInteractiveTransition.h"

#import <objc/runtime.h>

static char * const InteractiveTransitionKey = "InteractiveTransitionKey";

@implementation UIViewController (AnimationTransition)

- (void)setAnimationTransitionDelegate:(AnimationInteractiveTransition *)animationTransitionDelegate{
    
    objc_setAssociatedObject(self, InteractiveTransitionKey, animationTransitionDelegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (AnimationInteractiveTransition *)animationTransitionDelegate{
    return  objc_getAssociatedObject(self, InteractiveTransitionKey);
}

+ (void)load{
    Method oldMethod = class_getInstanceMethod([self class], @selector(viewWillAppear:));
    
    Method newMethod = class_getInstanceMethod([self class], @selector(newViewWillAppear:));
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        method_exchangeImplementations(oldMethod, newMethod);
    });
}

- (void)newViewWillAppear:(BOOL)animated{
    
    self.navigationController.delegate = self.animationTransitionDelegate;
    
    [self newViewWillAppear:animated];
}

- (UIView *)AnimationTransitionTargetView{
    return nil;
}


- (void)animation_presentVC:(UIViewController *)viewController type:(KAnimationTransitionType)type{
    
    if (type == KAnimationTransitionTypeNone) {
        
        [self none_presentViewController:viewController];
        
    }else if (type == KAnimationTransitionTypeSmooth) {
        
        [self smooth_presentViewController:viewController];
        
    }else if (type == KAnimationTransitionTypeTikTokComment){
        
        [self tikTokComment_presentViewController:viewController];
        
    }else{
        
        [self none_presentViewController:viewController];
    }
}

- (void)none_presentViewController:(UIViewController *)viewController{
    
    viewController.transitioningDelegate = nil;
    
    viewController.animationTransitionDelegate = nil;
    
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)smooth_presentViewController:(UIViewController *)viewController{
    
    self.animationTransitionDelegate = [[AnimationInteractiveTransition alloc] init];
    
    self.animationTransitionDelegate.type = KAnimationTransitionTypeSmooth;
    
    self.animationTransitionDelegate.targetView = viewController.view;         //增加手势
    
    self.animationTransitionDelegate.navigationController = nil;               //手势控制返回
    
    self.animationTransitionDelegate.currentViewController = viewController;   //手势控制返回
    
    self.animationTransitionDelegate.isOpenPanGesture = NO;                   //开启滑动手势
    
    self.animationTransitionDelegate.directionStyle = DirectionStyleNone;     //设置侧滑方向
    
    self.animationTransitionDelegate.isOpenScreenEdgePanGesture = YES;        //开启侧滑返回,注意:手势重叠问题
    
    viewController.transitioningDelegate = self.animationTransitionDelegate;
    
    viewController.animationTransitionDelegate = self.animationTransitionDelegate;
    
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)magicMove_presentViewController:(UIViewController *)viewController{
    
    self.animationTransitionDelegate = [[AnimationInteractiveTransition alloc] init];
    
    self.animationTransitionDelegate.type = KAnimationTransitionTypeMagicMove;
    
    self.animationTransitionDelegate.targetView = viewController.view;         //增加手势
    
    self.animationTransitionDelegate.navigationController = nil;             //手势控制返回
    
    self.animationTransitionDelegate.currentViewController = viewController;   //手势控制返回
    
    self.animationTransitionDelegate.isOpenPanGesture = YES;                  //开启滑动手势
    
    self.animationTransitionDelegate.directionStyle = DirectionStyleUp;       //设置滑动手势方向
    
    self.animationTransitionDelegate.isOpenScreenEdgePanGesture = YES;        //开启侧滑返回,注意:手势重叠问题
    
    viewController.transitioningDelegate = self.animationTransitionDelegate;
    
    viewController.animationTransitionDelegate = self.animationTransitionDelegate;
    
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)tikTokComment_presentViewController:(UIViewController *)viewController{
    
    self.animationTransitionDelegate = [[AnimationInteractiveTransition alloc] init];
    
    self.animationTransitionDelegate.type = KAnimationTransitionTypeTikTokComment;
    
    self.animationTransitionDelegate.targetView = nil;
    
    self.animationTransitionDelegate.navigationController = nil;               //手势控制返回
    
    self.animationTransitionDelegate.currentViewController = viewController;   //手势控制返回
    
    self.animationTransitionDelegate.isOpenPanGesture = YES;                   //开启滑动手势
    
    self.animationTransitionDelegate.directionStyle = DirectionStyleDown;     //设置滑动手势方向
    
    self.animationTransitionDelegate.isOpenScreenEdgePanGesture = NO;         //关闭侧滑返回,注意:手势重叠问题
    
    viewController.transitioningDelegate = self.animationTransitionDelegate;
    
    viewController.animationTransitionDelegate = self.animationTransitionDelegate;
    
    viewController.modalPresentationStyle = UIModalPresentationCustom;  //custom下,dismiss时,fromView并未移除
    
    [self presentViewController:viewController animated:YES completion:nil];
}

@end
