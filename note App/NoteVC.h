//
//  NoteVC.h
//  note App
//
//  Created by webwerks on 30/06/17.
//  Copyright © 2017 webwerks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NoteVC : UIViewController<UITableViewDelegate,UITableViewDataSource,UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *expandButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tblWidthConstraint;
@property (weak, nonatomic) IBOutlet UITextView *noteTF;
@property (weak, nonatomic) IBOutlet UIView *keyBoardview;
@property (weak, nonatomic) IBOutlet UIView *notePageView;
@property (weak, nonatomic) IBOutlet UIView *notesView;




- (IBAction)expandBtnPressed:(UIButton *)sender;
- (IBAction)makeNewNotePressed:(UIButton *)sender;

- (IBAction)DoneButtonPressed:(UIButton *)sender;
- (IBAction)DeleteNotesPressed:(UIButton *)sender;

@end
