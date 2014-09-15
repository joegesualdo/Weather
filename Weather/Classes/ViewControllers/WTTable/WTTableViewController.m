//
//  WTTableViewController.m
//  Weather
//
//  Created by Scott on 26/01/2013.
//  Updated by Joshua Greene 16/12/2013.
//
//  Copyright (c) 2013 Scott Sherwood. All rights reserved.
//

#import "WTTableViewController.h"
#import "WeatherAnimationViewController.h"
#import "NSDictionary+weather.h"
#import "NSDictionary+weather_package.h"

// base URL of the test script.
// the URL to an incredibly simple “web service” that I created for you for this tutorial.
// The web service returns weather data in three different formats – JSON, XML, and PLIST. You can take a look at the data it can return by using these URLS:
//    - http://www.raywenderlich.com/demos/weather_sample/weather.php?format=json
//    - http://www.raywenderlich.com/demos/weather_sample/weather.php?format=xml
//    - http://www.raywenderlich.com/demos/weather_sample/weather.php?format=plist (might not show correctly in your browser)
static NSString * const BaseURLString = @"http://www.raywenderlich.com/demos/weather_sample/";

@interface WTTableViewController ()
@property(strong) NSDictionary *weather;
@end

@implementation WTTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.toolbarHidden = NO;

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"WeatherDetailSegue"]){
        UITableViewCell *cell = (UITableViewCell *)sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        
        WeatherAnimationViewController *wac = (WeatherAnimationViewController *)segue.destinationViewController;
        
        NSDictionary *w;
        switch (indexPath.section) {
            case 0: {
                w = self.weather.currentCondition;
                break;
            }
            case 1: {
                w = [self.weather upcomingWeather][indexPath.row];
                break;
            }
            default: {
                break;
            }
        }
        wac.weatherDictionary = w;
    }
}

#pragma mark - Actions

- (IBAction)clear:(id)sender
{
    self.title = @"";
    self.weather = nil;
    [self.tableView reloadData];
}

- (IBAction)jsonTapped:(id)sender
{
  // You first create a string representing the full url from the base URL string. This is then used to create an NSURL object, which is used to make an NSURLRequest.
  NSString *string = [NSString stringWithFormat:@"%@weather.php?format=json", BaseURLString];
  NSURL *url = [NSURL URLWithString:string];
  NSURLRequest *request = [NSURLRequest requestWithURL:url];
  
  // AFHTTPRequestOperation is an all-in-one class for handling HTTP transfers across the network. You tell it that the response should be read as JSON by setting the responseSerializer property to the default JSON serializer. AFNetworking will then take care of parsing the JSON for you.
  AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
  operation.responseSerializer = [AFJSONResponseSerializer serializer];
  
  [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
    
    // The success block runs when (surprise!) the request succeeds. The JSON serializer parses the received data and returns a dictionary in the responseObject variable, which is stored in the weather property.
    self.weather = (NSDictionary *)responseObject;
    self.title = @"JSON Retrieved";
    [self.tableView reloadData];
    
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    
    // The failure block runs if something goes wrong – such as if networking isn’t available. If this happens, you simply display an alert with the error message.
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Retrieving Weather"
                                                        message:[error localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
    [alertView show];
  }];
  
  // You must explicitly tell the operation to “start” (or else nothing will happen)
  [operation start];
}

- (IBAction)plistTapped:(id)sender
{
  
}

- (IBAction)xmlTapped:(id)sender
{
    
}

- (IBAction)clientTapped:(id)sender
{
    
}

- (IBAction)apiTapped:(id)sender
{
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  //The table view will have two sections: the first to display the current weather and the second to display the upcoming weather.
  
  if(!self.weather)
    return 0;
  
  switch (section) {
    case 0: {
      return 1;
    }
    case 1: {
      NSArray *upcomingWeather = [self.weather upcomingWeather];
      return [upcomingWeather count];
    }
    default:
      return 0;
  }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *CellIdentifier = @"WeatherCell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
  
  NSDictionary *daysWeather = nil;
  
  switch (indexPath.section) {
    case 0: {
      daysWeather = [self.weather currentCondition];
      break;
    }
      
    case 1: {
      NSArray *upcomingWeather = [self.weather upcomingWeather];
      daysWeather = upcomingWeather[indexPath.row];
      break;
    }
      
    default:
      break;
  }
  
  cell.textLabel.text = [daysWeather weatherDescription];
  
  // You will add code here later to customize the cell, but it's good for now.
  
  return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
}

@end