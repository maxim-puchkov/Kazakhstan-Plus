//
//  ViewController.m
//  Kazakhstan Plus
//
//  Created by admin on 2016-03-17.
//  Copyright © 2016 Maxim Puchkov. All rights reserved.
//

#import "ViewController.h"

#define adUnitID @"ca-app-pub-7166098384972941/1763235713"

const static NSInteger ads = 3;

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"load");
    // Do any additional setup after loading the view, typically from a nib.
    
    self.defaults = [NSUserDefaults standardUserDefaults];
    adsBlocked = [[self.defaults objectForKey:@"ads"] boolValue];
    BOOL free = [[self.defaults objectForKey:@"hintForCurrentID"] boolValue];
    BOOL init = [[self.defaults objectForKey:@"init"] boolValue];

    if (!init) {
        [self initGameSettings];
    }
    
    
    self.currentQuestion = [[self.defaults objectForKey:@"id"] integerValue];
    
    self.alphabet = @[@"а", @"б", @"в", @"г", @"д", @"е", @"ё", @"ж", @"з", @"и", @"й", @"к", @"л", @"м", @"н", @"о", @"п", @"р", @"с", @"т", @"у", @"ф", @"х", @"ц", @"ч", @"ш", @"щ", @"ъ", @"ы", @"ь", @"э", @"ю", @"я"];
    self.content = [self readContentsOfFile:@"content" ofType:@"txt"];
    self.hintCompleteButton.hidden = YES;
    NSLog(@"%@", self.content);
    NSLog(@"%li", (long)self.currentQuestion);
    if (self.currentQuestion >= [self.content count]) {
        [self resetGame];
    }

    
    [self chooseNextQuestion];
    [self setConstaints];
    
    for (UIButton *key in self.keys) {
        [key addTarget:self action:@selector(keyPressed:) forControlEvents:UIControlEventTouchUpInside];
        [key.titleLabel setFont:[UIFont systemFontOfSize:self.buttonFontSize]];
        //key.adjustsImageWhenHighlighted = NO;
    }
    [self.answer setTitle:@" " forState:UIControlStateNormal];
    if (free) {
        self.hintUsed = YES;
        [self useHints:YES];
    }
    
    //self.fontSize = [self setFontSize];
    
    if (!adsBlocked) {
        answered = ads-1;
        [self createAndLoadInterstitial];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    
}

#pragma mark – Set Up

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)initGameSettings {
    self.currentQuestion = 0;
    [self.defaults setObject:[NSString stringWithFormat:@"%li", (long)self.currentQuestion] forKey:@"id"];
    [self.defaults setObject:@"3" forKey:@"hints"];
    [self.defaults setObject:@"true" forKey:@"init"];
    [self.defaults synchronize];
}

- (NSArray *)readContentsOfFile:(NSString *)file ofType:(NSString *)type {
    NSString *resource = [[NSBundle mainBundle] pathForResource:file ofType:type];
    NSError *error;
    NSString *fileContent = [NSString stringWithContentsOfFile:resource encoding:NSUTF8StringEncoding error:&error];
    NSArray *content = [fileContent componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    return content;
}

- (NSInteger)setFontSize {
    NSInteger size;
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    if (screenSize.height == 480) {
        size = 36;
    } else if (screenSize.height == 568) {
        size = 40;
    } else {
        size = 46;
    }
    return size;
}

- (void)setImage {
    NSString *imageName = [NSString stringWithFormat:@"%@.jpg", self.content[self.currentQuestion]];
    UIImage *image = [UIImage imageNamed:imageName];
    if (!image) {
        image = [UIImage imageNamed:@"test.png"];
    }
    NSLog(@"Current Image: %@; Properties: %@; Image View Size: {%f, %f}", imageName, image, self.imageView.frame.size.width, self.imageView.frame.size.height);
    self.imageView.image = image;
}

- (void)setConstaints {
    // Center vertically
    float constant;
    NSInteger size;
    NSInteger buttonSize;
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    NSLog(@"%f", screenSize.height);
    
    if (screenSize.height == 480) {
        // iPhone 4/4S
        constant = -80;
        size = 36;
        buttonSize = 14;
    } else if (screenSize.height == 568) {
        // iPhone 5
        constant = -80;
        size = 40;
        buttonSize = 16;
    } else if (screenSize.height == 667) {
        // iPhone 6/6S
        constant = -105;
        size = 46;
        buttonSize = 18;
    } else if (screenSize.height == 736) {
        // iPhone 6+/6S+
        constant = -125;
        size = 52;
        buttonSize = 22;
    } else if (screenSize.height == 1024) {
        // iPad 2, iPad Air /2, iPad Retina
        constant = -160;
        size = 64;
        buttonSize = 44;
    } else if (screenSize.height == 1366) {
        // iPad Pro
        constant = -240;
        size = 90;
        buttonSize = 60;
    }
    
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView
                                                            attribute:NSLayoutAttributeCenterY
                                                            relatedBy:NSLayoutRelationEqual
                                                            toItem:self.view
                                                            attribute:NSLayoutAttributeCenterY
                                                            multiplier:1.0
                                                            constant:constant]];
    self.fontSize = size;
    self.buttonFontSize = buttonSize;
}

#pragma mark – Main

- (void)chooseNextQuestion {
    NSString *question;
    NSInteger index = self.currentQuestion;
    question = self.content[index];
    NSLog(@"Original word: %@", question);
    question = [self shuffle:[self analyze:question]];
    
    UIButton *key;
    NSString *title;
    for (int i = 0; i < [self.keys count]; i++) {
        key = self.keys[i];
        NSRange range = NSMakeRange(i, 1);
        title = [[question substringWithRange:range] uppercaseString];
        [key setTitle:title forState:UIControlStateNormal];
        key.hidden = NO;
        key.alpha = 0.0;
    }
    for (int k = 0; k < [self.keys count]/2; k++) {
        key = self.keys[k];
        [UIView animateWithDuration:(0.35)
                         animations:^ {
                             key.alpha = 1.0;
                         }];
    }
    
    for (int j = (int)[self.keys count]-1; j > [self.keys count]/2-1; j--) {
        key = self.keys[j];
        [UIView animateWithDuration:(0.55)
                         animations:^ {
                             key.alpha = 1.0;
                         }];
    }
    
    [self setImage];
}

- (NSString *)analyze:(NSString *)string {
    NSString *character;
    while ([string length] < 12) {
        character = self.alphabet[arc4random() % [self.alphabet count]];
        string = [string stringByAppendingString:character];
    }
    return string;
}

- (NSString *)shuffle:(NSString *)string {
    NSUInteger length = [string length];
    if (length) {
        unichar *buffer = calloc(length, sizeof(unichar));
        [string getCharacters:buffer range:NSMakeRange(0, length)];
        for (int i = (int)length - 1; i >= 0; i--) {
            int j = arc4random() % (i + 1);
            //NSLog(@"%d %d", i, j);
            //swap at positions i and j
            unichar c = buffer[i];
            buffer[i] = buffer[j];
            buffer[j] = c;
        }
        NSString *result = [NSString stringWithCharacters:buffer length:length];
        free(buffer);
        string = result;
    }
    NSLog(@"Shuffled word: %@", string);
    return string;
}

- (void)keyPressed:(UIButton *)sender {
    NSString *current = self.answer.titleLabel.text;
    NSString *title = sender.titleLabel.text;
    NSArray *wordBlacklist = @[@"хуй", @"хуи", @"бля", @"пизд", @"еба", @"сука", @"нах"];
    if (![current isEqualToString:@" "]) {
        title = [current stringByAppendingString:title];
    }
    if (title.length > 6) {
        [self.answer.titleLabel setFont:[UIFont boldSystemFontOfSize:(self.fontSize-8)]];
    } else {
        [self.answer.titleLabel setFont:[UIFont boldSystemFontOfSize:self.fontSize]];
    }
    [self.answer setTitle:title forState:UIControlStateNormal];
    NSLog(@"%@", title);
    if ([[title lowercaseString] isEqualToString:self.content[self.currentQuestion]]) {
        self.currentQuestion++;
        if (self.currentQuestion >= [self.content count]) {
            [self resetGame];
        }
        [self.defaults setObject:[NSString stringWithFormat:@"%li", (long)self.currentQuestion] forKey:@"id"];
        [self.defaults synchronize];
        [self continueToNextQuestion];
        NSLog(@"correct answer");
    }
    [UIView animateWithDuration:0.45
                     animations:^ {
                         sender.alpha = 0.0;
                     }];
    for (int i = 0; i < [wordBlacklist count]; i++) {
        if ([[title lowercaseString] isEqualToString:wordBlacklist[i]]) {
            [self.answer sendActionsForControlEvents:UIControlEventTouchUpInside];
            break;
        }
    }
}

- (IBAction)answerPress:(id)sender {
    [self.answer setTitle:@" " forState:UIControlStateNormal];
    for (UIButton *key in self.keys) {
        [UIView animateWithDuration:0.45
                         animations:^ {
                             key.alpha = 1.0;
                         }];
    }
}

- (void)continueToNextQuestion {
    adsBlocked = [[self.defaults objectForKey:@"ads"] boolValue];
    CustomIOS7AlertView *alertView = [CustomIOS7AlertView alertWithTitle:@"Правильно" message:@"Продолжай в том же духе."];
    [alertView setButtonTitles:[NSMutableArray arrayWithObjects:@"Написать отзыв", @"Продолжить", nil]];
    [alertView setButtonColors:[NSMutableArray arrayWithObjects:[UIColor colorWithRed:0.0f green:0.5f blue:1.0f alpha:1.0f], [UIColor colorWithRed:0.05f green:0.85f blue:0.5f alpha:1.0f], nil]];
    [alertView setOnButtonTouchUpInside:^(CustomIOS7AlertView *alertView, int buttonIndex) {
        BOOL displayAd = YES;
        NSString *str = @"https://itunes.apple.com/us/app/kazahstan+/id1091212805?ls=1&mt=8";
        switch (buttonIndex) {
            case 0:
                displayAd = NO;
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
            case 1:
                for (UIButton *key in self.keys) {
                    key.alpha = 1.0;
                }
                [self.answer sendActionsForControlEvents:UIControlEventTouchUpInside];
                [self chooseNextQuestion];
                [alertView close];
                if (!adsBlocked && displayAd) {
                    answered++;
                    if (answered > ads) {
                        if (self.interstitial.isReady) {
                            answered = 0;
                            [self.interstitial presentFromRootViewController:self];
                            [self createAndLoadInterstitial];
                            NSLog(@"Ad shown");
                        } else {
                            NSLog(@"Currently unable to display interstitial");
                        }
                    }
                } else {
                    NSLog(@"Ads blocked");
                }
                break;
        }
    }];
    [alertView show];
    self.hintUsed = NO;
    self.hintButton.hidden = NO;
    self.hintCompleteButton.hidden = YES;
    [self.defaults setObject:@"false" forKey:@"hintForCurrentID"];
}

- (void)customIOS7dialogButtonTouchUpInside:(CustomIOS7AlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [alertView close];
}

- (IBAction)hintButtonPress:(id)sender {
    [self useHints:NO];
}

- (IBAction)hintCompleteButtonPress:(id)sender {
    [self solve];
}

- (void)useHints:(BOOL)free {
    NSInteger amount = [[self.defaults objectForKey:@"hints"] integerValue];
    BOOL infinite = [[self.defaults objectForKey:@"infinite"] boolValue];
    NSString *message = @"Эта подсказка удалит все лишние буквы.";
    NSString *hints;
    if (infinite) {
        hints = @"\nУ тебя бесконечные подсказки.";
    } else {
        hints = [NSString stringWithFormat:@"\nОсталось подсказок: %li", (long)amount];
    }
    message = [message stringByAppendingString:hints];
    if (!infinite) {
        NSLog(@"Amount of hints when used: %li", (long)amount);
    }
    if (!self.hintUsed) {
        if (amount > 0 || infinite) {
            CustomIOS7AlertView *alertView = [CustomIOS7AlertView alertWithTitle:@"Подсказка «Молния»" message:message];
            [alertView setButtonTitles:[NSMutableArray arrayWithObjects:@"Нет", @"Да", nil]];
            [alertView setButtonColors:[NSMutableArray arrayWithObjects:[UIColor colorWithRed:0.0f green:0.5f blue:1.0f alpha:1.0f], [UIColor colorWithRed:0.05f green:0.85f blue:0.5f alpha:1.0f], nil]];
            [alertView setOnButtonTouchUpInside:^(CustomIOS7AlertView *alertView, int buttonIndex) {
                if (buttonIndex == 1) {
                    NSString *answer = self.content[self.currentQuestion];
                    NSString *letter;
                    [self.answer sendActionsForControlEvents:UIControlEventTouchUpInside];
                    self.hintButton.hidden = YES;
                    self.hintCompleteButton.hidden = NO;
                    for (UIButton *key in self.keys) {
                        key.hidden = YES;
                    }
                    for (int i = 0; i < answer.length; i++) {
                        NSRange range = NSMakeRange(i, 1);
                        letter = [[answer substringWithRange:range] uppercaseString];
                        for (UIButton *key in self.keys) {
                            if ([key.titleLabel.text isEqualToString:letter] && key.hidden) {
                                key.hidden = NO;
                                break;
                            }
                        }
                    }
                    self.hintUsed = YES;
                    [self.defaults setObject:@"true" forKey:@"hintForCurrentID"];
                    [self.defaults synchronize];
                    if (!infinite) {
                        NSInteger amount = [[self.defaults objectForKey:@"hints"] integerValue];
                        amount--;
                        [self.defaults setObject:[NSString stringWithFormat:@"%li", (long)amount] forKey:@"hints"];
                        [self.defaults synchronize];
                    }
                    NSLog(@"Hint used");
                }
            }];
            [alertView show];
        } else {
            CustomIOS7AlertView *alertView = [CustomIOS7AlertView alertWithTitle:@"Нет подсказок" message:@"Тебе нужно больше подсказок"];
            [alertView setButtonTitles:[NSMutableArray arrayWithObjects:@"Хорошо", nil]];
            [alertView setButtonColors:[NSMutableArray arrayWithObjects:[UIColor colorWithRed:0.05f green:0.85f blue:0.5f alpha:1.0f], nil]];
            [alertView setOnButtonTouchUpInside:^(CustomIOS7AlertView *alertView, int buttonIndex) {
                [self.shopButton sendActionsForControlEvents: UIControlEventTouchUpInside];
            }];
            NSLog(@"Not enough hints");
            [alertView show];
        }
    } else if (free) {
        NSString *answer = self.content[self.currentQuestion];
        NSString *letter;
        [self.answer sendActionsForControlEvents:UIControlEventTouchUpInside];
        self.hintButton.hidden = YES;
        self.hintCompleteButton.hidden = NO;
        for (UIButton *key in self.keys) {
            key.hidden = YES;
        }
        for (int i = 0; i < answer.length; i++) {
            NSRange range = NSMakeRange(i, 1);
            letter = [[answer substringWithRange:range] uppercaseString];
            for (UIButton *key in self.keys) {
                if ([key.titleLabel.text isEqualToString:letter] && key.hidden) {
                    key.hidden = NO;
                    break;
                }
            }
        }
    }
}

- (void)solve {
    NSInteger amount = [[self.defaults objectForKey:@"hints"] integerValue];
    BOOL infinite = [[self.defaults objectForKey:@"infinite"] boolValue];
    NSString *message = @"Эта подсказка решит это слово";
    NSString *hints;
    if (infinite) {
        hints = @"\nУ тебя бесконечные подсказки.";
    } else {
        hints = [NSString stringWithFormat:@"\nОсталось подсказок: %li", (long)amount];
    }
    message = [message stringByAppendingString:hints];
    if (!infinite) {
        //NSLog(@"Amount of hints when used: %li", (long)amount);
    }
    
    if (amount > 0 || infinite) {
        CustomIOS7AlertView *alertView = [CustomIOS7AlertView alertWithTitle:@"Подсказка «Гений»" message:message];
        [alertView setButtonTitles:[NSMutableArray arrayWithObjects:@"Нет", @"Да", nil]];
        [alertView setButtonColors:[NSMutableArray arrayWithObjects:[UIColor colorWithRed:0.0f green:0.5f blue:1.0f alpha:1.0f], [UIColor colorWithRed:0.05f green:0.85f blue:0.5f alpha:1.0f], nil]];
        [alertView setOnButtonTouchUpInside:^(CustomIOS7AlertView *alertView, int buttonIndex) {
            if (buttonIndex == 1) {
                NSString *answer = self.content[self.currentQuestion];
                NSString *letter;
                [self.answer sendActionsForControlEvents:UIControlEventTouchUpInside];
                for (int i = 0; i < answer.length; i++) {
                    NSRange range = NSMakeRange(i, 1);
                    letter = [[answer substringWithRange:range] uppercaseString];
                    for (UIButton *key in self.keys) {
                        if ([key.titleLabel.text isEqualToString:letter] && !key.hidden) {
                            [key sendActionsForControlEvents:UIControlEventTouchUpInside];
                            key.hidden = YES;
                            break;
                        }
                    }
                }
                if (!infinite) {
                    NSInteger amount = [[self.defaults objectForKey:@"hints"] integerValue];
                    amount--;
                    [self.defaults setObject:[NSString stringWithFormat:@"%li", (long)amount] forKey:@"hints"];
                    [self.defaults synchronize];
                }
                NSLog(@"Hint Complete used");
            }
        }];
        [alertView show];
    } else {
        CustomIOS7AlertView *alertView = [CustomIOS7AlertView alertWithTitle:@"Нет подсказок" message:@"Тебе нужно больше подсказок"];
        [alertView setButtonTitles:[NSMutableArray arrayWithObjects:@"Хорошо", nil]];
        [alertView setButtonColors:[NSMutableArray arrayWithObjects:[UIColor colorWithRed:0.05f green:0.85f blue:0.5f alpha:1.0f], nil]];
        [alertView setOnButtonTouchUpInside:^(CustomIOS7AlertView *alertView, int buttonIndex) {
            [self.shopButton sendActionsForControlEvents: UIControlEventTouchUpInside];
        }];
        NSLog(@"Not enough hints");
        [alertView show];
    }
}

- (void)resetGame {
    CustomIOS7AlertView *alertView = [CustomIOS7AlertView alertWithTitle:@"Упс" message:@"Вопросы закончились. Игра начнется заново"];
    [alertView setButtonTitles:[NSMutableArray arrayWithObjects:@"Хорошо", nil]];
    [alertView setButtonColors:[NSMutableArray arrayWithObjects:[UIColor colorWithRed:0.05f green:0.85f blue:0.5f alpha:1.0f], nil]];
    [alertView setOnButtonTouchUpInside:^(CustomIOS7AlertView *alertView, int buttonIndex) {
    }];
    NSLog(@"Game reset");
    [alertView show];
    self.currentQuestion = 0;
}

#pragma mark – Interstitial
#pragma Interstitial button actions

- (void)createAndLoadInterstitial {
    NSLog(@"Loading Interstitial (Ad Unit ID: %@)", adUnitID);
    self.interstitial = [[GADInterstitial alloc] initWithAdUnitID:adUnitID];

    GADRequest *request = [GADRequest request];
    // Request test ads on devices you specify. Your test device ID is printed to the console when
    // an ad request is made. GADInterstitial automatically returns test ads when running on a
    // simulator.
    request.testDevices = @[
                            @"0ab35fb20ced290c5f04a1e425b84d4e"  // iPhone 6s!
                            ];
    [self.interstitial loadRequest:request];
}

#pragma mark GADInterstitialDelegate implementation

- (void)interstitial:(GADInterstitial *)interstitial didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"interstitialDidFailToReceiveAdWithError: %@", [error localizedDescription]);
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)interstitial {
    NSLog(@"interstitialDidDismissScreen");
}

@end
