//
//  DocumentCD.h
//  LotsOfManagers
//
//  Created by Predrag Karic on 9/27/12.
//  Copyright (c) 2012 codecentric AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DocumentCD : NSManagedObject

@property (nonatomic, retain) NSString * filename;
@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSNumber * version;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSString * documentId;
@property (nonatomic, retain) NSString * previewPath;

@end
