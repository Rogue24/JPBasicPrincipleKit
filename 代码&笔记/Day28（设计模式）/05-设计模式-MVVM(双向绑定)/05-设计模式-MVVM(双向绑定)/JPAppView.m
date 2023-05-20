//
//  JPAppView.m
//  02-设计模式-MVC(变种)
//
//  Created by 周健平 on 2019/12/29.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "JPAppView.h"
#import "JPApp.h"
#import "NSObject+FBKVOController.h"

@interface JPAppView ()
@property (nonatomic, weak) UIImageView *iconView;
@property (nonatomic, weak) UILabel *nameLabel;
@end

@implementation JPAppView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UIImageView *iconView = ({
            UIImageView *aImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
            aImgView;
        });
        [self addSubview:iconView];
        _iconView = iconView;
        
        UILabel *nameLabel = ({
            UILabel *aLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, 100, 30)];
            aLabel.textAlignment = NSTextAlignmentCenter;
            aLabel;
        });
        [self addSubview:nameLabel];
        _nameLabel = nameLabel;
    }
    return self;
}

- (void)setAppVM:(JPAppViewModel *)appVM {
    _appVM = appVM;
    
    // 监听ViewModel的属性改变随之刷新UI
    
    __weak typeof(self) weakSelf = self;
    
    [self.KVOController observe:appVM keyPath:@"imageName" options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSKeyValueChangeKey,id> * _Nonnull change) {
        weakSelf.iconView.image = [UIImage imageNamed:change[NSKeyValueChangeNewKey]];
    }];
    
    [self.KVOController observe:appVM keyPath:@"name" options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSKeyValueChangeKey,id> * _Nonnull change) {
        weakSelf.nameLabel.text = change[NSKeyValueChangeNewKey];
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if ([self.delegate respondsToSelector:@selector(appViewDidClick:)]) {
        [self.delegate appViewDidClick:self];
    }
}

@end
