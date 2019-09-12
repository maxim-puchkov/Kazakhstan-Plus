//
//  StoreTableViewController.h
//  Kazakhstan Plus
//
//  Created by admin on 2016-03-24.
//  Copyright © 2016 Maxim Puchkov. All rights reserved.
//

@import UIKit;
@import GoogleMobileAds;
@import StoreKit;

#import "Reachability.h"

@interface StoreTableViewController : UITableViewController <SKPaymentTransactionObserver, SKProductsRequestDelegate> {
    Reachability *internetReachable;
}

@property (strong, nonatomic) SKProduct *product;
@property (strong, nonatomic) NSString *productID;
@property (nonatomic) NSInteger type;
@property (strong, nonatomic) NSUserDefaults *defaults;
@property (strong, nonatomic) NSArray *restoreable;

- (void)getProductID;

@end
