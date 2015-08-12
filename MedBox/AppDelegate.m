//
//  AppDelegate.m
//  MedBox
//
//  Created by Athul Sai on 17/07/15.
//  Copyright (c) 2015 Incture Technologies. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "DetailViewController.h"
#import "Reminder.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // None of the code should even be compiled unless the Base SDK is iOS 8.0 or later
    #if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    }
    
    #endif
    
    UILocalNotification *notification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (notification)
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self openDetailForReminderId:notification.userInfo[kMedUserInfo]];
        });
    }

    return YES;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    
   UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateActive) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Medicine Alert"
                                                        message:notification.alertBody
                                                       delegate:self cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    } else {
        [self openDetailForReminderId:notification.userInfo[kMedUserInfo]];
    }
    
    // Request to reload table view data
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLocalNotifReceived object:self];
}

- (void)openDetailForReminderId:(NSString *)remId
{
    NSArray *remAsPropertyLists = [[NSUserDefaults standardUserDefaults]arrayForKey:MED_OBJECTS_KEY];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.medId = %@", remId];
    NSArray *filteredArray = [remAsPropertyLists filteredArrayUsingPredicate:predicate];
    if (filteredArray.count)
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        DetailViewController *detailController = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([DetailViewController class])];
        NSDictionary *remDict = filteredArray.firstObject;
        detailController.remObject = [[Reminder alloc] initWithData:remDict];
        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:detailController];
        //[self.window.rootViewController presentViewController:nc animated:NO completion:nil];
        UIViewController *activeController = [UIApplication sharedApplication].keyWindow.rootViewController;
        if ([activeController isKindOfClass:[UINavigationController class]])
        {
            activeController = [(UINavigationController*) activeController visibleViewController];
        }
        else if (activeController.presentedViewController)
        {
            activeController = activeController.presentedViewController;
        }
        
        // Check if activeController has intended reminder
        BOOL isReminderAlreadyShown = NO;
        if ([activeController isKindOfClass:[DetailViewController class]])
        {
            DetailViewController *dvc = (DetailViewController *)activeController;
            isReminderAlreadyShown = [dvc.remObject.remId isEqualToString:remId];
        }
        
        if (!isReminderAlreadyShown)
            [activeController presentViewController:nc animated:YES completion:nil];
    }
}

/*- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void (^)())completionHandler
{
    UINavigationController *nc = self.window.rootViewController;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@", [nc topViewController]]
                                                    message:notification.alertBody
                                                   delegate:self cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}*/

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
