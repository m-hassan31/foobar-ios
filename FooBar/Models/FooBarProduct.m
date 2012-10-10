#import "FooBarProduct.h"

@implementation FooBarProduct

@synthesize productId, name, description;

-(void)dealloc
{
    [productId release];
    [name release];
    [description release];
    
    [super dealloc];
}

@end
