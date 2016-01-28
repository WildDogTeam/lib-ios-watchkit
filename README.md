

## 用Wilddog开发WatchKit

我们很容易用 Wilddog 开发 WatchKit app。这个指南会提供 WatchKit 的基本概述和引导你如何将 Wilddog 应用到你的 WatchKit app 的过程。

#### 创建一个新的 Watch App

打开 Xcode，建立一个新工程。选择 iOS > Application > Single View Application。工程建立完成后，点击菜单栏 File > New > Target > Apple Watch。在 Apple Watch 栏中选中 WatchKit App，点击 Next > Finish > Activate完成新建工程操作。

**创建一个 WatchKit App Extension**
                    
[创建一个 WatchKit App Extension 视频实例](https://cdn.wilddog.com/console/video/create-watchapp-extension.mp4)

#### Wilddog Kit 引入工程

1、下载 SDK。  
2、把 Wilddog.Framework 拖到工程目录中。  
3、选中 Copy items if needed 、Create Groups，在 Add to targets中勾选 WatchKit Extension 和 WatchKit App ，点击 Finish。  
4、点击工程文件 -> TARGETS -> General，在 Linked Frameworks and Libraries 选项中点击 '+'，将 JavaScriptCore.framework 加入列表中。  
5、同样，点击工程文件 -> TARGETS -> 点击 WatchKit Extension -> General，在 Linked Frameworks and Libraries 选项中点击 '+'，将 JavaScriptCore.framework 加入列表中。

[Wilddog Kit 引入工程视频实例](https://cdn.wilddog.com/console/video/import-wilddogsdk.mp4)

#### Watch App 工程

Watch App 主要有三个部分：Host app,  WatchKit Extension 和 WatchApp。

**Host app**

Host app 是该项目的主要的应用程序。这是用户用 iOS 设备启动应用程序。

**WatchKit Extension**

WatchKit Extension 是一个在运行 iOS 设备的应用程序扩展。截至 watchOS 1.0，Watch App 的代码运行在 iOS 设备上，而不是 Apple Watch 上。

**WatchApp**

WatchApp 工程包含 Watch App 的 interface。这是 Watch App 运行在 Apple Watch 的唯一部分。


#### 创建 Interface

让我们建立一个简单的界面。打开在 WatchKit app 下的`Interface.storyboard`。在`Interface.storyboard`中添加一个 label 和 button。

[创建 Interface 视频实例](https://cdn.wilddog.com/console/video/create-the-interface.mp4)

在 WatchKit Extension 下的`InterfaceController`类中，添加 outlet 和 action。如：

Objective-C

```
@interface InterfaceController()
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *labelUpdate;
@end

@implementation InterfaceController
- (IBAction)updateButtonDidTouch {

}
@end

```

Swift

```
@IBOutlet weak var awesomeLabel: WKInterfaceLabel!
@IBAction func updateButtonIsTouched() {

}

```

[outlet 和 action 视频实例](https://cdn.wilddog.com/console/video/wktable-setup.mp4)


#### 创建一个 Wilddog 引用

在 WatchKit Extension 中，打开`InterfaceController`，加入 Wilddog  引用。

Objective-C

```
#import "InterfaceController.h"
#import <Wilddog/Wilddog.h>

@interface InterfaceController()

// reference property
@property (strong, nonatomic) Wilddog *ref;

// Outlets
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *labelUpdate;

@end

```

Swift

```
class InterfaceController: WKInterfaceController {

  // reference property
  var ref: Wilddog!

  // Outlets
  @IBOutlet weak var awesomeLabel: WKInterfaceLabel!

}

```

`WKInterfaceController`生命周期都有一套方法，在这里我们可以初始化一个引用，同步数据，并移除同步事件。使用 `awakeWithContext`函数，我们可以初始化上面创建的引用。

#### WKInterfaceController 生命周期

这儿我们将介绍如何将 Wilddog 应用到你的 app 中的每一个生命周期阶段。职能序列被称为一个`WKInterfaceController`过程通过它的生命周期。

**awakeWithContext**

当`WKInterfaceController`已加载，`awakeWithContext` 方法将被调用。因为控制器被加载时，这个方法才调用，所以，这个方法是初始化 Wilddog 引用的最佳地方。

Objective-C

```
- (void)awakeWithContext:(id)context {
  [super awakeWithContext:context];
  self.ref = [[Wilddog alloc] initWithUrl:@"https://<your-wilddog-app>.wilddogio.com/updates"];
}

```

Swift

```
override func awakeWithContext(context: AnyObject?) {
  super.awakeWithContext(context)
  ref = Wilddog(url: "https://<your-wilddog-app>.wilddogio.com/updates")
}

```

**willActivate**

当视图出现在屏幕上，`willActivate`方法将被调用。由于这个方法是视图将要显示时，所以这个地方最适合建立 Wilddog 引用。

Objective-C

```
- (void)willActivate {
  [super willActivate];
  [self.ref observeEventType:WEventTypeChildAdded withBlock:^(WDataSnapshot *snapshot) {
    NSLog(@"%@", snapshot.value);
  }];
}

```

Swift

```
override func willActivate() {
  super.willActivate()
  ref.observeEventType(.ChildAdded, withBlock: { (snapshot: WDataSnapshot!) in
    println(snapshot.value)
  })
}

```

**didDeactivate**

当视图在屏幕上消失时，`didDeactivate`函数被调用。这个地方比较适合移除 Wilddog 的事件监听。

Objective-C

```
- (void)didDeactivate {
  [super didDeactivate];
  [self.ref removeAllObservers];
}

```

Swift

```
override func didDeactivate() {
  super.didDeactivate()
  ref.removeAllObservers()
}

```

#### 保存数据

当用户每次点击该按钮时，我们可以存储一个新的时间戳。

Objective-C

```
- (IBAction)updateButtonDidTouch {
  [[self.ref childByAutoId]setValue:kWilddogServerValueTimestamp];
}

```

Swift

```
@IBAction func updateDidTouch() {
  ref.childByAutoId().setValue(kWilddogServerValueTimestamp)
}

```

## 同步数据

在`willActivate`方法中，我们可以用`ref`引用去同步数据。

Objective-C

```
- (void)willActivate {
  [super willActivate];
  [self.ref observeEventType:WEventTypeChildAdded withBlock:^(WDataSnapshot *snapshot) {

    if ([snapshot exists]) {
      [self.labelUpdate setText:[snapshot.value stringValue]];
    } else {
      [self.labelUpdate setText:@"No update"];
    }

  }];
}
```

Swift

```
override func willActivate() {
  super.willActivate()

  ref.observeEventType(.ChildAdded, withBlock: { (snap: WDataSnapshot!) -> Void in

    if snap.exists() {
      self.labelUpdate.setText(snap.value as? String)
    } else {
      self.labelUpdate.setText("No update")
    }

  })
}

```

为了确保在屏幕消失后不同步数据，我们需要在didDeactivate方法中删除所有的监听者。

Objective-C

```
- (void)didDeactivate {
  [super didDeactivate];
  [self.ref removeAllObservers];
}

```

Swift

```
override func didDeactivate() {
  super.didDeactivate()
  ref.removeAllObservers()
}

```

#### 运行模拟器

要在模拟器运行 WatchKit app，设置 scheme 为 WatchKit app，点击 run。运行 Apple Watch 模拟器同时，iPhone/iPad 模拟器也会被加载。

模拟器运行完成后，点击 update 按钮。我们的lable将被更新为时间戳字样，Wilddog数据库中数据也被实时更新。

如果没有看到Apple Watch模拟器，可以做如下设置：

打开模拟器 > 选择 Hardware > External Displays > Apple Watch 38mm/42mm

#### 创建 WKTableInterface

WatchKit 提供了一个类似于`UITableView`的表格控件，它是`WKTableInterface`。

[创建 WKTableInterface 视频实例](https://cdn.wilddog.com/console/video/wktable-model-setup.mp4)

使用`Interface.storyboard`拖一个`table`到视图。每个`table`由`row`组成。对于这个`table`的`row`，我们将它起名为`TableRow`。


[创建 tableRow 视频实例](https://cdn.wilddog.com/console/video/setup-outlets-actions.mp4)



Objective-C

```
// TableRow.h
#import <Foundation/Foundation.h>
#import <WatchKit/WatchKit.h>

@interface TableRow : NSObject
@end

// TableRow.m
#import "TableRow.h"
@interface TableRow()
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *labelUpdate;
@end

@implementation TableRow

@end

```

Swift

```
//In the WatchKit Extension target
import Foundation
import WatchKit

class TableRow : NSObject {
  @IBOutlet weak var labelUpdate: WKInterfaceLabel!
}

```

该model类必须与`Interface.storyboard`的`row`关联。

为了访问在视图上的table interface，我们创建一个`InterfaceController`。 

Objective-C

```
// inside the InterfaceController.m interface
@property (weak, nonatomic) IBOutlet WKInterfaceTable *table;

```

Swift

```
// inside the InterfaceController class
@IBOutlet weak var table: WKInterfaceTable!

```

#### 更新 WKTableInterface

为了将数据更新到WKTableInterface，我们使用.ChildAdded，.ChildRemoved和.ChildChanged事件从Wilddog数据库更新数据。得到数据后，我们将返回一个盛有WDataSnapshot对象的数组。

Objective-C

```
@property (strong, nonatomic) Wilddog *ref;
@property (strong, nonatomic) NSMutableArray *updates;

```

Swift

```
var ref: Wilddog!
var updates: [WDataSnapshot]!

```

在`awakeWithContext`方法中初始化数组。

Objective-C

```
- (void)awakeWithContext:(id)context {
  [super awakeWithContext:context];
  self.ref = [[Wilddog alloc] initWithUrl:@"https://<your-wilddog-app>.wilddogio.com/updates"];
  // Initialize the array
  self.updates = [[NSMutableArray alloc] init];
}

```

Swift

```
override func awakeWithContext(context: AnyObject?) {
  super.awakeWithContext(context)
  ref = Wilddog(url: "https://<your-wilddog-app>.wilddogio.com/updates")
  updates = [WDataSnapshot]()
}

```

在`willActivate`方法中添加监听者：

**.ChildAdded**

增加一个`.ChildAdded`观察者，监听最近增加的数据快照。

Objective-C

```
// Listen for children added to add new rows to the table
[self.ref observeEventType:WEventTypeChildAdded withBlock:^(WDataSnapshot *snapshot) {

  // Add to the local array of snapshots
  [self.updates addObject:snapshot];

  // Create the index for the NSIndexSet
  NSUInteger index = self.updates.count - 1;
  NSIndexSet *indexSet = [[NSIndexSet alloc] initWithIndex:index];

  // Insert the row into the table
  [self.table insertRowsAtIndexes:indexSet withRowType:@"TableRow"];

  // Set up the row, check for string and number in snapshot.value
  TableRow *row = [self.table rowControllerAtIndex:index];
  if ([snapshot.value isKindOfClass:[NSNumber class]]) {
    NSNumber *numberSnap = snapshot.value;
    [row.labelUpdate setText:[numberSnap stringValue]];
  } else if ([snapshot.value isKindOfClass:[NSString class]]){
    NSString *stringSnap = snapshot.value;
    [row.labelUpdate setText:stringSnap];
  }

}];

```

Swift

```
// Listen for children added to add new rows to the table
ref.observeEventType(.ChildAdded, withBlock: { [unowned self] (snapshot: WDataSnapshot!) -> Void in

  // Add to the local array of snapshots
  self.updates.append(snapshot)

  // Create the index for the NSIndexSet
  var index = self.updates.count - 1

  // Insert the row into the table
  self.table.insertRowsAtIndexes(NSIndexSet(index: index), withRowType: "TableRow")

  // Set up the row
  if let row = self.table.rowControllerAtIndex(index) as? TableRow {
    row.labelUpdate.setText(snapshot.value.description)
  }
})

```

**.ChildRemoved**

添加一个`.ChildRemoved`观察者，监听最近被移除的数据快照。我们先创建一个辅助的`findIndexOfSnapshotFromArrayByKey`方法：

Objective-C

```
// Find a snapshot by its key
- (int)findIndexOfSnapshotFromArrayByKey:(NSMutableArray *)array :(NSString *) key {
  for (int i=0; i < array.count; i++) {
    id item = array[i];
    if ([item isKindOfClass:[WDataSnapshot class]]) {
      WDataSnapshot *snapshot = item;
      if ([snapshot.key isEqualToString: key]) {
        return i;
      }
    }
  }
  return -1;
}

```

Swift

```
// Find a snapshot by its key
func findIndexOfSnapshotFromArrayByKey(array: [WDataSnapshot!], key: String) -> Int? {
  for (index, item) in enumerate(array) {
    let snapshot = item as WDataSnapshot;
    if snapshot.key == key {
      return index
    }
  }
  return nil;
}

```

在`willActivate`方法中添加下面的监听者:

Objective-C

```
// Listen for children removed to remove rows from the table
[self.ref observeEventType:WEventTypeChildRemoved withBlock:^(WDataSnapshot *snapshot) {

  // Find the index of the item being removed in the local array
  int index = [self findIndexOfSnapshotFromArrayByKey:self.updates : snapshot.key];

  // Create the index for the NSIndexSet
  NSIndexSet *indexSet = [[NSIndexSet alloc] initWithIndex:index];

  // Remove from the local array and from the table
  [self.updates removeObjectAtIndex:index];
  [self.table removeRowsAtIndexes:indexSet];

}];

```

Swift

```
// Listen for children removed to remove rows from the table
ref.observeEventType(.ChildRemoved, withBlock: { [unowned self] (snapshot: WDataSnapshot!) in

  // Find the index of the item being removed in the local array
  if let indexToRemove = self.findIndexOfSnapshotFromArrayByKey(self.updates, keysnapshot.key) {

    // Remove from the local array and from the table
    self.updates.removeAtIndex(indexToRemove)
    self.table.removeRowsAtIndexes(NSIndexSet(index: indexToRemove))
  }

})

```

**.ChildChanged**

添加一个`.ChildChanged`监听者，监听已变化的数据快照：

Objective-C

```
// Listen for children whose values have changed and re-render the row
[self.ref observeEventType:WEventTypeChildChanged withBlock:^(WDataSnapshot *snapshot) {

  // Find the index of the item that has changed
  int indexToChange = [self findIndexOfSnapshotFromArrayByKey:self.updates : snapshot.key];

  // Create the index for the NSIndexSet
  NSIndexSet *indexSet = [[NSIndexSet alloc] initWithIndex:indexToChange];

  // Replace the old snapshot with the new one
  self.updates[indexToChange] = snapshot;

  // Remove the old row
  [self.table removeRowsAtIndexes:indexSet];

  // Insert the new row
  [self.table insertRowsAtIndexes:indexSet withRowType:@"TableRow"];

  // Set up the row, check for string and number in snapshot.value
  TableRow *row = [self.table rowControllerAtIndex:indexToChange];
  if ([snapshot.value isKindOfClass:[NSNumber class]]) {
    NSNumber *numberSnap = snapshot.value;
    [row.labelUpdate setText:[numberSnap stringValue]];
  } else if ([snapshot.value isKindOfClass:[NSString class]]){
    NSString *stringSnap = snapshot.value;
    [row.labelUpdate setText:stringSnap];
  }

}];

```

Swift

```
// Listen for children whose values have changed and re-render the row
ref.observeEventType(.ChildChanged, withBlock: { [unowned self] (snapshot: WDataSnapshot!) in

  // Find the index of the item that has changed
  if let indexToChange = self.findIndexOfSnapshotFromArrayByKey(self.updates, key: snapshot.key) {

    // Replace the old snapshot with the new one
    self.updates[indexToChange] = snapshot

    // Remove the old row
    self.table.removeRowsAtIndexes(NSIndexSet(index: indexToChange))

    // Insert the new row
    self.table.insertRowsAtIndexes(NSIndexSet(index: indexToChange), withRowType: "TableRow")

    // Set up the row
    if let row = self.table.rowControllerAtIndex(indexToChange) as? TableRow {
      row.labelUpdate.setText(snapshot.value.description)
    }
  }

})

```

#### 用户认证

iOS App Extensions，和 Watch Apps 一样，都是单独的 bundle 。我们可以在`NSUserDefaults`中存储用户的认证 token。调用`authWithCustomToken`方法去用户认证。

#### 启用App Groups

[启用App Groups 视频实例](https://cdn.wilddog.com/console/video/configure-app-groups.mp4)

#### 保存认证token

在 host app 中，用户认证之后，存储用户的 [Wilddog auth token](https://z.wilddog.com/ios/guide/7) 。这是在`UIViewController`中处理登录的常规方法。

Objective-C

```
Wilddog *ref = [[Wilddog alloc] initWithUrl:@"https://<your-wilddog-app>.wilddogio.com/"];
NSUserDefaults *defaults = [[NSUserDefaults alloc]initWithSuiteName:@"group.username.SuiteName"];

[ref observeAuthEventWithBlock:^(WAuthData *authData) {
  if (authData) {
    [defaults setObject:authData.token forKey:@"WAuthDataToken"];
    [defaults synchronize];
  }
}];

```

Swift

```
let defaults = NSUserDefaults(suiteName: "group.username.SuiteName")!
ref.observeAuthEventWithBlock { [unowned self] (authData: WAuthData!) in
  if authData != nil {
    defaults.setObject(authData.token, forKey: "WAuthDataToken")
    defaults.synchronize()
  }
}

```

#### 认证 WatchKit Extension 用户

既然 auth token 已经在上一步中存储，在 WatchKit Extension 中就可以从`NSUserDefaults`中取出 token。

在 `InterfaceController` 控制器的 `awakeWithContext` 方法中添加以下代码：

Objective-C

```
- (void)awakeWithContext:(id)context {
  [super awakeWithContext:context];

  self.ref = [[Wilddog alloc] initWithUrl:@"https://<your-wilddog-app>.wilddogio.com/updates"];
  self.updates = [[NSMutableArray alloc] init];

  // Use the same suiteName as used in the host app
  NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.username.SuiteName"];

  // Grab the auth token
  NSString *authToken = [defaults objectForKey:@"WAuthDataToken"];

  // Authenticate with the token from the NSUserDefaults object
  [self.ref authWithCustomToken:authToken withCompletionBlock:^(NSError *error, WAuthData *authData) {
    if (authData != nil) {
      NSLog(@"Authenticated inside of the Watch App!");
    } else {
      NSLog(@"Not authenticated");
    }
  }];
}

```

Swift

```
override func awakeWithContext(context: AnyObject?) {
  super.awakeWithContext(context)

  ref = Wilddog(url: "https://<your-wilddog-app>.wilddogio.com/updates")
  updates = [WDataSnapshot]()

  // Use the same suiteName as used in the host app
  let defaults = NSUserDefaults(suiteName: "group.username.SuiteName")!

  // Grab the auth token
  let authToken = defaults.objectForKey("WAuthDataToken") as? String

  // Authenticate with the token from the NSUserDefaults object
  ref.authWithCustomToken(authToken, withCompletionBlock: { [unowned self] (error: NSError!, authData: WAuthData!) in
    if authData != nil {
      println("Authenticated inside of the Watch App!")
    } else {
      println("Not authenticated")
    }
  })
}

```

只要将 token 从`NSUserDefaults`中取出来，调用`authWithCustomToken`方法去登录认证用户。


#### 处理未认证 WatchKit Extension 用户

如果用户是未认证的，他们只会看到一个空白屏幕。如果认证失败，`withCompletionBlock`方法不会返回一个`authData`参数。在`withCompletionBlock`方法中修改以下代码：


Objective-C

```
// Authenticate with the token from the NSUserDefaults object
[self.ref authWithCustomToken:authToken withCompletionBlock:^(NSError *error, WAuthData *authData) {
  if (authData != nil) {
    NSLog(@"Authenticated inside of the Watch App!");
  } else {
    // Create a dummy row
    NSIndexSet *indexSet = [[NSIndexSet alloc] initWithIndex:0];
    [self.table insertRowsAtIndexes:indexSet withRowType:@"TableRow"];

    // Give it a message informing the user to log in
    id row = [self.table rowControllerAtIndex:0];
    if ([row isKindOfClass:[TableRow class]]) {
      TableRow *tableRow = row;
      [tableRow.labelUpdate setText:@"Please log in"];
    }
  }
}];

```

Swift

```
ref.authWithCustomToken(authToken, withCompletionBlock: { [unowned self] (error: NSError!, authData:WAuthData!) in
  if authData != nil {
    println("Authenticated inside of the Watch App!")
  } else {

    // Create a dummy row
    self.table.insertRowsAtIndexes(NSIndexSet(index: 0), withRowType: "TableRow")

    if let row = self.table.rowControllerAtIndex(0) as? TableRow {
      // Give it a message informing the user to log in
      row.labelUpdate.setText("Please log in")
    }

  }
})

```

如果`authData`是`nil`, label 或者 table row 就会通知用户你还未登录。
在这个例子中，我们用 row 显示用户未登录。


## 注册 Wilddog

WatchKit 需要 Wilddog 来同步和存储数据。您可以在这里[注册](https://www.wilddog.com/my-account/signup)一个免费帐户。


## 支持
如果在使用过程中有任何问题，请提 [issue](https://github.com/WildDogTeam/lib-ios-watchkit/issues) ，我会在 Github 上给予帮助。

## 相关文档

* [Wilddog 概览](https://z.wilddog.com/overview/introduction)
* [IOS SDK快速入门](https://z.wilddog.com/ios/quickstart)
* [IOS SDK API](https://z.wilddog.com/ios/api)
* [下载页面](https://www.wilddog.com/download/)
* [Wilddog FAQ](https://z.wilddog.com/questions)


## License
[MIT](http://wilddog.mit-license.org/)

## 感谢 Thanks

lib-ios-watchkit is built on and with the aid of several  projects. We would like to thank the following projects for helping us achieve our goals:

Open Source:

* [WatchKit](https://www.firebase.com/docs/ios/libraries/watchkit/guide.html) WatchKit for Objective-C - Realtime location queries with Firebase
