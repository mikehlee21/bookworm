//
//  ViewController.h

#import <UIKit/UIKit.h>
#import "NSData+AES.h"
#import "NSData+Base64.h"
#import "NSString+Base64.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioServices.h>
#import "AppDelegate.h"
#import "ViewController.h"

@class AppDelegate;

    @interface BonusViewController : ViewController <NSURLConnectionDelegate>{
    
    IBOutlet UIImageView *spinner;
    
    IBOutlet UIButton *spinWheelButton, *home;
    
     // bonus variables:

    float degreesWheel, wheelSpinTo;
    int location, amountToSpin, spinTimes;
    NSTimer *autoT;
}

- (IBAction)spin:(id)sender;
- (IBAction)home:(id)sender;
- (IBAction)coinsView:(id)sender;
- (void)manageWin:(long)winAmount;

@end
