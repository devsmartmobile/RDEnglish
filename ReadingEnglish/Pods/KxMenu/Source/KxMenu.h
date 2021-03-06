//
//  KxMenu.h
//  kxmenu project
//  https://github.com/kolyvan/kxmenu/
//
//  Created by Kolyvan on 17.05.13.
//

/*
 Copyright (c) 2013 Konstantin Bukreev. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 - Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 - Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/


#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    MENU_TYPE_SHOWING_DETAIL_DICTIONARY,
    MENU_TYPE_SHOWING_MENU,
    MENU_TYPE_SHOWING_LIST_ALL_STORY
} MENU_TYPE_SHOWING;
typedef enum : NSUInteger {
    MENU_TYPE_AIRPRINT,
    MENU_TYPE_CANONPRINT,
} MENU_TYPE_PRINT;
typedef enum : NSUInteger {
    STORY_TYPE_CREATE_NEW,
    STORY_TYPE_LIST_ALL_STORY,
    STORY_TYPE_SAVE_ALL_STORY
} STORY_TYPE;

@interface KxMenuItem : NSObject

@property (readwrite, nonatomic, strong) UIImage *image;
@property (readwrite, nonatomic, strong) NSString *title;
@property (readwrite, nonatomic, weak) id target;
@property (readwrite, nonatomic) SEL action;
@property (readwrite, nonatomic, strong) UIColor *foreColor;
@property (readwrite, nonatomic) NSTextAlignment alignment;
@property (readwrite, nonatomic) UISlider *slider;
@property (assign, nonatomic) NSUInteger fontSize;
@property (assign, nonatomic) NSUInteger languagecode;
@property (assign, nonatomic) MENU_TYPE_PRINT typePrint;
@property (assign, nonatomic) STORY_TYPE typeStory;
+ (instancetype) menuItem:(NSString *) title
                    image:(UIImage *) image
                   target:(id)target
                   action:(SEL) action;
@end

@interface KxMenu : NSObject <UIWebViewDelegate>
@property (readwrite, nonatomic) NSString *htmlString;
@property (readwrite, nonatomic) NSString *textAudio;
@property (assign, nonatomic)  MENU_TYPE_SHOWING typeSHow;
@property (readwrite, nonatomic) NSString *audiolangCode;
@property (strong, nonatomic) id edictViewControll;
@property (strong , nonatomic) NSDictionary *arrStories;
@property (strong , nonatomic) NSArray *arrGroups;
@property (strong , nonatomic) id targetStory;
@property (assign , nonatomic) SEL selectorStory;

+ (instancetype) sharedMenu;
+ (void) showMenuInView:(UIView *)view
               fromRect:(CGRect)rect
              menuItems:(NSArray *)menuItems;
+ (void) dismissMenu;

+ (UIColor *) tintColor;
+ (void) setTintColor: (UIColor *) tintColor;

+ (UIFont *) titleFont;
+ (void) setTitleFont: (UIFont *) titleFont;

@end
