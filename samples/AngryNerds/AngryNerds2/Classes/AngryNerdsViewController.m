#import "AngryNerdsViewController.h"
#import "JMC.h"

#import <QuartzCore/QuartzCore.h>
#import "JMCMacros.h"

@implementation AngryNerdsViewController

@synthesize nerd = _nerd, nerdsView = _nerdsView, splashView = _splashView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(hideSplash:) userInfo:nil repeats:NO];
    NSMutableArray *nerds = [NSMutableArray arrayWithObject:[UIImage imageNamed:@"frontend_blink"]];
    for (int i = 0; i < 20; i++) {
        [nerds addObject:[UIImage imageNamed:@"frontend"]];
    }

    [self.nerdsView setAnimationImages:nerds];
    [self.nerdsView setAnimationDuration:5];
    [self.nerdsView startAnimating];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}


-(void) hideSplash:(NSTimer*) timer
{
    self.splashView.hidden = YES;
}

- (IBAction)triggerFeedback
{
    UIViewController *controller = [[JMC sharedInstance] viewController];

    [self presentViewController:controller animated:YES completion:nil];

}

- (IBAction)triggerCrash
{
    NSLog(@"Triggering crash!");
    /* Trigger a crash. NB: if run from XCode, the sigquit handler wont be called to store crash data. */
#ifndef __clang_analyzer__
    CFRelease(NULL);
#endif
}

#pragma mark JCOCustomDataSource

- (NSDictionary *)customFields
{
    return [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"9999", @"42" , @"43", @"label1 label2 label3 space separated", nil]
                                       forKeys:[NSArray arrayWithObjects:@"Top Score", @"jmctestfield", @"jmctestfield2", @"customlabels", nil]];
}

-(NSArray*) components
{
    return [NSArray arrayWithObjects:@"iOS", @"JIRA", nil];
}

- (NSString *)jiraIssueTypeNameFor:(JMCIssueType)type
{
    if (type == JMCIssueTypeCrash) {
        return @"crash";
    } else if (type == JMCIssueTypeFeedback) {
        return @"improvement";
    }
    return nil;
}


- (JMCAttachmentItem *) customAttachment
{

    return [[[JMCAttachmentItem alloc] initWithName:@"custom-attachment"
                                              data:[@"Add any other data as an attachment" dataUsingEncoding:NSUTF8StringEncoding]
                                              type:JMCAttachmentTypePayload
                                       contentType:@"text/plain"
                                    filenameFormat:@"customattachment.txt"] autorelease];
}

-(CGRect)notifierStartFrame
{
    CGRect frame = self.view.frame;
    return CGRectMake(frame.origin.x, frame.size.height, frame.size.width, 40); // start just off screen.
}

-(CGRect)notifierEndFrame
{
    CGRect frame = self.view.frame;
    return CGRectMake(frame.origin.x, frame.size.height - 40 + 20, frame.size.width, 40); // end 40 pixels from bottom of the screen
}

- (NSString *)initialFeedbackText {
    return @"Please leave us your feedback. Even take a screenshot, and attach it via the camera icon below!\n";
}


#pragma end

- (IBAction)triggerDisplayNotifications
{
    [self presentViewController:[[JMC sharedInstance] issuesViewController] animated:YES completion:nil];
}

// allow shake gesture to trigger Feedback
- (void)viewDidAppear:(BOOL)animated
{
    [self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self resignFirstResponder];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    [self triggerFeedback];
}

- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event
{

}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{

}

- (void)jiggleNerd
{

    // Create the animation's path.
    CGPathRef path = NULL;
    CGMutablePathRef mutablepath = CGPathCreateMutable();
    CGPathMoveToPoint(mutablepath, NULL, self.nerdsView.center.x + 10, self.nerdsView.center.y);
    CGPathAddLineToPoint(mutablepath, NULL, self.nerdsView.center.x - 10, self.nerdsView.center.y);
    CGPathAddLineToPoint(mutablepath, NULL, self.nerdsView.center.x, self.nerdsView.center.y);
    CGPathAddLineToPoint(mutablepath, NULL, self.nerdsView.center.x + 10, self.nerdsView.center.y);
    CGPathAddArc(mutablepath, NULL, self.nerdsView.center.x, self.nerdsView.center.y, 5, 0, M_2_PI, YES);

    path = CGPathCreateCopy(mutablepath);
    CGPathRelease(mutablepath);
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    animation.delegate = self;
    animation.path = path;
    animation.speed = 3.0;
    animation.repeatCount = 5;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    animation.delegate = self;
    [self.nerdsView.layer addAnimation:animation forKey:@"rotationAnimation"];
    CGPathRelease(path);
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
    [UIView animateWithDuration:0.7 animations:^{
        self.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        NSLog(@"Crashing...");
#ifndef __clang_analyzer__
        CFRelease(NULL);
#endif
    }];
}

- (IBAction)bounceNerd
{

    UIViewAnimationOptions opts = UIViewAnimationOptionCurveEaseOut;
    [UIView animateWithDuration:0.2
                          delay:0 options:opts
                       animations:^{
                           CGRect frame = self.nerdsView.frame;
                           frame.origin.y -= 100;
                           self.nerdsView.frame = frame;
                       } completion:^(BOOL finished) {

        [UIView animateWithDuration:0.2
                              delay:0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             CGRect frame = self.nerdsView.frame;
                             frame.origin.y += 100;
                             self.nerdsView.frame = frame;
                         }
                         completion:^(BOOL fini) {
                             [self jiggleNerd];
                         }];
    }];

}

- (void)dealloc
{
    self.nerd = nil;
    self.nerdsView = nil;
    self.splashView = nil;
    [super dealloc];
}


@end
