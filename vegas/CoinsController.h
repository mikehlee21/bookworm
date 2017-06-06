//
//  ViewController.h


#import "BaseViewController.h"
#import <StoreKit/StoreKit.h>
#import "SKProduct+priceAsString.h"

//@interface CoinsController : BaseViewController <SKProductsRequestDelegate, SKPaymentTransactionObserver, GameCenterManagerDelegate>{
    @interface CoinsController : BaseViewController <SKProductsRequestDelegate, SKPaymentTransactionObserver>{

    IBOutlet UIWebView *webProfilePic;
    
    IBOutlet UIBarButtonItem *barCloseBtn;
}

@property (strong, nonatomic) ViewController *viewController;
@property (nonatomic, retain) IBOutlet UIWebView *webView;

- (IBAction)closeCoins:(id)sender;
- (IBAction)purchaseCoins:(id)sender;


@end
