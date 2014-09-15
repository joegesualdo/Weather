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
// AFNetworking adds a category to UIImageView that lets you load images asynchronously, meaning the UI will remain responsive while images are downloaded in the background. To take advantage of this, add the category import
#import "UIImageView+AFNetworking.h"

// base URL of the test script.
// the URL to an incredibly simple “web service” that I created for you for this tutorial.
// The web service returns weather data in three different formats – JSON, XML, and PLIST. You can take a look at the data it can return by using these URLS:
//    - http://www.raywenderlich.com/demos/weather_sample/weather.php?format=json
//    - http://www.raywenderlich.com/demos/weather_sample/weather.php?format=xml
//    - http://www.raywenderlich.com/demos/weather_sample/weather.php?format=plist (might not show correctly in your browser)
static NSString * const BaseURLString = @"http://www.raywenderlich.com/demos/weather_sample/";

@interface WTTableViewController ()

@property(strong) NSDictionary *weather;

// These properties will come in handy when you’re parsing the XML.

// current section being parsed
@property(nonatomic, strong) NSMutableDictionary *currentDictionary;
// completed parsed xml response
@property(nonatomic, strong) NSMutableDictionary *xmlWeather;
@property(nonatomic, strong) NSString *elementName;
@property(nonatomic, strong) NSMutableString *outstring;
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

// Notice that this code is almost identical to the JSON version, except for changing the responseSerializer to the default AFPropertyListResponseSerializer to let AFNetworking know that you’re going to be parsing a plist.
- (IBAction)plistTapped:(id)sender
{
  NSString *string = [NSString stringWithFormat:@"%@weather.php?format=plist", BaseURLString];
  NSURL *url = [NSURL URLWithString:string];
  NSURLRequest *request = [NSURLRequest requestWithURL:url];
  
  AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
  
  // Make sure to set the responseSerializer correctly
  operation.responseSerializer = [AFPropertyListResponseSerializer serializer];
  
  [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
    
    self.weather = (NSDictionary *)responseObject;
    self.title = @"PLIST Retrieved";
    [self.tableView reloadData];
    
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Retrieving Weather"
                                                        message:[error localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
    [alertView show];
  }];
  
  [operation start];
}

- (IBAction)xmlTapped:(id)sender
{
  NSString *string = [NSString stringWithFormat:@"%@weather.php?format=xml", BaseURLString];
  NSURL *url = [NSURL URLWithString:string];
  NSURLRequest *request = [NSURLRequest requestWithURL:url];
  
  AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
  
  // Make sure to set the responseSerializer correctly
  operation.responseSerializer = [AFXMLParserResponseSerializer serializer];
  
  [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
    //  The biggest change is that in the success block you don’t get a nice, preprocessed NSDictionary object passed to you. Instead, responseObject is an instance of NSXMLParser, which you will use to do the heavy lifting in parsing the XML.
    NSXMLParser *XMLParser = (NSXMLParser *)responseObject;
    [XMLParser setShouldProcessNamespaces:YES];
    
    // You’ll need to implement a set of delegate methods for NXMLParser to be able to parse the XML. Notice that XMLParser’s delegate is set to self, so you will need to add NSXMLParser’s delegate methods to WTTableViewController to handle the parsing.
     XMLParser.delegate = self;
     [XMLParser parse];
    
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Retrieving Weather"
                                                        message:[error localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
    [alertView show];
    
  }];
  
  [operation start];
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
  
  // ==========================
  // This code will set the image using AFNetworking to load images asynchronously, meaning the UI will remain responsive while images are downloaded in the background.
  
  // UIImageView+AFNetworking makes setImageWithURLRequest: and several other related methods available to you.
  NSURL *url = [NSURL URLWithString:daysWeather.weatherIconURL];
  NSURLRequest *request = [NSURLRequest requestWithURL:url];
  // When the cell is first created, its image view will display the placeholder image until the real image has finished downloading.
  UIImage *placeholderImage = [UIImage imageNamed:@"placeholder"];

  __weak UITableViewCell *weakCell = cell;

  [cell.imageView setImageWithURLRequest:request
            placeholderImage:placeholderImage
                     success:^(NSURLRequest *request, NSHTTPURLResponse *response,
                               UIImage *image) {
                       // Both the success and failure blocks are optional, but if you do provide a success block, you must explicitly set the image property on the image view (or else it won’t be set). If you don’t provide a success block, the image will automatically be set for you.

                         weakCell.imageView.image = image;
                         [weakCell setNeedsLayout];
                     }
                     failure:nil];
  // ==========================
  
  return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
}

#pragma mark - NSXMLParserDelegate methods

// The parser calls this method when it first starts parsing. When this happens, you set self.xmlWeather to a new dictionary, which will hold hold the XML data.
- (void)parserDidStartDocument:(NSXMLParser *)parser
{
  self.xmlWeather = [NSMutableDictionary dictionary];
}

// The parser calls this method when it finds a new element start tag.
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
  // you keep track of the new element’s name as self.elementName
  self.elementName = qName;
  
  // set self.currentDictionary to a new dictionary if the element name represents the start of a new weather forecast.
  if([qName isEqualToString:@"current_condition"] ||
     [qName isEqualToString:@"weather"] ||
     [qName isEqualToString:@"request"]) {
    self.currentDictionary = [NSMutableDictionary dictionary];
  }
  
  // reset outstring as a new mutable string in preparation for new XML to be received related to the element.
  self.outstring = [NSMutableString string];
}

// As the name suggests, the parser calls this method when it finds new characters on an XML element.
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
  if (!self.elementName)
    return;
  
  // You append the new characters to outstring, so they can be processed once the XML tag is closed.
  [self.outstring appendFormat:@"%@", string];
}

// This method is called when an end element tag is encountered. When that happens, you check for a few special tags:
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
  // The current_condition element indicates you have the weather for the current day. You add this directly to the xmlWeather dictionary.
  if ([qName isEqualToString:@"current_condition"] ||
      [qName isEqualToString:@"request"]) {
    self.xmlWeather[qName] = @[self.currentDictionary];
    self.currentDictionary = nil;
  }
  // The weather element means you have the weather for a subsequent day. While there is only one current day, there may be several subsequent days, so you add this weather information to an array.
  else if ([qName isEqualToString:@"weather"]) {
    
    // Initialize the list of weather items if it doesn't exist
    NSMutableArray *array = self.xmlWeather[@"weather"] ?: [NSMutableArray array];
    
    // Add the current weather object
    [array addObject:self.currentDictionary];
    
    // Set the new array to the "weather" key on xmlWeather dictionary
    self.xmlWeather[@"weather"] = array;
    
    self.currentDictionary = nil;
  }
  // The value tag only appears inside other tags, so it’s safe to skip over it.
  else if ([qName isEqualToString:@"value"]) {
    // Ignore value tags, they only appear in the two conditions below
  }
  // The weatherDesc and weatherIconUrl element values need to be boxed inside an array before they can be stored. This way, they will match how the JSON and plist versions of the data are structured exactly.
  else if ([qName isEqualToString:@"weatherDesc"] ||
           [qName isEqualToString:@"weatherIconUrl"]) {
    NSDictionary *dictionary = @{@"value": self.outstring};
    NSArray *array = @[dictionary];
    self.currentDictionary[qName] = array;
  }
  // All other elements can be stored as is.
  else if (qName) {
    self.currentDictionary[qName] = self.outstring;
  }
  
	self.elementName = nil;
}

// The parser calls this method when it reaches the end of the document.
- (void) parserDidEndDocument:(NSXMLParser *)parser
{
  //  At this point, the xmlWeather dictionary that you’ve been building is complete, so the table view can be reloaded.
  // Wrapping xmlWeather inside another NSDictionary might seem redundant, but this ensures the format matches up exactly with the JSON and plist versions. This way, all three data formats can be displayed with the same code!
  self.weather = @{@"data": self.xmlWeather};
  self.title = @"XML Retrieved";
  [self.tableView reloadData];
}

@end