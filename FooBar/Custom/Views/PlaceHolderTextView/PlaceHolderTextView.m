#import "PlaceHolderTextView.h"
#import <QuartzCore/QuartzCore.h>

@implementation PlaceHolderTextView

@synthesize placeHolderLabel;
@synthesize placeholder;
@synthesize placeholderColor;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [placeHolderLabel release]; placeHolderLabel = nil;
    [placeholderColor release]; placeholderColor = nil;
    [placeholder release]; placeholder = nil;
    [super dealloc];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
	[self.layer setCornerRadius:6.0];
    [self setPlaceholder:@""];
    [self setPlaceholderColor:[UIColor lightGrayColor]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
}

- (id)initWithFrame:(CGRect)frame
{
    if( (self = [super initWithFrame:frame]) )
    {
		[self.layer setCornerRadius:6.0];
        [self setPlaceholder:@""];
		[self setPlaceholderColor:[UIColor lightGrayColor]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
    }
    return self;
}

- (void)textChanged:(NSNotification *)notification
{
    if([[self placeholder] length] == 0)
    {
        return;
    }
	
    if([[self text] length] == 0)
    {
        [[self viewWithTag:999] setAlpha:1];
    }
    else
    {
        [[self viewWithTag:999] setAlpha:0];
    }
}

- (void)drawRect:(CGRect)rect
{
	[super drawRect:rect];
    if( [[self placeholder] length] > 0 )
    {
        if ( placeHolderLabel == nil )
        {
            placeHolderLabel = [[UILabel alloc] initWithFrame:CGRectMake(8,8,self.bounds.size.width - 16,10)];
			placeHolderLabel.lineBreakMode = UILineBreakModeWordWrap;
            placeHolderLabel.numberOfLines = 0;
			placeHolderLabel.font = self.font;
            placeHolderLabel.backgroundColor = [UIColor clearColor];
            placeHolderLabel.textColor = self.placeholderColor;
            placeHolderLabel.alpha = 0;
            placeHolderLabel.tag = 999;
            [self addSubview:placeHolderLabel];
        }
		
        placeHolderLabel.text = self.placeholder;
        [placeHolderLabel sizeToFit];
        [self sendSubviewToBack:placeHolderLabel];
    }
	
    if( [[self text] length] == 0 && [[self placeholder] length] > 0 )
    {
        [[self viewWithTag:999] setAlpha:1];
    }

	/*UIGraphicsBeginImageContext(self.frame.size);
	
	CGContextRef currentContext = UIGraphicsGetCurrentContext();
	CGContextSetLineWidth(currentContext, 1.0); //or whatever width you want
	CGContextSetRGBStrokeColor(currentContext, 224/255, 224/255, 224/255, 1.0);
	
	CGRect myRect = CGContextGetClipBoundingBox(currentContext);  
	
	float myShadowColorValues[] = {0,0,0,1};
	CGColorSpaceRef myColorSpace = CGColorSpaceCreateDeviceRGB();
	CGColorRef colorRef = CGColorCreate(myColorSpace, myShadowColorValues);
	CGContextSetShadowWithColor(currentContext, CGSizeMake(0, -1), 3, colorRef);
	
	CGContextStrokeRect(currentContext, myRect);
	UIImage *backgroundImage = (UIImage *)UIGraphicsGetImageFromCurrentImageContext();
	UIImageView *myImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
	[myImageView setImage:backgroundImage];
	[self addSubview:myImageView];
	[backgroundImage release];  
	
	UIGraphicsEndImageContext();*/
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
	BOOL retValue = NO;
	
	if (action == @selector(paste:) 
		|| action == @selector(cut:) 
		|| action == @selector(copy:) 
		|| action == @selector(select:) 
		|| action == @selector(selectAll:) )
	{
		retValue = NO;
	}
	else
	{
		retValue = [super canPerformAction:action withSender:sender];
	}
	
	return retValue;
}

@end