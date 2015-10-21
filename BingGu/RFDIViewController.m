//
//  RFDIViewController.m
//  BingGu
//
//  Created by RockLu on 10/12/15.
//  Copyright © 2015 RockLu. All rights reserved.
//

#import "RFDIViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import <MediaPlayer/MediaPlayer.h>
#import "AJDHex.h"
#import "CardQueryHelper.h"

#define TTT 100  //waiting length


@interface RFDIViewController (){
        MBProgressHUD *HUD;
}
@property (weak, nonatomic) IBOutlet UILabel *labelTest;

@end

@implementation RFDIViewController
{
    ACRAudioJackReader *_reader;
    BOOL _isReseted;        //reader is reseted
    BOOL _isPowerOned;
    BOOL _isTransmitReturned;
    BOOL _resultNotified;
    NSString * _outPut;
    int _specialCount;
    
    BOOL _isRunning;
}

//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
//{
//    NSLog(@"touch");
//
//}

#pragma mark toolBox

- (BOOL) ReaderIsPlugged {
    BOOL plugged = NO;
    CFStringRef route = NULL;
    UInt32 routeSize = sizeof(route);
    if (AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &routeSize, &route) == kAudioSessionNoError) {
        if (CFStringCompare(route, CFSTR("HeadsetInOut"), kCFCompareCaseInsensitive) == kCFCompareEqualTo) {
            plugged = YES;
        }
    }
    return plugged;
}

- (void)setSystemVolumeToMax
{
    MPVolumeView *volumeView = [[MPVolumeView alloc] init];
    UISlider* volumeViewSlider = nil;
    for (UIView *view in [volumeView subviews]){
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
            volumeViewSlider = (UISlider*)view;
            break;
        }
    }
    
    // retrieve system volume
    float systemVolume = volumeViewSlider.value;
    
    if (systemVolume < 1.0f) {
        //save user volume
//        _userVolume = systemVolume;
        // change system volume, the value is between 0.0f and 1.0f
        [volumeViewSlider setValue:1.0f animated:NO];
        // send UI control event to make the change effect right now.
        [volumeViewSlider sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
    
}




- (void)waitReaderPluggedAndReset
{
    // activate the reader
    _reader.mute = false;
    
    self.view.userInteractionEnabled = false;
    
    float progress = 0.0f;
    HUD.mode = MBProgressHUDModeIndeterminate;
    HUD.labelText = @"正在等待「音频读卡器」...";
    
    // waiting
    while (![self ReaderIsPlugged]) {
        sleep(1);
    }
    
    HUD.mode = MBProgressHUDModeDeterminate;
    
    HUD.labelText = @"正在「连接」...";
    while (progress < 0.3f) {
        progress += 0.01f;
        HUD.progress = progress;
        usleep(200*TTT);
    }
    
    HUD.labelText = @"正在「设置参数」...";
    while (progress < 0.6f) {
        progress += 0.01f;
        HUD.progress = progress;
        usleep(200*TTT);
    }

    
    HUD.labelText = @"正在「启动读卡器」...";
    // reset the reader
    [_reader reset];
    while (!_isReseted) {
        usleep(100000);   //0.1s
    }
    

    // power on thr reader
//    if (![self powerOn]) {
//        // faild case
//        NSLog(@"power on error");
//    }
    while (progress < 1.0f) {
        progress += 0.01f;
        HUD.progress = progress;
        usleep(300*TTT);
    }
    
    
    self.view.userInteractionEnabled = true;
    
}



- (void) runLoop
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (_isRunning) {
            NSLog(@"looping...");
            _isPowerOned = NO;
            _isTransmitReturned = NO;
            _resultNotified = NO;
            
            if (![self powerOn]) {
                NSLog(@"powerOn error");
            }else{
                //wait powerOn
                while (!_isPowerOned) {
                    NSLog(@"waiting for _isPowerOned....");
                    usleep(200000);   //0.2s
                    _specialCount++;
                    if (_specialCount > 10) {
                        _specialCount = 0;
                        if (![self powerOn]) {
                            NSLog(@"powerOn error");
                        }
                    }
                }
                _specialCount = 0;
                
                if (![self transmit]) {
                    NSLog(@"transmit error");
                }else{
                    
                    //wait transmit
                    while (!_isTransmitReturned) {
                        NSLog(@"waiting for _isTransmitReturned....");
                        usleep(200000);   //0.2s
                    }
                    
//                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self didGetCardID:_outPut];
//                    });
                }
            }
        }
    });
}

-(void)didGetCardID:(NSString*)cardID
{
    self.labelTest.text = cardID;
    NSString* trueID = [cardID substringToIndex:20];
//    NSLog(@"%@-----------", trueID);
    NSInteger enterCount = [CardQueryHelper getJSON:trueID];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        HUD.mode = MBProgressHUDModeIndeterminate;
        if (-1 == enterCount) {
            HUD.labelText = @"检票失败";
        }else{
            HUD.labelText = [NSString stringWithFormat:@"检票成功，入场次数：%ld",(long)enterCount ] ;
        }
        [HUD showAnimated:YES whileExecutingBlock:^{
            sleep(2);
        } completionBlock:^{
            
        }];
    });
    sleep(2);
}



#pragma mark viewDidLoad

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // Initialize ACRAudioJackReader object.
    _reader = [[ACRAudioJackReader alloc] init];
    [_reader setDelegate:self];
    
    //init HUD
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    HUD.delegate = self;
    [self.view addSubview:HUD];
    HUD.mode = MBProgressHUDModeDeterminate;
    

}

- (void)viewDidAppear:(BOOL)animated
{
    _isRunning = YES;
    
    [self setSystemVolumeToMax];
    //    [HUD showWhileExecuting:@selector(waitReaderPluggedAndReset) onTarget:self withObject:nil animated:YES];
    [HUD showAnimated:YES whileExecutingBlock:^{
        [self waitReaderPluggedAndReset];
    } completionBlock:^{
        [self runLoop];
    }];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    _isRunning = NO;
}
//@section reset Resetting the reader
//
//The sleep mode of reader is enabled by default. To use the reader, your
//application should call ACRAudioJackReader::reset method. If your delegate
//object implements ACRAudioJackReaderDelegate::readerDidReset: method, it will
//receive a notification after the operation is completed.



// Reset the reader.
//[_reader reset];



#pragma mark - Audio Jack Reader


- (void)readerDidReset:(ACRAudioJackReader *)reader {
    
    // TODO: Add code here to process the notification.
    NSLog(@"didReset");
    _isReseted = YES;
}




NSUInteger timeOut = 1; // 1 second.
NSUInteger cardType = ACRPiccCardTypeIso14443TypeA |
ACRPiccCardTypeIso14443TypeB |
ACRPiccCardTypeFelica212kbps |
ACRPiccCardTypeFelica424kbps |
ACRPiccCardTypeAutoRats;



// Power on the PICC.
- (BOOL)powerOn
{
    NSLog(@"poweroning...");
    return [_reader piccPowerOnWithTimeout:timeOut cardType:cardType];
}


// Transmit the APDU.
- (BOOL)transmit
{
    NSLog(@"transmitting...");
    return [_reader piccTransmitWithTimeout:timeOut commandApdu:(u_int8_t*)[[AJDHex byteArrayFromHexString:@"FF CA 00 00 00"] bytes] length:[[AJDHex byteArrayFromHexString:@"FF CA 00 00 00"] length]];
}


// Power off the PICC.
-(void)powerOff
{
    [_reader piccPowerOff];
}



#pragma mark - Audio Jack Reader


- (void)reader:(ACRAudioJackReader *)reader didSendPiccAtr:(const uint8_t *)atr
length:(NSUInteger)length {
    
    // TODO: Add code here to process the ATR.
    NSLog(@"didSendPiccAtr, powerOn ok");
    
    _isPowerOned = YES;
}

- (void)reader:(ACRAudioJackReader *)reader
didSendPiccResponseApdu:(const uint8_t *)responseApdu
length:(NSUInteger)length {
    
    // TODO: Add code here to process the response APDU.
    NSLog(@"didSendPiccResponseApdu, transmit ok。length:%lu", (unsigned long)length);

//    while (!_resultNotified) {
//        usleep(200000);   //0.2s
//    }
    
    _outPut = nil;
    _outPut = [AJDHex hexStringFromByteArray:[NSData dataWithBytes:responseApdu length:length]];
    NSLog(@"outPut:...%@", _outPut);
    _isTransmitReturned = YES;
}

- (void)reader:(ACRAudioJackReader *)reader didNotifyResult:(ACRResult *)result {
    
    _resultNotified = YES;
    // TODO: Add code here to process the notification.
    NSLog(@"didNotifyResult, timeOut!!!");
    [self powerOn];
}



@end








 



