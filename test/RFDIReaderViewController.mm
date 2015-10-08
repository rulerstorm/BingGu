//
//  RFDIReaderViewController.m
//  test
//
//  Created by RockLu on 10/8/15.
//  Copyright © 2015 RockLu. All rights reserved.
//

#import "RFDIReaderViewController.h"

#import <CommonCrypto/CommonCrypto.h>
#import <AudioToolbox/AudioToolbox.h>
#import "AudioJack/AudioJack.h"
#import "MBProgressHUD.h"
#import <MediaPlayer/MediaPlayer.h>
#import "AJDHex.h"
#import "HMAudioTool.h"

#define TTT 100

//#import "AJDMasterViewController.h"


@interface RFDIReaderViewController () <MBProgressHUDDelegate, ACRAudioJackReaderDelegate>{
    MBProgressHUD *HUD;
    long long expectedLength;
    long long currentLength;
    
    __weak IBOutlet UILabel *labelTest;
    
    float _userVolume;
    BOOL _isRunning;
    BOOL _timeOut;
    BOOL _getAnswer;
@public
    ACRAudioJackReader * _reader;
}

    

@property(atomic,strong) NSString * readOutPut;
@property(atomic) BOOL timeOOut;


@end

@implementation RFDIReaderViewController


- (void)setReadOutPut:(NSString *)readOutPut
{
    NSLog(@"%@",readOutPut);
    
        dispatch_async(dispatch_get_main_queue(), ^{
            labelTest.text = readOutPut;
            
            sleep(1);
            
            // reset the reader
            [_reader reset];
            
            sleep(1);
            
            // power on thr reader
            if (![_reader piccPowerOnWithTimeout:10 cardType:_piccCardType]) {
                // faild case
                NSLog(@"power on error");
            }
            
            sleep(1);
            
            [self readCard];

        });
    
   }


- (void)setTimeOOut:(BOOL)timeOOut
{
    NSLog(@"time out...");
//    sleep(1);
//    
//    // reset the reader
//    [_reader reset];
//    
//    sleep(1);
//    
//    // power on thr reader
//    if (![_reader piccPowerOnWithTimeout:10 cardType:_piccCardType]) {
//        // faild case
//        NSLog(@"power on error");
//    }
//    
//    sleep(1);
//    
    [self readCard];
}



#pragma mark - ReaderStuff
//    ACRAudioJackReader *_reader;
    ACRDukptReceiver *_dukptReceiver;
    int _swipeCount;

    NSCondition *_responseCondition;

    BOOL _firmwareVersionReady;
    NSString *_firmwareVersion;

    BOOL _statusReady;
    ACRStatus *_status;

    BOOL _resultReady;
    ACRResult *_result;

    BOOL _customIdReady;
    NSData *_customId;

    BOOL _deviceIdReady;
    NSData *_deviceId;

    BOOL _dukptOptionReady;
    BOOL _dukptOption;

    BOOL _trackDataOptionReady;
    ACRTrackDataOption _trackDataOption;

    BOOL _piccAtrReady;
    NSData *_piccAtr;

    BOOL _piccResponseApduReady;
    NSData *_piccResponseApdu;

    NSUserDefaults *_defaults;
    NSData *_masterKey;
    NSData *_masterKey2;
    NSData *_aesKey;
    NSData *_iksn;
    NSData *_ipek;

    NSString *_piccTimeoutString;
    NSString *_piccCardTypeString;
    NSString *_piccCommandApduString;
    NSString *_piccRfConfigString;

    NSUInteger _piccTimeout;
    NSUInteger _piccCardType;
    NSData *_piccCommandApdu;
    NSData *_piccRfConfig;

    UIAlertView *_trackDataAlert;

- (BOOL) AJDIsReaderPlugged {
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


- (void)showPiccResponseApdu
{
    [_responseCondition lock];
    
    // Wait for the PICC response APDU.
    while (!_piccResponseApduReady && !_resultReady) {
        if (![_responseCondition waitUntilDate:[NSDate dateWithTimeIntervalSinceNow:10]]) {
            break;
        }
    }
    
    if (_piccResponseApduReady) {

        [AJDHex hexStringFromByteArray:(u_int8_t*)[_piccResponseApdu bytes] length:[_piccResponseApdu length]];
        
    } else {
            // timeout.
    }
    
    _piccResponseApduReady = NO;
    _resultReady = NO;
    
    [_responseCondition unlock];
}



- (NSUInteger)toByteArray:(NSString *)hexString buffer:(uint8_t *)buffer bufferSize:(NSUInteger)bufferSize {
    
    NSUInteger length = 0;
    BOOL first = YES;
    int num = 0;
    unichar c = 0;
    NSUInteger i = 0;
    
    for (i = 0; i < [hexString length]; i++) {
        
        c = [hexString characterAtIndex:i];
        if ((c >= '0') && (c <= '9')) {
            num = c - '0';
        } else if ((c >= 'A') && (c <= 'F')) {
            num = c - 'A' + 10;
        } else if ((c >= 'a') && (c <= 'f')) {
            num = c - 'a' + 10;
        } else {
            num = -1;
        }
        
        if (num >= 0) {
            
            if (first) {
                
                buffer[length] = num << 4;
                
            } else {
                
                buffer[length] |= num;
                length++;
            }
            
            first = !first;
        }
        
        if (length >= bufferSize) {
            break;
        }
    }
    
    return length;
}






- (void)reader:(ACRAudioJackReader *)reader didSendTrackData:(ACRTrackData *)trackData {
    
    ACRTrack1Data *track1Data = [[ACRTrack1Data alloc] init];
    ACRTrack2Data *track2Data = [[ACRTrack2Data alloc] init];
    ACRTrack1Data *track1MaskedData = [[ACRTrack1Data alloc] init];
    ACRTrack2Data *track2MaskedData = [[ACRTrack2Data alloc] init];
    NSString *track1MacString = @"";
    NSString *track2MacString = @"";
    NSString *batteryStatusString = [self AJD_stringFromBatteryStatus:trackData.batteryStatus];
    NSString *keySerialNumberString = @"";
    NSString *errorString = @"";
    
    // Dismiss the track data alert.
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self AJD_dismissAlertView:_trackDataAlert];
//    });
    
    if ((trackData.track1ErrorCode != ACRTrackErrorSuccess) &&
        (trackData.track2ErrorCode != ACRTrackErrorSuccess)) {
        
        errorString = @"The track 1 and track 2 data";
        
    } else {
        
        if (trackData.track1ErrorCode != ACRTrackErrorSuccess) {
            errorString = @"The track 1 data";
        }
        
        if (trackData.track2ErrorCode != ACRTrackErrorSuccess) {
            errorString = @"The track 2 data";
        }
    }
    
    errorString = [errorString stringByAppendingString:@" may be corrupted. Please swipe the card again!"];
    
    // Show the track error.
    if ((trackData.track1ErrorCode != ACRTrackErrorSuccess) ||
        (trackData.track2ErrorCode != ACRTrackErrorSuccess)) {
        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:errorString message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
//            [alert show];
//        });
    }
    
    if ([trackData isKindOfClass:[ACRAesTrackData class]]) {
        
        ACRAesTrackData *aesTrackData = (ACRAesTrackData *) trackData;
        uint8_t *buffer = (uint8_t *) [aesTrackData.trackData bytes];
        NSUInteger bufferLength = [aesTrackData.trackData length];
        uint8_t decryptedTrackData[128];
        size_t decryptedTrackDataLength = 0;
        
        // Decrypt the track data.
        if (![self decryptData:buffer dataInLength:bufferLength key:[_aesKey bytes] keyLength:[_aesKey length] dataOut:decryptedTrackData dataOutLength:sizeof(decryptedTrackData) pBytesReturned:&decryptedTrackDataLength]) {
            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                
//                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"The track data cannot be decrypted. Please swipe the card again!" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
//                [alert show];
//            });
        }
        
        // Verify the track data.
        if (![_reader verifyData:decryptedTrackData length:decryptedTrackDataLength]) {
            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                
//                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"The track data contains checksum error. Please swipe the card again!" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
//                [alert show];
//            });
            
        }
        
        // Decode the track data.
        track1Data = [track1Data initWithBytes:decryptedTrackData length:trackData.track1Length];
        track2Data = [track2Data initWithBytes:decryptedTrackData + 79 length:trackData.track2Length];
        
    } else if ([trackData isKindOfClass:[ACRDukptTrackData class]]) {
        
        ACRDukptTrackData *dukptTrackData = (ACRDukptTrackData *) trackData;
        NSUInteger ec = 0;
        NSUInteger ec2 = 0;
        NSData *key = nil;
        NSData *dek = nil;
        NSData *macKey = nil;
        uint8_t dek3des[24];
        
        keySerialNumberString = [AJDHex hexStringFromByteArray:dukptTrackData.keySerialNumber];
        track1MacString = [AJDHex hexStringFromByteArray:dukptTrackData.track1Mac];
        track2MacString = [AJDHex hexStringFromByteArray:dukptTrackData.track2Mac];
        track1MaskedData = [track1MaskedData initWithString:dukptTrackData.track1MaskedData];
        track2MaskedData = [track2MaskedData initWithString:dukptTrackData.track2MaskedData];
        
        // Compare the key serial number.
        if (![ACRDukptReceiver compareKeySerialNumber:_iksn ksn2:dukptTrackData.keySerialNumber]) {
            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                
//                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"The key serial number does not match with the settings." message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
//                [alert show];
//            });
            
        }
        
        // Get the encryption counter from KSN.
        ec = [ACRDukptReceiver encryptionCounterFromKeySerialNumber:dukptTrackData.keySerialNumber];
        
        // Get the encryption counter from DUKPT receiver.
        ec2 = [_dukptReceiver encryptionCounter];
        
        // Load the initial key if the encryption counter from KSN is less than
        // the encryption counter from DUKPT receiver.
        if (ec < ec2) {
            
            [_dukptReceiver loadInitialKey:_ipek];
            ec2 = [_dukptReceiver encryptionCounter];
        }
        
        // Synchronize the key if the encryption counter from KSN is greater
        // than the encryption counter from DUKPT receiver.
        while (ec > ec2) {
            
            [_dukptReceiver key];
            ec2 = [_dukptReceiver encryptionCounter];
        }
        
        if (ec != ec2) {
            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"The encryption counter is invalid." message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
//                [alert show];
//            });
//            
//            goto cleanup;
        }
        
        key = [_dukptReceiver key];
        if (key == nil) {
            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"The maximum encryption count had been reached." message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
//                [alert show];
//            });
//            
//            goto cleanup;
        }
        
        dek = [ACRDukptReceiver dataEncryptionRequestKeyFromKey:key];
        macKey = [ACRDukptReceiver macRequestKeyFromKey:key];
        
        // Generate 3DES key (K1 = K3).
        memcpy(dek3des, [dek bytes], [dek length]);
        memcpy(dek3des + [dek length], [dek bytes], 8);
        
        if (dukptTrackData.track1Data != nil) {
            
            uint8_t track1Buffer[80];
            size_t bytesReturned = 0;
            NSString *track1DataString = nil;
            
            // Decrypt the track 1 data.
            if (![self AJD_tripleDesDecryptData:[dukptTrackData.track1Data bytes] dataInLength:[dukptTrackData.track1Data length] key:dek3des keyLength:sizeof(dek3des) dataOut:track1Buffer dataOutLength:sizeof(track1Buffer) bytesReturned:&bytesReturned]) {
                
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    
//                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"The track 1 data cannot be decrypted. Please swipe the card again!" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
//                    [alert show];
//                });
//                
//                goto cleanup;
            }
            
            // Generate the MAC for track 1 data.
            track1MacString = [track1MacString stringByAppendingFormat:@" (%@)", [AJDHex hexStringFromByteArray:[ACRDukptReceiver macFromData:track1Buffer dataLength:sizeof(track1Buffer) key:(u_int8_t*)[macKey bytes] keyLength:[macKey length]]]];
            
            // Get the track 1 data as string.
            track1DataString = [[NSString alloc] initWithBytes:track1Buffer length:dukptTrackData.track1Length encoding:NSASCIIStringEncoding];
            
            // Divide the track 1 data into fields.
            track1Data = [track1Data initWithString:track1DataString];
        }
        
        if (dukptTrackData.track2Data != nil) {
            
            uint8_t track2Buffer[48];
            size_t bytesReturned = 0;
            NSString *track2DataString = nil;
            
            // Decrypt the track 2 data.
            if (![self AJD_tripleDesDecryptData:[dukptTrackData.track2Data bytes] dataInLength:[dukptTrackData.track2Data length] key:dek3des keyLength:sizeof(dek3des) dataOut:track2Buffer dataOutLength:sizeof(track2Buffer) bytesReturned:&bytesReturned]) {
                
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    
//                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"The track 2 data cannot be decrypted. Please swipe the card again!" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
//                    [alert show];
//                });
//                
//                goto cleanup;
            }
            
            // Generate the MAC for track 2 data.
            track2MacString = [track2MacString stringByAppendingFormat:@" (%@)", [AJDHex hexStringFromByteArray:[ACRDukptReceiver macFromData:track2Buffer dataLength:sizeof(track2Buffer) key:(u_int8_t*)[macKey bytes] keyLength:[macKey length]]]];
            
            // Get the track 2 data as string.
            track2DataString = [[NSString alloc] initWithBytes:track2Buffer length:dukptTrackData.track2Length encoding:NSASCIIStringEncoding];
            
            // Divide the track 2 data into fields.
            track2Data = [track2Data initWithString:track2DataString];
        }
    }
    
}


- (void)reader:(ACRAudioJackReader *)reader didNotifyResult:(ACRResult *)result {
    
    [_responseCondition lock];
    _result = result;
    _resultReady = YES;
    [_responseCondition signal];
    [_responseCondition unlock];
}

- (void)reader:(ACRAudioJackReader *)reader didSendFirmwareVersion:(NSString *)firmwareVersion {
    
    [_responseCondition lock];
    _firmwareVersion = firmwareVersion;
    _firmwareVersionReady = YES;
    [_responseCondition signal];
    [_responseCondition unlock];
}

- (void)reader:(ACRAudioJackReader *)reader didSendStatus:(ACRStatus *)status {
    
    [_responseCondition lock];
    _status = status;
    _statusReady = YES;
    [_responseCondition signal];
    [_responseCondition unlock];
}

- (void)readerDidNotifyTrackData:(ACRAudioJackReader *)reader {
    
    // Show the track data alert.
    dispatch_async(dispatch_get_main_queue(), ^{
        
        _trackDataAlert = [[UIAlertView alloc] initWithTitle:@"Information" message:@"Processing the track data..." delegate:nil cancelButtonTitle:nil otherButtonTitles: nil];
        [_trackDataAlert show];
        
        // Dismiss the track data alert after 5 seconds.
        [self performSelector:@selector(AJD_dismissAlertView:) withObject:_trackDataAlert afterDelay:5];
    });
}



- (void)reader:(ACRAudioJackReader *)reader didSendRawData:(const uint8_t *)rawData length:(NSUInteger)length {
    
    NSString *hexString = [AJDHex hexStringFromByteArray:rawData length:length];
    
    hexString = [hexString stringByAppendingString:[_reader verifyData:rawData length:length] ? @" (Checksum OK)" : @" (Checksum Error)"];
    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        
//        self.dataReceivedLabel.text = hexString;
//        [self.tableView reloadData];
//    });
}

- (void)reader:(ACRAudioJackReader *)reader didSendCustomId:(const uint8_t *)customId length:(NSUInteger)length {
    
    [_responseCondition lock];
    _customId = [NSData dataWithBytes:customId length:length];
    _customIdReady = YES;
    [_responseCondition signal];
    [_responseCondition unlock];
}

- (void)reader:(ACRAudioJackReader *)reader didSendDeviceId:(const uint8_t *)deviceId length:(NSUInteger)length {
    
    [_responseCondition lock];
    _deviceId = [NSData dataWithBytes:deviceId length:length];
    _deviceIdReady = YES;
    [_responseCondition signal];
    [_responseCondition unlock];
}

- (void)reader:(ACRAudioJackReader *)reader didSendDukptOption:(BOOL)enabled {
    
    [_responseCondition lock];
    _dukptOption = enabled;
    _dukptOptionReady = YES;
    [_responseCondition signal];
    [_responseCondition unlock];
}



- (BOOL)decryptData:(const void *)dataIn dataInLength:(size_t)dataInLength key:(const void *)key keyLength:(size_t)keyLength dataOut:(void *)dataOut dataOutLength:(size_t)dataOutLength pBytesReturned:(size_t *)pBytesReturned {
    
    BOOL ret = NO;
    
    // Decrypt the data.
    if (CCCrypt(kCCDecrypt, kCCAlgorithmAES128, 0, key, keyLength, NULL, dataIn, dataInLength, dataOut, dataOutLength, pBytesReturned) == kCCSuccess) {
        ret = YES;
    }
    
    return ret;
}


- (BOOL)AJD_tripleDesDecryptData:(const void *)dataIn dataInLength:(size_t)dataInLength key:(const void *)key keyLength:(size_t)keyLength dataOut:(void *)dataOut dataOutLength:(size_t)dataOutLength bytesReturned:(size_t *)bytesReturnedPtr {
    
    BOOL ret = NO;
    
    // Decrypt the data.
    if (CCCrypt(kCCDecrypt, kCCAlgorithm3DES, 0, key, keyLength, NULL, dataIn, dataInLength, dataOut, dataOutLength, bytesReturnedPtr) == kCCSuccess) {
        ret = YES;
    }
    
    return ret;
}


- (NSString *)AJD_stringFromBatteryStatus:(NSUInteger)batteryStatus {
    
    NSString *batteryStatusString = nil;
    
    switch (batteryStatus) {
            
        case ACRBatteryStatusLow:
            batteryStatusString = @"Low";
            break;
            
        case ACRBatteryStatusFull:
            batteryStatusString = @"Full";
            break;
            
        default:
            batteryStatusString = @"Unknown";
            break;
    }
    
    return batteryStatusString;
}



- (void)AJD_dismissAlertView:(UIAlertView *)alertView {
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
}



- (void)reader:(ACRAudioJackReader *)reader didSendTrackDataOption:(ACRTrackDataOption)option {
    
    [_responseCondition lock];
    _trackDataOption = option;
    _trackDataOptionReady = YES;
    [_responseCondition signal];
    [_responseCondition unlock];
}

- (void)reader:(ACRAudioJackReader *)reader didSendPiccAtr:(const uint8_t *)atr length:(NSUInteger)length {
    
    [_responseCondition lock];
    _piccAtr = [NSData dataWithBytes:atr length:length];
    _piccAtrReady = YES;
    [_responseCondition signal];
    [_responseCondition unlock];
}

- (void)reader:(ACRAudioJackReader *)reader didSendPiccResponseApdu:(const uint8_t *)responseApdu length:(NSUInteger)length {
    
    [_responseCondition lock];
    _piccResponseApdu = [NSData dataWithBytes:responseApdu length:length];
    _piccResponseApduReady = YES;
    [_responseCondition signal];
    [_responseCondition unlock];
}





#pragma mark - MyFunc

- (void)viewDidLoad {
    [super viewDidLoad];

    //init HUD
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    HUD.delegate = self;
    [self.view addSubview:HUD];
    HUD.mode = MBProgressHUDModeDeterminate;

    // Initialize ACRAudioJackReader object.
    _reader = [[ACRAudioJackReader alloc] initWithMute:YES];
    [_reader setDelegate:self];

    _piccCommandApdu = [AJDHex byteArrayFromHexString:@"FF CA 00 00 00"];
    
    // Listen the audio route change.
    AudioSessionAddPropertyListener(kAudioSessionProperty_AudioRouteChange, AJDAudioRouteChangeListener, (__bridge void *) self);
    
    _swipeCount = 0;
    
    _responseCondition = [[NSCondition alloc] init];
    
    _firmwareVersionReady = NO;
    _firmwareVersion = nil;
    
    _statusReady = NO;
    _status = nil;
    
    _resultReady = NO;
    _result = nil;
    
    _customIdReady = NO;
    _customId = nil;
    
    _deviceIdReady = NO;
    _deviceId = nil;
    
    _dukptOptionReady = NO;
    _dukptOption = NO;
    
    _trackDataOptionReady = NO;
    _trackDataOption = NO;
    
    _piccAtrReady = NO;
    _piccAtr = nil;
    
    _piccResponseApduReady = NO;
    _piccResponseApdu = nil;
    
    
    
    // Load the settings.
    _defaults = [NSUserDefaults standardUserDefaults];
    
    _masterKey = [_defaults dataForKey:@"MasterKey"];
    if (_masterKey == nil) {
        _masterKey = [AJDHex byteArrayFromHexString:@"00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00"];
    }
    
    _masterKey2 = [_defaults dataForKey:@"MasterKey2"];
    if (_masterKey2 == nil) {
        _masterKey2 = [AJDHex byteArrayFromHexString:@"00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00"];
    }
    
    _aesKey = [_defaults dataForKey:@"AesKey"];
    if (_aesKey == nil) {
        _aesKey = [AJDHex byteArrayFromHexString:@"4E 61 74 68 61 6E 2E 4C 69 20 54 65 64 64 79 20"];
    }
    
    _iksn = [_defaults dataForKey:@"IKSN"];
    if (_iksn == nil) {
        _iksn = [AJDHex byteArrayFromHexString:@"FF FF 98 76 54 32 10 E0 00 00"];
    }
    
    _ipek = [_defaults dataForKey:@"IPEK"];
    if (_ipek == nil) {
        _ipek = [AJDHex byteArrayFromHexString:@"6A C2 92 FA A1 31 5B 4D 85 8A B3 A3 D7 D5 93 3A"];
    }
    
    _piccTimeoutString = [_defaults stringForKey:@"PiccTimeout"];
    _piccCardTypeString = [_defaults stringForKey:@"PiccCardType"];
    _piccCommandApduString = [_defaults stringForKey:@"PiccCommandApdu"];
    _piccRfConfigString = [_defaults stringForKey:@"PiccRfConfig"];
    
    if (_piccTimeoutString == nil) {
        _piccTimeoutString = @"1";
    }
    
    if (_piccCardTypeString == nil) {
        _piccCardTypeString = @"8F";
    }
    
    if (_piccCommandApduString == nil) {
        _piccCommandApduString = @"FF CA 00 00 00";
    }
    
    if (_piccRfConfigString == nil) {
        _piccRfConfigString = @"07 85 85 85 85 85 85 85 85 69 69 69 69 69 69 69 69 3F 3F";
    }
    
    _piccTimeout = [_piccTimeoutString integerValue];
    uint8_t cardType[] = { 0 };
    [self toByteArray:_piccCardTypeString buffer:cardType bufferSize:sizeof(cardType)];
    _piccCardType = cardType[0];
    NSLog(@"%lu", _piccCardType);
    _piccCommandApdu = [AJDHex byteArrayFromHexString:_piccCommandApduString];
    _piccRfConfig = [AJDHex byteArrayFromHexString:_piccRfConfigString];
    
    
    // Initialize the DUKPT receiver object.
    _dukptReceiver = [[ACRDukptReceiver alloc] init];
    
    // Set the key serial number.
    [_dukptReceiver setKeySerialNumber:_iksn];
    
    // Load the initial key.
    [_dukptReceiver loadInitialKey:_ipek];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    
    _isRunning = true;
    _getAnswer = true;
    _timeOut = true;
    
    [self setSystemVolumeToMax];
//    [HUD showWhileExecuting:@selector(waitReaderPluggedAndReset) onTarget:self withObject:nil animated:YES];
    [HUD showAnimated:YES whileExecutingBlock:^{
        [self waitReaderPluggedAndReset];
    } completionBlock:^{
        [self runLoop];
    }];

}

- (void)viewDidDisappear:(BOOL)animated
{
//    [self recoverUserVolume];
    [self pauseLoop];
    _reader.mute = true;
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
        _userVolume = systemVolume;
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
    while (![self AJDIsReaderPlugged]) {
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
    // reset the reader
    [_reader reset];
    
    sleep(1);
    
        HUD.labelText = @"正在「启动读卡器」...";
        // power on thr reader
        if (![_reader piccPowerOnWithTimeout:10 cardType:_piccCardType]) {
            // faild case
            NSLog(@"power on error");
        }
        while (progress < 1.0f) {
            progress += 0.01f;
            HUD.progress = progress;
            usleep(300*TTT);
        }

        
        self.view.userInteractionEnabled = true;
    
}




- (void) readCard
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        // Transmit the command APDU.
        _piccResponseApduReady = NO;
        _resultReady = NO;
        if (![_reader piccTransmitWithTimeout:3 commandApdu:(u_int8_t*)[_piccCommandApdu bytes] length:[_piccCommandApdu length]]) {
            // Show the request queue error.
            NSLog(@"queue error");
            
        } else {
            
            [_responseCondition lock];
            
            // Wait for the PICC response APDU.
            while (!_piccResponseApduReady || !_resultReady) {
                if (![_responseCondition waitUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]]) {
                    break;
                }
            }
            
            if (_piccResponseApduReady) {
                dispatch_async(dispatch_get_main_queue(), ^{
                   self.readOutPut = [AJDHex hexStringFromByteArray:(u_int8_t*)[_piccResponseApdu bytes] length:[_piccResponseApdu length]];
    //                NSLog(_readOutPut);
                });
            }else {
                self.timeOOut = YES;
                
            }
            
            _piccResponseApduReady = NO;
            _resultReady = NO;
            
            [_responseCondition unlock];
        }
    });
//    sleep(5);
}

- (void) runLoop
{
//    while(_isRunning){
//        if (_isRunning && (_getAnswer || _timeOut)) {
            [self readCard];
            
//            _timeOut = false;
//            _getAnswer = false;
//        }
//        sleep(10);
//    }
}

- (void) pauseLoop
{
    _isRunning = NO;
}


static void AJDAudioRouteChangeListener(void *inClientData, AudioSessionPropertyID inID, UInt32 inDataSize, const void *inData) {
    
    RFDIReaderViewController *viewController = (__bridge RFDIReaderViewController *) inClientData;
//viewController->_reader.mute = AJDIsReaderPlugged();
    // Set mute to YES if the reader is unplugged, otherwise NO.

}



@end




