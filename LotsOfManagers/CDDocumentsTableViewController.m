//
//  CDDocumentsTableViewController.m
//  LotsOfManagers
//
//  Created by Daniel Schneller on 18.09.12.
//  Copyright (c) 2012 codecentric AG. All rights reserved.
//

#import "CDDocumentsTableViewController.h"
#import "CDDocument.h"

#define FETCH_BLOCK_SIZE 50
#define NUM_BLOCKS 3

@interface CDDocumentsTableViewController ()

@property (nonatomic, readonly, getter = isScrollingFast) BOOL scrollingFast;

@end

@implementation CDDocumentsTableViewController
{
    NSMutableArray* _displayedItems;
    NSUInteger _totalCount;
    NSRange _cachedRange;
    
    NSInteger _currentBlock;
    
    // used to determine scrolling speed
    NSTimeInterval _lastOffsetCapture;
    CGPoint _lastOffset;
    BOOL _scrollingInProgress;
}

/* Threshold to distinguish "fast" from "slow" scrolling. In pixels per second. */
static CGFloat const kScrollSpeedThreshold = 4.0f;


- (void)viewDidLoad
{
    [super viewDidLoad];
    _scrollingInProgress = NO;
    _totalCount = 0;
    _currentBlock = 0;
    _cachedRange = NSMakeRange(0, NUM_BLOCKS*FETCH_BLOCK_SIZE);
}

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(handleDocumentsReceivedNotification:) name:DOCUMENTS_RETRIEVED_NOTIFICATION object:nil];

    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(handleElementCountReceivedNotification:) name:ELEMENT_COUNT_RETRIEVED_NOTIFICATION object:nil];

    
    if (_displayedItems == nil)
    {
        [[CDDataManager instance] retrieveElementCountForTaskId:@"count.all"];
        [[CDDataManager instance] retrieveDocumentsInRange:_cachedRange forTaskId:@"docs.all_0"];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}


#pragma mark - Handle Notifications
- (void) handleElementCountReceivedNotification:(NSNotification*)notification
{
    NSNumber* elementCount = notification.object;
    NSDictionary* userInfo = notification.userInfo;
    
    _totalCount = [elementCount unsignedIntegerValue];
    _displayedItems = nil;
    [self.tableView reloadData];
}

- (void) handleDocumentsReceivedNotification:(NSNotification*)notification
{
    NSArray* documents = notification.object;
    NSDictionary* userInfo = notification.userInfo;
    NSNumber *n_loc = [userInfo valueForKey:@"range"];
    NSUInteger loc = [n_loc unsignedIntegerValue];
    
    NSMutableArray* newDisplayedItems = [NSMutableArray arrayWithCapacity:documents.count];
    
    for (CDDocument* doc in documents)
    {
        CDDocumentViewModel* viewModel = [[CDDocumentViewModel alloc] init];
        viewModel.documentFileName = doc.filename;
        viewModel.smallThumbImage = [UIImage imageNamed:@"first"];
    
        [newDisplayedItems addObject:viewModel];
    }
    _cachedRange = NSMakeRange(loc, NUM_BLOCKS*FETCH_BLOCK_SIZE);
    _displayedItems = newDisplayedItems;
    //NSLog(@"New documents arrived for range %d-%d", _cachedRange.location, _cachedRange.location + _cachedRange.length);

    [self refreshVisibleItems:self.tableView];
}


#pragma mark - Scroll Delegate

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self controlBackgroundTasksByScrollingSpeed:scrollView];
    [self retrieveCurrentWindow];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (_scrollingInProgress)
    {
        [self refreshVisibleItems:scrollView];
    }
    _scrollingInProgress = YES;
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSLog(@"Did End Decvelertio");
    _scrollingInProgress = NO;
    [self refreshVisibleItems:scrollView];
}

- (void) controlBackgroundTasksByScrollingSpeed:(UIScrollView *)scrollView
{
    CGPoint currentOffset = scrollView.contentOffset;
    NSTimeInterval currentTime = [NSDate timeIntervalSinceReferenceDate];
    
    NSTimeInterval timeDiff = currentTime - _lastOffsetCapture;
    if(timeDiff > 0.1) {
        CGFloat distance = currentOffset.y - _lastOffset.y;
        //The multiply by 10, / 1000 isn't really necessary.......
        CGFloat scrollSpeedNotAbs = (distance * 10) / 1000; //in pixels per millisecond
        
        CGFloat scrollSpeed = fabsf(scrollSpeedNotAbs);
        
        if (scrollSpeed > kScrollSpeedThreshold) {
            _scrollingFast = YES;
        } else {
            _scrollingFast = NO;
        }
        
        _lastOffset = currentOffset;
        _lastOffsetCapture = currentTime;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
//    //NSLog(@"didEndDragging");
    [self refreshVisibleItems:scrollView];
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
//    //NSLog(@"didScrollToTop");
    [self refreshVisibleItems:scrollView];
}

- (void)refreshVisibleItems:(UIScrollView*)scrollView
{
//    //NSLog(@"refreshVisibleItems");
    _scrollingFast = NO;
    [self retrieveCurrentWindow];

    if ([scrollView isKindOfClass:[UITableView class]])
    {
        UITableView* tableView = (UITableView*)scrollView;
        [tableView reloadRowsAtIndexPaths:[tableView indexPathsForVisibleRows]
                          withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void) retrieveCurrentWindow
{
    if (!self.scrollingFast)
    {
        NSArray* indexPaths = [self.tableView indexPathsForVisibleRows];
        if (indexPaths.count == 0)
        {
            return;
        }
        NSIndexPath* middle = [indexPaths objectAtIndex:indexPaths.count / 2];
        
        NSInteger row = middle.row;
        NSInteger new_block = row / FETCH_BLOCK_SIZE;
        
        if (abs(new_block - _currentBlock) != 0)
        {
            
            _currentBlock = new_block;
            NSInteger new_location = new_block == 0 ? 0 : (new_block-1) * FETCH_BLOCK_SIZE;
            NSRange new_range = NSMakeRange(new_location, NUM_BLOCKS*FETCH_BLOCK_SIZE);
            //NSLog(@"New Block: %d (%d - %d)", new_block, new_location, new_location + NUM_BLOCKS*FETCH_BLOCK_SIZE);
            
            // order data manager to fetch documents in given range
            [[CDDataManager instance] cancelTaskIdWithPrefix:@"docs.all_"];
            [[CDDataManager instance] retrieveDocumentsInRange:new_range forTaskId:[NSString stringWithFormat:@"docs.all_%d", new_range.location]];
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _totalCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    CDDocumentViewModel* viewModel;
    if (self.isScrollingFast)
    {
        cell.textLabel.text = [NSString stringWithFormat:@"%d --- ---", indexPath.row];
    }
    else
    {
        NSUInteger itemIndex = indexPath.row-_cachedRange.location;
        if (itemIndex >= _displayedItems.count)
        {
            viewModel = nil;
        }
        else
        {
            viewModel = [_displayedItems objectAtIndex:itemIndex];
        }
        
        if (viewModel == nil)
        {
            cell.textLabel.text = [NSString stringWithFormat:@"%d ...", indexPath.row];
        }
        else
        {
            cell.textLabel.text = [NSString stringWithFormat:@"%d File: %@",indexPath.row, viewModel.documentFileName];
        }
    }
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
       *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
