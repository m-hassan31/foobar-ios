#import <UIKit/UIKit.h>

#ifdef __IPHONE_5_0
#import <Twitter/TWTweetComposeViewController.h>
#import <Accounts/Accounts.h>
#import <Twitter/TWRequest.h>
#endif

#import "SAProgressHUD.h"

@protocol TwitterAccountPickerDelegate;

@interface TwitterAccountPickerController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource, SAProgressHUDDelegate>
{
    IBOutlet UIPickerView *twitterAccountPickerView;
    IBOutlet UIToolbar *toolBar;
    
    NSArray* twitterAccountsArray;
    NSUInteger selectedRow;
    
	#ifdef __IPHONE_5_0
    ACAccount* phoneTwitterAccount;
    ACAccountStore *store;
	#endif
    
    id<TwitterAccountPickerDelegate> delegate;
    SAProgressHUD* hud;
}

@property (nonatomic, retain) NSArray *twitterAccountsArray;
@property (nonatomic, retain) IBOutlet UIPickerView *twitterAccountPickerView;
@property (nonatomic, retain) IBOutlet UIToolbar *toolBar;

#ifdef __IPHONE_5_0
@property(nonatomic, retain) ACAccount* phoneTwitterAccount;
#endif

@property (nonatomic, assign) 	id<TwitterAccountPickerDelegate> delegate;

- (void)show;
- (void)hide;
- (void)selectButtonPressed:(id)sender;
- (void)cancelButtonPressed:(id)sender;
- (void)fetchTwitterAccountsAndConfigure;
- (void)showHUDwithText:(NSString *)text;
- (BOOL)hasAccountWithUsername:(NSString*)username;

@end

@protocol TwitterAccountPickerDelegate <NSObject>

- (void) twitterAccountSelected;

@end