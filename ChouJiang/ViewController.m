//
//  ViewController.m
//  ChouJiang
//
//  Created by superMan on 2017/7/18.
//  Copyright © 2017年 徐学超. All rights reserved.
//

#import "ViewController.h"

#define Main_Screen_Height      [[UIScreen mainScreen] bounds].size.height
#define Main_Screen_Width       [[UIScreen mainScreen] bounds].size.width

//获取View的属性
#define GetViewWidth(view)  view.frame.size.width
#define GetViewHeight(view) view.frame.size.height

//不同屏幕尺寸字体适配（320，568是因为效果图为IPHONE5 如果不是则根据实际情况修改）
#define kScreenWidthRatio  (Main_Screen_Width / 375.0)
#define kScreenHeightRatio (Main_Screen_Height / 667.0)
#define AdaptedWidth(x)  ceilf((x) * kScreenWidthRatio * .5)
#define AdaptedHeight(x) ceilf((x) * kScreenHeightRatio * .5)

//获取图片资源
#define GetImage(imageName) [UIImage imageNamed:[NSString stringWithFormat:@"%@",imageName]]


#define MaxTime .45
#define MinTime .05

@interface ViewController () {
    NSArray <NSArray <NSNumber *>*>*_scaleArray;
    int _x,_y,_z;// _x:加速过程中的个数 _y:匀速过程中的个数 _z:减速过程中的个数（_x，_z是不变的，_y是随机生成的）
    int _lastImgTag;//记录最后时刻橘黄框旋转到哪个imgView上
}

@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) UIImageView *selectedImgView;
@property (nonatomic, strong) UIButton *goBtn;
@property (nonatomic, retain) NSMutableArray <UIImageView *>*imgArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initData];
    [self initViews];
}

#pragma mark - Init
- (void)initData {
    _x = 8;
    _y = 60 + (arc4random() % 20);
    _z = 8;
    _lastImgTag = 0;
    //这个数组是用来计算_imgArray中的imageView相对于_goBtn的位置
    _scaleArray = @[@[@(-1),@(-1)],@[@(0),@(-1)],@[@(1),@(-1)],@[@(1),@(0)],@[@(1),@(1)],@[@(0),@(1)],@[@(-1),@(1)],@[@(-1),@(0)]];
}

- (void)initViews {
    [self.view addSubview:self.goBtn];
    for (UIImageView *imgView in self.imgArray) {
        [self.view addSubview:imgView];
    }
    [self.view addSubview:self.selectedImgView];
}

#pragma mark - Setter And Getter

- (UIImageView *)selectedImgView {
    if (!_selectedImgView) {
        _selectedImgView = [UIImageView new];
        _selectedImgView.layer.borderColor = [UIColor orangeColor].CGColor;
        _selectedImgView.layer.borderWidth = AdaptedWidth(6);
    }
    return _selectedImgView;
}

- (UIButton *)goBtn {
    if (!_goBtn) {
        _goBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _goBtn.bounds = CGRectMake(0, 0, AdaptedWidth(150), AdaptedWidth(150));
        _goBtn.center = self.view.center;
        [_goBtn setImage:GetImage(@"jifen_zhuanpan_go") forState:UIControlStateNormal];
        [_goBtn addTarget:self action:@selector(goLottery) forControlEvents:UIControlEventTouchUpInside];
    }
    return _goBtn;
}

- (NSMutableArray <UIImageView *>*)imgArray {
    if (!_imgArray) {
        _imgArray = [NSMutableArray new];
        for (NSInteger i = 0; i < 8; i++) {
            UIImageView *imgView = [UIImageView new];
            imgView.tag = i + 100;
            // 这里imgView的frame都是根据_goBtn算的
            imgView.frame = CGRectMake(CGRectGetMinX(_goBtn.frame)+[_scaleArray[i][0] integerValue]*(GetViewWidth(_goBtn)+AdaptedWidth(8)), CGRectGetMinY(_goBtn.frame)+[_scaleArray[i][1] integerValue]*(GetViewHeight(_goBtn)+AdaptedHeight(8)), GetViewWidth(_goBtn), GetViewHeight(_goBtn));
            imgView.image = i % 2 ? GetImage(@"jifen_zhuanpan_kulian") : GetImage(@"jifen_zhuanpan_hongbao");
            [_imgArray addObject:imgView];
            if (i == 0) {
                self.selectedImgView.frame = imgView.frame;
            }
        }
    }
    return _imgArray;
}

#pragma mark - events
- (void)goLottery {
    static int currentNum = 1;//记录将要走向的格数
    if (currentNum == _lastImgTag) {
        _goBtn.userInteractionEnabled = NO;
    }
    _selectedImgView.frame = _imgArray[currentNum%_imgArray.count].frame;
    
    if (currentNum <= _x+_lastImgTag) {
        //MARK: 加速
        [self performSelector:@selector(goLottery) withObject:nil afterDelay:MaxTime-(currentNum-_lastImgTag)*(MaxTime-MinTime)/_x];
        currentNum++;
    } else if (currentNum <= _x+_y+_lastImgTag) {
        //MARK: 匀速
        [self performSelector:@selector(goLottery) withObject:nil afterDelay:MinTime];
        currentNum++;
    } else if (currentNum < _x+_y+_z+_lastImgTag) {
        //MARK: 减速
        [self performSelector:@selector(goLottery) withObject:nil afterDelay:MinTime+(currentNum-_x-_y-_lastImgTag)*(MaxTime-MinTime)/_z];
        currentNum++;
    } else {
        currentNum = currentNum%_imgArray.count;
        _lastImgTag = currentNum;
        _goBtn.userInteractionEnabled = YES;
        //结束时，要将_y重新赋值，不然每次旋转的圈数都是固定的
        _y = 60 + arc4random() % 20;
        [self latteryEnd];
    }
    
}

//这里写结束想要展示的东西
- (void)latteryEnd {
    NSLog(@"%d",_lastImgTag);
    _lastImgTag % 2 ? NSLog(@"没中奖") : NSLog(@"中奖");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
