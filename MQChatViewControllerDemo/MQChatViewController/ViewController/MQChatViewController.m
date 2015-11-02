//
//  MQChatViewController.m
//  MeiQiaSDK
//
//  Created by ijinmao on 15/10/28.
//  Copyright © 2015年 MeiQia Inc. All rights reserved.
//

#import "MQChatViewController.h"
#import "MQChatViewTableDataSource.h"
#import "MQChatViewModel.h"
#import "MQCellModelProtocol.h"
#import "MQDeviceFrameUtil.h"
#import "MQInputBar.h"
#import "MQToast.h"
#import "MQRecordView.h"
#import "MQChatAudioRecorder.h"
#import "VoiceConverter.h"

static CGFloat const kMQChatViewInputBarHeight = 50.0;

@interface MQChatViewController () <UITableViewDelegate, MQChatViewModelDelegate, MQInputBarDelegate, UIImagePickerControllerDelegate, MQChatAudioRecorderDelegate>

@end

@implementation MQChatViewController {
    MQChatViewConfig *chatViewConfig;
    MQChatViewTableDataSource *tableDataSource;
    MQChatViewModel *chatViewModel;
    MQInputBar *chatInputBar;
    MQRecordView *recordView;
    MQChatAudioRecorder *audioRecorder;
}

- (instancetype)initWithChatViewManager:(MQChatViewConfig *)config {
    if (self = [super init]) {
        chatViewConfig = config;
    }
    return  self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = false;
    
    [self setViewGesture];
    [self setNavBar];
    [self initChatTableView];
    [self initChatViewModel];
    [self initInputBar];
    tableDataSource = [[MQChatViewTableDataSource alloc] initWithTableView:self.chatTableView chatViewModel:chatViewModel];
    self.chatTableView.dataSource = tableDataSource;
    chatViewModel.chatViewWidth = self.chatTableView.frame.size.width;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [chatViewConfig setConfigToDefault];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MQAudioPlayerDidInterrupt" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma 对view添加gesture
- (void)setViewGesture {
    UITapGestureRecognizer *tapViewGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapChatView:)];
    tapViewGesture.cancelsTouchesInView = false;
    self.view.userInteractionEnabled = true;
    [self.view addGestureRecognizer:tapViewGesture];
}

- (void)tapChatView:(id)sender {
    [self.view endEditing:true];
}

#pragma 编辑导航栏
- (void)setNavBar {
#ifndef INCLUDE_MEIQIA_SDK
    UIButton *loadMessageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    loadMessageBtn.frame = CGRectMake(0, 0, 62, 22);
    [loadMessageBtn setTitle:@"收取消息" forState:UIControlStateNormal];
    [loadMessageBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    loadMessageBtn.titleLabel.font = [UIFont systemFontOfSize:12.0];
    loadMessageBtn.backgroundColor = [UIColor clearColor];
    [loadMessageBtn addTarget:self action:@selector(tapLoadMessageBtn:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:loadMessageBtn];
#endif
}
#ifndef INCLUDE_MEIQIA_SDK
- (void)tapLoadMessageBtn:(id)sender {
    [chatViewModel loadLastMessage];
    [self chatTableViewScrollToBottom];
}
#endif

#pragma 初始化viewModel
- (void)initChatViewModel {
    chatViewModel = [[MQChatViewModel alloc] init];
    chatViewModel.delegate = self;
}

#pragma 初始化所有Views
/**
 * 初始化聊天的tableView
 */
- (void)initChatTableView {
    if (CGRectEqualToRect(chatViewConfig.chatViewFrame, [MQDeviceFrameUtil getDeviceScreenRect])) {
        CGRect navBarRect = [MQDeviceFrameUtil getDeviceNavRect:self];
        chatViewConfig.chatViewFrame = CGRectMake(0, navBarRect.origin.y+navBarRect.size.height, navBarRect.size.width, [MQDeviceFrameUtil getDeviceScreenRect].size.height - navBarRect.origin.y - navBarRect.size.height - kMQChatViewInputBarHeight);
    }
    self.chatTableView = [[MQChatTableView alloc] initWithFrame:chatViewConfig.chatViewFrame style:UITableViewStylePlain];
    self.chatTableView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
    self.chatTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.chatTableView.delegate = self;
    [self.view addSubview:self.chatTableView];
}

/**
 * 初始化聊天的inpur bar
 */
- (void)initInputBar {
    CGRect inputBarFrame = CGRectMake(self.chatTableView.frame.origin.x, self.chatTableView.frame.origin.y+self.chatTableView.frame.size.height, self.chatTableView.frame.size.width, kMQChatViewInputBarHeight);
    chatInputBar = [[MQInputBar alloc] initWithFrame:inputBarFrame superView:self.view tableView:self.chatTableView enableRecordBtn:chatViewConfig.enableVoiceMessage];
    chatInputBar.delegate = self;
    [self.view addSubview:chatInputBar];
    self.inputBarView = chatInputBar;
    self.inputBarTextView = chatInputBar.textView.internalTextView;
}

#pragma UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    id<MQCellModelProtocol> cellModel = [chatViewModel.cellModels objectAtIndex:indexPath.row];
    return [cellModel getCellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.view endEditing:YES];
}

#pragma MQChatViewModelDelegate
- (void)didGetHistoryMessages {
    [self.chatTableView reloadData];
}

- (void)didUpdateCellWithIndexPath:(NSIndexPath *)indexPath {
    [self.chatTableView beginUpdates];
    [self.chatTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self.chatTableView endUpdates];
}

- (void)reloadChatTableView {
    [self.chatTableView reloadData];
}

#pragma MQInputBarDelegate
-(BOOL)sendTextMessage:(NSString*)text {
    if (self.isInitializing) {
        [MQToast showToast:@"正在分配客服，请稍后发送消息" duration:3 window:self.view];
        return NO;
    }
    [chatViewModel sendTextMessageWithContent:text];
    [self chatTableViewScrollToBottom];
    return YES;
}

-(void)sendImageWithSourceType:(UIImagePickerControllerSourceType *)sourceType {
    if (TARGET_IPHONE_SIMULATOR && (int)sourceType == UIImagePickerControllerSourceTypeCamera){
        [MQToast showToast:@"当前设备没有相机" duration:2 window:self.view];
        NSLog(@"当前设备没有相机");
        return;
    }
    //兼容ipad打不开相册问题，使用队列延迟，规避ios8的警惕性
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType               = (int)sourceType;
        picker.delegate                 = (id)self;
        [self presentViewController:picker animated:YES completion:nil];
    }];
}

-(void)inputting:(NSString*)content {
    //用户正在输入
    [chatViewModel sendUserInputtingWithContent:content];
    [self chatTableViewScrollToBottom];
}

-(void)chatTableViewScrollToBottom {
    NSInteger lastCellIndex = chatViewModel.cellModels.count;
    if (lastCellIndex == 0) {
        return;
    }
    [self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:lastCellIndex-1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:true];
}

-(void)beginRecord:(CGPoint)point {
    if (TARGET_IPHONE_SIMULATOR){
        [MQToast showToast:@"当前设备无法完成录音" duration:2 window:self.view];
        NSLog(@"当前设备无法完成录音");
        return;
    }
    
    //停止播放的通知
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MQAudioPlayerDidInterrupt" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MQAudioPlayerDidInterrupt" object:nil];
    
#warning 这里生成录音开始的回调给开发者
    //    if(self.delegate && [self.delegate respondsToSelector:@selector(recordWillBegin)]){
    //        [self.delegate recordWillBegin];
    //    }

    //如果开发者不自定义录音界面，则将播放界面显示出来
    if ([MQChatViewConfig sharedConfig].enableCustomRecordView) {
        if (!recordView) {
            recordView = [[MQRecordView alloc] initWithFrame:CGRectMake(0, 0,
                                                                        self.chatTableView.frame.size.width,
                                                                        self.chatTableView.frame.size.height)];
            recordView.recordOverDelegate = (id)self;
            [self.view addSubview:recordView];
        }
        [recordView reDisplayRecordView];
        [recordView startRecording];
    }
    
    [self.chatTableView setScrollEnabled:NO];
    
#warning 这里增加语音输入的数据处理
    if (!audioRecorder) {
        audioRecorder = [[MQChatAudioRecorder alloc] init];
        audioRecorder.delegate = self;
    }
    [audioRecorder beginRecording];

}

-(void)finishRecord:(CGPoint)point {
    [recordView stopRecord];
    [audioRecorder finishRecording];
}

-(void)cancelRecord:(CGPoint)point {
    [recordView stopRecord];
    [audioRecorder cancelRecording];
}

-(void)changedRecordViewToCancel:(CGPoint)point {
    recordView.revoke = true;
}

-(void)changedRecordViewToNormal:(CGPoint)point {
    recordView.revoke = false;
}

#pragma MQChatAudioRecorderDelegate
- (void)didFinishRecordingWithAMRFilePath:(NSString *)filePath {
    [chatViewModel sendVoiceMessageWithAMRFilePath:filePath];
}

- (void)didUpdateAudioVolume:(Float32)volume {
    [recordView setRecordingVolume:volume];
}

- (void)didEndRecording {
    [recordView stopRecord];
}

- (void)didBeginRecording {
    
}

#pragma UIImagePickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSString *type          = [info objectForKey:UIImagePickerControllerMediaType];
    //当选择的类型是图片
    if (![type isEqualToString:@"public.image"]) {
        return;
    }
    UIImage *image          = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    [picker dismissViewControllerAnimated:YES completion:nil];
    [chatViewModel sendImageMessageWithImage:image];
    [self chatTableViewScrollToBottom];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}





@end