//
//  FICustomEmojiView.h
//  testXibView
//
//  Created by flagadmin on 2019/3/20.
//  Copyright © 2019 flagadmin. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FICustomEmojiView;
NS_ASSUME_NONNULL_BEGIN
@protocol WZCustomEmojiDelegate <NSObject>

@optional
- (void)didClickEmojiLabel:(NSString*)emojiStr;
- (void)didClickDeleteButton:(FICustomEmojiView *)stickerKeyboard;
- (void)didClickSendEmojiBtn;

@end
@interface WZCustomEmojiView : UIView
@property (nonatomic, weak) id<WZCustomEmojiDelegate>delegate;
@end

NS_ASSUME_NONNULL_END
