//
//  ViewController.h
//  Kazakhstan Plus
//
//  Created by admin on 2016-03-17.
//  Copyright © 2016 Maxim Puchkov. All rights reserved.
//

@import UIKit;
@import GoogleMobileAds;
@import StoreKit;

#import "CustomIOS7AlertView.h"

@interface ViewController : UIViewController {
    BOOL adsBlocked;
    NSInteger answered;
}

@property (strong, nonatomic) NSArray *content;
@property (strong, nonatomic) NSArray *alphabet;
@property (nonatomic) NSInteger currentQuestion;
@property (nonatomic) NSInteger fontSize;
@property (nonatomic) NSInteger buttonFontSize;
@property (nonatomic) BOOL hintUsed;
@property (strong, nonatomic) NSUserDefaults *defaults;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *keys;
@property (weak, nonatomic) IBOutlet UIButton *answer;
@property (weak, nonatomic) IBOutlet UIButton *hintButton;
@property (weak, nonatomic) IBOutlet UIButton *hintCompleteButton;
@property (weak, nonatomic) IBOutlet UIButton *shopButton;

@property (strong, nonatomic) GADInterstitial *interstitial;

@end
