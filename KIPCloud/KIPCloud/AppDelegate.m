//
//  AppDelegate.m
//  KIPCloud
//
//  Created by 孔雨露 on 2017/7/4.
//  Copyright © 2017年 孔雨露. All rights reserved.
//

#import "AppDelegate.h"
#import "YLComFun.h"
#import "YLCameraListController.h"
#import "YLEventListController.h"
#import "YLAddCameraController.h"
#import "YLMoreInfoController.h"
#import <AVFoundation/AVFoundation.h>
#import "MyCamera.h"


@interface AppDelegate ()

@property (nonatomic, strong, readonly) YLNavController *navController0;
@property (nonatomic, strong, readonly) YLNavController *navController1;
@property (nonatomic, strong, readonly) YLNavController *navController2;
@property (nonatomic, strong, readonly) YLNavController *navController3;
@property (nonatomic, strong, readonly) YLNavController *navController4;

@property (nonatomic, strong, readonly) YLCameraListController *cameraListVC;
@property (nonatomic, strong, readonly) YLEventListController *eventListVC;
@property (nonatomic, strong, readonly) YLAddCameraController *addCameraVC;
@property (nonatomic, strong, readonly) YLMoreInfoController *moreInfoVC;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [self initSDK];
    [self initUI];
    
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}




- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    switch( self.mOpenUrlCmdStore.cmd ) {
            
        case emShowTabIndexPage: {
            if( 0 <= _mOpenUrlCmdStore.tabIdx && _mOpenUrlCmdStore.tabIdx < 4 ) {
                [_rootViewController setSelectedIndex:_mOpenUrlCmdStore.tabIdx];
                [self urlCommandDone];
            }
        }	break;
        case emAddDeviceByUID: {
            [_rootViewController setSelectedIndex:2];
        }	break;
        case emShowLiveViewByUID: {
            
            int i=0;
            YLGlobal *gGlobalObj = [YLGlobal shareInstance];
            for (Camera *cam in gGlobalObj.cameraArr) {
                if( 0 == [cam.uid compare:[NSString stringWithFormat:@"%s",_mOpenUrlCmdStore.uid]] ) {
                    _mOpenUrlCmdStore.tabIdx = i;
                    break;
                }
                i++;
            }
            [_rootViewController setSelectedIndex:0];
        }	break;
        default:
            break;
            
    }
}

- (void)applicationWillTerminate:(UIApplication *) application
{
    [[YLGlobal shareInstance] disConnectAllCamera];

    
    [MyCamera uninitIOTC];
    [[YLGlobal shareInstance] closeDB];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

#pragma mark - Application Custom URL Schemes

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if (!url) {
        return NO;
    }
    
    NSString *urlString = [[url absoluteString] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    if (!urlString)
        return NO;
    
    NSInteger nPrefix_Len = [@"p2pipcam://com.ipcam.AztechIPCam?" length];
    NSString* strCheck = [urlString substringWithRange:NSMakeRange(0, nPrefix_Len)];
    
    BOOL bIsDiff = [strCheck compare:@"p2pipcam://com.ipcam.AztechIPCam?"/* options:NSCaseInsensitiveSearch*/];
    
    if( bIsDiff )
        return NO;
    
    NSString* strParse = [urlString substringFromIndex:nPrefix_Len];
    NSLog( @">>>>openURL parameter: %@", strParse );
    
    BOOL bContinueTest = TRUE;
    NSRange bingo;
    
    bingo = [strParse rangeOfString:@"tabIdx:" options:NSCaseInsensitiveSearch];
    if( bingo.length > 0 ) {
        NSString* strTabIdx = [strParse substringFromIndex:(bingo.location+bingo.length)];
        NSLog( @"\tstrTabIdx: %@", strTabIdx );
        
        _mOpenUrlCmdStore.cmd = emShowTabIndexPage;
        _mOpenUrlCmdStore.tabIdx = [strTabIdx intValue];
        
        bContinueTest = FALSE;
    }
    
    if( bContinueTest ) {
        bingo = [strParse rangeOfString:@"addDev:" options:NSCaseInsensitiveSearch];
        if( bingo.length > 0 ) {
            NSString* strDevUID = [strParse substringFromIndex:(bingo.location+bingo.length)];
            NSLog( @"\tstrDevUID: %@", strDevUID );
            
            _mOpenUrlCmdStore.cmd = emAddDeviceByUID;
            strncpy( _mOpenUrlCmdStore.uid, [strDevUID UTF8String], 20 );
            _mOpenUrlCmdStore.uid[20] = 0;
            
            bContinueTest = FALSE;
        }
    }
    
    if( bContinueTest ) {
        bingo = [strParse rangeOfString:@"liveView:" options:NSCaseInsensitiveSearch];
        if( bingo.length > 0 ) {
            NSString* strToUID = [strParse substringFromIndex:(bingo.location+bingo.length)];
            NSLog( @"\tstrToUID: %@", strToUID );
            
            _mOpenUrlCmdStore.cmd = emShowLiveViewByUID;
            strncpy( _mOpenUrlCmdStore.uid, [strToUID UTF8String], 20 );
            _mOpenUrlCmdStore.uid[20] = 0;
            
            bContinueTest = FALSE;
        }
    }
    
    return YES;
}

- (void) urlCommandDone
{
    _mOpenUrlCmdStore.cmd = emNoCmd;
}


-(void) initSDK
{
    _mOpenUrlCmdStore.cmd = emNoCmd;
    [MyCamera initIOTC];
    [self initAudioSession];
}

-(void) loadUIData
{
    NSString *appidString = [[NSBundle mainBundle] bundleIdentifier];
    NSArray *arr = [appidString componentsSeparatedByString:@"."];
    if( arr != nil && NSOrderedSame == [(NSString*)[arr objectAtIndex:[arr count]-1] compare:@"2"] ) {
        g_bDiagnostic = TRUE;
    }
    if ([[YLGlobal shareInstance].cameraArr count] == 0)
        [_rootViewController setSelectedIndex:2];

}


- (void) initUI
{

    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    //self.window.backgroundColor = [UIColor blackColor];
    //hide the status bar
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    //[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
    
    self.rootViewController = [[YLTabBarController alloc] init];
    
    _cameraListVC = [[YLCameraListController alloc] init];
    _eventListVC = [[YLEventListController alloc] init];
    _addCameraVC = [[YLAddCameraController alloc] init];
    _addCameraVC.bAddCameraPage = YES;
    _moreInfoVC = [[YLMoreInfoController alloc] init];
  
    
    _navController1 = [[YLNavController alloc] initWithRootViewController:_cameraListVC];
    _navController2 = [[YLNavController alloc] initWithRootViewController:_eventListVC];
    _navController3 = [[YLNavController alloc] initWithRootViewController:_addCameraVC];
    _navController4 = [[YLNavController alloc] initWithRootViewController:_moreInfoVC];

    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version >= 7.0)
    {
        
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:KYL_NavTitleTextColor,NSForegroundColorAttributeName, nil];
        _navController1.navigationBar.tintColor = KYL_NavTitleTextColor;
        [_navController1.navigationBar setTitleTextAttributes:attributes];
        _navController2.navigationBar.tintColor = KYL_NavTitleTextColor;
        [_navController2.navigationBar setTitleTextAttributes:attributes];
        _navController3.navigationBar.tintColor = KYL_NavTitleTextColor;
        [_navController3.navigationBar setTitleTextAttributes:attributes];
        _navController4.navigationBar.tintColor = KYL_NavTitleTextColor;
        [_navController4.navigationBar setTitleTextAttributes:attributes];
        
        //[_navController1.navigationBar setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHexString:@"0xFFFFFF"]] forBarMetrics:UIBarMetricsDefault];
        //设置状态栏字体颜色
        //_navController1.navigationBar.barStyle = UIBarStyleDefault;
        _navController1.navigationBar.barTintColor = KYL_NavBarBgColor;
        _navController2.navigationBar.barTintColor = KYL_NavBarBgColor;
        _navController3.navigationBar.barTintColor = KYL_NavBarBgColor;
        _navController4.navigationBar.barTintColor = KYL_NavBarBgColor;
        
    }
    else
    {
        _navController1.navigationBar.tintColor = KYL_NavTitleTextColor;
        _navController2.navigationBar.tintColor = KYL_NavTitleTextColor;
        _navController3.navigationBar.tintColor = KYL_NavTitleTextColor;
        _navController4.navigationBar.tintColor = KYL_NavTitleTextColor;
    }
    
    UITabBarItem *item1 = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Camera", nil) image:nil tag:0];
    [item1 setFinishedSelectedImage:[UIImage imageNamed:@"camera"]
        withFinishedUnselectedImage:[UIImage imageNamed:@"camera"]];
    self.navController1.tabBarItem = item1;
    
    UITabBarItem *item2 = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Events", nil) image:nil tag:1];
    [item2 setFinishedSelectedImage:[UIImage imageNamed:@"event"]
        withFinishedUnselectedImage:[UIImage imageNamed:@"event"]];
    self.navController2.tabBarItem = item2;
    
    UITabBarItem *item3 = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Add Camera" , nil) image:nil tag:2];
    [item3 setFinishedSelectedImage:[UIImage imageNamed:@"addCamera"]
        withFinishedUnselectedImage:[UIImage imageNamed:@"addCamera"]];
    self.navController3.tabBarItem = item3;
    
    UITabBarItem *item4 = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"App Info", nil) image:nil tag:2];
    [item4 setFinishedSelectedImage:[UIImage imageNamed:@"info"]
        withFinishedUnselectedImage:[UIImage imageNamed:@"info"]];
    self.navController4.tabBarItem = item4;
    
    _rootViewController.viewControllers = [NSArray arrayWithObjects:_navController1, _navController2, _navController3,_navController4, nil];
    
    _navController0 = [[YLNavController alloc] initWithRootViewController:_rootViewController];
    self.window.rootViewController = _navController0;
    _navController0.navigationBar.hidden = YES;
    
    [self loadUIData];
    
    //阻止屏幕锁屏
    [[UIApplication sharedApplication] setIdleTimerDisabled: YES];
    [self.window makeKeyAndVisible];
    
    
}




#pragma mark - TabBarNavigationController Delegate Methods
- (void)tabBarController:(UITabBarController *)tabBarController
 didSelectViewController:(UIViewController *)viewController
{
    if (tabBarController.selectedIndex == 1) {
        [[[[_rootViewController tabBar] items] objectAtIndex:1]
         setBadgeValue:nil];
    }
}




#pragma mark - AudioSession implementations
void interruptionListener(void * inClientData, UInt32 inInterruptionState) {
    
    if (inInterruptionState == kAudioSessionBeginInterruption) {
        
        NSLog(@"AudioSession Begin Interruption");
    }
    else if (inInterruptionState == kAudioSessionEndInterruption) {
        
        NSLog(@"AudioSession End Interruption");
    }
}

- (void)initAudioSession {
    
    OSStatus error = AudioSessionInitialize(NULL, NULL, interruptionListener, (__bridge void *)(self));
    
    if (error) {
        printf("ERROR INITIALIZING AUDIO SESSION! %d/n", (int)error);
    }
}




@end
