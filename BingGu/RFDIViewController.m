//
//  RFDIViewController.m
//  BingGu
//
//  Created by RockLu on 10/12/15.
//  Copyright © 2015 RockLu. All rights reserved.
//

#import "RFDIViewController.h"

@interface RFDIViewController ()

@end

@implementation RFDIViewController
{
    ACRAudioJackReader *_reader;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    

    
    // Initialize ACRAudioJackReader object.
    _reader = [[ACRAudioJackReader alloc] init];
    [_reader setDelegate:self];
    

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

- (void)reader:(ACRAudioJackReader *)reader
didSendRawData:(const uint8_t *)rawData length:(NSUInteger)length {
    
    // TODO: Add code here to process the raw data.
    NSLog(@"didSendRowDate");
}









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



NSUInteger timeout = 1; // 1 second.
NSUInteger cardType = ACRPiccCardTypeIso14443TypeA |
ACRPiccCardTypeIso14443TypeB |
ACRPiccCardTypeFelica212kbps |
ACRPiccCardTypeFelica424kbps |
ACRPiccCardTypeAutoRats;
uint8_t commandApdu[] = { 0x00, 0x84, 0x00, 0x00, 0x08 };



// Power on the PICC.
- (void)powerOn
{
    [_reader piccPowerOnWithTimeout:timeout cardType:cardType];
}


// Transmit the APDU.
- (void)transmit
{
    [_reader piccTransmitWithTimeout:timeout commandApdu:commandApdu
                              length:sizeof(commandApdu)];
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
    NSLog(@"didSendPiccAtr");
}

- (void)reader:(ACRAudioJackReader *)reader
didSendPiccResponseApdu:(const uint8_t *)responseApdu
length:(NSUInteger)length {
    
    // TODO: Add code here to process the response APDU.
    NSLog(@"didSendPiccResponseApdu");
}

- (void)reader:(ACRAudioJackReader *)reader didNotifyResult:(ACRResult *)result {
    
    // TODO: Add code here to process the notification.
    NSLog(@"didNotifyResult");
}



@end








 



