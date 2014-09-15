//
//  WeatherHTTPClient.m
//  Weather
//
//  Created by Joe Gesualdo on 9/15/14.
//  Copyright (c) 2014 Scott Sherwood. All rights reserved.
//

#import "WeatherHTTPClient.h"

// Set this to your World Weather Online API Key
static NSString * const WorldWeatherOnlineAPIKey = @"72454381eaf7355174caaa19247f335fa80936c2";

static NSString * const WorldWeatherOnlineURLString = @"http://api.worldweatheronline.com/free/v1/";

@implementation WeatherHTTPClient

// The sharedWeatherHTTPClient method uses Grand Central Dispatch to ensure the shared singleton object is only allocated once.
+ (WeatherHTTPClient *)sharedWeatherHTTPClient
{
  static WeatherHTTPClient *_sharedWeatherHTTPClient = nil;
  
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _sharedWeatherHTTPClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:WorldWeatherOnlineURLString]];
  });
  
  return _sharedWeatherHTTPClient;
}

//You initialize the object with a base URL and set it up to request and expect JSON responses from the web service.
- (instancetype)initWithBaseURL:(NSURL *)url
{
  self = [super initWithBaseURL:url];
  
  if (self) {
    self.responseSerializer = [AFJSONResponseSerializer serializer];
    self.requestSerializer = [AFJSONRequestSerializer serializer];
  }
  
  return self;
}

// This method calls out to World Weather Online to get the weather for a particular location.
- (void)updateWeatherAtLocation:(CLLocation *)location forNumberOfDays:(NSUInteger)number
{
  NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
  
  parameters[@"num_of_days"] = @(number);
  parameters[@"q"] = [NSString stringWithFormat:@"%f,%f",location.coordinate.latitude,location.coordinate.longitude];
  parameters[@"format"] = @"json";
  parameters[@"key"] = WorldWeatherOnlineAPIKey;
  
  [self GET:@"weather.ashx" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
    // Once the object has loaded the weather data, it needs some way to communicate that data back to whoever’s interested. Thanks to the WeatherHTTPClientDelegate protocol and its delegate methods, the success and failure blocks in the above code can notify a controller that the weather has been updated for a given location. That way, the controller can update what it is displaying.
    if ([self.delegate respondsToSelector:@selector(weatherHTTPClient:didUpdateWithWeather:)]) {
      [self.delegate weatherHTTPClient:self didUpdateWithWeather:responseObject];
    }
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    if ([self.delegate respondsToSelector:@selector(weatherHTTPClient:didFailWithError:)]) {
      [self.delegate weatherHTTPClient:self didFailWithError:error];
    }
  }];
}

@end
