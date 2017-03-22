//
//  ReadingEnglishHeader.h
//  ReadingEnglish
//
//  Created by Tran Han on 3/22/17.
//  Copyright © 2017 HMobile. All rights reserved.
//

#ifndef ReadingEnglishHeader_h
#define ReadingEnglishHeader_h

/*---------------------------
 Check IOS Version
 ---------------------------*/
#define U_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)                           \
([[[UIDevice currentDevice] systemVersion]                                   \
compare:v                                                               \
options:NSNumericSearch] != NSOrderedAscending)
#define U_SYSTEM_CURRENT_IOS_VERSION [[UIDevice currentDevice] systemVersion]
//@"Do you want to install app via Appstore?"
#define TEXT_APPSTORE_CANNON_APP_LINK                                          \
@"itms://itunes.apple.com/us/app/apple-store/id664425773?mt=8"

#endif /* ReadingEnglishHeader_h */
