//
//  FICustomEmojiView.m
//  testXibView
//
//  Created by flagadmin on 2019/3/20.
//  Copyright © 2019 flagadmin. All rights reserved.
//
//将数字转为
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define EMOJI_CODE_TO_SYMBOL(x) ((((0x808080F0 | (x & 0x3F000) >> 4) | (x & 0xFC0) << 10) | (x & 0x1C0000) << 18) | (x & 0x3F) << 24);
#import "WZCustomEmojiView.h"
@interface WZCustomEmojiView()<UICollectionViewDelegateFlowLayout,UICollectionViewDelegate,UICollectionViewDataSource>
@property(nonatomic, strong) UICollectionView *fiCollectionView;
/**表情下方视图*/
@property(nonatomic, strong) UIView *footerView;
/**发送按钮*/
@property(nonatomic, strong) UIButton *sendBtn;
/**表情删除按钮*/
@property(nonatomic, strong) UIButton *deleteBtn;

/**emoji表情数组*/
@property(nonatomic, copy) NSArray *emojiArray;
/**一行显示几个*/
@property(nonatomic, assign) NSInteger  showLineNum;
/**一页显示几个*/
@property(nonatomic, assign) NSInteger  showPageNum;
/**表情之间的间距*/
@property(nonatomic, assign) CGFloat  emojiSpace;
/**表情显示大小*/
@property(nonatomic, assign) CGFloat  emojiSize;
/**页数控制pageControl*/
@property(nonatomic, strong) UIPageControl *pageControl;

@end
@implementation WZCustomEmojiView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
       
        self.showLineNum = 9;
        self.showPageNum = self.showLineNum * 3;
        self.emojiSpace = 15;
        self.emojiSize = 30;
        self.backgroundColor = [UIColor whiteColor];
        [self setupViews];
    }
    return self;
}

/**
 建立UI
 */
- (void)setupViews{
    [self addSubview:self.fiCollectionView];
    [self addSubview:self.footerView];
    [self.footerView addSubview:self.pageControl];
    [self.footerView addSubview:self.sendBtn];
    [self.footerView addSubview:self.deleteBtn];
    [self countPageNums];
}
/**
 懒加载展示的表格
 @return fiCollectionView
 */
- (UICollectionView *)fiCollectionView{
    if (!_fiCollectionView) {
        UICollectionViewFlowLayout *layout =[[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(self.emojiSize,self.emojiSize);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _fiCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height-50) collectionViewLayout:layout];
        _fiCollectionView.backgroundColor = [UIColor whiteColor];
        _fiCollectionView.delegate  = self;
        _fiCollectionView.dataSource = self;
        _fiCollectionView.bounces = NO;
        _fiCollectionView.pagingEnabled = YES;
        _fiCollectionView.showsVerticalScrollIndicator = NO;
        _fiCollectionView.showsHorizontalScrollIndicator = NO;
        [_fiCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"emojiCell"];
    }
    return _fiCollectionView;
}

/**
 pageControl页面控制

 @return _pageControl
 */
- (UIPageControl *)pageControl{
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 35)];
//        _pageControl.backgroundColor = [UIColor redColor];
        _pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
        _pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    }
    return _pageControl;
}

/**
 底部视图

 @return _footerView
 */
- (UIView *)footerView {
    if (!_footerView) {
        _footerView = [[UIView alloc]init];
        _footerView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.6];
        CGFloat bottomHeight = 50;
        _footerView.frame = CGRectMake(0, self.frame.size.height - bottomHeight, self.frame.size.width, 50);
    }
    return _footerView;
}

/**
 发送按钮

 @return _sendBtn
 */
- (UIButton *)sendBtn {
    if (!_sendBtn) {
        _sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _sendBtn.frame = CGRectMake(self.frame.size.width - 70, 0, 70, 50);
        [_sendBtn setTitle:@"发送" forState:UIControlStateNormal];
        [_sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_sendBtn setBackgroundColor:[UIColor redColor]];
        [_sendBtn addTarget:self action:@selector(sendEmoji) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendBtn;
}

/**
 删除表情按钮
 @return _deleteBtn
 */
- (UIButton *)deleteBtn {
    if (!_deleteBtn) {
        _deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _deleteBtn.frame = CGRectMake(self.frame.size.width - 140, 0, 70, 50);
        [_deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
        [_deleteBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_deleteBtn setBackgroundColor:[UIColor redColor]];
        [_deleteBtn addTarget:self action:@selector(deleteEmoji) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteBtn;
}


/**
 emoji表情包数组

 @return emojiArray
 */
- (NSArray *)emojiArray{
    if (!_emojiArray) {
        _emojiArray = [NSArray array];
        _emojiArray = [self defaultEmoticons];
    }
    return _emojiArray;
}

#pragma mark -
#pragma mark UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return (self.emojiArray.count / self.showPageNum) + (self.emojiArray.count % self.showPageNum == 0 ? 0 : 1);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.showPageNum;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return self.emojiSpace;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return self.emojiSpace;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.emojiSize, self.emojiSize);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    //每个分区的左右边距
    CGFloat sectionOffset = (CGRectGetWidth(self.frame) - self.showLineNum * self.emojiSize - (self.showLineNum - 1) * self.emojiSpace) / 2;
    //分区内容偏移
    return UIEdgeInsetsMake(self.emojiSize, sectionOffset, self.emojiSize, sectionOffset);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell =
    [collectionView dequeueReusableCellWithReuseIdentifier:@"emojiCell" forIndexPath:indexPath];
    [self setCell:cell withIndexPath:indexPath];

    return cell;
}
/**cell数据配置*/
- (void)setCell:(UICollectionViewCell *)cell withIndexPath:(NSIndexPath *)indexPath {
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    UILabel *emojiLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.emojiSize, self.emojiSize)];
    if (self.showPageNum * indexPath.section + indexPath.item < self.emojiArray.count) {
        emojiLabel.text = self.emojiArray[indexPath.section * self.showPageNum + indexPath.row];
    }else {
        emojiLabel.text = @"";
    }
    emojiLabel.font = [UIFont systemFontOfSize:25];
    [cell.contentView addSubview:emojiLabel];

}
/**点击表情事件*/
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *emojiStr = @"";
    if (self.showPageNum * indexPath.section + indexPath.item < self.emojiArray.count) {
        emojiStr = self.emojiArray[indexPath.section * self.showPageNum + indexPath.row];
    }
    //NSLog(@"表情 %@", emojiStr);
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickEmojiLabel:)]) {
        [self.delegate didClickEmojiLabel:emojiStr];
    }
}

/**
 发送表情
 */
- (void)sendEmoji {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickSendEmojiBtn)]) {
        [self.delegate didClickSendEmojiBtn];
    }
}

/**
 删除表情
 */
- (void)deleteEmoji{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickDeleteButton:)]) {
        [self.delegate didClickDeleteButton:self];
    }
}
/**
 计算表情总共占得页面数并设置pageControl
 */
- (void)countPageNums{
    NSInteger remainder = self.emojiArray.count % 27;
    NSInteger divisible = self.emojiArray.count/27;
    if (remainder==0) {
        self.pageControl.numberOfPages = divisible;
    }else{
        self.pageControl.numberOfPages = divisible + 1;
    }
}
/**
 获取系统表情包
 @return array
 */
- (NSArray *)defaultEmoticons {
    NSMutableArray *array = [NSMutableArray new];
    for (int i = 0x1F600; i <= 0x1F64F; i++) {
        if (i < 0x1F641 || i > 0x1F644) {
            int sym = EMOJI_CODE_TO_SYMBOL(i);
            NSString *emoT = [[NSString alloc] initWithBytes:&sym length:sizeof(sym) encoding:NSUTF8StringEncoding];
            [array addObject:emoT];
        }
    }
    return array;
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self cycleScroll];
}

/**
 
 */
- (void)cycleScroll {
    NSInteger page = self.fiCollectionView.contentOffset.x/self.fiCollectionView.bounds.size.width;
    _pageControl.currentPage = page;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
