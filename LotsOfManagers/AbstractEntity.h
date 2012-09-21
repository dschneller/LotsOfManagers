//
//  AbstractEntity.h
//  CenterDevice
//
//  Created by Marko Cicak on 8/10/12.
//
//

#import <Foundation/Foundation.h>

@interface AbstractEntity : NSObject
{
    NSString* _name;
}

@property (nonatomic, strong) NSString* name;

@end
