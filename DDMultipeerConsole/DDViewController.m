//
//  DDViewController.m
//  DDMultipeerConsole
//

#import "DDViewController.h"
#import "NBULog.h"
#import <LumberjackConsole/PTEDashboard.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface DDViewController () <MCBrowserViewControllerDelegate, MCSessionDelegate> {
    MCPeerID *_myDevicePeerId;
    MCSession *_session;
}

@end

@implementation DDViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    _myDevicePeerId = [[MCPeerID alloc] initWithDisplayName:[[UIDevice currentDevice] name]];
    
    _session = [[MCSession alloc] initWithPeer:_myDevicePeerId securityIdentity:nil encryptionPreference:MCEncryptionNone];
    _session.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)attachToAppTapped:(id)sender {
    MCBrowserViewController* browserVC = [[MCBrowserViewController alloc] initWithServiceType:@"debugee-service" session:_session];
    browserVC.delegate = self;
    [self presentViewController:browserVC animated:YES completion:nil];
}
#pragma mark - MCSessionDelegate Methods

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state {
	switch (state) {
		case MCSessionStateConnected:
            NSLog(@"PEER CONNECTED: %@", peerID.displayName);
			break;
		case MCSessionStateConnecting:
            NSLog(@"PEER CONNECTING: %@", peerID.displayName);
			break;
		case MCSessionStateNotConnected:
            NSLog(@"PEER NOT CONNECTED: %@", peerID.displayName);
			break;
	}
}

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID {
    NSDictionary* logMessageDict = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    int logFlag = [logMessageDict[@"logFlag"] intValue];
    if (logFlag == LOG_FLAG_ERROR) {
        NBULogError(@"(%@) %@",peerID.displayName, logMessageDict[@"logMsg"]);
    } else if (logFlag == LOG_FLAG_DEBUG) {
        NBULogDebug(@"(%@) %@",peerID.displayName, logMessageDict[@"logMsg"]);
    } else if (logFlag == LOG_FLAG_INFO) {
        NBULogInfo(@"(%@) %@",peerID.displayName, logMessageDict[@"logMsg"]);
    } else if (logFlag == LOG_FLAG_VERBOSE) {
        NBULogVerbose(@"(%@) %@",peerID.displayName, logMessageDict[@"logMsg"]);
    } else if (logFlag == LOG_FLAG_WARN) {
        NBULogWarn(@"(%@) %@",peerID.displayName, logMessageDict[@"logMsg"]);
    }
}

- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID {
}

- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress {
}

- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error {
}

#pragma mark - MCBroweserViewController

- (void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController {
    [self dismissViewControllerAnimated:YES completion:^{
        [[PTEDashboard sharedDashboard] toggleFullscreen:nil];
    }];
}

- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
