//
//  ViewController.h



#import "ViewController.h"
#import "ALAdDisplayDelegate.h"
#import <RevMobAds/RevMobAds.h>
#import <RevMobAds/RevMobAdsDelegate.h>

 @interface GameClassic20 : ViewController < NSURLConnectionDelegate,ALAdDisplayDelegate, RevMobAdsDelegate>{
    IBOutlet UIImageView *slot1Set1, *slot1Set2, *slot2Set1, *slot2Set2, *slot3Set1, *slot3Set2, *slot4Set1, *slot4Set2, *slot5Set1, *slot5Set2, *winFlash, *iphone5Logo;
    
    IBOutlet UILabel *displayNudge, *displayWon, *displayBet, *displayCoinsBackScreen, *displayNudgeBackScreen, *displayWonBackScreen, *iphone5Text;
    IBOutlet UIButton *nudge1Button, *nudge2Button, *nudge3Button, *nudge4Button, *nudge5Button, *line1, *line2, *line3, *line4, *line5, *line6, *line7, *line8, *line9, *line10, *line11, *line12, *line13, *line14, *line15, *line16, *line17, *line18, *line19, *line20, *btnPayTable, *btnWon, *btnLines, *btnBet, *btnBetMax, *btnSpin, *btnHome;
    
	IBOutlet UILabel *currentScoreLabel, *optionLines, *optionBet, *optionWon, *optionMaxBet, *lblLines, *lblBet, *lblWon, *lblMaxBet, *lblPayTable1, *lblPayTable2, *lblSpin, *lblLevelUp1, *lblLevelUp2, *lblLevelUpLevel, *lblAutoSpin;
    
    IBOutlet UIView *goldenGame, *viewAlert, *viewWelcome, *viewGameOver, *viewBack, *viewPrize, *boot, *viewPayTable, *viewLevelUp, *viewAutoSpinMenu, *viewMoreCoins, *viewSmooth, *viewBigWin;
    
    IBOutlet UIBarButtonItem *highscores;
    
    IBOutlet UIImageView *winBox1,*winBox2,*winBox3,*winBox4,*winBox5,*winBox6,*winBox7,*winBox8,*winBox9,*winBox10,*winBox11,*winBox12,*winBox13,*winBox14,*winBox15;
    
    NSTimer *scheduleBonus, *dropCoinsTimer;
    NSString *autoSpinStatusMenu, *handleDropCoinsStatus;
    
    int autoSpinAmountCounter,startrew;

    IBOutlet UIButton  *btnBuyCoins;
    
    IBOutlet UIButton *line30_1, *line30_2, *line30_3, *line30_4, *line30_5, *line30_6, *line30_7, *line30_8, *line30_9, *line30_10, *line30_11, *line30_12, *line30_13, *line30_14, *line30_15, *line30_16, *line30_17, *line30_18, *line30_19, *line30_20, *line30_21, *line30_22, *line30_23, *line30_24, *line30_25, *line30_26, *line30_27, *line30_28, *line30_29, *line30_30;
    
    IBOutlet UIView *viewBonusWin, *viewMain, *viewAd;
    
    
    IBOutlet UIView *lines_20_left, *lines_20_right, *lines_30_left, *lines_30_right;
    
    IBOutlet UIImageView *imgA, *imgQ, *imgJ, *imgK, *imgLemon, *imgDiamond, *img7, *imgStar, *imgBonus, *imgWild;
    
    NSString  *bonusDoubleStatus;
    
    NSTimer *alertControl;
}

- (IBAction)showPayTable:(id)sender;
- (IBAction)hidePayTable:(id)sender;
- (IBAction)hideLevel:(id)sender;


- (IBAction)hideCoinPopup:(id)sender;

-(IBAction)changeLines:(id)sender;
-(IBAction)changeBet:(id)sender;
-(IBAction)changeAllLines:(id)sender;
-(IBAction)maxBet:(id)sender;

-(IBAction)autoSpin:(id)sender;
-(IBAction)autoSpinByAmount:(id)sender;
- (void)cleanUpOnClose;

- (IBAction)home:(id)sender;



- (IBAction)showFreeCoins1:(id)sender;
- (IBAction)showFreeCoins2:(id)sender;
- (IBAction)showFreeCoins3:(id)sender;


- (IBAction)play:(id)sender;
- (IBAction)playAgain:(id)sender;
- (IBAction)coinsView:(id)sender;
//@property (nonatomic, strong)RevMobFullscreen *rewardedVideo;
@property (nonatomic, strong)RevMobFullscreen *fullscreen, *video, *rewardedVideo ;
@end
