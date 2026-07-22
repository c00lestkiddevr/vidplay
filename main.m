#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) AVPlayer *player;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // 1. Manually configure the base window layer geometry
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    UIViewController *rootVC = [[UIViewController alloc] init];
    rootVC.view.backgroundColor = [UIColor blackColor];
    
    // 2. Discover the target video inside the application package root
    NSString *videoPath = [[NSBundle mainBundle] pathForResource:@"Movie" ofType:@"m4v"];
    if (videoPath) {
        NSURL *videoURL = [NSURL fileURLWithPath:videoPath];
        self.player = [AVPlayer playerWithURL:videoURL];
        
        // 3. Render raw decoded video directly to the viewport layer with zero overlays
        AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        playerLayer.frame = self.window.bounds;
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        [rootVC.view.layer addSublayer:playerLayer];
        
        // 4. Register a looping callback hook
        [[NSNotificationCenter defaultCenter] addObserverForName:AVPlayerItemDidPlayToEndTime
                                                          object:self.player.currentItem
                                                           queue:[NSOperationQueue mainQueue]
                                                      usingBlock:^(NSNotification *note) {
            [self.player seekToTime:kCMTimeZero];
            [self.player play];
        }];
    }
    
    self.window.rootViewController = rootVC;
    [self.window makeKeyAndVisible];
    
    if (self.player) {
        [self.player play];
    }
    
    return YES;
}
@end

// Fallback runtime context mapping
@interface MoviePlayerViewApplication : UIApplication
@end
@implementation MoviePlayerViewApplication
@end

int main(int argc, char * argv[]) {
    @autoreleasepool {
        return UIApplicationMain(argc, argv, NSStringFromClass([MoviePlayerViewApplication class]), NSStringFromClass([AppDelegate class]));
    }
}

