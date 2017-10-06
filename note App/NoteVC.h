//
//  NoteVC.h
//  note App
//
//  Created by webwerks on 30/06/17.
//  Copyright © 2017 webwerks. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ACEDrawingView;
#import "ACEDrawingTools.h"
@interface NoteVC : UIViewController<UITableViewDelegate,UITableViewDataSource,UITextViewDelegate,UIActionSheetDelegate>
@property (nonatomic, unsafe_unretained) IBOutlet ACEDrawingView *drawingView;
@property (nonatomic, unsafe_unretained) IBOutlet UIImageView *baseImageView;



@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *expandButton;
@property (weak, nonatomic) IBOutlet UIButton *DeleteBtn;
@property (weak, nonatomic) IBOutlet UITextView *noteTF;
@property (weak, nonatomic) IBOutlet UIView *keyBoardview;
@property (weak, nonatomic) IBOutlet UIView *notePageView;
@property (weak, nonatomic) IBOutlet UIView *notesView;
@property (weak, nonatomic) IBOutlet UIView *expandBtnView;


@property (weak, nonatomic) IBOutlet UIView *colorOptionView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *colorViewHeight;
@property (weak, nonatomic) IBOutlet UIView *captureView;

- (IBAction)expandBtnPressed:(UIButton *)sender;
- (IBAction)makeNewNotePressed:(UIButton *)sender;

- (IBAction)DoneButtonPressed:(UIButton *)sender;
- (IBAction)DeleteNotesPressed:(UIButton *)sender;
- (IBAction)setColorPressed:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIView *sliderView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sliderViewHeight;
@property (weak, nonatomic) IBOutlet UISlider *sizeSlider;
- (IBAction)sliderFontValue:(UISlider *)sender;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *colorHeight;
@property (weak, nonatomic) IBOutlet UIView *drawingToolView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableviewXOrigin;
@property (weak, nonatomic) IBOutlet UILabel *noteTitle;
- (void)drawingView:(ACEDrawingView *)view willBeginDrawUsingTool:(id<ACEDrawingTool>)tool;
@end
