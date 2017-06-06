//
//  ViewController.m


#import "ViewController.h"
#import "BonusViewController.h"
#import "CoinsController.h"

#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonDigest.h>
#import <QuartzCore/QuartzCore.h>
#import "ObjectAL.h"


@implementation BonusViewController

-(void)addWinCoins{
    
    if(coinsAdd == currentWinCoins){
        [addWin invalidate];
        [BaseViewController playSoundEffect:kSoundCoinDrop];
        currentWinCoins = 0;
        addWinStatus = @"NO";
    }else{
        int currentWon = [[CommonUtilities decryptString:@"won"] intValue];
        currentWon = currentWon + 1;
        [CommonUtilities encryptString:[NSString stringWithFormat:@"%i", currentWon]:@"won"];
        
        int currentCoins = [[CommonUtilities decryptString:@"coins"] intValue];
        currentCoins = currentCoins + 1;
        [CommonUtilities encryptString:[NSString stringWithFormat:@"%i", currentCoins]:@"coins"];
        
        displayCoins.text = [NSString stringWithFormat:@"%i", currentCoins];
        
        coinsAdd = coinsAdd + 1;
    }
}

- (void)manageWin:(int)winAmount{
    
    if(winAmount > 30){
        NSLog(@"win greater than 30");
        // local remove 30 coins from the amount
        int currentWon = [[CommonUtilities decryptString:@"won"] intValue];
        currentWon = currentWon + (winAmount - 30);
        [CommonUtilities encryptString:[NSString stringWithFormat:@"%i", currentWon]:@"won"];
        
        int currentCoins = [[CommonUtilities decryptString:@"coins"] intValue];
        currentCoins = currentCoins + (winAmount - 30);
        [CommonUtilities encryptString:[NSString stringWithFormat:@"%i", currentCoins]:@"coins"];
        
        displayCoins.text = [NSString stringWithFormat:@"%i", currentCoins];
        
        currentWinCoins = currentWinCoins + 30;
        coinsAdd = 0;
        
        if([addWinStatus isEqual:@"YES"]){}else{
            addWin = [NSTimer scheduledTimerWithTimeInterval:0.001 target:self selector:@selector(addWinCoins) userInfo:nil repeats:YES];
            addWinStatus = @"YES";
        }
    }else{
        currentWinCoins = currentWinCoins + winAmount;
        coinsAdd = 0;
        
        if([addWinStatus isEqual:@"YES"]){}else{
            addWin = [NSTimer scheduledTimerWithTimeInterval:0.001 target:self selector:@selector(addWinCoins) userInfo:nil repeats:YES];
            addWinStatus = @"YES";
        }
    }
    
}

- (IBAction)home:(id)sender{
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)coinsView:(id)sender{
    [BaseViewController showCoinsView:sender inController:self];
}


- (void)viewWillAppear:(BOOL)animated{
    
    prizeShuffleCounter = 0;

    displayCoins.text = [CommonUtilities decryptString:@"coins"];
    int xp = [[CommonUtilities decryptString:@"exp"] intValue];
    
    optionXP.text = [CommonUtilities decryptString:@"exp"];
    optionLvl.text = [self returnLevel:xp];
    lblDisplayLevel.text = [NSString stringWithFormat:@"Level %@", [self returnLevel:xp]];
}


-(void)finishedSpin{
    NSLog(@"done spinning");
    
    int coins = [[CommonUtilities decryptString:@"coins"] intValue];
    
    
    coins = coins + [[lblAlert1.text stringByReplacingOccurrencesOfString:@"WON" withString:@""] intValue];
    
    [CommonUtilities encryptString:[NSString stringWithFormat:@"%i", coins]:@"coins"];
    
    [self dismissViewControllerAnimated:NO completion:nil];
    // sort win money
}

-(void)spinSector{
    amountToSpin = 2;
    
    int random = arc4random() % 16;
    
    wheelSpinTo = ((random+1) * 22.5);
    
    autoT = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(moveWheel) userInfo:nil repeats:YES];
    degreesWheel = 0;
    
    
}

-(void)moveWheel{
    
    if(degreesWheel >= 360){
        degreesWheel = degreesWheel - 360;
        spinTimes = spinTimes + 1;
    }
    
    degreesWheel = degreesWheel + amountToSpin;
    spinner.transform = CGAffineTransformMakeRotation(degreesWheel * M_PI/180);
    
    NSString *currentlyAt = [NSString stringWithFormat:@"%.0f", degreesWheel/22.5];
    
    int currently = [currentlyAt intValue];
       
    int winValue;
    
    if(currently == 1){
        winValue = 900;
    }else if(currently == 2){
        winValue = 150;
    }else if(currently == 3){
        winValue = 300;
    }else if(currently == 4){
        winValue = 250;
    }else if(currently == 5){
        winValue = 800;
    }else if(currently == 6){
        winValue = 100;
    }else if(currently == 7){
        winValue = 500;
    }else if(currently == 8){
        winValue = 200;
    }else if(currently == 9){
        winValue = 400;
    }else if(currently == 10){
        winValue = 550;
    }else if(currently == 11){
        winValue = 700;
    }else if(currently == 12){
        winValue = 600;
    }else if(currently == 13){
        winValue = 150;
    }else if(currently == 14){
        winValue = 350;
    }else if(currently == 15){
        winValue = 450;
    }else{
        winValue = 800;
    }

    lblAlert1.text = [NSString stringWithFormat:@"You won %i", winValue];
    
    if(spinTimes > 1){
        if(currently == [[NSString stringWithFormat:@"%f", ((wheelSpinTo)/22.5)] intValue]){
            if([autoT isValid]){
                [autoT invalidate];
            }
            [BaseViewController playSoundEffect:kSoundWon];
            
            //lblAlert1.text = [NSString stringWithFormat:@"Bonus win %i", winValue];
            [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(finishedSpin) userInfo:nil repeats:NO];
            
            //spinWheelButton.enabled = 1;
            degreesWheel = 0;
            
            [self manageWin:winValue];
        }
    }
    
}

-(IBAction)spin:(id)sender{
    spinWheelButton.enabled = 0;
    home.enabled = 0;
    spinTimes = 1;
    [self spinSector];
}

- (void)viewDidLoad{
    [CommonUtilities encryptString:@"NO":@"zd"];
    [self sortLevelBar];
    
    displayCoins.text = [CommonUtilities decryptString:@"coins"];
    
    //spinner.transform = CGAffineTransformMakeRotation(4 * M_PI/180);
    
    //degreesWheel = 0;
    
    //[CommonUtilities encryptString:@"NO":@"zd"];
    [self presetSoundButtons];
    
    int xp = [[CommonUtilities decryptString:@"exp"] intValue];
    
    optionXP.text = [CommonUtilities decryptString:@"exp"];
    optionLvl.text = [self returnLevel:xp];
    lblDisplayLevel.text = [NSString stringWithFormat:@"Level %@", [self returnLevel:xp]];
    
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        NSLog(@"can build to ipad");
        [[UILabel appearance] setFont:[UIFont fontWithName:@"Myriad Web Pro" size:20.0]];
        [lblAlert1 setFont:[UIFont fontWithName:@"Myriad Web Pro" size:36.0]];
    }else{
        [[UILabel appearance] setFont:[UIFont fontWithName:@"Myriad Web Pro" size:10.0]];
        
        [displayCoins setFont:[UIFont fontWithName:@"Myriad Web Pro" size:10.0]];
        [optionXP setFont:[UIFont fontWithName:@"Myriad Web Pro" size:10.0]];
        [optionLvl setFont:[UIFont fontWithName:@"Myriad Web Pro" size:10.0]];
        [displayCoins setFont:[UIFont fontWithName:@"Myriad Web Pro" size:10.0]];
        [lblAlert1 setFont:[UIFont fontWithName:@"Myriad Web Pro" size:18.0]];
    }
    
    
    
    lblAlert1.text = @"Tap 'Spin' for Bonus";
}

@end
