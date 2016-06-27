//
//  AppDelegate.m
//  JSPatchTest
//
//  Created by hoomsun on 16/6/27.
//  Copyright © 2016年 njm. All rights reserved.
//

#import "AppDelegate.h"
#import <JSPatch/JSPatch.h>
#import "ViewController.h"

const static NSString *jsAppKey = @"you-appkey";


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //    [self initJSPatch];
    [JSPatch testScriptInBundle];
    
    
    [self initVC];
    return YES;
}

- (void)initJSPatch
{
    NSString  *_userId = @"10010";
    NSString  *_loc = @"sh";
    NSString  *_sexual = @"male";
    
    [JSPatch setupLogger:^(NSString *msg) {
        //msg 是 JSPatch log 字符串，用你自定义的logger打出
        NSLog(@"%@", msg);
    }];
    [JSPatch startWithAppKey:jsAppKey];
    //获取在线参数
    [JSPatch updateConfigWithAppKey:jsAppKey];
    [JSPatch setupConfigInterval:30000];
    [JSPatch setupUpdatedConfigCallback:^(NSDictionary *configs, NSError *error) {
        NSLog(@"====config-callback:%@ %@", configs, error);
    }];
    NSDictionary *params = [JSPatch getConfigParams];
    NSLog(@"====parmas:%@",params);
    /*
     自定义RSA密钥
     终端执行 openssl，再执行以下三句命令，生成 PKCS8 格式的 RSA 公私钥，执行过程中提示输入密码，密码为空（直接回车）就行
     openssl >
     genrsa -out rsa_private_key.pem 1024
     pkcs8 -topk8 -inform PEM -in rsa_private_key.pem -outform PEM –nocrypt
     rsa -in rsa_private_key.pem -pubout -out rsa_public_key.pem
     执行的目录下就有了 rsa_private_key.pem 和 rsa_public_key.pem 这两个文件。这里生成了长度为 1024 的私钥，长度可选 1024 / 2048 / 3072 / 4096
     Public Key 以字符串的方式传入，注意换行处要手动加换行符\n
     */
    //    [JSPatch setupRSAPublicKey:@"-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEApgeqKYKPVFk1dk2JGrKv\n.......----END PUBLIC KEY-----"];
    //    +setupDevelopment
    //条件下发 和 灰度下发
    [JSPatch setupUserData:@{
                             @"userId":_userId,
                             @"location":_loc,
                             @"sex":_sexual
                             }];
    //开始同步脚本
    [JSPatch sync];
    
    
    //jspatch callback
    /*
     //JSPatch 执行过程中的事件回调，在以下事件发生时会调用传入的 block：
     typedef NS_ENUM(NSInteger, JPCallbackType){
     JPCallbackTypeUnknow        = 0,
     JPCallbackTypeRunScript     = 1,    //执行脚本
     JPCallbackTypeUpdate        = 2,    //脚本有更新
     JPCallbackTypeUpdateDone    = 3,    //已拉取新脚本
     JPCallbackTypeCondition     = 4,    //条件下发
     JPCallbackTypeGray          = 5,    //灰度下发
     };
     */
    [JSPatch setupCallback:^(JPCallbackType type, NSDictionary *data, NSError *error) {
        switch (type) {
            case JPCallbackTypeUpdate: {
                NSLog(@"updated %@ %@", data, error);
                break;
            }
            case JPCallbackTypeRunScript: {
                NSLog(@"run script %@ %@", data, error);
                break;
            }
            default:
                break;
        }
    }];
}

- (void)initVC
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor blackColor];
    ViewController *mVC = [[ViewController alloc] init];
    self.window.rootViewController = mVC;
    
    [self.window makeKeyAndVisible];
}

/*
 //===JSPatch地址：https://github.com/bang590/JSPatch/blob/master/README-CN.md ====
 
 
 // ====== js端基础用法 ======
 
 // 调用require引入要使用的OC类
 require('UIView, UIColor, UISlider, NSIndexPath')
 
 // 调用类方法
 var redColor = UIColor.redColor();
 
 // 调用实例方法
 var view = UIView.alloc().init();
 view.setNeedsLayout();
 
 // set proerty
 view.setBackgroundColor(redColor);
 
 // get property
 var bgColor = view.backgroundColor();
 
 // 多参数方法名用'_'隔开：
 // OC：NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
 var indexPath = NSIndexPath.indexPathForRow_inSection(0, 1);
 
 // 方法名包含下划线'_'，js用双下划线表示
 // OC: [JPObject _privateMethod];
 JPObject.__privateMethod()
 
 // 如果要把 `NSArray` / `NSString` / `NSDictionary` 转为对应的 JS 类型，使用 `.toJS()` 接口.
 var arr = require('NSMutableArray').alloc().init()
 arr.addObject("JS")
 jsArr = arr.toJS()
 console.log(jsArr.push("Patch").join(''))  //output: JSPatch
 
 // 在JS用字典的方式表示 CGRect / CGSize / CGPoint / NSRange
 var view = UIView.alloc().initWithFrame({x:20, y:20, width:100, height:100});
 var x = view.bounds().x;
 
 // block 从 JavaScript 传入 Objective-C 时，需要写上每个参数的类型。
 // OC Method: + (void)request:(void(^)(NSString *content, BOOL success))callback
 require('JPObject').request(block("NSString *, BOOL", function(ctn, succ) {
 if (succ) log(ctn)
 }));
 
 // GCD
 dispatch_after(function(1.0, function(){
 // do something
 }))
 dispatch_async_main(function(){
 // do something
 })
 
 // ====== 类/替换方法 =========
 // JS
 defineClass("JPTableViewController", {
 // instance method definitions
 tableView_didSelectRowAtIndexPath: function(tableView, indexPath) {
 var row = indexPath.row()
 if (self.dataSource().count() > row) {  //fix the out of bound bug here
 var content = self.dataSource().objectAtIndex(row);
 var ctrl = JPViewController.alloc().initWithContent(content);
 self.navigationController().pushViewController(ctrl);
 }
 },
 
 dataSource: function() {
 // get the original method by adding prefix 'ORIG'
 var data = self.ORIGdataSource().toJS();
 return data.push('Good!');
 }
 }, {})
 
 
 
 */



- (void)applicationDidBecomeActive:(UIApplication *)application {
    //    [JSPatch sync];
}

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

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
