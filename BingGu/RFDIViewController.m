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
    
    BOOL _isRunning;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touch");

}

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
//    while (progress < 1.0f) {
//        progress += 0.01f;
//        HUD.progress = progress;
//        usleep(300*TTT);
//    }
    
    
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
                }
                
                if (![self transmit]) {
                    NSLog(@"transmit error");
                }else{
                    
                    //wait transmit
                    while (!_isTransmitReturned) {
                        NSLog(@"waiting for _isTransmitReturned....");
                        usleep(200000);   //0.2s
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.labelTest.text = _outPut;
                    });
                }
            }
        }
    });
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



//@section sleepmode Controlling the sleep mode
//
//You can enable the sleep mode by calling ACRAudioJackReader::sleep method. If
//your delegate object implements
//ACRAudioJackReaderDelegate::reader:didNotifyResult: method, it will receive a
//notification after the operation is completed.



// Enable the sleep mode.
//[_reader sleep];



#pragma mark - Audio Jack Reader


//- (void)reader:(ACRAudioJackReader *)reader didNotifyResult:(ACRResult *)result {
//    
//    // TODO: Add code here to process the notification.
//
//}



//@section sleeptimeout Setting the sleep timeout
//
//You can set the sleep timeout by calling ACRAudioJackReader::setSleepTimeout
//method. If your delegate object implements
//ACRAudioJackReaderDelegate::reader:didNotifyResult: method, it will receive a
//notification after the operation is completed.



// Set the sleep timeout to 10 seconds.
//[_reader setSleepTimeout:10];



#pragma mark - Audio Jack Reader



//- (void)reader:(ACRAudioJackReader *)reader didNotifyResult:(ACRResult *)result {
//    
//    // TODO: Add code here to process the notification.
//    
//}






//@section status Getting the status
//
//To get the status, your application should call ACRAudioJackReader::getStatus
//method. Your delegate object should implement
//ACRAudioJackReaderDelegate::reader:didSendStatus: method in order to receive the
//status.




// Get the status.
//[_reader getStatus];


//
//#pragma mark - Audio Jack Reader
//
//
//- (void)reader:(ACRAudioJackReader *)reader didSendStatus:(ACRStatus *)status {
//    
//    // TODO: Add code here to process the status.
//    
//}




//@section track Receiving the track data
//
//When you swipe a card, the reader notifies a track data and sends it through an
//audio channel to your iOS device. To receive the notification and the track
//data, your delegate object should implement
//ACRAudioJackReaderDelegate::readerDidNotifyTrackData: and
//ACRAudioJackReaderDelegate::reader:didSendTrackData: method. You can check the
//track error using ACRTrackData::track1ErrorCode and
//ACRTrackData::track2ErrorCode properties. Note that the received ACRTrackData
//object will be the instance of ACRAesTrackData or ACRDukptTrackData according to
//the settings. You must check the type of instance before accessing the object.
//
//You can get the track data using ACRAesTrackData::trackData,
//ACRDukptTrackData::track1Data and ACRDukptTrackData::track2Data properties. Note
//that the track data of ACRAesTrackData object is encrypted by AES while the
//track data of ACRDukptTrackData object is encrypted by Triple DES. You must
//decrypt it before accessing the original track data.
//
//After decrypting the track data of ACRAesTrackData object, you can use
//ACRTrack1Data::initWithBytes:length: and ACRTrack2Data::initWithBytes:length:
//methods to decode the track data into fields. For the track data or masked track
//data of ACRDukptTrackData object, you can use ACRTrack1Data::initWithString: and
//ACRTrack2Data::initWithString: methods.


//#pragma mark - Audio Jack Reader
//
//
//- (void)readerDidNotifyTrackData:(ACRAudioJackReader *)reader {
//    
//    // TODO: Add your code here to process the notification.
//    
//}
//
//
//- (void)reader:(ACRAudioJackReader *)reader
//didSendTrackData:(ACRTrackData *)trackData {
//    
//    // TODO: Add code here to process the track data.
//    if ((trackData.track1ErrorCode != ACRTrackErrorSuccess) ||
//        (trackData.track2ErrorCode != ACRTrackErrorSuccess)) {
//        
//        // Show the track error.
//        
//        
//        return;
//    }
//    
//    if ([trackData isKindOfClass:[ACRAesTrackData class]]) {
//        
//        ACRAesTrackData *aesTrackData = (ACRAesTrackData *) trackData;
//        
////        ...
//        
//    } else if ([trackData isKindOfClass:[ACRDukptTrackData class]]) {
//        
//        ACRDukptTrackData *dukptTrackData = (ACRDukptTrackData *) trackData;
//        
////        ...
//    }
//    
////    ...
//}



//@section raw Receiving the raw data
//
//If you want to access a raw data of a response, your delegate object should
//implement ACRAudioJackReaderDelegate::reader:didSendRawData:length: method. Note
//that the raw data is not verified by CRC16 checksum and you can call
//ACRAudioJackReader::verifyData:length: method to verify it.



#pragma mark - Audio Jack Reader

//- (void)reader:(ACRAudioJackReader *)reader
//didSendRawData:(const uint8_t *)rawData length:(NSUInteger)length {
//    
//    // TODO: Add code here to process the raw data.
//    NSLog(@"didSendRowData");
//}









//@section picc Working with the PICC
//
//If your reader came with the PICC interface, you can operate the card using the
//following methods:
//
//- ACRAudioJackReader::piccPowerOnWithTimeout:cardType:
//- ACRAudioJackReader::piccTransmitWithTimeout:commandApdu:length:
//- ACRAudioJackReader::piccPowerOff
//
//Before transmitting the APDU, you need to power on the card using
//ACRAudioJackReader::piccPowerOnWithTimeout:cardType: method. If your delegate
//object implements ACRAudioJackReaderDelegate::reader:didSendPiccAtr:length
//method, it will receive the ATR string from the card.
//
//To transmit the APDU, you can use
//ACRAudioJackReader::piccTransmitWithTimeout:commandApdu:length: method. If your
//delegate object implements
//ACRAudioJackReaderDelegate::reader:didSendPiccResponseApdu:length method, it
//will receive the response APDU from the card.
//
//After using the card, you can pwoer off the card using
//ACRAudioJackReader::piccPowerOff method. If your delegate object implements
//ACRAudioJackReaderDelegate::reader:didNotifyResult: method, it will receive a
//notification after the operation is completed.



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








 



