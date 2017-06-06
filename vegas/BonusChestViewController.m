//
//  ViewController.m

#import "BonusChestViewController.h"

@implementation BonusChestViewController

-(void)closeBonus{
    [self dismissViewControllerAnimated:NO completion:nil];
}

-(IBAction)prizeChest:(id)sender{
    if (userPicked) return;
    userPicked = YES;

    UIButton *btn = (UIButton*)sender;
    [self checkIfWonPrize:[NSString stringWithFormat:@"%li",(long)btn.tag]];
    
    prizeChest1.userInteractionEnabled = NO;
    prizeChest2.userInteractionEnabled = NO;
    prizeChest3.userInteractionEnabled = NO;
    prizeChest4.userInteractionEnabled = NO;
    prizeChest5.userInteractionEnabled = NO;
    prizeChest6.userInteractionEnabled = NO;
    prizeChest7.userInteractionEnabled = NO;
    prizeChest8.userInteractionEnabled = NO;
    prizeChest9.userInteractionEnabled = NO;
    prizeChest10.userInteractionEnabled = NO;
}

- (void)checkIfWonPrize:(NSString *)chest{
    
    NSString *wonPrize = @"NO";
    int currentChestWin = [chest intValue];
    
    if(currentChestWin == 1){
        if (winPostion == currentChestWin){
            [prizeChest1 setBackgroundImage:[UIImage imageForDeviceForName:@"chest_open_coins.png"] forState:UIControlStateNormal];
            wonPrize = @"YES";
        }else{
            [prizeChest1 setBackgroundImage:[UIImage imageForDeviceForName:@"chest_open.png"] forState:UIControlStateNormal];
        }
    }else if(currentChestWin == 2){
        if (winPostion == currentChestWin){
            [prizeChest2 setBackgroundImage:[UIImage imageForDeviceForName:@"chest_open_coins.png"] forState:UIControlStateNormal];
            wonPrize = @"YES";
        }else{
            [prizeChest2 setBackgroundImage:[UIImage imageForDeviceForName:@"chest_open.png"] forState:UIControlStateNormal];
        }
    }else if(currentChestWin == 3){
        if (winPostion == currentChestWin){
            [prizeChest3 setBackgroundImage:[UIImage imageForDeviceForName:@"chest_open_coins.png"] forState:UIControlStateNormal];
            wonPrize = @"YES";
        }else{
            [prizeChest3 setBackgroundImage:[UIImage imageForDeviceForName:@"chest_open.png"] forState:UIControlStateNormal];
        }
    }else if(currentChestWin == 4){
        if (winPostion == currentChestWin){
            [prizeChest4 setBackgroundImage:[UIImage imageForDeviceForName:@"chest_open_coins.png"] forState:UIControlStateNormal];
            wonPrize = @"YES";
        }else{
            [prizeChest4 setBackgroundImage:[UIImage imageForDeviceForName:@"chest_open.png"] forState:UIControlStateNormal];
        }
    }else if(currentChestWin == 5){
        if (winPostion == currentChestWin){
            [prizeChest5 setBackgroundImage:[UIImage imageForDeviceForName:@"chest_open_coins.png"] forState:UIControlStateNormal];
            wonPrize = @"YES";
        }else{
            [prizeChest5 setBackgroundImage:[UIImage imageForDeviceForName:@"chest_open.png"] forState:UIControlStateNormal];
        }
    }else if(currentChestWin == 6){
        if (winPostion == currentChestWin){
            [prizeChest6 setBackgroundImage:[UIImage imageForDeviceForName:@"chest_open_coins.png"] forState:UIControlStateNormal];
            wonPrize = @"YES";
        }else{
            [prizeChest6 setBackgroundImage:[UIImage imageForDeviceForName:@"chest_open.png"] forState:UIControlStateNormal];
        }
    }else if(currentChestWin == 7){
        if (winPostion == currentChestWin){
            [prizeChest7 setBackgroundImage:[UIImage imageForDeviceForName:@"chest_open_coins.png"] forState:UIControlStateNormal];
            wonPrize = @"YES";
        }else{
            [prizeChest7 setBackgroundImage:[UIImage imageForDeviceForName:@"chest_open.png"] forState:UIControlStateNormal];
        }
    }else if(currentChestWin == 8){
        if (winPostion == currentChestWin){
            [prizeChest8 setBackgroundImage:[UIImage imageForDeviceForName:@"chest_open_coins.png"] forState:UIControlStateNormal];
           wonPrize = @"YES";
        }else{
            [prizeChest8 setBackgroundImage:[UIImage imageForDeviceForName:@"chest_open.png"] forState:UIControlStateNormal];
        }
    }else if(currentChestWin == 9){
        if (winPostion == currentChestWin){
            [prizeChest9 setBackgroundImage:[UIImage imageForDeviceForName:@"chest_open_coins.png"] forState:UIControlStateNormal];
            wonPrize = @"YES";
        }else{
            [prizeChest9 setBackgroundImage:[UIImage imageForDeviceForName:@"chest_open.png"] forState:UIControlStateNormal];
        }
    }else if(currentChestWin == 10){
        if (winPostion == currentChestWin){
            [prizeChest10 setBackgroundImage:[UIImage imageForDeviceForName:@"chest_open_coins.png"] forState:UIControlStateNormal];
            wonPrize = @"YES";
        }else{
            [prizeChest10 setBackgroundImage:[UIImage imageForDeviceForName:@"chest_open.png"] forState:UIControlStateNormal];
        }
    }
    
    if([wonPrize isEqual:@"YES"]){
        int randomWin = arc4random() % 10;
        
        if(randomWin == 0){
            randomWin = 100;
        }else{
            randomWin = randomWin * 10;
        }
        
        if([[CommonUtilities decryptString:@"coins"] intValue] < 100){
            // x 5 daily bonus for users with less than 100 coins
            randomWin = randomWin * 5;
        }else{
            
        }
        
        int randomWin2 = arc4random() % 5;
        randomWin2 = (randomWin2*5)*10;
        
        randomWin = randomWin + randomWin2;
        
        //currentWinCoins = currentWinCoins + randomWin;
        coinsAdd = 0;
        
        lblAlert1.text = [NSString stringWithFormat:@"%i coins won!", randomWin];
        
        [self manageWin:randomWin];
    }else{
        lblAlert1.text = @"That's the wrong box!";
    }
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:2.0];
    //viewPrize.alpha = 0.0;
    //viewBack.alpha = 0.0;
    [UIView commitAnimations];
    
   [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(closeBonus) userInfo:nil repeats:NO];
}

-(void)loadPrize{
    
    [prizeChest1 setBackgroundImage:[UIImage imageForDeviceForName:@"chest.png"] forState:UIControlStateNormal];
    [prizeChest2 setBackgroundImage:[UIImage imageForDeviceForName:@"chest.png"] forState:UIControlStateNormal];
    [prizeChest3 setBackgroundImage:[UIImage imageForDeviceForName:@"chest.png"] forState:UIControlStateNormal];
    [prizeChest4 setBackgroundImage:[UIImage imageForDeviceForName:@"chest.png"] forState:UIControlStateNormal];
    [prizeChest5 setBackgroundImage:[UIImage imageForDeviceForName:@"chest.png"] forState:UIControlStateNormal];
    [prizeChest6 setBackgroundImage:[UIImage imageForDeviceForName:@"chest.png"] forState:UIControlStateNormal];
    [prizeChest7 setBackgroundImage:[UIImage imageForDeviceForName:@"chest.png"] forState:UIControlStateNormal];
    [prizeChest8 setBackgroundImage:[UIImage imageForDeviceForName:@"chest.png"] forState:UIControlStateNormal];
    [prizeChest9 setBackgroundImage:[UIImage imageForDeviceForName:@"chest.png"] forState:UIControlStateNormal];
    [prizeChest10 setBackgroundImage:[UIImage imageForDeviceForName:@"chest.png"] forState:UIControlStateNormal];
    
    prizeChest1.userInteractionEnabled = NO;
    prizeChest2.userInteractionEnabled = NO;
    prizeChest3.userInteractionEnabled = NO;
    prizeChest4.userInteractionEnabled = NO;
    prizeChest5.userInteractionEnabled = NO;
    prizeChest6.userInteractionEnabled = NO;
    prizeChest7.userInteractionEnabled = NO;
    prizeChest8.userInteractionEnabled = NO;
    prizeChest9.userInteractionEnabled = NO;
    prizeChest10.userInteractionEnabled = NO;
    
    if(prizeShuffleCounter == 4){
        
        lblAlert1.text = @"Tap the box with the gold in!";
        
        prizeChest1.userInteractionEnabled = YES;
        prizeChest2.userInteractionEnabled = YES;
        prizeChest3.userInteractionEnabled = YES;
        prizeChest4.userInteractionEnabled = YES;
        prizeChest5.userInteractionEnabled = YES;
        prizeChest6.userInteractionEnabled = YES;
        prizeChest7.userInteractionEnabled = YES;
        prizeChest8.userInteractionEnabled = YES;
        prizeChest9.userInteractionEnabled = YES;
        prizeChest10.userInteractionEnabled = YES;
        
    }else{
        [NSTimer scheduledTimerWithTimeInterval:0.4 target:self selector:@selector(shuffleDailyPrize1) userInfo:nil repeats:NO];
    }
    
}

-(void)shuffleDailyPrize1{
    prizeShuffleCounter = prizeShuffleCounter + 1;
    winPostion = 0;
    // shuffle one
    [prizeChest1 setBackgroundImage:[UIImage imageForDeviceForName:@"chest_open.png"] forState:UIControlStateNormal];
    [prizeChest2 setBackgroundImage:[UIImage imageForDeviceForName:@"chest_open.png"] forState:UIControlStateNormal];
    [prizeChest3 setBackgroundImage:[UIImage imageForDeviceForName:@"chest_open.png"] forState:UIControlStateNormal];
    [prizeChest4 setBackgroundImage:[UIImage imageForDeviceForName:@"chest_open.png"] forState:UIControlStateNormal];
    [prizeChest5 setBackgroundImage:[UIImage imageForDeviceForName:@"chest_open.png"] forState:UIControlStateNormal];
    [prizeChest6 setBackgroundImage:[UIImage imageForDeviceForName:@"chest_open.png"] forState:UIControlStateNormal];
    [prizeChest7 setBackgroundImage:[UIImage imageForDeviceForName:@"chest_open.png"] forState:UIControlStateNormal];
    [prizeChest8 setBackgroundImage:[UIImage imageForDeviceForName:@"chest_open.png"] forState:UIControlStateNormal];
    [prizeChest9 setBackgroundImage:[UIImage imageForDeviceForName:@"chest_open.png"] forState:UIControlStateNormal];
    [prizeChest10 setBackgroundImage:[UIImage imageForDeviceForName:@"chest_open.png"] forState:UIControlStateNormal];
    
    
    int shuffleWin1 = arc4random() % 9;
    
    
    if(shuffleWin1 == 0){
        [prizeChest1 setBackgroundImage:[UIImage imageForDeviceForName:@"chest_open_coins.png"] forState:UIControlStateNormal];
        winPostion = 1;
    }else if(shuffleWin1 == 1){
        [prizeChest2 setBackgroundImage:[UIImage imageForDeviceForName:@"chest_open_coins.png"] forState:UIControlStateNormal];
        winPostion = 2;
    }else if(shuffleWin1 == 2){
        [prizeChest3 setBackgroundImage:[UIImage imageForDeviceForName:@"chest_open_coins.png"] forState:UIControlStateNormal];
        winPostion = 3;
    }else if(shuffleWin1 == 3){
        [prizeChest4 setBackgroundImage:[UIImage imageForDeviceForName:@"chest_open_coins.png"] forState:UIControlStateNormal];
        winPostion = 4;
    }else if(shuffleWin1 == 4){
        [prizeChest5 setBackgroundImage:[UIImage imageForDeviceForName:@"chest_open_coins.png"] forState:UIControlStateNormal];
        winPostion = 5;
    }else if(shuffleWin1 == 5){
        [prizeChest6 setBackgroundImage:[UIImage imageForDeviceForName:@"chest_open_coins.png"] forState:UIControlStateNormal];
        winPostion = 6;
    }else if(shuffleWin1 == 6){
        [prizeChest7 setBackgroundImage:[UIImage imageForDeviceForName:@"chest_open_coins.png"] forState:UIControlStateNormal];
        winPostion = 7;
    }else if(shuffleWin1 == 7){
        [prizeChest8 setBackgroundImage:[UIImage imageForDeviceForName:@"chest_open_coins.png"] forState:UIControlStateNormal];
        winPostion = 8;
    }else if(shuffleWin1 == 8){
        [prizeChest9 setBackgroundImage:[UIImage imageForDeviceForName:@"chest_open_coins.png"] forState:UIControlStateNormal];
        winPostion = 9;
    }else if(shuffleWin1 == 9){
        [prizeChest10 setBackgroundImage:[UIImage imageForDeviceForName:@"chest_open_coins.png"] forState:UIControlStateNormal];
        winPostion = 10;
    }
    
    
   [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(loadPrize) userInfo:nil repeats:NO];
}

- (void)viewDidLoad{
    userPicked = NO;
    [super viewDidLoad];
    prizeChest1.userInteractionEnabled = NO;
    prizeChest2.userInteractionEnabled = NO;
    prizeChest3.userInteractionEnabled = NO;
    prizeChest4.userInteractionEnabled = NO;
    prizeChest5.userInteractionEnabled = NO;
    prizeChest6.userInteractionEnabled = NO;
    prizeChest7.userInteractionEnabled = NO;
    prizeChest8.userInteractionEnabled = NO;
    prizeChest9.userInteractionEnabled = NO;
    prizeChest10.userInteractionEnabled = NO;
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(loadPrize) userInfo:nil repeats:NO];
    
    lblAlert1.text = @"Follow the gold";
}
@end
