//
//  StoreTableViewController.m
//  Kazakhstan Plus
//
//  Created by admin on 2016-03-24.
//  Copyright © 2016 Maxim Puchkov. All rights reserved.
//

#import "StoreTableViewController.h"

@interface StoreTableViewController ()

@end

@implementation StoreTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"leftMenu.png"]];
    self.tableView.backgroundView = imageView;
    self.tableView.separatorColor = [UIColor cyanColor];
    self.defaults = [NSUserDefaults standardUserDefaults];
    self.restoreable = @[@"com.maximpuchkov.kz.iap.infinite", @"com.maximpuchkov.kz.iap.ads"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    NSLog(@"Removing transaction observer");
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 7;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 75;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"storeCell" forIndexPath:indexPath];
    NSString *title;
    BOOL infinite = [[self.defaults objectForKey:@"infinite"] boolValue];
    BOOL ads = [[self.defaults objectForKey:@"ads"] boolValue];
    BOOL enabled = YES;
    
    switch (indexPath.row) {
        case 0:
            title = @"5 подсказок за $0.99";
            if (infinite) {
                enabled = NO;
            }
            break;
        case 1:
            title = @"15 подсказок за $1.99";
            if (infinite) {
                enabled = NO;
            }
            break;
        case 2:
            title = @"40 подсказок за $2.99";
            if (infinite) {
                enabled = NO;
            }
            break;
        case 3:
            title = @"Бесконечые подсказки";
            if (infinite) {
                enabled = NO;
            }
            break;
        case 4:
            title = @"Выключить рекламу";
            if (ads) {
                enabled = NO;
            }
            break;
        case 5:
            title = @"Восстановить покупки";
            break;
        case 6:
            title = @"Казахская Клавиатура+ для iPhone";
            break;
    }
    
    cell.textLabel.text = title;
    cell.backgroundColor = [UIColor clearColor];
    cell.userInteractionEnabled = enabled;
    if (!cell.userInteractionEnabled) {
        cell.textLabel.textColor = [UIColor darkGrayColor];
    } else {
        cell.textLabel.textColor = [UIColor whiteColor];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *productID;
    if ([self internetConnection]) {
        self.navigationItem.hidesBackButton = YES;
        switch (indexPath.row) {
            case 0:
                productID = @"com.maximpuchkov.kz.iap.five";
                break;
            case 1:
                productID = @"com.maximpuchkov.kz.iap.fifteen";
                break;
            case 2:
                productID = @"com.maximpuchkov.kz.iap.forty";
                break;
            case 3:
                productID = @"com.maximpuchkov.kz.iap.infinite";
                break;
            case 4:
                productID = @"com.maximpuchkov.kz.iap.ads";
                break;
            case 5:
                [self restore];
                break;
            case 6:
                [self buyKazakhKeyboard];
                //[self clearData];
                break;
        }
        if (productID) {
            self.productID = productID;
            self.type = indexPath.row;
            [self getProductID];
        }
    } else {
        [self showAlert:@"Ошибка" content:@"Не удалось подключиться к сети Интернет" okButtonText:@"Ок"];
    }
}

- (void)getProductID {
    NSLog(@"Getting product ID");
    if ([SKPaymentQueue canMakePayments]) {
        NSLog(@"Can make payments");
        SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:self.productID]];
        request.delegate = self;
        [request start];
    } else {
        NSLog(@"Cannot make payments");
    }
}

#pragma mark – SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    NSLog(@"Requesting");
    NSArray *products = response.products;
    if (products.count != 0) {
        NSLog(@"Products found");
        self.product = products[0];
    } else {
        NSLog(@"Products not found");
    }
    
    products = response.invalidProductIdentifiers;
    
    for (SKProduct *product in products) {
        NSLog(@"Product not found: %@", product);
    }
    [self buy];
}

- (void)buy {
    NSLog(@"Adding transaction observer");
    NSLog(@"Buying product: %@ ...", self.productID);
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    SKPayment *payment = [SKPayment paymentWithProduct:self.product];
    if (payment) {
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }
}

- (void)restore {
    NSLog(@"Restoring purchases...");
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions {
    NSLog(@"%lu transactions in StoreKit Payment Queue", (unsigned long)transactions.count);
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
                NSLog(@"Transaction complete");
                switch (self.type) {
                    case 0:
                        [self addHints:5];
                        break;
                    case 1:
                        [self addHints:15];
                        break;
                    case 2:
                        [self addHints:40];
                        break;
                    case 3:
                        [self enableInfiniteHints:self.tableView];
                        break;
                    case 4:
                        [self disableAds:self.tableView];
                        break;
                }
                self.navigationItem.hidesBackButton = NO;
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self showAlert:@"Ошибка" content:@"Не удалось купить товар" okButtonText:@"Ок"];
                NSLog(@"Transaction Failed");
                self.navigationItem.hidesBackButton = NO;
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                self.navigationItem.hidesBackButton = NO;
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            default:
                break;
        }
    }
}

- (void) paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    BOOL restored = NO;
    NSMutableArray *purchasedItemIDs = [[NSMutableArray alloc] init];
    NSLog(@"received restored transactions: %lu", (unsigned long)queue.transactions.count);
    for (SKPaymentTransaction *transaction in queue.transactions) {
        NSString *productID = transaction.payment.productIdentifier;
        [purchasedItemIDs addObject:productID];
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    }
    
    NSLog(@"%@", purchasedItemIDs);
    for (int i = 0; i < [self.restoreable count]; i++) {
        if ([purchasedItemIDs containsObject:self.restoreable[i]]) {
            restored = YES;
            switch (i) {
                case 0:
                    [self enableInfiniteHints:self.tableView];
                    break;
                case 1:
                    [self disableAds:self.tableView];
                    break;
            }
        }
    }
    if (restored) {
        [self showAlert:@"Спасибо!" content:@"Все покупки были успешно восстановлены" okButtonText:@"Ок"];
    }
}

#pragma mark – In-App Purchases

- (void)addHints:(NSInteger)amount {
    NSString *currentAmount = [self.defaults objectForKey:@"hints"];
    NSLog(@"Added %li hints", (long)amount);
    amount += [currentAmount integerValue];
    NSLog(@"Total %li hints", (long)amount);
    [self.defaults setObject:[NSString stringWithFormat:@"%li", (long)amount] forKey:@"hints"];
    [self.defaults synchronize];
}

- (void)enableInfiniteHints:(UITableView *)tableView {
    NSLog(@"Enabling infinite hints");
    [self.defaults setObject:@"true" forKey:@"infinite"];
    [self.defaults synchronize];
    for (int i = 0; i < 4; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.textLabel.textColor = [UIColor darkGrayColor];
        cell.userInteractionEnabled = NO;
    }
}

- (void)disableAds:(UITableView *)tableView {
    NSLog(@"Disabling ads");
    [self.defaults setObject:@"true" forKey:@"ads"];
    [self.defaults synchronize];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:4 inSection:0];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.textLabel.textColor = [UIColor darkGrayColor];
    cell.userInteractionEnabled = NO;
}

#pragma mark – Alert

- (void)showAlert:(NSString *)title content:(NSString *)message okButtonText:(NSString *)okButtonText {
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:title
                                  message:message
                                  preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:okButtonText
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action) {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                         }];
    [alert addAction:ok];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark – Reachability

- (BOOL)internetConnection {
    internetReachable = [Reachability reachabilityForInternetConnection];
    [internetReachable startNotifier];
    NetworkStatus netStatus = [internetReachable currentReachabilityStatus];
    switch (netStatus) {
        case NotReachable:
            return NO;
        case ReachableViaWWAN:
            return YES;
        case ReachableViaWiFi:
            return YES;
    }
}

#pragma mark – Buy Kazakh Keyboard+

- (void)buyKazakhKeyboard {
    self.navigationItem.hidesBackButton = NO;
    NSString *str = @"https://itunes.apple.com/us/app/kazahskaa-klaviatura+/id1084095398?ls=1&mt=8";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
}

#pragma mark – Debug

- (void)clearData {
    NSLog(@"Debug: clearing NSUserDefaults");
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
}

@end
