//
//  NSKVONotifying_JPPerson.h
//  01-KVO
//
//  Created by 周健平 on 2019/10/25.
//  Copyright © 2019 周健平. All rights reserved.
//

// 【伪】NSKVONotifying_JPPerson
// 在 Build Phases 的 Compile Sources 中去掉该文件，不要参与到编译中。
// 不然就会报错：KVO failed to allocate class pair for name NSKVONotifying_JPPerson, automatic key-value observing will not work for this class，无法继续使用KVO，因为跟使用KVO生成的类同名了

#import "JPPerson.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSKVONotifying_JPPerson : JPPerson

@end

NS_ASSUME_NONNULL_END
