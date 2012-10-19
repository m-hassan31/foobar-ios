#import <UIKit/UIKit.h>
#import "ConnectionManager.h"
#import "SAProgressHUD.h"

@interface UploadViewController : UIViewController
<UITextViewDelegate, UIPickerViewDelegate, ConnectionManagerDelegate>
{
    SAProgressHUD* hud;
    ConnectionManager *manager;
}

@property (retain, nonatomic) IBOutlet UITableView *uploadTableView;
@property (retain, nonatomic) IBOutlet UIToolbar *productsToolbar;
@property (retain, nonatomic) IBOutlet UIPickerView *foobarProductPicker;
@property (retain, nonatomic) NSMutableArray *foobarProductsArray;
@property (retain, nonatomic) UIImage *image;
@property (retain, nonatomic) NSString *captionText;
@end
