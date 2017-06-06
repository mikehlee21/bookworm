//
//  AppDelegate.h

#import <UIKit/UIKit.h>
#import <RevMobAds/RevMobAds.h>
#import <RevMobAds/RevMobAdsDelegate.h>
#import "Chartboost/Chartboost.h"
#import "CommonUtilities.h"

@class ViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate, RevMobAdsDelegate>
@property (assign, nonatomic) CGSize initialWindowFrame;
@property (assign, nonatomic) CGSize initialWindowBounds;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ViewController *viewController;


-(void)closeBackground;

@end
