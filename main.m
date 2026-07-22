#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) AVPlayer *player;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    UIViewController *viewController = [[UIViewController alloc] init];
    viewController.view.backgroundColor = [UIColor blackColor];
    
    // Find the video file in the app bundle
    NSString *videoPath = [[NSBundle mainBundle] pathForResource:@"Movie" ofType:@"m4v"];
    if (videoPath) {
        NSURL *videoURL = [NSURL fileURLWithPath:videoPath];
        self.player = [AVPlayer playerWithURL:videoURL];
        
        // Use raw AVPlayerLayer so there are absolutely NO menus, seekbars, or playback controls
        AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        playerLayer.frame = viewController.view.bounds;
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill; // Full screen fill
        [viewController.view.layer addSublayer:playerLayer];
        
        // Loop the video infinitely when it ends
        [[NSNotificationCenter defaultCenter] addObserverForName:AVPlayerItemDidPlayToEndTime
                                                          object:self.player.currentItem
                                                           queue:[NSOperationQueue mainQueue]
                                                      usingBlock:^(NSNotification *note) {
            [self.player seekToTime:kCMTimeZero];
            [self.player play];
        }];
    }
    
    self.window.rootViewController = viewController;
    [self.window makeKeyAndVisible];
    
    if (self.player) {
        [self.player play];
    }
    
    return YES;
}
@end

int main(int argc, char * argv[]) {
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
