//
//  CDDocumentsTableViewController.m
//  LotsOfManagers
//
//  Created by Daniel Schneller on 18.09.12.
//  Copyright (c) 2012 codecentric AG. All rights reserved.
//

#import "CDDocumentsTableViewController.h"
#import "CDDocument.h"
#import "CDPreview.h"

#define FETCH_BLOCK_SIZE 25
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
    NSMutableArray* _selectedRows;
    
    CDTask* _countTask;
    CDTask* _metadataTask;
	NSMutableSet* _previewTasks;
    
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
	_previewTasks = [NSMutableSet set];
    _scrollingInProgress = NO;
    _totalCount = 0;
    _currentBlock = 0;
    _cachedRange = NSMakeRange(0, NUM_BLOCKS*FETCH_BLOCK_SIZE);
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

	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(handlePreviewLoaded:)
	 name:DATAMGR_PREVIEW_LOADED_NOTIFICATION
	 object:nil];
	
    
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
	NSMutableDictionary *result = notification.object;
	NSArray *documents = [result valueForKey:@"documents"];
	NSLog(@"task documents %@ returns results", [result valueForKey:@"taskId"]);
	NSNumber *n_loc = [result valueForKey:@"range"];
    NSUInteger loc = [n_loc unsignedIntegerValue];
    
    NSArray* visibleCellIndexPaths = [self.tableView indexPathsForVisibleRows];
	NSUInteger firstVisibleRow = ((NSIndexPath*)visibleCellIndexPaths[0]).row;
	NSInteger itemIndex = firstVisibleRow - ((_currentBlock == 0 ? 0 : _currentBlock-1) * FETCH_BLOCK_SIZE);
	NSUInteger relevantRangeLength = (NUM_BLOCKS * FETCH_BLOCK_SIZE);
	if (itemIndex > relevantRangeLength || itemIndex < 0)
	{
		NSLog(@"Ignoring document received notification, itemIndex %d > %d; firstVisibleRow: %d, current block: %d", itemIndex, relevantRangeLength, firstVisibleRow, _currentBlock);
		// the table has already scrolled past the range of documents that
		// this notification covers. So we need to schedule anything for the
		// UI, another notification should be on the way anyhow.
		return;
	}
	
	
    NSMutableArray* newDisplayedItems = [NSMutableArray arrayWithCapacity:documents.count];
	for (NSUInteger i=0; i<documents.count; i++)
	{
		[newDisplayedItems addObject:[NSNull null]];
	}

	for (NSIndexPath *path in visibleCellIndexPaths)
	{
		NSUInteger itemIndex = path.row-loc;
		CDDocumentViewModel *viewModel = [self createDocumentViewModelForIndex:itemIndex withDocument:documents[itemIndex]];
		newDisplayedItems[itemIndex] = viewModel;
	}
	
    for (NSUInteger itemIndex=0; itemIndex<documents.count; itemIndex++)
    {
		if (newDisplayedItems[itemIndex] == [NSNull null])
		{
			CDDocumentViewModel *viewModel = [self createDocumentViewModelForIndex:itemIndex withDocument:documents[itemIndex]];
			newDisplayedItems[itemIndex] = viewModel;
		}
    }
    _cachedRange = NSMakeRange(loc, NUM_BLOCKS*FETCH_BLOCK_SIZE);
    _displayedItems = newDisplayedItems;
    [self refreshVisibleItems:self.tableView];
}

- (CDDocumentViewModel *)createDocumentViewModelForIndex:(NSUInteger)itemIndex withDocument:(CDDocument *)doc
{
    CDDocumentViewModel* viewModel = [[CDDocumentViewModel alloc] init];
    viewModel.documentId = doc.documentId;
    viewModel.documentFileName = doc.filename;
#warning provide correct preview resolution for device
    NSString* res = @"240x240";
    CDPreview* preview = [CDPreview previewForDocument:doc page:1 resolution:res allowPlaceholder:YES];
    if (preview.isPlaceholder)
    {
        [_previewTasks addObject:[[CDDataManager instance] retrievePreviewForDocument:doc page:1 resolution:res version:doc.version]];
    }else {
        viewModel.smallThumbImage = preview.image;
    }
    return viewModel;
}


- (void) handlePreviewLoaded:(NSNotification*)notification
{
	UIImage* image = notification.object;
	NSDictionary* userInfo = notification.userInfo;
	
	NSString* previewAvailability = userInfo[@"preview-availability"];
	if ([@"available" isEqualToString:previewAvailability])
	{
		for (CDDocumentViewModel* viewModel in _displayedItems)
		{
			if ([viewModel.documentId isEqualToString:userInfo[@"documentId"]])
			{
				viewModel.smallThumbImage = image;
			}
		}
		[self refreshVisibleItems:self.tableView];
	}
	else
	{
		NSLog(@"Preview availability: %@", previewAvailability);
	}
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
        NSIndexPath* middle = indexPaths[indexPaths.count / 2];
        
        NSInteger row = middle.row;
        NSInteger new_block = row / FETCH_BLOCK_SIZE;
        
        if (abs(new_block - _currentBlock) != 0)
        {
            
            _currentBlock = new_block;
            NSInteger new_location = new_block == 0 ? 0 : (new_block-1) * FETCH_BLOCK_SIZE;
            NSRange new_range = NSMakeRange(new_location, NUM_BLOCKS*FETCH_BLOCK_SIZE);
            //NSLog(@"New Block: %d (%d - %d)", new_block, new_location, new_location + NUM_BLOCKS*FETCH_BLOCK_SIZE);
            
            // order data manager to fetch documents in given range
            [[CDDataManager instance] cancelTask:_metadataTask];
			[[CDDataManager instance] cancelTasks:_previewTasks];
			
            _metadataTask = [[CDDataManager instance] retrieveDocumentsInRange:new_range];
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
		cell.imageView.image = [UIImage imageNamed:@"stapel-1-dots"];
		cell.detailTextLabel.text = @"---";
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
            viewModel = _displayedItems[itemIndex];
        }
        
        if (viewModel == nil)
        {
            cell.textLabel.text = [NSString stringWithFormat:@"%d ...", indexPath.row];
			cell.imageView.image = [UIImage imageNamed:@"stapel-1-dots"];
			cell.detailTextLabel.text = @"...";
		}
        else
        {
            cell.textLabel.text = [NSString stringWithFormat:@"%d File: %@",indexPath.row, viewModel.documentFileName];
			cell.imageView.image = viewModel.smallThumbImage;
			cell.detailTextLabel.text = viewModel.documentId;
        }
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([_selectedRows containsObject:@(indexPath.row)]) {
        cell.selected = YES;
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }else{
        cell.selected = NO;
    }
    
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSNumber* row = @(indexPath.row);
    [_selectedRows addObject:row];
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_selectedRows removeObject:@(indexPath.row)];
}


@end
