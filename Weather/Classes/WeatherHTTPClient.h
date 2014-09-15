//
//  WeatherHTTPClient.h
//  Weather
//
//  Created by Joe Gesualdo on 9/15/14.
//  Copyright (c) 2014 Scott Sherwood. All rights reserved.
//

// What is this class?
// You want the class to do three things:
//    1) perform HTTP requests
//    2) call back to a delegate when the new weather data is available
//    3) and use the user’s physical location to get accurate weather.

// Here are two guidelines on AFHTTPSessionManager best practices:
//    1) Create a subclass for each web service. For example, if you’re writing a social network aggregator, you might want one subclass for Twitter, one for Facebook, another for Instragram and so on.
//    2) In each AFHTTPSessionManager subclass, create a class method that returns a shared singleton instance. This saves resources and eliminates the need to allocate and spin up new objects.
#import "AFHTTPSessionManager.h"

@protocol WeatherHTTPClientDelegate;

@interface WeatherHTTPClient : AFHTTPSessionManager
@property (nonatomic, weak) id<WeatherHTTPClientDelegate>delegate;

+ (WeatherHTTPClient *)sharedWeatherHTTPClient;
- (instancetype)initWithBaseURL:(NSURL *)url;
- (void)updateWeatherAtLocation:(CLLocation *)location forNumberOfDays:(NSUInteger)number;

@end

@protocol WeatherHTTPClientDelegate <NSObject>
@optional
-(void)weatherHTTPClient:(WeatherHTTPClient *)client didUpdateWithWeather:(id)weather;
-(void)weatherHTTPClient:(WeatherHTTPClient *)client didFailWithError:(NSError *)error;
@end
