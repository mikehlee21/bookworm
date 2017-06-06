//
//  Configure.h

// -----------------------------------
// GAME SETTINGS
// -----------------------------------
#define INITIAL_STARTUP_COINS @"3000"
#define INITIAL_STARTUP_BET @"200"
#define INITIAL_LINES_COUNT @"20"
#define LABEL_WELCOME @"Welcome to Vegas Slots Bookworm!"
#define LABEL_TAPPLAY @"Tap Spin to Play"

#define DELAY_FOR_AUTO_SPIN 5

#define DONT_SHOW_APPLOVIN_ON_EACH_SCREEN

//#define kGameCenterLeaderboardID @"score"

// -----------------------------------
// IN APP PURCHASES
// these must match the product identifiers that you've set up in iTunesConnect
// -----------------------------------
#define IAP1 @"vegas.1500"
#define IAP2 @"vegas.4200"
#define IAP3 @"vegas.10000"
#define IAP4 @"vegas.30000"
#define IAP5 @"vegas.110000"
#define IAP6 @"vegas.300000"
// -----------------------------------
// the amounts of coins you buy in each in app purchase
// -----------------------------------
#define IAP_AMT_1 1500
#define IAP_AMT_2 4200
#define IAP_AMT_3 10000
#define IAP_AMT_4 30000
#define IAP_AMT_5 110000
#define IAP_AMT_6 300000


// -----------------------------------
// ADVERTISING SETTINGS:
// -----------------------------------

// chartboost
#define CHARTBOOST_APP_KEY  @"5898f623f6cd45740d4a8e98"
#define CHARTBOOST_APP_SECRET @"e99ce4398bca182890d829bbf2c5601b75e8afeb"
// revmob
#define REVMOB_APP_ID @"5898fce5f5fe51ec61e4c993"

// if this one is 1, then we'll show the AppLovin interstitial on the lobby every single time we get to the lobby; otherwise, we show it once every N times
#define ADS_INTERSTITIAL_ON_LOBBY_FREQUENCY 3

// if you comment out this line there will be no showing of ads on app resume
#define ADS_RESUME_FREQUENCY 3
/*
 for revmob interstitials instead of Chartboost, in method - (void)applicationWillEnterForeground:(UIApplication *)application of AppDelegate.m,
 instead of the line that says
 [[Chartboost sharedChartboost] showInterstitial];
 write a line that says
 [[RevMobAds session] showFullscreen];
 */

// if you comment out this line there will be no showing of ads on spin during the game
#define ADS_SPIN_FREQUENCY 3
/*
 for revmob interstitials instead of Chartboost, in method  - (void)spin of GameClassic20.m,
 instead of the line that says
 [[Chartboost sharedChartboost] showInterstitial];
 write a line that says
 [[RevMobAds session] showFullscreen];
 */
