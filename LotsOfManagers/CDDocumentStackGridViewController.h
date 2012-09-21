//
//  CDFirstViewController.h
//  AQGridViewTests
//
//  Created by Daniel Schneller on 09.07.12.
//  Copyright (c) 2012 codecentric AG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AQGridView.h"
#import "CDDocumentStackModel.h"

@interface CDDocumentStackGridViewController : UIViewController <AQGridViewDelegate, AQGridViewDataSource>
{
    CGSize _gridCellSize;
    NSOperationQueue* _dataRetrievalQueue;
    BOOL _dataRetrievalPaused;
}

extern NSInteger const kCellContentViewTag;

@property (strong, nonatomic) IBOutlet AQGridView *gridView;


/*
 * Override this method and return the model object for
 * the index passed. 
 */
- (CDDocumentStackModel*) docStackModelAtIndex:(NSUInteger)index;

/*
 * Return the total number of items in the grid view.
 * This is part of the Grid View Data Source Protocol
 */
-(NSUInteger) numberOfItemsInGridView:(AQGridView *)gridView;

@end
