//
//  CDFirstViewController.m
//  AQGridViewTests
//
//  Created by Daniel Schneller on 09.07.12.
//  Copyright (c) 2012 codecentric AG. All rights reserved.
//

#import "CDDocumentStackGridViewController.h"
#import "CDDocumentStackCell.h"
#import "CDDocumentStackModel.h"

typedef void(^UpdateCellUIBlock)(CDDocumentStackModel* model);

#pragma mark -

@implementation CDDocumentStackGridViewController

#pragma Constants
const CGFloat kCellWidth = 160.0f;
const CGFloat kCellHeight = 175.0f;
const CGFloat kCellPadX = 15.0f;
const CGFloat kCellPadY = 15.0f;

/* Threshold to distinguish "fast" from "slow" scrolling. In pixels per second. */
static const CGFloat kScrollSpeedThreshold = 4.0f;

/* Tag used to determine the cell content view in the XIB */
const NSInteger kCellContentViewTag = 1;

#pragma Properties

@synthesize gridView = _gridView;

#pragma mark -
#pragma Abstract Methods - override in subclass

/*
 * This default implementation raises an Exception.
 */
- (CDDocumentStackModel *) docStackModelAtIndex:(NSUInteger)index
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass",
                                           NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}


/*
 * This default implementation raises an Exception.
 */
- (NSUInteger) numberOfItemsInGridView:(AQGridView *)gridView
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass",
                                           NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}



#pragma mark -
#pragma mark Utility Methods

- (UIImage*) documentStackFrameImage:(NSUInteger)numberOfDocs
{
    NSString* frameImageName;
    if (numberOfDocs < 2) { frameImageName = @"stapel-1"; }
    else if (numberOfDocs < 5) { frameImageName = @"stapel-2"; }
    else if (numberOfDocs < 10) { frameImageName = @"stapel-3"; }
    else { frameImageName = @"stapel-4"; }
    return  [UIImage imageNamed:frameImageName];
}



#pragma mark -
#pragma mark View Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    _gridView = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}


#pragma mark -
#pragma mark Grid View Data Source - Base Implementations 

- (CGSize)portraitGridCellSizeForGridView:(AQGridView *)gridView
{
    return CGSizeMake(kCellPadX + kCellWidth + kCellPadX, kCellPadY + kCellHeight + kCellPadY);
}

#pragma mark Scroll Handling


- (void) updateScrollToRefreshIndicator:(CDPullToRefreshScrollView*)scrollView
{
    if (!scrollView.isLoading)
    {
        if (scrollView.contentOffset.y <= -REFRESH_HEADER_HEIGHT) {
            [scrollView displayReleaseText];
        } else if (self.gridView.isDragging) {
            [scrollView displayPullText];
        }
    }
}


- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([[scrollView class] isSubclassOfClass:[CDPullToRefreshScrollView class]])
    {
        [self updateScrollToRefreshIndicator:(CDPullToRefreshScrollView*)scrollView];
    }
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.gridView.isDragging = YES;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    self.gridView.isDragging = NO;
    if (self.gridView.contentOffset.y <= -REFRESH_HEADER_HEIGHT) {
        [self.gridView startLoading];
    }
}


@end
