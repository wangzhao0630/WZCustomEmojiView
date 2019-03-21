//
//  ViewController.m
//  WZCustomeEmojiView
//
//  Created by flagadmin on 2019/3/21.
//  Copyright © 2019 flagadmin. All rights reserved.
//
#import "WZCustomEmojiView.h"
#import "ViewController.h"

@interface ViewController ()<WZCustomEmojiDelegate,UITextViewDelegate>
@property(nonatomic, strong) UITextView *inserTF;
@property(nonatomic, strong) UIButton *changeBtn;
@property(nonatomic, strong) UIButton *sendBtn;
@property(nonatomic, strong) WZCustomEmojiView *emojiKeyboard;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.view addSubview:self.inserTF];
    [self.view addSubview:self.changeBtn];
    [self.view addSubview:self.sendBtn];
}
- (UITextView *)inserTF {
    if (!_inserTF) {
        _inserTF = [[UITextView alloc]initWithFrame:CGRectMake(20, 100, 150, 40)];
        _inserTF.font = [UIFont systemFontOfSize:15];
        _inserTF.backgroundColor = [UIColor redColor];
        _inserTF.delegate =self;
        _inserTF.textColor = [UIColor whiteColor];
    }
    return _inserTF;
}

- (UIButton *)changeBtn {
    if (!_changeBtn) {
        _changeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _changeBtn.frame = CGRectMake(190, 100, 50, 40);
        [_changeBtn setTitle:@"表情" forState:UIControlStateNormal];
        [_changeBtn setTitle:@"键盘" forState:UIControlStateSelected];
        [_changeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _changeBtn.backgroundColor = [UIColor blueColor];
        [_changeBtn addTarget:self action:@selector(changeEmoji) forControlEvents:UIControlEventTouchUpInside];
    }
    return _changeBtn;
}

- (UIButton *)sendBtn {
    if (!_sendBtn) {
        _sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _sendBtn.frame = CGRectMake(250, 100, 50, 40);
        [_sendBtn setTitle:@"发送" forState:UIControlStateNormal];
        [_sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _sendBtn.backgroundColor = [UIColor blueColor];
        [_sendBtn addTarget:self action:@selector(send) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendBtn;
}

- (WZCustomEmojiView *)emojiKeyboard {
    if (!_emojiKeyboard) {
        _emojiKeyboard = [[WZCustomEmojiView alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame) - 250, CGRectGetWidth(self.view.frame), 250)];
        _emojiKeyboard.delegate = self;
        //        _emojiKeyboard.insertTF = self.inserTF;
    }
    return _emojiKeyboard;
}
#pragma mark - EmojiDelegate
- (void)didClickSendEmojiBtn {
    [self send];
}
- (void)didClickEmojiLabel:(NSString *)emojiStr{
    if (self.inserTF) {
        self.inserTF.text = [self.inserTF.text stringByAppendingString:emojiStr];
        [self.inserTF insertText:@""];
    } else if (self.inserTF) {
        self.inserTF.text = [self.inserTF.text stringByAppendingString:emojiStr];
        [self.inserTF insertText:@""];
    } else {
        NSLog(@"未设置输入框");
    }
}
- (void)didClickDeleteButton:(FICustomEmojiView *)stickerKeyboard{
    NSRange selectedRange = self.inserTF.selectedRange;
    if (selectedRange.location == 0 && selectedRange.length == 0) {
        return;
    }
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithAttributedString:self.inserTF.attributedText];
    if (selectedRange.length > 0) {
        [attributedText deleteCharactersInRange:selectedRange];
        self.inserTF.attributedText = attributedText;
        self.inserTF.selectedRange = NSMakeRange(selectedRange.location, 0);
    } else {
        NSUInteger deleteCharactersCount = 1;
        
        // 下面这段正则匹配是用来匹配文本中的所有系统自带的 emoji 表情，以确认删除按钮将要删除的是否是 emoji。这个正则匹配可以匹配绝大部分的 emoji，得到该 emoji 的正确的 length 值；不过会将某些 combined emoji（如 👨‍👩‍👧‍👦 👨‍👩‍👧‍👦 👨‍👨‍👧‍👧），这种几个 emoji 拼在一起的 combined emoji 则会被匹配成几个个体，删除时会把 combine emoji 拆成个体。瑕不掩瑜，大部分情况下表现正确，至少也不会出现删除 emoji 时崩溃的问题了。
        NSString *emojiPattern1 = @"[\\u2600-\\u27BF\\U0001F300-\\U0001F77F\\U0001F900-\\U0001F9FF]";
        NSString *emojiPattern2 = @"[\\u2600-\\u27BF\\U0001F300-\\U0001F77F\\U0001F900–\\U0001F9FF]\\uFE0F";
        NSString *emojiPattern3 = @"[\\u2600-\\u27BF\\U0001F300-\\U0001F77F\\U0001F900–\\U0001F9FF][\\U0001F3FB-\\U0001F3FF]";
        NSString *emojiPattern4 = @"[\\rU0001F1E6-\\U0001F1FF][\\U0001F1E6-\\U0001F1FF]";
        NSString *pattern = [[NSString alloc] initWithFormat:@"%@|%@|%@|%@", emojiPattern4, emojiPattern3, emojiPattern2, emojiPattern1];
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:kNilOptions error:NULL];
        NSArray<NSTextCheckingResult *> *matches = [regex matchesInString:attributedText.string options:kNilOptions range:NSMakeRange(0, attributedText.string.length)];
        for (NSTextCheckingResult *match in matches) {
            if (match.range.location + match.range.length == selectedRange.location) {
                deleteCharactersCount = match.range.length;
                break;
            }
        }
        
        [attributedText deleteCharactersInRange:NSMakeRange(selectedRange.location - deleteCharactersCount, deleteCharactersCount)];
        self.inserTF.attributedText = attributedText;
        self.inserTF.selectedRange = NSMakeRange(selectedRange.location - deleteCharactersCount, 0);
    }
}
#pragma mark - Action
- (void)changeEmoji {
    if ([self.inserTF.inputView isKindOfClass:[WZCustomEmojiView class]]) {
        //键盘为表情键盘时切换为普通键盘
        
        self.inserTF.inputView = nil;
        self.changeBtn.selected = NO;
    } else {
        //键盘为普通键盘时切换为表情键盘
        
        self.inserTF.inputView = self.emojiKeyboard;
        self.changeBtn.selected = YES;
    }
    
    //刷新inputView
    [self.inserTF reloadInputViews];
    
}

- (void)send {
    NSLog(@"%@",self.inserTF.text);
}

@end
