//
//  main.m
//  LotsOfManagers
//
//  Created by Daniel Schneller on 18.09.12.
//  Copyright (c) 2012 codecentric AG. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CDAppDelegate.h"

int main(int argc, char *argv[])
{
    @autoreleasepool {
        int retVal = 0;
        
        @try {
            retVal = UIApplicationMain(argc, argv, nil, NSStringFromClass([CDAppDelegate class]));
        }
        @catch (NSException *exception) {
            NSArray *backtrace = [exception callStackSymbols];
            NSString *version = [[UIDevice currentDevice] systemVersion];
            NSString *message = [NSString stringWithFormat:@"OS: %@. Backtrace:\n%@",
                                 version,
                                 backtrace];
            NSLog(@"Exception - %@",[exception description]);
            NSLog(@"%@", message);
            exit(EXIT_FAILURE);
        }
        return retVal;
    }

}
