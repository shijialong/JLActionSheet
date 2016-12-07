//
//  JLActionSheet.m
//  CW
//
//  Created by shijialong on 2016/12/1.
//  Copyright © 2016年 Ken.Liu. All rights reserved.
//

#import "JLActionSheet.h"

#define SCREEN_BOUNDS           [UIScreen mainScreen].bounds
#define SCREEN_WIDTH            [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT           [UIScreen mainScreen].bounds.size.height
#define SCREEN_ADJUST(Value)    SCREEN_WIDTH * (Value) / 375.0

#define kRowButtonHeight        SCREEN_ADJUST(50)
#define kRowLineHeight          0.5
#define kDividerViewHeight      7.5

#define kTitleFontSize          SCREEN_ADJUST(16)
#define kButtonTitleFontSize    SCREEN_ADJUST(17)

#define RGBA(R, G, B, A)                [UIColor colorWithRed:R / 255.0 green:G / 255.0 blue:B / 255.0 alpha:A]
#define kActionSheetViewColor           RGBA(225, 225, 225, 1)
#define kTitleFontColor                 RGBA(111, 111, 111, 1)
#define kButtonHighlightedColor         RGBA(242, 242, 242, 1)
#define KDividerViewColor               RGBA(225, 225, 225, 1)

@interface JLActionSheet ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *cancelButtonTitle;
@property (nonatomic, copy) NSArray  *otherButtonTitles;

@property (nonatomic, strong) UIView *coverView;
@property (nonatomic, strong) UIView *actionSheetView;

@property (nonatomic, assign, getter = isShow) BOOL show;
@property (nonatomic, assign) CGFloat actionSheetHeight;

@property (nonatomic, copy) ActionSheetDidSelectSheetBlock selectSheetBlock;

@end


@implementation JLActionSheet

+ (void)showActionSheetViewWithTitle:(nullable NSString *)title
                   cancelButtonTitle:(nullable NSString *)cancelButtonTitle
                   otherButtonTitles:(nullable NSArray<__kindof NSString *> *)otherButtonTitles
                    selectSheetBlock:(ActionSheetDidSelectSheetBlock)selectSheetBlock {
    
    JLActionSheet *sheet = [[JLActionSheet alloc] initWithTitle:title
                                              cancelButtonTitle:cancelButtonTitle
                                              otherButtonTitles:otherButtonTitles
                                               selectSheetBlock:selectSheetBlock];
    [sheet show];
}

- (instancetype)initWithTitle:(NSString *)title
            cancelButtonTitle:(NSString *)cancelButtonTitle
            otherButtonTitles:(NSArray *)otherButtonTitles
             selectSheetBlock:(ActionSheetDidSelectSheetBlock)selectSheetBlock {
    self = [super initWithFrame:SCREEN_BOUNDS];
    if (self) {
        _title = title;
        _cancelButtonTitle = cancelButtonTitle;
        _otherButtonTitles = otherButtonTitles;
        _selectSheetBlock = selectSheetBlock;
        
        [self setupCoverView];
        [self setupActionSheetView];
    }
    return self;
}

#pragma mark - setup UI
- (void)setupCoverView {
    _coverView = [[UIView alloc] initWithFrame:self.bounds];
    _coverView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    _coverView.alpha = 0;
    [self addSubview:_coverView];
}

- (void)setupActionSheetView {
    _actionSheetView = [[UIView alloc] init];
    _actionSheetView.backgroundColor = kActionSheetViewColor;
    [self addSubview:_actionSheetView];
    
    CGFloat offsetY = 0;
    CGFloat width = self.frame.size.width;
    
    if (_title && _title.length > 0) {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, kRowButtonHeight)];
        titleLabel.backgroundColor = [UIColor whiteColor];
        titleLabel.textColor = kTitleFontColor;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont systemFontOfSize:kTitleFontSize];
        titleLabel.numberOfLines = 0;
        titleLabel.text = _title;
        [_actionSheetView addSubview:titleLabel];
        offsetY += kRowButtonHeight + kRowLineHeight;
    }
    
    UIImage *normalImage = [self imageWithColor:[UIColor whiteColor]];
    UIImage *highlightedImage = [self imageWithColor:kButtonHighlightedColor];
    
    if (_otherButtonTitles && _otherButtonTitles.count > 0) {
        if (_otherButtonTitles.count <= 5) {
            for (int i = 0; i < _otherButtonTitles.count; i++) {
                UIButton *otherBtn = [[UIButton alloc] init];
                otherBtn.frame = CGRectMake(0, offsetY, width, kRowButtonHeight);
                otherBtn.tag = i;
                otherBtn.backgroundColor = [UIColor whiteColor];
                otherBtn.titleLabel.font = [UIFont systemFontOfSize:kButtonTitleFontSize];
                [otherBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                [otherBtn setTitle:_otherButtonTitles[i] forState:UIControlStateNormal];
                [otherBtn setBackgroundImage:normalImage forState:UIControlStateNormal];
                [otherBtn setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];
                [otherBtn addTarget:self action:@selector(didSelectSheet:) forControlEvents:UIControlEventTouchUpInside];
                [_actionSheetView addSubview:otherBtn];
                offsetY += kRowButtonHeight + kRowLineHeight;
            }
            offsetY -= kRowLineHeight;
            UIView *dividerView = [[UIView alloc] initWithFrame:CGRectMake(0, offsetY, width, kDividerViewHeight)];
            dividerView.backgroundColor = KDividerViewColor;
            [_actionSheetView addSubview:dividerView];
        } else {
            UITableView *sheetTable = [[UITableView alloc] initWithFrame:CGRectMake(0, offsetY, width, kRowButtonHeight * 5) style:UITableViewStylePlain];
            sheetTable.delegate = self;
            sheetTable.dataSource = self;
            sheetTable.separatorStyle = UITableViewCellSeparatorStyleNone;
            [_actionSheetView addSubview:sheetTable];
            offsetY += sheetTable.frame.size.height;
        }
    }
    
    offsetY += kDividerViewHeight;
    UIButton *cancelBtn = [[UIButton alloc] init];
    cancelBtn.frame = CGRectMake(0, offsetY, width, kRowButtonHeight);
    cancelBtn.tag = -1;
    cancelBtn.backgroundColor = [UIColor whiteColor];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:kButtonTitleFontSize];
    [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cancelBtn setTitle:_cancelButtonTitle ? : @"取消" forState:UIControlStateNormal];
    [cancelBtn setBackgroundImage:normalImage forState:UIControlStateNormal];
    [cancelBtn setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];
    [cancelBtn addTarget:self action:@selector(didSelectSheet:) forControlEvents:UIControlEventTouchUpInside];
    [_actionSheetView addSubview:cancelBtn];
    
    offsetY += kRowButtonHeight;
    _actionSheetHeight = offsetY;
    _actionSheetView.frame = CGRectMake(0, CGRectGetHeight(self.frame), CGRectGetWidth(self.frame), _actionSheetHeight);
    
}


#pragma mark - Touche action
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:_coverView];
    if (!CGRectContainsPoint(_actionSheetView.frame, touchPoint)) {
        [self dismiss];
    }
}

- (void)didSelectSheet:(UIButton *)button {
    if (_selectSheetBlock) {
        _selectSheetBlock(self, button.tag);
    }
    [self dismiss];
}


#pragma mark - Show & Dismiss
- (void)show {
    if(self.isShow) {
        return;
    }
    self.show = YES;
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.9f initialSpringVelocity:0.7f
                        options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionLayoutSubviews
                     animations:^{
                         [[[[UIApplication sharedApplication] delegate] window] addSubview:self];
                         _coverView.alpha = 1.0;
                         _actionSheetView.transform = CGAffineTransformMakeTranslation(0, -_actionSheetHeight);
                     } completion:nil];
}

- (void)dismiss {
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.9f initialSpringVelocity:0.7f
                        options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionLayoutSubviews
                     animations:^{
                         _coverView.alpha = 0;
                         _actionSheetView.transform = CGAffineTransformIdentity;
                     } completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }];
}


#pragma mark - Tool method
- (UIImage *)imageWithColor:(UIColor *)color {
    
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}


#pragma mark - tableView delegate & datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _otherButtonTitles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"btnCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(cell.contentView.frame), 43.5)];
    label.text = _otherButtonTitles[indexPath.row];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:kButtonTitleFontSize];
    [cell.contentView addSubview:label];
    
    UIView *line = [[UIView alloc] initWithFrame:(CGRect){0, CGRectGetHeight(cell.contentView.frame) - 0.5, CGRectGetWidth(cell.contentView.frame), 0.5}];
    line.backgroundColor = KDividerViewColor;
    [cell.contentView addSubview:line];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_selectSheetBlock) {
        _selectSheetBlock(self, indexPath.row);
    }
    [self dismiss];
    
}

@end
