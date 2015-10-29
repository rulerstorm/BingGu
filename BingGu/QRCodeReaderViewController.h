//
//  QRCodeReaderViewController.h
//  test
//
//  Created by RockLu on 10/4/15.
//  Copyright © 2015 RockLu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "OutputOfCheckTicketView.h"


@interface QRCodeReaderViewController : UIViewController<AVCaptureMetadataOutputObjectsDelegate, OutputOfCheckTicketViewDelegate>

@property (strong, nonatomic) AVCaptureSession *captureSession;
@property (strong, nonatomic) AVCaptureDevice *videoDevice;
@property (strong, nonatomic) AVCaptureDeviceInput *videoInput;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;
@property (strong, nonatomic) AVCaptureMetadataOutput *metadataOutput;

@property BOOL isRunning;

- (void)stopRunning; 

@property (strong, nonatomic) NSString* cardCode;

+ (instancetype)getInstanceWithOption:(BOOL)pushed;

@end
