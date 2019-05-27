//
//  XHFloatWindowController.m
//  XHFloatingWindow
//
//  Created by Xinhou Jiang on 14/1/17.
//  Copyright © 2017年 Xinhou Jiang. All rights reserved.
//

#import "XHFloatWindowController.h"
#import "XHDraggableButton.h"
#import "XHFloatWindowSingleton.h"
#define floatWindowSizeW 100
#define floatWindowSizeH 50

@interface XHFloatWindowController ()<UIDragButtonDelegate,UITextFieldDelegate>

@property (strong,nonatomic) UIWindow *window;           // float window
@property (strong,nonatomic) XHDraggableButton *button;  // button on window for drag and click event response, and present the textfeild text content
@property (strong,nonatomic) UITextField *textFeild;     // temporal textfeild for text edit
@property (assign,nonatomic) bool isEditing;             // edit state

// button bg
@property (nonatomic, strong)UIImage *imageNormal;
@property (nonatomic, strong)UIImage *imageSelected;

@end

@implementation XHFloatWindowController

- (void)viewDidLoad {
    [super viewDidLoad];
    // init edit state
    _isEditing = NO;
    // hide the root view
    self.view.frame = CGRectZero;
    // create floating window button
    [self createButton];
    // register UIDeviceOrientationDidChangeNotification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    // listen the keyborad to hide to reset the float label
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

/**
 * create floating window and button
 */
- (void)createButton
{
    // floating window
    _window = [[UIWindow alloc]init];
    _window.backgroundColor = [UIColor redColor];
    
    _window.frame = CGRectMake(50, 300, floatWindowSizeW, floatWindowSizeH);
    _window.windowLevel = UIWindowLevelAlert+1;
    [_window makeKeyAndVisible];

    
    // 1.floating button
    _button = [XHDraggableButton buttonWithType:UIButtonTypeCustom];
    _button.buttonDelegate = self;
    _button.initOrientation = [UIApplication sharedApplication].statusBarOrientation;
    _button.originTransform = _button.transform;
    _button.backgroundColor = [UIColor whiteColor];
    [_button setTitle:@"我显示输入的最终文字" forState:UIControlStateNormal];
    [_button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    _button.frame = CGRectMake(0, 0, floatWindowSizeW, floatWindowSizeH);
    _button.originTransform = _button.transform;
    [_window addSubview:_button];
    
    
    // 2. textFeild
    _textFeild = [[UITextField alloc] init];
    _textFeild.text = @"我是输入框";
    _textFeild.backgroundColor = [UIColor whiteColor];
    _textFeild.textColor = [UIColor blackColor];
    _textFeild.returnKeyType = UIReturnKeyDone;
    _textFeild.delegate = self;
    
    _textFeild.frame = CGRectMake(0, 0,floatWindowSizeW, floatWindowSizeH);
}

/**
 * set rootview
 */
- (void)setRootView {
    _button.rootView = self.view.superview;
}

/**
 *  floating button clicked
 */
- (void)dragButtonClicked:(UIButton *)sender {
    if(!_isEditing) {
        //_button.titleLabel.text = @"";
        [_window addSubview:_textFeild];
        [_textFeild becomeFirstResponder];
        _isEditing = YES;
    }
    
    // click callback
    //[XHFloatWindowSingleton Ins].floatWindowCallBack();
}

/**
 * reset window hiden
 */
- (void)setHideWindow:(BOOL)hide {
    _window.hidden = hide;
}

/**
 * reset floating window size
 */
- (void)setWindowSize:(float)size {
    CGRect rect = _window.frame;
    _window.frame = CGRectMake(rect.origin.x, rect.origin.y, size, size);
    _button.frame = CGRectMake(0, 0, size, size);
    [self.view setNeedsLayout];
}

/**
 * reset button background image
 */
- (void)resetBackgroundImage:(NSString *)imageName forState:(UIControlState)UIControlState {
    UIImage *image = [UIImage imageNamed:imageName];
    switch (UIControlState) {
        case UIControlStateNormal:
            _imageNormal = image;
            break;
        case UIControlStateSelected:
            _imageSelected = image;
            break;
            
        default:
            break;
    }
    [_button setBackgroundImage:image forState:UIControlState];
}

/**
 * notification
 */
- (void)orientationChange:(NSNotification *)notification {
    [_button buttonRotate:_window];
}

/**
 * keyboard will hide
 */
- (void)keyBoardWillHide:(NSNotification *)notifivation
{
    _isEditing = NO;
}

/**
 * on keyboard return
 */
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_button setTitle:_textFeild.text forState:UIControlStateNormal];
    [textField resignFirstResponder];
    [_textFeild removeFromSuperview];
    return YES;
}

@end
