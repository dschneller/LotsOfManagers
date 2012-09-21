//
//  CDDocumentsTableViewController.m
//  LotsOfManagers
//
//  Created by Daniel Schneller on 18.09.12.
//  Copyright (c) 2012 codecentric AG. All rights reserved.
//

#import "CDDocumentsTableViewController.h"
#import "CDDocument.h"

#define WINDOW_TRASHOLD     50
#define REFRESH_TRASHOLD    15

@interface CDDocumentsTableViewController ()
@property (nonatomic, readonly, getter = isScrollingFast) BOOL scrollingFast;
@end

@implementation CDDocumentsTableViewController
{
    NSMutableArray* _displayedItems;
    NSUInteger _totalCount;
    NSRange _cachedRange;
    NSMutableArray* _selectedRows;
    
    // used to determine scrolling speed
    NSTimeInterval _lastOffsetCapture;
    CGPoint _lastOffset;
}

/* Threshold to distinguish "fast" from "slow" scrolling. In pixels per second. */
CGFloat const kScrollSpeedThreshold = 4.0f;


- (void)viewDidLoad
{
    _totalCount = 0;
    _cachedRange = NSMakeRange(0, 3*WINDOW_TRASHOLD);
    _selectedRows = [NSMutableArray array];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(handleDocumentsReceivedNotification:)
     name:DOCUMENTS_RETRIEVED_NOTIFICATION
     object:nil];

    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(handleElementCountReceivedNotification:)
     name:ELEMENT_COUNT_RETRIEVED_NOTIFICATION
     object:nil];

    
    if (_displayedItems == nil)
    {
		//[[CDDataManager instance] retrieveElementCountForTaskId:@"count.all"];
		[[CDDataManager instance] retrieveElementCount];
        //[[CDDataManager instance] retrieveDocumentsInRange:_cachedRange forTaskId:@"docs.all_0"];
		[[CDDataManager instance] retrieveDocumentsInRange:_cachedRange];
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
	NSLog(@"task count returns results : %@", notification.object);
    NSNumber* elementCount = notification.object;
    
    _totalCount = [elementCount unsignedIntegerValue];
    _displayedItems = nil;
    [self.tableView reloadData];
}

- (void) handleDocumentsReceivedNotification:(NSNotification*)notification
{
	NSLog(@"task documents returns results : %@", [notification.object description]);
	NSMutableDictionary *result = notification.object;
	NSArray *documents = [result valueForKey:@"documents"];
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
    _cachedRange = NSMakeRange(loc, 3*WINDOW_TRASHOLD);
    _displayedItems = newDisplayedItems;
    NSLog(@"New documents arrived");
    [self.tableView reloadData];
}


#pragma mark - Scroll Delegate

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self controlBackgroundTasksByScrollingSpeed:scrollView];
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

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self.tableView reloadRowsAtIndexPaths:[self.tableView indexPathsForVisibleRows]
                          withRowAnimation:UITableViewRowAnimationNone];
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
        @try {
            viewModel = [_displayedItems objectAtIndex:indexPath.row-_cachedRange.location];
        }
        @catch (NSException *exception) {
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

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([_selectedRows containsObject:[NSNumber numberWithInteger:indexPath.row]]) {
        cell.selected = YES;
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }else{
        cell.selected = NO;
    }
    
    if(self.isScrollingFast)return;
    
    int row = indexPath.row;    
    if(row % REFRESH_TRASHOLD != 0)return;
    
    int location = (row-WINDOW_TRASHOLD)/WINDOW_TRASHOLD*WINDOW_TRASHOLD;
    if(location < 0) {
        location = 0;
    }
    
    if(location == _cachedRange.location)return;
    
    NSRange range = NSMakeRange(location, 3*WINDOW_TRASHOLD);
    
    // order data manager to fetch documents in given range
//    [[CDDataManager instance] retrieveDocumentsInRange:range
//                                             forTaskId:[NSString stringWithFormat:@"docs.all_%d", range.location]];
	[[CDDataManager instance] retrieveDocumentsInRange:range];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSNumber* row = [NSNumber numberWithInteger:indexPath.row];
    [_selectedRows addObject:row];
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_selectedRows removeObject:[NSNumber numberWithInteger:indexPath.row]];
}


@end
