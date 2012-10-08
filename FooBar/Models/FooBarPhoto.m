#import "FooBarPhoto.h"

@implementation FooBarPhoto

@synthesize photoId, url, filename, width, height;

-(void)dealloc
{
    [photoId release];
    [url release];
    [filename release];
    
    [super dealloc];
}

@end
