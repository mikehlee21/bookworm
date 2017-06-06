//
//  ViewController.h


#import "BaseViewController.h"


@interface ViewController : BaseViewController{
    IBOutlet UIImageView *showWin, *showLevel;
    IBOutlet UILabel *displayCoins, *lblDisplayName, *lblDisplayLevel, *lblDisplayNameNOT, *lblDisplayLevelNOT;
    IBOutlet UIButton *btnMoveLeft, *btnMoveRight, *game1, *game2, *game3, *game4, *game5, *game6, *game7, *game8, *game9, *game10, *game11, *game12, *btnDownloadNow, *btnDownloadCancel;
    
    AVAudioPlayer *nudgeSound, *finishedSpinSound, *wonSound;
    
	int64_t  currentScore;
	IBOutlet UILabel *optionLvl, *optionXP, *lblAlert1, *lblAlert2, *lblAlert3;
    
    IBOutlet UIView *viewSettings, *viewDownload;
    
    IBOutlet UIImageView *moveCoin1, *moveCoin2, *moveCoin3, *moveCoin4, *moveCoin5, *moveCoin6, *moveCoin7, *moveCoin8, *moveCoin9;
    
    IBOutlet UIScrollView *games;
        
    IBOutlet UISwitch *switchSound, *switchNotif, *switchPublic;
    
    IBOutlet UIButton *downloadNow, *downloadCancel;
    
    NSError* lastError;
    
    int moveRow1Counter, moveRow2Counter, moveRow3Counter, moveRow4Counter, moveRow5Counter;
    int moveRow1Amount, moveRow2Amount, moveRow3Amount, moveRow4Amount, moveRow5Amount;
    int row1Postion, row2Postion, row3Postion, row4Postion, row5Postion;
    int nudgeCounter, currentWinCoins, wonCounter, holdCounter, chestWin, coinsAdd, prizeShuffleCounter, winPostion, lblCounter;
    
    int linesToSpin, showWinItems, showWinItemsCounter, betAmount, totalWinAmount, moveSlides;
    
    NSTimer *row, *nudgeTimer, *wonTimer, *endNudgeTimer, *goldenTimer, *addWin, *showWinLines, *autoSpinTimer;
    NSString *play, *finished1, *finished2, *finished3, *finished4, *finished5, *won, *nudgeStatus, *cheatStatus, *cheatInfo, *nudgeLastTime, *endNudgeStatus, *holdStatus1, *holdStatus2, *holdStatus3, *holdStatus4, *holdStatus5, *holdStatus, *holdPressed1, *holdPressed2, *holdPressed3, *holdPressed4, *holdPressed5, *spinSafe, *chestWinStatus, *winFlashStatus, *addWinStatus, *advertStatus, *showWinStatus, *defaultMessages, *autoSpinStatus;
    NSMutableArray *showWinData;
    
    int moveCoin1By, moveCoin2By, moveCoin3By, moveCoin4By, moveCoin5By, moveCoin6By, moveCoin7By, moveCoin8By, moveCoin9By;

    NSTimer *bgDropCoinsTimer;
}

-(int)giveRandom:(int)by;
 
-(NSString *)randomCoinImg;

- (IBAction)coinsView:(id)sender;
- (IBAction)GameMega20:(id)sender;
- (IBAction)GameMega30:(id)sender;
- (IBAction)GameHorse20:(id)sender;
- (IBAction)GameHorse30:(id)sender;
- (IBAction)GameClassic20:(id)sender;
- (IBAction)GameClassic30:(id)sender;
- (IBAction)GameGem30:(id)sender;
- (IBAction)GameBingo30:(id)sender;

- (IBAction)GameSports30:(id)sender;
- (IBAction)GameSnacks30:(id)sender;
- (IBAction)GameKings30:(id)sender;
- (IBAction)GameZoo30:(id)sender;

- (IBAction)moveLeft:(id)sender;
- (IBAction)moveRight:(id)sender;

- (IBAction)changePublic:(id)sender;
- (IBAction)changeNotif:(id)sender;
- (IBAction)changeSound:(id)sender;

-(void)manageServer:(NSString *)where;
- (NSString*)isLevelUnlocked:(int)level;

-(void)sortLevelBar;
-(NSString*)returnLevel:(int)exp;

// Settings popup
- (IBAction)hideSettings:(id)sender;
- (IBAction)showSettings:(id)sender;

@end
