//
//  ViewController.m
//  MutiButtonAutolayout
//
//  Created by 于晓鹏 on 15/4/1.
//  Copyright (c) 2015年 roc. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIView *firstLineContainer;
@property (weak, nonatomic) IBOutlet UIView *secondLineContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *secondLineWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *firstLineWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *baseContainerWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *baseContainerView;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *texts = @[ @"伊斯坦伊", @"美国美", @"沙巴", @"奥地利"];
    NSMutableArray *buttons = [[NSMutableArray alloc] init];
    
    CGRect screenSize = [UIScreen mainScreen].bounds;
    CGFloat widthOfScreen  = screenSize.size.width;
    float maxWidth = widthOfScreen - 60;
    int indexOfLeftmostButtonOnCurrentLine = 0;
    float runningWidth = 0.0f;
    
    float horizontalSpaceBetweenButtons = 6.0f;
    float verticalSpaceBetweenButtons = 0.0f;
    float leadingSpaceToSuperview = 0.0f;
    float buttonsWidth = 0.0f;
    float firstLineMaxWidth = 0.0f;
    BOOL isSecondLineFirstButton = NO;
    
    for (int i=0; i<texts.count; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        button.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
        [button setTitle:[texts objectAtIndex:i] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"featured_dest_bg"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"featured_dest_bg_hl"] forState:UIControlStateHighlighted];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button sizeToFit];
        button.translatesAutoresizingMaskIntoConstraints = NO;
        
        buttonsWidth += button.frame.size.width + horizontalSpaceBetweenButtons;
        
        // check if first button or button would exceed maxWidth
        if (i == 0) {
            [self.firstLineContainer addSubview:button];
            // wrap around into next line
            runningWidth = button.frame.size.width;
            buttonsWidth = buttonsWidth - horizontalSpaceBetweenButtons;
            // first button (top left)
            // horizontal position: same as previous leftmost button (on line above)
            NSLayoutConstraint *horizontalConstraint = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.firstLineContainer attribute:NSLayoutAttributeLeft multiplier:1.0f constant:0];
            [self.firstLineContainer addConstraint:horizontalConstraint];
            
            // vertical position:
            NSLayoutConstraint *verticalConstraint = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.firstLineContainer attribute:NSLayoutAttributeTop multiplier:1.0f constant:0];
            [self.firstLineContainer addConstraint:verticalConstraint];
        } else if (buttonsWidth > maxWidth) {
            [self.secondLineContainer addSubview:button];
            if (firstLineMaxWidth == 0.0) {
                firstLineMaxWidth = runningWidth;
                isSecondLineFirstButton = YES;
            }
            
            if (isSecondLineFirstButton) {
                runningWidth = button.frame.size.width;
                buttonsWidth = buttonsWidth - horizontalSpaceBetweenButtons;
                NSLayoutConstraint *horizontalConstraint = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.secondLineContainer attribute:NSLayoutAttributeLeft multiplier:1.0f constant:leadingSpaceToSuperview];
                [self.secondLineContainer addConstraint:horizontalConstraint];
                
                // vertical position:
                NSLayoutConstraint *verticalConstraint = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.secondLineContainer attribute:NSLayoutAttributeTop              multiplier:1.0f constant:verticalSpaceBetweenButtons];
                [self.secondLineContainer addConstraint:verticalConstraint];
                indexOfLeftmostButtonOnCurrentLine = i;
                isSecondLineFirstButton = NO;
            } else {
                runningWidth += button.frame.size.width + horizontalSpaceBetweenButtons;
                UIButton *previousButton = [buttons objectAtIndex:(i-1)];
                
                // horizontal position: same as previous leftmost button (on line above)
                NSLayoutConstraint *horizontalConstraint = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:previousButton attribute:NSLayoutAttributeRight multiplier:1.0f constant:horizontalSpaceBetweenButtons];
                [self.secondLineContainer addConstraint:horizontalConstraint];
                
                // vertical position
                NSLayoutConstraint *verticalConstraint = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.secondLineContainer attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
                [self.secondLineContainer addConstraint:verticalConstraint];
            }
            
        } else {
            [self.firstLineContainer addSubview:button];
            // put it right from previous buttom
            runningWidth += button.frame.size.width + horizontalSpaceBetweenButtons;
            UIButton *previousButton = [buttons objectAtIndex:(i-1)];
            
            // horizontal position: right from previous button
            NSLayoutConstraint *horizontalConstraint = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:previousButton attribute:NSLayoutAttributeRight multiplier:1.0f constant:horizontalSpaceBetweenButtons];
            [self.firstLineContainer addConstraint:horizontalConstraint];
            
            // vertical position same as previous button
            NSLayoutConstraint *verticalConstraint = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.firstLineContainer attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.0f];
            [self.firstLineContainer addConstraint:verticalConstraint];
        }
        [buttons addObject:button];
        NSLog(@"running width:%f",runningWidth);
        NSLog(@"buttons width:%f",buttonsWidth);
    }
    if (firstLineMaxWidth == 0) {
        [self.firstLineWidthConstraint setConstant:runningWidth];
        [self.secondLineWidthConstraint setConstant:0];
        [self.baseContainerWidthConstraint setConstant:runningWidth];
    } else if (firstLineMaxWidth > runningWidth) {
        [self.firstLineWidthConstraint setConstant:firstLineMaxWidth];
        [self.secondLineWidthConstraint setConstant:runningWidth];
        [self.baseContainerWidthConstraint setConstant:firstLineMaxWidth];
    } else {
        [self.firstLineWidthConstraint setConstant:firstLineMaxWidth];
        [self.secondLineWidthConstraint setConstant:runningWidth];
        [self.baseContainerWidthConstraint setConstant:runningWidth];
    }
    UIButton *thirdButton = [buttons objectAtIndex:(2)];
    UIButton *fourthButton = [buttons objectAtIndex:(3)];
    NSLog(@"the last two button width is %f", thirdButton.frame.size.width + fourthButton.frame.size.width + 10);
    NSLog(@"max width:%f",maxWidth);
    
    NSLog(@"base container origin x:%f, y:%f", self.baseContainerView.frame.origin.x, self.baseContainerView.frame.origin.y);

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
