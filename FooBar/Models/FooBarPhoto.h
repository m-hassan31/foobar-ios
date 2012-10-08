#import <Foundation/Foundation.h>

@interface FooBarPhoto : NSObject

@property(nonatomic, retain) NSString* photoId;
@property(nonatomic, retain) NSString* url;
@property(nonatomic, retain) NSString* filename;

@property(nonatomic, assign) NSUInteger width;
@property(nonatomic, assign) NSUInteger height;

@end