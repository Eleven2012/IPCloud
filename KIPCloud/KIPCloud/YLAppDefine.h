//
//  YLAppDefine.h
//  KIPCloud
//
//  Created by 孔雨露 on 2017/7/6.
//  Copyright © 2017年 孔雨露. All rights reserved.
//


#define KYL_NAV_BAR_BG_IMAGE ("icon_nav_back.png")


// begin modidied by kongyulu at 2013-10-30
#define MAX_CAMERA_LIMIT 8
#define MAX_IMG_BUFFER_SIZE	(1280*720*4)
#define PT_SPEED 8
#define PT_DELAY 1.5
#define ZOOM_MAX_SCALE 5.0
#define ZOOM_MIN_SCALE 1.0
#define degreeToRadians(x) (M_PI * (x) / 180.0)


#ifndef P2PCAMLIVE
#define SHOW_SESSION_MODE
#endif
#define DEF_WAIT4STOPSHOW_TIME	250

typedef enum
{
    YLDirection_None = 0,
    YLDirection_UP = 1,
    YLDirection_DOWN = 2,
    YLDirection_LEFT = 3,
    YLDirection_RIGHT = 4,
} YLDirection;

typedef enum
{
    AUDIO_MODE_OFF          = 0,
    AUDIO_MODE_SPEAKER      = 1,
    AUDIO_MODE_MICROPHONE   = 2,
}ENUM_AUDIO_MODE;

enum open_url_cmd{
    emNoCmd = 0,
    emShowTabIndexPage = 1,
    emAddDeviceByUID,
    emShowLiveViewByUID
};

typedef struct tagOpenUrlCmdStore
{
    enum open_url_cmd cmd;
    int tabIdx;
    char uid[21];
    
}SOPENURLCMDSTORE, *LPSOPENURLCMDSTORE;
// end modidied by kongyulu at 2013-10-30

#define SQLCMD_CREATE_TABLE_DEVICE @"CREATE TABLE IF NOT EXISTS device(id INTEGER PRIMARY KEY AUTOINCREMENT, dev_uid TEXT, dev_nickname TEXT, dev_name TEXT, dev_pwd TEXT, view_acc TEXT, view_pwd TEXT, ask_format_sdcard INTEGER, channel INTEGER, dev_videoQuality INTEGER)"

#define SQLCMD_CREATE_TABLE_SNAPSHOT @"CREATE TABLE IF NOT EXISTS snapshot(id INTEGER PRIMARY KEY AUTOINCREMENT, dev_uid TEXT, file_path TEXT, time REAL)"


#ifdef DEBUG
# define DebugLog(fmt, ...) NSLog((@"\n""[函数名:%s]\n""[行号:%d] \n\n" fmt),  __FUNCTION__, __LINE__, ##__VA_ARGS__);
# define DebugLog2(fmt, ...) NSLog((@"\n[文件名:%s]\n""[函数名:%s]\n""[行号:%d] \n" fmt), __FILE__, __FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
# define DebugLog(...);
#endif

#define RGB(a, b, c) [UIColor colorWithRed:(a / 255.0f) green:(b / 255.0f) blue:(c / 255.0f) alpha:1.0f]
#define RGBA(a, b, c, d) [UIColor colorWithRed:(a / 255.0f) green:(b / 255.0f) blue:(c / 255.0f) alpha:d]







#if defined(APP_ORDER_MontionVizion) //{{-- 方春梅-MontionVizon


//***************************************************************************************************{{
//定义推送的bundle id
#define STR_QUERY_PUBLIC_TOKEN_PASSWD   ("HYQryPwd123")
#define STR_BUNDLE_ID                   ("com.wswy.iSmartViewPro")
//帮助连接
#define  KYL_WEB_LINK_ADDRESS @"http://www.mclview.fr"
#define APP_DownloadURL @"http://itunes.apple.com/app/id871560808?mt=8" //MCL
#define APP_LOOKUP_URL @"http://itunes.apple.com/lookup?id=871560808" //itunes.apple.com/lookup?id=你的应用程序的ID
#define KYL_APPIRATER_APP_ID_GiveScore  @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=871560808"
//{{--tingyun
#define KYL_TINGYUN_KEY "2520b75378d743589d0a277eaa40423a"
// 字体定制
#define kGlobalFontFamilyName @"Helvetica"       // 全局字体名称
#define kGlobalBaseFontSize 14
#define kGlobalTopNavTitleFontSize 14
//定义用户类型字体颜色
#define KYL_UserTypeTextColor [UIColor colorWithRed:0 green:172.0/255.0 blue:200.0/255.0 alpha:1.0]
//定义UISwitch颜色
#define KYL_UISWitchBgColor [UIColor colorWithRed:76.0/255.0 green:217.0/255.0 blue:100.0/255.0 alpha:1.0]
#define KYL_UISWitchBgColor2 [UIColor colorWithRed:76.0/255.0 green:217.0/255.0 blue:100.0/255.0 alpha:1.0]
//定义UIControl颜色
#define KYL_UISegementControlBgColor [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0]
#define KYL_UISegementControlTextColor [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0]
#define KYL_UISegementControlBgColor_Calendar [UIColor colorWithRed:52.0/255.0 green:86.0/255.0 blue:132.0/255.0 alpha:1.0]
#define KYL_UISegementControlTextColor_Calendar  [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0]
//定义按钮颜色
#define KYL_CustomButtonBgColor [UIColor colorWithRed:52.0/255.0 green:86.0/255.0 blue:132.0/255.0 alpha:1.0]
#define KYL_CustomButtonTextColor [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0]
//定义Tabbar按钮字体颜色
#define KYL_TabBarTextColor [UIColor colorWithRed:0.0/255.0 green:118.0/255.0 blue:255.0/255.0 alpha:1.0]
//定义Tabbar背景颜色
#define KYL_TabBarBgColor [UIColor colorWithRed:244.0/255.0 green:241.0/255.0 blue:241.0/255.0 alpha:1.0]
//定义设备状态字体颜色
#define KYL_DeviceStatusTextColor [UIColor colorWithRed:52.0/255.0 green:86.0/255.0 blue:132.0/255.0 alpha:1.0]
//定义导航栏标题字体颜色
#define KYL_NavTitleTextColor [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0]
//定义导航栏按钮字体颜色
#define KYL_NavBarTextColor [UIColor colorWithRed:52.0/255.0 green:86.0/255.0 blue:132.0/255.0 alpha:1.0]
//定义导航栏背景颜色
#define KYL_NavBarBgColor [UIColor colorWithRed:225.0/255.0 green:166.0/255.0 blue:0 alpha:1.0]
//定义View的颜色
#define KYL_ViewBgColor [UIColor colorWithRed:255.0/255.0 green:246.0/255.0 blue:248.0/255.0 alpha:1.0]
//***************************************************************************************************}}


#elif defined(APP_ORDER_IPCloud) //{{-- 公司中性IPCloud

//***************************************************************************************************{{
//定义推送的bundle id
#define STR_QUERY_PUBLIC_TOKEN_PASSWD   ("HYQryPwd123")
#define STR_BUNDLE_ID                   ("com.wswy.iSmartViewPro")
//帮助连接
#define  KYL_WEB_LINK_ADDRESS @"http://www.mclview.fr"
#define APP_DownloadURL @"http://itunes.apple.com/app/id871560808?mt=8" //MCL
#define APP_LOOKUP_URL @"http://itunes.apple.com/lookup?id=871560808" //itunes.apple.com/lookup?id=你的应用程序的ID
#define KYL_APPIRATER_APP_ID_GiveScore  @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=871560808"
//{{--tingyun
#define KYL_TINGYUN_KEY "2520b75378d743589d0a277eaa40423a"
// 字体定制
#define kGlobalFontFamilyName @"Helvetica"       // 全局字体名称
#define kGlobalBaseFontSize 14
#define kGlobalTopNavTitleFontSize 14
//定义用户类型字体颜色
#define KYL_UserTypeTextColor [UIColor colorWithRed:0 green:172.0/255.0 blue:200.0/255.0 alpha:1.0]
//定义UISwitch颜色
#define KYL_UISWitchBgColor [UIColor colorWithRed:76.0/255.0 green:217.0/255.0 blue:100.0/255.0 alpha:1.0]
#define KYL_UISWitchBgColor2 [UIColor colorWithRed:76.0/255.0 green:217.0/255.0 blue:100.0/255.0 alpha:1.0]
//定义UIControl颜色
#define KYL_UISegementControlBgColor [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0]
#define KYL_UISegementControlTextColor [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0]
#define KYL_UISegementControlBgColor_Calendar [UIColor colorWithRed:52.0/255.0 green:86.0/255.0 blue:132.0/255.0 alpha:1.0]
#define KYL_UISegementControlTextColor_Calendar  [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0]
//定义按钮颜色
#define KYL_CustomButtonBgColor [UIColor colorWithRed:52.0/255.0 green:86.0/255.0 blue:132.0/255.0 alpha:1.0]
#define KYL_CustomButtonTextColor [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0]
//定义Tabbar按钮字体颜色
#define KYL_TabBarTextColor [UIColor colorWithRed:0.0/255.0 green:118.0/255.0 blue:255.0/255.0 alpha:1.0]
//定义Tabbar背景颜色
#define KYL_TabBarBgColor [UIColor colorWithRed:244.0/255.0 green:241.0/255.0 blue:241.0/255.0 alpha:1.0]
//定义设备状态字体颜色
#define KYL_DeviceStatusTextColor [UIColor colorWithRed:52.0/255.0 green:86.0/255.0 blue:132.0/255.0 alpha:1.0]
//定义导航栏标题字体颜色
#define KYL_NavTitleTextColor [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0]
//定义导航栏按钮字体颜色
#define KYL_NavBarTextColor [UIColor colorWithRed:52.0/255.0 green:86.0/255.0 blue:132.0/255.0 alpha:1.0]
//定义导航栏背景颜色
#define KYL_NavBarBgColor [UIColor colorWithRed:0.0/255.0 green:99.0/255.0 blue:176.0/255.0 alpha:1.0]
//定义View的颜色
#define KYL_ViewBgColor [UIColor colorWithRed:255.0/255.0 green:246.0/255.0 blue:248.0/255.0 alpha:1.0]
//***************************************************************************************************}}


#else

//***************************************************************************************************{{
//定义推送的bundle id
#define STR_QUERY_PUBLIC_TOKEN_PASSWD   ("HYQryPwd123")
#define STR_BUNDLE_ID                   ("com.wswy.iSmartViewPro")
//帮助连接
#define  KYL_WEB_LINK_ADDRESS @"http://www.mclview.fr"
#define APP_DownloadURL @"http://itunes.apple.com/app/id871560808?mt=8" //MCL
#define APP_LOOKUP_URL @"http://itunes.apple.com/lookup?id=871560808" //itunes.apple.com/lookup?id=你的应用程序的ID
#define KYL_APPIRATER_APP_ID_GiveScore  @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=871560808"
//{{--tingyun
#define KYL_TINGYUN_KEY "2520b75378d743589d0a277eaa40423a"
// 字体定制
#define kGlobalFontFamilyName @"Helvetica"       // 全局字体名称
#define kGlobalBaseFontSize 14
#define kGlobalTopNavTitleFontSize 14
//定义用户类型字体颜色
#define KYL_UserTypeTextColor [UIColor colorWithRed:0 green:172.0/255.0 blue:200.0/255.0 alpha:1.0]
//定义UISwitch颜色
#define KYL_UISWitchBgColor [UIColor colorWithRed:76.0/255.0 green:217.0/255.0 blue:100.0/255.0 alpha:1.0]
#define KYL_UISWitchBgColor2 [UIColor colorWithRed:76.0/255.0 green:217.0/255.0 blue:100.0/255.0 alpha:1.0]
//定义UIControl颜色
#define KYL_UISegementControlBgColor [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0]
#define KYL_UISegementControlTextColor [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0]
#define KYL_UISegementControlBgColor_Calendar [UIColor colorWithRed:52.0/255.0 green:86.0/255.0 blue:132.0/255.0 alpha:1.0]
#define KYL_UISegementControlTextColor_Calendar  [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0]
//定义按钮颜色
#define KYL_CustomButtonBgColor [UIColor colorWithRed:52.0/255.0 green:86.0/255.0 blue:132.0/255.0 alpha:1.0]
#define KYL_CustomButtonTextColor [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0]
//定义Tabbar按钮字体颜色
#define KYL_TabBarTextColor [UIColor colorWithRed:0.0/255.0 green:118.0/255.0 blue:255.0/255.0 alpha:1.0]
//定义Tabbar背景颜色
#define KYL_TabBarBgColor [UIColor colorWithRed:244.0/255.0 green:241.0/255.0 blue:241.0/255.0 alpha:1.0]
//定义设备状态字体颜色
#define KYL_DeviceStatusTextColor [UIColor colorWithRed:52.0/255.0 green:86.0/255.0 blue:132.0/255.0 alpha:1.0]
//定义导航栏标题字体颜色
#define KYL_NavTitleTextColor [UIColor colorWithRed:0.0/255.0 green:25.0/255.0 blue:25.0/255.0 alpha:1.0]
//定义导航栏按钮字体颜色
#define KYL_NavBarTextColor [UIColor colorWithRed:52.0/255.0 green:86.0/255.0 blue:132.0/255.0 alpha:1.0]
//定义导航栏背景颜色
#define KYL_NavBarBgColor [UIColor colorWithRed:0.0/255.0 green:147.0/255.0 blue:220.0 alpha:1.0]
//定义View的颜色
#define KYL_ViewBgColor [UIColor colorWithRed:255.0/255.0 green:246.0/255.0 blue:248.0/255.0 alpha:1.0]
//***************************************************************************************************}}


#endif

