//
//  XHFloatWindowController.m
//  XHFloatingWindow
//
//  Created by Xinhou Jiang on 14/1/17.
//  Copyright © 2017年 Xinhou Jiang. All rights reserved.
//

#import "XHFloatWindowController.h"
#import "XHDraggableButton.h"
#import "UIDraggableTextFeild.h"
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
    // root view click gesture
    UITapGestureRecognizer *tagGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rootViewTag)];
    [self.view.superview addGestureRecognizer:tagGestureRecognizer];
}

/**
 * create floating window and button
 */
- (void)createButton
{
    // 1.floating button
    _button = [XHDraggableButton buttonWithType:UIButtonTypeCustom];
    //[self resetBackgroundImage:@"default_normal" forState:UIControlStateNormal];
    //[self resetBackgroundImage:@"default_selected" forState:UIControlStateSelected];
    _button.imageView.contentMode = UIViewContentModeScaleAspectFill;
    _button.frame = CGRectMake(0, 0, floatWindowSizeW, floatWindowSizeH);
    _button.buttonDelegate = self;
    _button.initOrientation = [UIApplication sharedApplication].statusBarOrientation;
    _button.originTransform = _button.transform;
    [_button setTitle:@"我显示输入的最终文字" forState:UIControlStateNormal];
    _button.backgroundColor = [UIColor purpleColor];
    //_button.imageView.alpha = 0.8;
    
    
    // 2. textFeild
    _textFeild = [[UIDraggableTextFeild alloc] initWithFrame:CGRectMake(0, 0,floatWindowSizeW, floatWindowSizeH)];
    _textFeild.text = @"我是输入框";
    _textFeild.backgroundColor = [UIColor yellowColor];
    _textFeild.textColor = [UIColor purpleColor];
    _textFeild.returnKeyType = UIReturnKeyDone;
    _textFeild.delegate = self;
    
    
    // 3.floating window
    _window = [[UIWindow alloc]init];
    _window.frame = CGRectMake(50, 300, floatWindowSizeW, floatWindowSizeH);
    _window.windowLevel = UIWindowLevelAlert+1;
    _window.backgroundColor = [UIColor clearColor];
    //_window.layer.cornerRadius = floatWindowSize/2;
    //_window.layer.masksToBounds = YES;
    
    [_window addSubview:_button];
    //[_window addSubview:_textFeild];
    [_window makeKeyAndVisible];
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
        _button.titleLabel.text = @"";
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
    [_button buttonRotate];
}

/**
 * keyboard will hide
 */
- (void)keyBoardWillHide:(NSNotification *)notifivation
{
    [_button setTitle:_textFeild.text forState:UIControlStateNormal];
    [_textFeild removeFromSuperview];
    _isEditing = NO;
}

/**
 * on click rootview
 */
- (void)rootViewTag{
    [_textFeild resignFirstResponder];
}

/**
 * on keyboard return
 */
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
