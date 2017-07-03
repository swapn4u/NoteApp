//
//  NoteVC.m
//  note App
//
//  Created by webwerks on 30/06/17.
//  Copyright © 2017 webwerks. All rights reserved.
//

#import "NoteVC.h"
#import "InfoCEll.h"
static int totalNotes;
@interface NoteVC ()
{
    
    NSIndexPath *selIndexPath;
    NSMutableArray *notesNameArr;
    BOOL isNotePreviewWindowOpened;
    InfoCEll *cell;
}

@end

@implementation NoteVC

- (void)viewDidLoad {
    [super viewDidLoad];
    notesNameArr=[[NSMutableArray alloc]init];
    [_tableView registerNib:[UINib nibWithNibName:@"InfoCEll" bundle:nil]  forCellReuseIdentifier:@"cell"];
    
    _notePageView.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"swap.png"]];
    _notesView.backgroundColor=_notePageView.backgroundColor;
    
    [_expandButton setBackgroundImage:[UIImage imageNamed:@"UNexpand.png"] forState:UIControlStateNormal];
    _noteTF.inputAccessoryView=self.keyBoardview;
    [self.keyBoardview removeFromSuperview];
    
    _noteTF.delegate=self;
    _tableView.delegate=self;
    _tableView.dataSource=self;
    // this is test for pull
 
}
-(void)viewDidAppear:(BOOL)animated
{
    
    notesNameArr.count>0 ? _tblWidthConstraint.constant=277 : 0;
    [self.view layoutIfNeeded];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return notesNameArr.count>0 ? notesNameArr.count :0;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
   cell=(InfoCEll*)[tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    NSString *noteName=notesNameArr[indexPath.row];
    cell.noteTitleLbl.text=noteName.length>24 ? [noteName substringToIndex:24] : noteName;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath
{
    selIndexPath=indexPath;
    cell=[_tableView cellForRowAtIndexPath:indexPath];
    _noteTF.text=[notesNameArr[indexPath.row] isEqualToString:@"New note"] ? @"" : notesNameArr[indexPath.row];
}

- (IBAction)expandBtnPressed:(UIButton *)sender
{
    if (notesNameArr.count>0)
    {
        [UIView animateWithDuration:0.5 animations:^{
            if([sender.currentBackgroundImage isEqual:[UIImage imageNamed:@"UNexpand.png"]])
            {
                [sender setBackgroundImage:[UIImage imageNamed:@"expand.png"] forState:UIControlStateNormal];
                _tblWidthConstraint.constant=277;
                isNotePreviewWindowOpened=YES;
                [self.view layoutIfNeeded];
                
            }
            else
            {
                [sender setBackgroundImage:[UIImage imageNamed:@"UNexpand.png"] forState:UIControlStateNormal];
                _tblWidthConstraint.constant=0;
                isNotePreviewWindowOpened=NO;
                [self.view layoutIfNeeded];
                
            }
        }];
    }
    else
    {
        UIAlertController *noNoteAlert = [UIAlertController alertControllerWithTitle:@"Preview Notes" message:@"There is no any saved notes to preview" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok=[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [self dismissViewControllerAnimated:notesNameArr completion:nil];
        }];
        [noNoteAlert addAction:ok];
        [self presentViewController:noNoteAlert animated:YES completion:nil];
    }
}

- (IBAction)makeNewNotePressed:(UIButton *)sender
{
    if(![notesNameArr containsObject:@"New note"]&&notesNameArr.count>0)
    {
        totalNotes +=1;
        [notesNameArr addObject:@"New note"];
        if(notesNameArr.count==1&&!isNotePreviewWindowOpened)
            [self expandBtnPressed:_expandButton];
        
        NSIndexPath* selectedCellIndexPath= [NSIndexPath indexPathForRow:totalNotes inSection:0];
        [self tableView:_tableView didSelectRowAtIndexPath:selectedCellIndexPath];
        [_tableView selectRowAtIndexPath:selectedCellIndexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        
        [_tableView reloadData];
    }
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    cell.noteTitleLbl.text=textView.text.length>24 ? [textView.text substringToIndex:24] : textView.text ;
    return YES;
}


-(void)textViewDidEndEditing:(UITextView *)textView
{
    //InfoCEll *cell;
    cell.noteTitleLbl.text=@"";
    if(textView.text.length>0)
    {
        if(selIndexPath.row>0)
        {
            cell=[_tableView cellForRowAtIndexPath:selIndexPath];
            if(notesNameArr.count>0)
                [notesNameArr replaceObjectAtIndex:selIndexPath.row withObject:textView.text];
            else
            {
                [notesNameArr addObject:textView.text];
            }
        }
        else
        {
            cell=[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            
            if(notesNameArr.count>0)
                [notesNameArr replaceObjectAtIndex:0 withObject:textView.text];
            else
            {
                [notesNameArr addObject:textView.text];
            }
        }
        
        if(notesNameArr.count==1&&!isNotePreviewWindowOpened)
            [self expandBtnPressed:_expandButton];
        [_tableView reloadData];
    }
}
- (IBAction)DoneButtonPressed:(UIButton *)sender
{
    [self.view endEditing:YES];
    [self.noteTF resignFirstResponder];
    if(notesNameArr.count==1&&!isNotePreviewWindowOpened)
        [self expandBtnPressed:_expandButton];
    [_tableView reloadData];

}

- (IBAction)DeleteNotesPressed:(UIButton *)sender
{
    if(selIndexPath.row>0)
    { 
        [notesNameArr removeObjectAtIndex:selIndexPath.row];
       
         selIndexPath=[NSIndexPath indexPathForRow:selIndexPath.row-1 inSection:0];
        _noteTF.text=notesNameArr[selIndexPath.row];
        [_tableView reloadData];
    }
    else
    {
        if(notesNameArr.count!=0)
        {
         [notesNameArr removeObjectAtIndex:0];
            if(notesNameArr.count==0)
            {
                [UIView animateWithDuration:0.5 animations:^{
                    [notesNameArr removeAllObjects];
                   _noteTF.text=@"";
                    [_expandButton setBackgroundImage:[UIImage imageNamed:@"UNexpand.png"] forState:UIControlStateNormal];
                    _tblWidthConstraint.constant=0;
                    isNotePreviewWindowOpened=NO;
                    [self.view layoutIfNeeded];
                }];
            }
         [_tableView reloadData];
        }
    }
}
@end
