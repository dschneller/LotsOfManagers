//
//  CDPullToRefreshScrollView.h
//  CenterDevice
//
//  Created by Daniel Schneller on 18.07.12.
//  Copyright (c) 2012 codecentric AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#define REFRESH_HEADER_HEIGHT 80.0f


@protocol CDPullToRefreshScrollViewDelegate;

@interface CDPullToRefreshScrollView : UIScrollView<UIScrollViewDelegate> {
    
	UIView *refreshHeaderView;
    UILabel *refreshLabel;
    UIImageView *refreshArrow;
    UIActivityIndicatorView *refreshSpinner;
    BOOL isDragging;
    BOOL isLoading;
    NSString *textPull;
    NSString *textRelease;
    NSString *textLoading;

}

@property (nonatomic, retain) UIView *refreshHeaderView;
@property (nonatomic, retain) UILabel *refreshLabel;
@property (nonatomic, retain) UIImageView *refreshArrow;
@property (nonatomic, retain) UIActivityIndicatorView *refreshSpinner;
@property (nonatomic, copy) NSString *textPull;
@property (nonatomic, copy) NSString *textRelease;
@property (nonatomic, copy) NSString *textLoading;
@property (nonatomic, assign) id <CDPullToRefreshScrollViewDelegate> pullToRefreshDelegate; 
@property (nonatomic, assign) BOOL isDragging;
@property (nonatomic, readonly) BOOL isLoading;

-(void)displayReleaseText;
-(void)displayPullText;


-(void)startLoading;
-(void)stopLoading;
-(void)refresh; 

@end

@protocol CDPullToRefreshScrollViewDelegate

-(void)didPullToRefreshForScrollView:(CDPullToRefreshScrollView*)scrollView;

@end