//
//  WTTableViewController.h
//  Weather
//
//  Created by Scott on 26/01/2013.
//  Updated by Joshua Greene 16/12/2013.
//
//  Copyright (c) 2013 Scott Sherwood. All rights reserved.
//

#import <UIKit/UIKit.h>

// This means the class will implement the NSXMLParserDelegate protocol. You will implement these methods soon, but first you need to add a few properties.
@interface WTTableViewController : UITableViewController<NSXMLParserDelegate, CLLocationManagerDelegate, UIActionSheetDelegate>

// Actions
- (IBAction)clear:(id)sender;
- (IBAction)jsonTapped:(id)sender;
- (IBAction)plistTapped:(id)sender;
- (IBAction)xmlTapped:(id)sender;
- (IBAction)clientTapped:(id)sender;
- (IBAction)apiTapped:(id)sender;

@end