MQChatViewController
===============
**编辑中...**

An easy to cutomized messages UI library for iOS.

**MQChatViewController**是一套易于定制的iOS开源聊天界面。

该library的**初衷**是为了方便**美洽用户**集成美洽SDK、自定义美洽客服聊天界面。但为了能让该library满足其他开发者的需要，我们尽量将美洽业务逻辑从该library剥离出去。

**美洽SDK**的用户可以直接使用该界面，也可进行二次开发。

非美洽SDK用户的童鞋们经过简单的自定义，也可以将之当做聊天界面框架使用。

为什么再写一套聊天library？
---
之前在其他项目中用过[JSQMessagesViewController](https://github.com/jessesquires/JSQMessagesViewController)和[UUChatTableView](https://github.com/ZhipingYang/UUChatTableView)，两个开源项目都很好，但由于JSQMessage多文字气泡[卡顿的问题](https://github.com/jessesquires/JSQMessagesViewController/issues/492)迟迟得不到解决，UUChatView增加自定义Cell并不是那么方便，所以决定写一套方便自定义的聊天界面。

Goal - 目标
---
该聊天界面的**目标**是，**能让开发者很方便地进行定制**。

为了达成该目标，该library做了如下设计：
* 避免MVC(Massive View Controller)，将TableView、TableView的DataSource和ViewController的数据管理都独立出去，ViewController只充当View和Model的接口；
* 为每一种cell建立一个单独的类，以方便开发者进行修改和替换；
* 所有的Cell都继承于一个基Cell，这样开发者就不需要修改DataSource中的逻辑；
* 所有的CellModel都必须满足一类协议方法，避免开发者过多的修改数据管理的逻辑；
* 如果开发者不需要再自定义其他的View，则不需要修改ViewController；

Usage - 使用方法
---
最简单的使用方式，即初始化`MQChatViewManager`，并对界面进行配置，然后调用启动接口即可；

如果你想在某一个ViewController，Push一个聊天界面，可复制下面两行代码：
```objective-c
	MQChatViewManager *chatViewManager = [[MQChatViewManager alloc] init];
	[chatViewManager pushMQChatViewControllerInViewController:self];
```
有关聊天界面的配置，请见文档末尾的**Configuration**小节.

Project Structure - 代码结构
---

文件 | 作用
----- | -----
[Config/](https://github.com/Meiqia/MQChatViewController/tree/master/MQChatViewControllerDemo/MQChatViewController/ChatViewManager) | 对聊天界面进行配置的文件
[Controllers/MQChatViewController](https://github.com/Meiqia/MQChatViewController/blob/master/MQChatViewControllerDemo/MQChatViewController/ViewController/MQChatViewController.h) | 界面的Controller类
[Controllers/MQChatViewService](https://github.com/Meiqia/MQChatViewController/blob/master/MQChatViewControllerDemo/MQChatViewController/ViewController/MQChatViewService.h) | 界面的数据管理类，开发者可在该类中对接自己项目的APIManager，来进行发送、收取消息等业务逻辑
[Controllers/MQChatViewTableDataSource](https://github.com/Meiqia/MQChatViewController/blob/master/MQChatViewControllerDemo/MQChatViewController/ViewController/MQChatViewTableDataSource.h) | 消息的TableView的DataSource，开发者不需要修改该类
[Views/MQChatTableView](https://github.com/Meiqia/MQChatViewController/blob/master/MQChatViewControllerDemo/MQChatViewController/ViewController/MQChatTableView.h) | 消息的TableView
[TableCells/CellModel](https://github.com/Meiqia/MQChatViewController/tree/master/MQChatViewControllerDemo/MQChatViewController/ChatCells/cellModel) | 自定义cell的ViewModel，进行内容转换、布局计算等等
[TableCells/CellView](https://github.com/Meiqia/MQChatViewController/tree/master/MQChatViewControllerDemo/MQChatViewController/ChatCells/cell) | 自定义的cell，cell中的View直接使用在相应的CellModel中计算好的数据
[MessageModels/](https://github.com/Meiqia/MQChatViewController/tree/master/MQChatViewControllerDemo/MQChatViewController/ChatMessages) | 该文件夹中的类是该library会用到的Message实体
[Utils/](https://github.com/Meiqia/MQChatViewController/tree/master/MQChatViewControllerDemo/MQChatViewController/ChatUtil) | 自定义的工具类
[Views/](https://github.com/Meiqia/MQChatViewController/tree/master/MQChatViewControllerDemo/MQChatViewController/Views) | 界面中用到的自定义View，如聊天TableView、下拉刷新、输入框等等
[Assets/MQChatViewAsset.bundle](https://github.com/Meiqia/MQChatViewController/tree/master/MQChatViewControllerDemo/MQChatViewController/MQChatViewBundle.bundle) | 资源文件，如图片、声音文件等，**注意**用户如果需要通过MQChatViewManager修改自定义元素图片，需要将图片放在该bundle中
[Vendors/](https://github.com/Meiqia/MQChatViewController/tree/master/MQChatViewControllerDemo/MQChatViewController/Vendors) | 第三方开源库

注意：
* 代码中的预处理是为了剥离美洽SDK的逻辑，如果你不是美洽SDK的用户，可将代码中所有`#ifdef INCLUDE_MEIQIA_SDK`中的逻辑换成自己的API逻辑，如下方：

```objective-c
	#ifdef INCLUDE_MEIQIA_SDK
	//调用美洽的API逻辑
	#endif
```

* 如果你是美洽SDK用户，则需要在MQChatViewConfig.h中，取消下面define的注释，以便打开美洽的API：

```objective-c
	//是否引入美洽SDK
	//#define INCLUDE_MEIQIA_SDK
```

Demo - 示例
---
开发者可参考demo中的用法，对聊天界面进行配置，来进行基本的自定义功能，例如下面的示例：

**开发者可这样push出聊天界面**
```objective-c
	MQChatViewManager *chatViewManager = [[MQChatViewManager alloc] init];
    [chatViewManager pushMQChatViewControllerInViewController:self];
```
![screenshot1](https://github.com/ijinmao/MQChatViewController/blob/master/DemoGif/MQChatViewDemo1.gif)


**开发者可这样present出聊天界面的模态视图**
```objective-c
	MQChatViewManager *chatViewManager = [[MQChatViewManager alloc] init];
    [chatViewManager presentMQChatViewControllerInViewController:self];
```
![screenshot2](https://github.com/ijinmao/MQChatViewController/blob/master/DemoGif/MQChatViewDemo2.gif)


**开发者可这样配置：底部按钮、修改气泡颜色、文字颜色、使头像设为圆形**
```objective-c
	[chatViewManager setPhotoSenderImage:photoImage highlightedImage:photoHighlightedImage];
    [chatViewManager setVoiceSenderImage:voiceImage highlightedImage:voiceHighlightedImage];
    [chatViewManager setTextSenderImage:keyboardImage highlightedImage:keyboardHighlightedImage];
    [chatViewManager setResignKeyboardImage:resightKeyboardImage highlightedImage:resightKeyboardHighlightedImage];
    [chatViewManager setIncomingBubbleColor:[UIColor redColor]];
    [chatViewManager setIncomingMessageTextColor:[UIColor whiteColor]];
    [chatViewManager setOutgoingBubbleColor:[UIColor yellowColor]];
    [chatViewManager setOutgoingMessageTextColor:[UIColor darkTextColor]];
    [chatViewManager enableRoundAvatar:true];
    [chatViewManager pushMQChatViewControllerInViewController:self];
```
![screenshot3](https://github.com/ijinmao/MQChatViewController/blob/master/DemoGif/MQChatViewDemo3.gif)


**开发者可这样配置：是否支持发送语音、是否显示本机头像、修改气泡的样式**
```objective-c
    [chatViewManager enableSendVoiceMessage:false];
    [chatViewManager enableClientAvatar:false];
    [chatViewManager setIncomingBubbleImage:incomingBubbleImage];
    [chatViewManager setOutgoingBubbleImage:outgoingBubbleImage];
    [chatViewManager setBubbleImageStretchInsets:UIEdgeInsetsMake(stretchPoint.y, stretchPoint.x, incomingBubbleImage.size.height-stretchPoint.y+0.5, stretchPoint.x)];
    [chatViewManager pushMQChatViewControllerInViewController:self];
```
![screenshot4](https://github.com/ijinmao/MQChatViewController/blob/master/DemoGif/MQChatViewDemo4.gif)


**开发者可这样配置：增加可点击链接的正则表达式(library本身已支持多种格式链接，如未满足需求可增加)、增加欢迎语、是否开启消息声音、修改接受消息的铃声**
```objective-c
	[chatViewManager setMessageLinkRegex:@"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|([a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)"];
    [chatViewManager enableChatWelcome:true];
    [chatViewManager setChatWelcomeText:@"你好，请问有什么可以帮助到您？"];
    [chatViewManager setIncomingMessageSoundFileName:@"MQNewMessageRingStyle2.wav"];
    [chatViewManager enableMessageSound:true];
    [chatViewManager pushMQChatViewControllerInViewController:self];
```
![screenshot5](https://github.com/ijinmao/MQChatViewController/blob/master/DemoGif/MQChatViewDemo5.gif)



**如果tableView没有在底部，开发者可这样打开消息的提示**
```objective-c
	[chatViewManager enableShowNewMessageAlert:true];
    [chatViewManager pushMQChatViewControllerInViewController:self];
```
![screenshot6](https://github.com/ijinmao/MQChatViewController/blob/master/DemoGif/MQChatViewDemo6.gif)



**开发者可这样配置：是否支持下拉刷新、修改下拉刷新颜色、增加导航栏标题**
```objective-c
	[chatViewManager enableTopPullRefresh:true];
    [chatViewManager setPullRefreshColor:[UIColor redColor]];
    [chatViewManager setNavTitleText:@"美洽SDK"];
    [chatViewManager pushMQChatViewControllerInViewController:self];
```
![screenshot7](https://github.com/ijinmao/MQChatViewController/blob/master/DemoGif/MQChatViewDemo7.gif)


**开发者可这样修改导航栏颜色、导航栏左右键**
```objective-c
	[chatViewManager setNavTitleText:@"美洽SDK"];
    [chatViewManager setNavigationBarTintColor:[UIColor redColor]];
    [chatViewManager setNavRightButton:rightButton];
    [chatViewManager pushMQChatViewControllerInViewController:self];
```
![screenshot8](https://github.com/ijinmao/MQChatViewController/blob/master/DemoGif/MQChatViewDemo8.gif)


Customization - 深度自定义
---
**3步添加自定义cell**
* 添加自定义的cell类，注意该cell必须继承于`MQChatBaseCell`;
* 添加自定义cell的CellModel，注意CellModel必须实现`MQCellModelProtocol`协议中的方法；
* 接下来你需要在`MQChatViewService.m`中，使用你自己的发送消息、接受消息的数据接口；注：你可以查看`#ifdef INCLUDE_MEIQIA_SDK`里面的内容，里面用到了我们数据层和UI层的中间接口`MQServiceToViewInterface`；

**替换加载图片的策略**
* 该library中没有使用**图片/文件缓存**等策略，加载图片的地方都新开了一个线程进行数据加载，如下方所示，开发者可根据自己的项目替换成不同的缓存策略，如SDWebImage等;

```objective-c
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
#warning 这里开发者可以使用自己的图片缓存策略，如SDWebImage
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:message.userAvatarPath]];
    });
```

Configuration - 配置
---
如果你不想修改聊天界面的内部逻辑，`MQChatViewManager`提供了很多接口，可以实现一些自定义设置。

名词解释
名词 | 说明
--- | ---
incoming | 表示聊天对方
outgoing | 表示本机用户

下面列举一些常用的配置聊天界面的接口如下：(详细请见[MQChatViewManager.h](https://github.com/ijinmao/MQChatViewController/blob/master/MQChatViewControllerDemo/MQChatViewController/ChatViewManager/MQChatViewManager.h))
```objective-c
	/**
	 * @brief 增加消息中可选中的链接的正则表达式，用于匹配消息，满足条件段落可以被用户点击。
	 * @param numberRegex 链接的正则表达式
	 */
	- (void)setMessageLinkRegex:(NSString *)linkRegex;

	/**
	 * @brief 增加消息中可选中的email的正则表达式，用于匹配消息，满足条件段落可以被用户点击。
	 * @param emailRegex email的正则表达式
	 */
	- (void)setMessageEmailRegex:(NSString *)emailRegex;

	/**
	 * @brief 设置收到消息的声音；
	 * @param soundFileName 声音文件
	 */
	- (void)setIncomingMessageSoundFileName:(NSString *)soundFileName;

	/**
	 * @brief 是否支持发送语音消息；
	 * @param enable YES:支持发送语音消息 NO:不支持发送语音消息
	 */
	- (void)enableSendVoiceMessage:(BOOL)enable;

	/**
	 * @brief 是否支持发送图片消息；
	 * @param enable YES:支持发送图片消息 NO:不支持发送图片消息
	 */
	- (void)enableSendImageMessage:(BOOL)enable;

	/**
	 * @brief 是否支持对方头像的显示；
	 * @param enable YES:支持 NO:不支持
	 */
	- (void)enableIncomingAvatar:(BOOL)enable;

	/**
	 * @brief 是否支持当前用户头像的显示
	 *
	 * @param enable YES:支持 NO:不支持
	 */
	- (void)enableOutgoingAvatar:(BOOL)enable;

	/**
	 * @brief 是否开启接受/发送消息的声音；
	 * @param enable YES:开启声音 NO:关闭声音
	 */
	- (void)enableMessageSound:(BOOL)enable;

	/**
	 * @brief 是否开启下拉刷新（顶部刷新）
	 *
	 * @param enable YES:支持 NO:不支持
	 */
	- (void)enableTopPullRefresh:(BOOL)enable;

	/**
	 *  @brief 设置下拉/上拉刷新的颜色
	 *
	 *  @param pullRefreshColor 颜色
	 */
	- (void)setPullRefreshColor:(UIColor *)pullRefreshColor;

	/**
	 * @brief 设置发送过来的message的文字颜色；
	 * @param textColor 文字颜色
	 */
	- (void)setIncomingMessageTextColor:(UIColor *)textColor;

	/**
	 *  @brief 设置发送过来的message气泡颜色
	 *
	 *  @param bubbleColor 气泡颜色
	 */
	- (void)setIncomingBubbleColor:(UIColor *)bubbleColor;

	/**
	 * @brief 设置发送出去的message的文字颜色；
	 * @param textColor 文字颜色
	 */
	- (void)setOutgoingMessageTextColor:(UIColor *)textColor;

	/**
	 *  @brief 设置发送的message气泡颜色
	 *
	 *  @param bubbleColor 气泡颜色
	 */
	- (void)setOutgoingBubbleColor:(UIColor *)bubbleColor;
```
更多配置请见MQChatViewManager.h文件。

To-do-list - 待修复问题
---
由于SDK发布催的很紧，以下问题还没有得到妥善解决，但影响不大，所以还没有修复，开发者打怪得分后可提PR^.^：
* tableView中有图片显示在屏幕上，转屏会很卡；(测试显示，iOS6和iOS7不会出现卡顿)
* 目前只支持单张图片全屏浏览，还不支持多张图片浏览；
* 下拉刷新的瞬间，tableView会跳跃一下，给人造成一种"卡了一下"的感觉；
* 启动上拉刷新(底部刷新)，只显示了loading的indicator，没有显示出loading的path效果；
* 使用TTTAttributedLabel，输入emoji，text会往下偏移；
* TTTAttributedLabel中使用了NSUnderlineColorAttributeName，导致不兼容iOS6，所以对于iOS7以下的用户，消息气泡中的文字用的是UILabel；所以对于iOS7以下用户，没有文字选中的效果；
* 开发者可在项目中搜索#warning，其中有一个warning是TTTAttributedLabel的bug，开发者感兴趣可以解决一下；

Vendors - 用到的第三方开源库
---
以下是该library用到的第三方开源代码，如果开发者的项目中用到了相同的库，需要删除一份，避免类名冲突：

第三方开源库 | 说明
----- | -----
VoiceConvert | AMR和WAV语音格式的互转；没找到出处，哪位童鞋找到来源后，请更新下文档~
[MLAudioRecorder](https://github.com/molon/MLAudioRecorder) | 边录边转码，播放网络音频Button(本地缓存)，实时语音。
[MHFacebookImageViewer](https://github.com/michaelhenry/MHFacebookImageViewer) | 图片查看器；**注意**，我们对该开源库进行了修改，以支持单击关闭Viewer等一些操作，该修改版本可见[MHFacebookImageViewer](https://github.com/ijinmao/MHFacebookImageViewer)；
[FBDigitalFont](https://github.com/lyokato/FBDigitalFont) | 类LED显示效果，用于本项目中的语音倒计时显示；
[GrowingTextView](https://github.com/HansPinckaers/GrowingTextView) | 随文字改变高度的的textView，用于本项目中的聊天输入框；
[TTTAttributedLabel](https://github.com/TTTAttributedLabel/TTTAttributedLabel) | 支持多种效果的Lable，用于本项目中的聊天气泡的文字Label；

Hope to Help Each Other - 互助
---
由于开发进度紧张，该项目写的较快，肯定有很多地方没有考虑周到，欢迎开发者指正和建议~

如果该library有帮助到你，或是你想完善此library，欢迎通过任何形式联系我们，一起讨论、一起互帮互助总是好的^.^

美洽官方开发者群:  295646206
