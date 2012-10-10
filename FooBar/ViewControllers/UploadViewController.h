#import <UIKit/UIKit.h>
#import "ConnectionManager.h"

@interface UploadViewController : UIViewController
<UITextViewDelegate, UIPickerViewDelegate, ConnectionManagerDelegate>
{
    ConnectionManager *manager;
}

@property (retain, nonatomic) IBOutlet UITableView *uploadTableView;
@property (retain, nonatomic) IBOutlet UIPickerView *foobarProductPicker;
@property (retain, nonatomic) NSMutableArray *foobarProductsArray;
@property (retain, nonatomic) UIImage *image;
@end
