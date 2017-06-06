//
//  ViewController.m

#import "BonusDoubleViewController.h"

@implementation BonusDoubleViewController

-(void)closeBonus{
    [self dismissViewControllerAnimated:NO completion:nil];
}

-(IBAction)prizeChest:(id)sender{
    if (userPicked) return;
    userPicked = YES;
    
    UIButton *btn = (UIButton*)sender;
    //[self checkIfWonPrize:[NSString stringWithFormat:@"%i",btn.tag]];
    
    NSInteger hitvalue = btn.tag;
    NSInteger xBy;
    
    int currentWon = [[CommonUtilities decryptString:@"won"] intValue];
    int currentBet = [[CommonUtilities decryptString:@"bet"] intValue];
    
    if (currentWon > currentBet) {
        if(hitvalue == 1){
            [prizeChest1 setBackgroundImage:[UIImage imageForDeviceForName:@"design_xnowin@2x.png"] forState:UIControlStateNormal];
            //xBy = card1;
        }else if(hitvalue == 2){
            [prizeChest2 setBackgroundImage:[UIImage imageForDeviceForName:@"design_xnowin@2x.png"] forState:UIControlStateNormal];
            //xBy = card2;
        }else{
            [prizeChest3 setBackgroundImage:[UIImage imageForDeviceForName:@"design_xnowin@2x.png"] forState:UIControlStateNormal];
            //xBy = card3;
        }
        
        lblAlert1.text = @"Hit a Skull! No Win";
        prizeChest1.userInteractionEnabled = NO;
        prizeChest2.userInteractionEnabled = NO;
        prizeChest3.userInteractionEnabled = NO;
    }else{
        if(hitvalue == 1){
            prizeChest1.alpha = 1.0;
            prizeChest2.alpha = 0.3;
            prizeChest3.alpha = 0.3;
            [prizeChest1 setBackgroundImage:[UIImage imageForDeviceForName:[NSString stringWithFormat:@"design_x%i@2x.png", card1]] forState:UIControlStateNormal];
            xBy = card1;
        }else if(hitvalue == 2){
            prizeChest1.alpha = 0.3;
            prizeChest2.alpha = 1.0;
            prizeChest3.alpha = 0.3;
            [prizeChest2 setBackgroundImage:[UIImage imageForDeviceForName:[NSString stringWithFormat:@"design_x%i@2x.png", card2]] forState:UIControlStateNormal];
            xBy = card2;
        }else{
            prizeChest1.alpha = 0.3;
            prizeChest2.alpha = 0.3;
            prizeChest3.alpha = 1.0;
            [prizeChest3 setBackgroundImage:[UIImage imageForDeviceForName:[NSString stringWithFormat:@"design_x%i@2x.png", card3]] forState:UIControlStateNormal];
            xBy = card3;
        }
        
        long total = [[CommonUtilities decryptString:@"lastWin"] intValue] * xBy;
        
        lblAlert1.text = [NSString stringWithFormat:@"%i x %li = Win %li", [[CommonUtilities decryptString:@"lastWin"] intValue], (long)xBy, total];
        
        [self manageWin:total];
    }

    
    
    [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(closeBonus) userInfo:nil repeats:NO];
    //addWinStatus = @"YES";
}

- (void)viewDidLoad{
    userPicked = NO;
    [super viewDidLoad];
    int randomWin = arc4random() % 3;
    
    if(randomWin == 0){
        card1 = 2;
        
        int randomWin2 = arc4random() % 2;
        if(randomWin2 == 0){
            card2 = 5;
            card3 = 10;
    
        }else{
            card2 = 10;
            card3 = 5;
        }
        
    }else if(randomWin == 1){
        card1 = 5;
        
        int randomWin2 = arc4random() % 2;
        if(randomWin2 == 0){
            card2 = 10;
            card3 = 2;
        }else{
            card2 = 2;
            card3 = 10;
        }
    }else{
        card1 = 10;
        
        int randomWin2 = arc4random() % 2;
        if(randomWin2 == 0){
            card2 = 2;
            card3 = 5;
        }else{
            card2 = 5;
            card3 = 2;
        }
    }
    
    lblAlert1.text = @"Tap a card to multiple win";
    prizeChest1.userInteractionEnabled = YES;
    prizeChest2.userInteractionEnabled = YES;
    prizeChest3.userInteractionEnabled = YES;
}

@end
