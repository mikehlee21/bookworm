//
//  BaseViewController.h

#import <UIKit/UIKit.h>
#import "Reachability.h"
#import "AppDelegate.h"
#import "CommonUtilities.h"
#import <GameKit/GameKit.h>
#import "NSData+AES.h"
#import "NSData+Base64.h"
#import "NSString+Base64.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioServices.h>
#import "UIImage+CustomNamingForDevice.h"

#import "Configure.h"

@interface BaseViewController : UIViewController<NSURLConnectionDelegate>
{
    IBOutlet UIWebView *webView, *jackpotView;
    
    NSArray *tableData;

    IBOutlet UITableView *usersTable;
    
    NSMutableArray *users;
    //NSMutableDictionary *item;
    IBOutlet UIView *viewLogin, *viewRegister, *viewConnect, *viewSearching, *viewPlay, *viewLoading, *viewWinner, *bettingArea,  *displayUser, *alertView, *noCoinsView;
    IBOutlet UIButton *changebet100, *changebet500, *changebet1000;
    
    IBOutlet UIButton *soundswitch;

    NSTimer *countdown;
    NSUInteger remainingSeconds;

    IBOutlet UIView* viewNoInternet;
    
    
    IBOutlet UILabel *cost1000, *cost3200, *cost8000, *cost20000, *cost80000, *cost200000, *loadingtext;
    
    NSString* currentLeaderBoard;

    NSMutableDictionary *item;
    
    IBOutlet AppDelegate *appDelegate;
    
    IBOutlet UINavigationBar *bar;

    NSMutableData* responseData;
    NSURLConnection *connection;
    
    Reachability* internetReachable;
    Reachability* hostReachable;
}

- (IBAction)tryConnect:(id)sender;
- (void) checkNetworkStatus:(NSNotification *)notice;
- (IBAction)sound:(id)sender;
- (void)presetSoundButtons;

@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (readwrite, copy, nonatomic) NSArray *tableData;
@property (nonatomic, assign) int64_t currentScore;
@property (nonatomic, retain) NSString* currentLeaderBoard;
@property (nonatomic, retain) UILabel *currentScoreLabel;


+ (void)showCoinsView:(id)sender inController:(UIViewController*)controller;
+(void)playSoundEffect:(NSString*)soundEfectId;
@end

// sounds
#define kSoundFinishedSpin @"finishedspin.caf"
#define kSoundWon @"won.caf"
#define kSoundCoinDrop @"coindrop.caf"
#define kSoundChestOpen @"chestopen.caf"
#define kSoundNudge @"nudge.caf"
