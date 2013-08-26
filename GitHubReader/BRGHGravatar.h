//
//  BRGHGravatar.h
//  GitHubReader
//
//  Created by Daniel Norton on 8/26/13.
//  Copyright (c) 2013 Daniel Norton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BRGHLogin;

@interface BRGHGravatar : NSManagedObject

@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSString * lastModified;
@property (nonatomic, retain) BRGHLogin *thumbnailLogin;

@end
