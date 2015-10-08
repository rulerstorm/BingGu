//
//  QRCodeReaderViewController.m
//  test
//
//  Created by RockLu on 10/4/15.
//  Copyright © 2015 RockLu. All rights reserved.
//

#import "QRCodeReaderViewController.h"
#import "HMAudioTool.h"

@interface QRCodeReaderViewController ()
@property (weak, nonatomic) IBOutlet UIView *cameraView;
@property (weak, nonatomic) IBOutlet UILabel *mainLabel;

@end

@implementation QRCodeReaderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //init cameraCaptureSession
    [self setupCaptureSession];

    _previewLayer.frame = _cameraView.bounds;
    [_cameraView.layer addSublayer:_previewLayer];
    
//    NSLog(@"sdfs");
    
    // turn on and off the camera if this app goes into the background/foreground.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    //start scan~~~~
    [self startRunning];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self stopRunning];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)setupCaptureSession
{
    // If the session has already been created, then exit early as there’s no need to set things up again.
    if (_captureSession)
        return;
    /* Initialize the video device by obtaining the type of the default video media device. This returns the most relevant device available. In practice, this generally references the device’s rear camera. If there’s no camera available, this method will return nil and exit. */
    
    _videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (!_videoDevice)
    {
        NSLog(@"No video camera on this device!");
        return;
    }
    
    // Initialize the capture session so you’re prepared to receive input.
    _captureSession = [[AVCaptureSession alloc] init];
    
    //Create the capture input from the device obtained in 2nd comment.
    _videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:_videoDevice error:nil];
    
    //Query the session with canAddInput: to determine if it will accept an input. If so, call addInput: to add the input to the session.
    
    if ([_captureSession canAddInput:_videoInput]) { [_captureSession addInput:_videoInput];
    }
    
    /*Finally, create and initialize a preview layer and indicate which capture session to preview. Set the gravity to "resize aspect fill" so that frames will scale to fit the layer, clipping them if required to maintain the aspect ratio. */
    
    _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    _metadataOutput = [[AVCaptureMetadataOutput alloc] init];
    dispatch_queue_t metadataQueue = dispatch_queue_create("org.petrogeorge.qrCodeData.metadata", 0);
    [_metadataOutput setMetadataObjectsDelegate:self queue:metadataQueue];
    if ([_captureSession canAddOutput:_metadataOutput]) { [_captureSession addOutput:_metadataOutput];
    }
    
}


#pragma mark notification center methods

- (void)applicationWillEnterForeground:(NSNotification*)note
{
    [self startRunning];
}

- (void)applicationDidEnterBackground:(NSNotification*)note
{
    [self stopRunning];
}

- (void)startRunning
{
    if (_isRunning)
        return;
    [_captureSession startRunning];
    _metadataOutput.metadataObjectTypes = _metadataOutput.availableMetadataObjectTypes;
    _isRunning = YES;
}

- (void)stopRunning {
    if (!_isRunning) return;
    [_captureSession stopRunning];
    _isRunning = NO;
}


#pragma mark delegate methods
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    [metadataObjects enumerateObjectsUsingBlock:^(AVMetadataObject *obj, NSUInteger idx, BOOL *stop){
         [metadataObjects enumerateObjectsUsingBlock:^(AVMetadataObject *obj, NSUInteger idx, BOOL *stop) {
             if ([obj isKindOfClass:[AVMetadataMachineReadableCodeObject class]]){
                 AVMetadataMachineReadableCodeObject *code = (AVMetadataMachineReadableCodeObject*)[_previewLayer transformedMetadataObjectForMetadataObject:obj];
                 
                 //important!! here is not main queue!
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self stopRunning];
                     [self doSomething:code.stringValue];             //UI stuff
                     [self startRunning];
                 });
             }
         }];
     }];
}


#pragma mark after scan
//do what you want with the qrCode's string
- (void)doSomething:(NSString*)code
{
    _mainLabel.text = code;
    [HMAudioTool playAudioWithFilename:@"001.wav"];
}



@end
