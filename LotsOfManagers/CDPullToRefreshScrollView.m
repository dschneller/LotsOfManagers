//
//  CDPullToRefreshScrollView.m
//  CenterDevice
//
//  Created by Daniel Schneller on 18.07.12.
//  Copyright (c) 2012 codecentric AG. All rights reserved.
//

#import "CDPullToRefreshScrollView.h"
#import <QuartzCore/QuartzCore.h>

@implementation CDPullToRefreshScrollView

@synthesize pullToRefreshDelegate;
@synthesize textPull, textRelease, textLoading, refreshHeaderView, refreshLabel, refreshArrow, refreshSpinner, isDragging, isLoading;

- (void)startLoading {
    isLoading = YES;
    [self displayLoadingText];
    // Refresh action!
    [self refresh];
}

- (void)stopLoading {
    isLoading = NO;
	
    // Hide the header
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDidStopSelector:@selector(stopLoadingComplete:finished:context:)];
    self.contentInset = UIEdgeInsetsZero;
    [UIView commitAnimations];
}

-(void)awakeFromNib
{
	textPull = @"Pull";
	textRelease = @"Release";
	textLoading = @"Loading";

	refreshHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0 - REFRESH_HEADER_HEIGHT, self.frame.size.width, REFRESH_HEADER_HEIGHT)];
	refreshHeaderView.backgroundColor = [UIColor clearColor];
	refreshHeaderView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	
    refreshLabel = [[UILabel alloc] initWithFrame:CGRectMake(REFRESH_HEADER_HEIGHT + 5, 0, 320, REFRESH_HEADER_HEIGHT)];
    refreshLabel.backgroundColor = [UIColor clearColor];
    refreshLabel.font = [UIFont boldSystemFontOfSize:12.0];
    refreshLabel.textAlignment = UITextAlignmentLeft;
    refreshLabel.textColor = [UIColor whiteColor];
	
    refreshArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow.png"]];
    refreshArrow.frame = CGRectMake((REFRESH_HEADER_HEIGHT - 27) / 2,
                                    (REFRESH_HEADER_HEIGHT - 44) / 2,
                                    27, 44);
	
    refreshSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    refreshSpinner.frame = CGRectMake((REFRESH_HEADER_HEIGHT - 20) / 2, (REFRESH_HEADER_HEIGHT - 20) / 2, 20, 20);
    refreshSpinner.hidesWhenStopped = YES;
    refreshSpinner.color = [UIColor whiteColor];
	
    [refreshHeaderView addSubview:refreshLabel];
    [refreshHeaderView addSubview:refreshArrow];
    [refreshHeaderView addSubview:refreshSpinner];	
	
	[self addSubview:refreshHeaderView];
	
	[super awakeFromNib];		
}

- (void)stopLoadingComplete:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    // Reset the header
    [self displayPullText];
}

- (void) displayReleaseText
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [refreshSpinner stopAnimating];
    self.refreshLabel.text = self.textRelease;
    self.refreshArrow.hidden = NO;
    [self animateArrow:CGAffineTransformMakeRotation(-M_PI)];
    [UIView commitAnimations];
}

- (void) displayPullText
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [refreshSpinner stopAnimating];
    self.refreshLabel.text = self.textPull;
    self.refreshArrow.hidden = NO;
    [self animateArrow:CGAffineTransformIdentity];
    [UIView commitAnimations];
}

- (void) displayLoadingText
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    self.contentInset = UIEdgeInsetsMake(REFRESH_HEADER_HEIGHT, 0, 0, 0);
    refreshLabel.text = self.textLoading;
    refreshArrow.hidden = YES;
    [refreshSpinner startAnimating];
    [UIView commitAnimations];
}

- (void) animateArrow:(CGAffineTransform)transform
{
    [UIView animateWithDuration:0.2f 
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseIn|UIViewAnimationOptionBeginFromCurrentState 
                     animations:^{
                         self.refreshArrow.transform = transform; 
                     } 
                     completion:^(BOOL finished) {
                     }];
}

- (void)refresh {
    [self.pullToRefreshDelegate didPullToRefreshForScrollView:self];
}


@end