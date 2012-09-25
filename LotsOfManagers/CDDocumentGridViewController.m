//
//  CDDocumentGridViewController.m
//  LotsOfManagers
//
//  Created by Daniel Schneller on 20.09.12.
//  Copyright (c) 2012 codecentric AG. All rights reserved.
//

#import "CDDocumentGridViewController.h"
#import "CDDataManager.h"
#import "CDDocument.h"
#import "CDDocumentViewModel.h"
#import "CDDocumentStackCell.h"

#define FETCH_BLOCK_SIZE 50
#define NUM_BLOCKS 3


@interface CDDocumentGridViewController ()
@property (nonatomic, readonly, getter = isScrollingFast) BOOL scrollingFast;

@end

@implementation CDDocumentGridViewController
{
    NSMutableArray* _displayedItems;
    NSUInteger _totalCount;
    NSRange _cachedRange;
    
    NSInteger _currentBlock;
    
    CDTask* _countTask;
    CDTask* _metadataTask;

    
    // used to determine scrolling speed
    NSTimeInterval _lastOffsetCapture;
    CGPoint _lastOffset;
    BOOL _scrollingInProgress;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
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
        _countTask = [[CDDataManager instance] retrieveElementCount];
        _metadataTask = [[CDDataManager instance] retrieveDocumentsInRange:_cachedRange];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}




#pragma mark - Handle Notifications
- (void) handleElementCountReceivedNotification:(NSNotification*)notification
{
    NSNumber* elementCount = notification.object;
    NSDictionary* userInfo = notification.userInfo;
    
    _totalCount = [elementCount unsignedIntegerValue];
    _displayedItems = nil;
    [self.gridView reloadData];
}

- (void) handleDocumentsReceivedNotification:(NSNotification*)notification
{
	NSMutableDictionary *result = notification.object;
	NSArray *documents = [result valueForKey:@"documents"];
	NSLog(@"task documents %@ returns results", [result valueForKey:@"taskId"]);
	NSNumber *n_loc = [result valueForKey:@"range"];
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
    
    [self refreshVisibleItems:self.gridView];
}
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
    NSLog(@"Did End Decelerating");
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
        
        if (scrollSpeed > 4.0f) {
            _scrollingFast = YES;
        } else {
            _scrollingFast = NO;
        }
        _scrollingInProgress = YES;
        _lastOffset = currentOffset;
        _lastOffsetCapture = currentTime;
    }
}


- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
    NSLog(@"didScrollToTop");
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
    else if ([scrollView isKindOfClass:[AQGridView class]])
    {
        AQGridView* gridView = (AQGridView*)scrollView;
        [gridView reloadItemsAtIndices:gridView.visibleCellIndices withAnimation:AQGridViewItemAnimationNone];
    }
    
}

- (void) retrieveCurrentWindow
{
    if (!self.scrollingFast)
    {
        NSIndexSet* visible = [self.gridView visibleCellIndices];
        if (visible.count == 0)
        {
            return;
        }

        NSUInteger middle = [visible firstIndex];
    
        NSUInteger row = middle;
        NSInteger new_block = row / FETCH_BLOCK_SIZE;
        
        if (abs(new_block - _currentBlock) != 0)
        {
            
            _currentBlock = new_block;
            NSInteger new_location = new_block == 0 ? 0 : (new_block-1) * FETCH_BLOCK_SIZE;
            NSRange new_range = NSMakeRange(new_location, NUM_BLOCKS*FETCH_BLOCK_SIZE);
            //NSLog(@"New Block: %d (%d - %d)", new_block, new_location, new_location + NUM_BLOCKS*FETCH_BLOCK_SIZE);
            
            // order data manager to fetch documents in given range
            [[CDDataManager instance] cancelTask:_metadataTask];
            _metadataTask = [[CDDataManager instance] retrieveDocumentsInRange:new_range];
        }
    }
}

#pragma mark - Grid Delegate


- (NSUInteger) numberOfItemsInGridView:(AQGridView *)gridView
{
    return _totalCount;
}

- (AQGridViewCell *) dequeueAndConfigureGridCellForGridView:(AQGridView*)gridView
{
    static NSString* docStackCellID = @"CDDocumentStackCell";
    AQGridViewCell* cell = [gridView dequeueReusableCellWithIdentifier:docStackCellID];
    if (!cell)
    {
        UINib* nib = [UINib nibWithNibName:@"CDDocumentStackCell" bundle:[NSBundle mainBundle]];
        NSArray* nibContent = [nib instantiateWithOwner:nil options:nil];
        
        UIView* topViewFromXib = nibContent[0];
        
        cell = [[AQGridViewCell alloc] initWithFrame:topViewFromXib.frame
                                     reuseIdentifier:docStackCellID];
        [cell.contentView addSubview:topViewFromXib];
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.backgroundColor = [UIColor clearColor];
        
    }
    return cell;
}

- (AQGridViewCell *)gridView:(AQGridView *)gridView cellForItemAtIndex:(NSUInteger)index
{
    AQGridViewCell* cell = [self dequeueAndConfigureGridCellForGridView:gridView];
    
    CDDocumentStackCell* docStackCell;
    CDDocumentViewModel* viewModel;
    docStackCell = (CDDocumentStackCell*)[cell.contentView viewWithTag:kCellContentViewTag];

    if (self.isScrollingFast) {
        docStackCell.placeholder = YES;
    }
    else
    {
        NSUInteger itemIndex = index - _cachedRange.location;
        if (itemIndex >= _displayedItems.count)
        {
            viewModel = nil;
        }
        else
        {
            viewModel = _displayedItems[itemIndex];
        }
        
        if (viewModel == nil)
        {
            docStackCell.elementName = [NSString stringWithFormat:@"%d ...", index];
        }
        else
        {
            docStackCell.elementName = [NSString stringWithFormat:@"%d File: %@", index, viewModel.documentFileName];
            docStackCell.image = viewModel.smallThumbImage;
        }
    }
        
    /* returning the cell as it currently is, as a placeholder */
    return cell;
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
