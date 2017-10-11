//
//  NoteVC.m
//  note App
//
//  Created by webwerks on 30/06/17.
//  Copyright © 2017 webwerks. All rights reserved.
//

#import "NoteVC.h"
#import "ACEDrawingView.h"
#import <AVFoundation/AVUtilities.h>
#import <QuartzCore/QuartzCore.h>
#import "InfoCEll.h"
#import "UIView+DropShadow.h"
#define tableXAxis -305
#define sliderStepValue 2.0f
static int totalNotes;
@interface NoteVC ()<ACEDrawingViewDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    
    NSIndexPath *selIndexPath;
    NSMutableArray *notesNameArr;
    BOOL isNotePreviewWindowOpened;
    InfoCEll *cell;
    BOOL isNewNoting,isDeleteClick;
    int lastQuestionStep;
   
}

@end

@implementation NoteVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [_notesView DefaultShadow];
    [_expandBtnView addDropShadow:[UIColor blackColor] withOffset:CGSizeMake(0,1) radius:1 opacity:1];
    
    lastQuestionStep = (self.sizeSlider.value) /sliderStepValue;
    
    _colorViewHeight.constant=0.0f;
    for (NSLayoutConstraint *constraint in self.colorHeight)
        {                constraint.constant=0;
        }
    _sliderViewHeight.constant=0.0f;
    _sizeSlider.hidden=YES;
    
    _drawingToolView.hidden=YES;
    
     self.drawingView.delegate = self;
    for (UIView *view in [_colorOptionView subviews])
    {
        if([view isKindOfClass:[UIButton class]])
        {
            view.layer.cornerRadius=view.frame.size.width/2;
            view.layer.borderWidth=2.0f;
            view.layer.borderColor=[UIColor blackColor].CGColor;
        }
    }
    
    notesNameArr=[[NSMutableArray alloc]init];
    [_tableView registerNib:[UINib nibWithNibName:@"InfoCEll" bundle:nil]  forCellReuseIdentifier:@"cell"];

    
    [_expandButton setBackgroundImage:[UIImage imageNamed:@"UNexpand.png"] forState:UIControlStateNormal];
    _noteTF.inputAccessoryView=self.keyBoardview;
    [self.keyBoardview removeFromSuperview];
    
    _noteTF.delegate=self;
    _tableView.delegate=self;
    _tableView.dataSource=self;
    _sliderView.transform= CGAffineTransformMakeRotation(-M_PI_2);

 
}
-(void)viewDidAppear:(BOOL)animated
{
    
    [self.view layoutIfNeeded];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return notesNameArr.count>0 ? notesNameArr.count :0;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
   cell=(InfoCEll*)[tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    NSString *noteName=@"";
    if([notesNameArr[indexPath.row] isKindOfClass:[NSDictionary class]])
    {
         noteName=[notesNameArr[indexPath.row] valueForKey:@"noteName"];
    }
    else
    {
         noteName=notesNameArr[indexPath.row];
    }
    cell.noteTitleLbl.text=noteName.length>24 ? [noteName substringToIndex:24] : noteName;
    cell.backgroundColor=[UIColor clearColor];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath
{
   
    isNewNoting=NO;
    selIndexPath=indexPath;
    cell=[_tableView cellForRowAtIndexPath:indexPath];
    if([notesNameArr[indexPath.row] isKindOfClass:[NSDictionary class]])
    {
        _noteTF.hidden=YES;
        _baseImageView.hidden=NO;
        _drawingView.hidden=NO;
        [self ClearNoting:nil];
        UIImage *noteImage=[UIImage imageWithData:[notesNameArr[indexPath.row] valueForKey:@"noteImage"]];
        _noteTitle.text=[[notesNameArr[indexPath.row] valueForKey:@"noteName"] length] >30 ? [[notesNameArr[indexPath.row] valueForKey:@"noteName"]  substringToIndex:30] : [notesNameArr[indexPath.row] valueForKey:@"noteName"];
        _baseImageView.image=noteImage;
    }
    else
    {
        _noteTF.hidden=NO;
        _baseImageView.hidden=YES;
        _drawingView.hidden=YES;
        _drawingToolView.hidden=YES;
        _noteTF.text=[notesNameArr[indexPath.row] isEqualToString:@"New note"] ? @"" : notesNameArr[indexPath.row];
        _noteTitle.text=_noteTF.text.length>30 ? [_noteTF.text substringToIndex:30] : _noteTF.text;
    }
    [self expandBtnPressed:_expandButton];
}
- (UIImage *)ForRawImage:(UIImage*)freeHandImage
{
   
    UIImage *image = self.drawingView.image;
    
    UIGraphicsBeginImageContext( freeHandImage.size );
    CGRect imageFrame = CGRectMake(0.0f, 0.0f, freeHandImage.size.width, freeHandImage.size.height);
    
    // Use existing opacity as is
    [freeHandImage drawInRect:imageFrame];
    
    // Apply supplied opacity
    [image drawInRect:imageFrame blendMode:kCGBlendModeNormal alpha:0.8];
    
    UIImage *blendImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return blendImage;
}
-(void)AnimateButtonWithRotation
{
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    if(isNotePreviewWindowOpened)
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0  * 0.5 * 0.5 ];
    else
    rotationAnimation.toValue = [NSNumber numberWithFloat: -(M_PI * 2.0  * 0.5 * 0.5 )];
    rotationAnimation.duration = 0.5;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = 0;//repeat ? HUGE_VALF : 0;
    
    [_expandButton.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}
- (void)HideShowTableView:(UIButton *)sender {
    [UIView animateWithDuration:0.5 animations:^{
        
        if([sender.currentBackgroundImage isEqual:[UIImage imageNamed:@"UNexpand.png"]])
        {
            [sender setBackgroundImage:[UIImage imageNamed:@"expand.png"] forState:UIControlStateNormal];
            _tableviewXOrigin.constant=0;
            isNotePreviewWindowOpened=YES;
            [self.view layoutIfNeeded];
            
        }
        else
        {
            [sender setBackgroundImage:[UIImage imageNamed:@"UNexpand.png"] forState:UIControlStateNormal];
            _tableviewXOrigin.constant=tableXAxis;
            isNotePreviewWindowOpened=NO;
            [self.view layoutIfNeeded];
            
        }
        [self  AnimateButtonWithRotation];
    }];
}

- (IBAction)expandBtnPressed:(UIButton *)sender
{
    [self.view endEditing:YES];
    if (notesNameArr.count>0)
    {
        [self HideShowTableView:_expandButton];
    }
    else
    {
        if (sender!=nil)
        {
            NSString *alertMsg=@"";
            if(sender==_expandButton)
            {
                alertMsg=@"There is no any saved notes to preview";
            }
            else if(sender==_DeleteBtn)
            {
                alertMsg=@"There is no any saved notes to delete";
            }
            
            UIAlertController *noNoteAlert = [UIAlertController alertControllerWithTitle:@"Notes" message:alertMsg preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ok=[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [self dismissViewControllerAnimated:notesNameArr completion:nil];
            }];
            [noNoteAlert addAction:ok];
            [self presentViewController:noNoteAlert animated:YES completion:nil];
        }
    }
}

- (IBAction)makeNewNotePressed:(UIButton *)sender
{
    _noteTitle.text=@"";
    [self ClearNoting:nil];
    _baseImageView.hidden=YES;
    _drawingView.hidden=YES;
    _noteTF.hidden=NO;
    if(![notesNameArr containsObject:@"New note"]&&notesNameArr.count>0)
    {
        totalNotes +=1;
        [notesNameArr addObject:@"New note"];
        [_expandButton setBackgroundImage:[UIImage imageNamed:@"expand.png"] forState:UIControlStateNormal];
        NSIndexPath* selectedCellIndexPath= [NSIndexPath indexPathForRow:notesNameArr.count-1 inSection:0];
        [self tableView:_tableView didSelectRowAtIndexPath:selectedCellIndexPath];
        [_tableView selectRowAtIndexPath:selectedCellIndexPath animated:YES scrollPosition:UITableViewScrollPositionNone];

        [_tableView reloadData];
    }
}
-(void)textViewDidBeginEditing:(UITextField *)textField {
    if(_tableviewXOrigin.constant==0)
    [self HideShowTableView:_expandButton];
}
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    NSString *updatedStr = [textView.text stringByAppendingString:text];
    cell.noteTitleLbl.text=updatedStr.length>24 ? [updatedStr substringToIndex:24] : updatedStr ;
    _noteTitle.text=updatedStr.length>30 ? [updatedStr substringToIndex:30] : updatedStr;
    
        
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

        [_tableView reloadData];
    }
}
- (IBAction)DoneButtonPressed:(UIButton *)sender
{
    [self.view endEditing:YES];
    [self.noteTF resignFirstResponder];
//    if(notesNameArr.count==1&&!isNotePreviewWindowOpened)
//        [self HideShowTableView:_expandButton];
    if(_tableviewXOrigin.constant==0)
    {
        [self HideShowTableView:_expandButton];
    }
    
        if([notesNameArr containsObject:@"New note"])
        {
            NSInteger emptyNoteIndex=[notesNameArr indexOfObject:@"New note"];
            if(NSNotFound == emptyNoteIndex) {
                NSLog(@"not found");
            }
            else{
                
                NSLog(@"index of new note : %ld",(long)emptyNoteIndex);
                [notesNameArr removeObjectAtIndex:emptyNoteIndex];
            }
        }
    [_tableView reloadData];

}
-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
-(void)hideUnusedView:(BOOL)isShow
{
    _noteTF.hidden=!isShow;
    _drawingView.hidden=isShow;
    _baseImageView.hidden=isShow;
}
- (IBAction)DeleteNotesPressed:(UIButton *)sender
{
    if(notesNameArr.count==0)
    {
        _noteTF.text=@"";
        _noteTitle.text=@"";
        _baseImageView.image=nil;
        [self ClearNoting:nil];
        
        [self expandBtnPressed:_DeleteBtn];
        return;
    }
    [self.view endEditing:YES];
    isDeleteClick=YES;
    NSString *noteName=@"";
    if(selIndexPath.row>0)
    {
        [notesNameArr removeObjectAtIndex:selIndexPath.row];
        
        selIndexPath=[NSIndexPath indexPathForRow:selIndexPath.row-1 inSection:0];
        
        if([notesNameArr[selIndexPath.row] isKindOfClass:[NSDictionary class]])
        {
            UIImage *noteImage=[UIImage imageWithData:[notesNameArr[selIndexPath.row] valueForKey:@"noteImage"]];
            [self hideUnusedView:NO];
            _baseImageView.image=nil;
            _baseImageView.image=noteImage;
            noteName=[notesNameArr[selIndexPath.row] valueForKey:@"noteName"];
            
        }
        else
        {
            [self hideUnusedView:YES];
            noteName=notesNameArr[selIndexPath.row];
            _noteTF.text=noteName;
        }
        _noteTitle.text=noteName.length>30 ? [noteName substringToIndex:30] : noteName;
        [_tableView reloadData];
    }
    else
    {
        if(notesNameArr.count!=0)
        {
            [notesNameArr removeObjectAtIndex:0];
            if(notesNameArr.count==0)
            {
                if(_tableviewXOrigin.constant==0)
                 [self HideShowTableView:_expandButton];
                _noteTF.text=@"";
                _noteTitle.text=@"";
                _baseImageView.image=nil;
                [self ClearNoting:nil];
            }
            else
            {
                if([notesNameArr[0] isKindOfClass:[NSDictionary class]])
                {
                    UIImage *noteImage=[UIImage imageWithData:[notesNameArr[0] valueForKey:@"noteImage"]];
                    [self hideUnusedView:NO];
                    _baseImageView.image=nil;
                    _baseImageView.image=noteImage;
                    noteName=[notesNameArr[0] valueForKey:@"noteName"];
                    
                }
                else
                {
                    [self hideUnusedView:YES];
                    noteName=notesNameArr[0];
                    _noteTF.text=noteName;
                }
                _noteTitle.text=noteName.length>30 ? [noteName substringToIndex:30] : noteName;
            }
            [_tableView reloadData];
        }
        
    }
}

- (IBAction)setColorPressed:(UIButton *)sender
{
    [self openColorPannel];
    switch (sender.tag)
    {
        case 0:
             self.drawingView.lineColor=[UIColor blackColor];
             break;
            
        case 1:
            self.drawingView.lineColor=[UIColor brownColor];
            break;
           
        case 2:
           self.drawingView.lineColor=[UIColor blueColor];
            
            break;
        case 3:
            self.drawingView.lineColor=[UIColor redColor];
            
            break;
        case 4:
            self.drawingView.lineColor=[UIColor greenColor];
            
            break;
            
        default:
            break;
    }
}

- (IBAction)FreeHandDrawingPressed:(UIButton *)sender
{
    if(_tableviewXOrigin.constant==0)
    {
        [self HideShowTableView:_expandButton];
    }
    [self.view endEditing:YES];
    _noteTitle.text=@"";
    isNewNoting=YES;
    _noteTF.hidden=YES;
    [self ClearNoting:nil];
    _drawingView.hidden=NO;
   _drawingToolView.hidden=NO;

}
- (IBAction)ClearNoting:(UIButton *)sender
{
    if ([self.baseImageView image])
    {
        [self.baseImageView setImage:nil];
        [self.drawingView setFrame:self.baseImageView.frame];
    }
    
    [self.drawingView clear];
}
-(void)openColorPannel
{
    if(_sliderViewHeight.constant==178.0f)
    {
        [self openFontSize:nil];
    }
    [UIView animateWithDuration:0.5 animations:^{
        if(_colorViewHeight.constant==0.0f)
        {
            _colorViewHeight.constant=160.0f;
           for (NSLayoutConstraint *constraint in self.colorHeight)
           {
               constraint.constant=28;
           }
        }
        else
        {
            _colorViewHeight.constant=0.0f;
            for (NSLayoutConstraint *constraint in self.colorHeight)
            {
                constraint.constant=0;
            }
        }
        [self.view layoutIfNeeded];
    }];

}
- (IBAction)openColorPicker:(UIButton *)sender
{
    [self openColorPannel];
}
- (IBAction)openFontSize:(UIButton *)sender
{
    if(_colorViewHeight.constant==160.0f)
    {
        [self openColorPannel];
    }
    [UIView animateWithDuration:0.5 animations:^{
        if(_sliderViewHeight.constant==0.0f)
        {
            _sliderViewHeight.constant=178.0f;
             _sizeSlider.hidden=NO;
        }
        else
        {
            _sliderViewHeight.constant=0.0f;
             _sizeSlider.hidden=YES;
        }
        [self.view layoutIfNeeded];
       
    }];
    //fontSizeViewOpened = !fontSizeViewOpened;
}
- (IBAction)sliderFontValue:(UISlider *)sender
{
    //self.drawingView.lineWidth=sender.value;//*7.5+7.5;
    
    // This determines which "step" the slider should be on. Here we're taking
    //   the current position of the slider and dividing by the `self.stepValue`
    //   to determine approximately which step we are on. Then we round to get to
    //   find which step we are closest to.
    float newStep = roundf((_sizeSlider.value) / sliderStepValue);
    
    // Convert "steps" back to the context of the sliders values.
    _sizeSlider.value = newStep > 1 ? newStep * sliderStepValue : newStep;
    self.drawingView.lineWidth=newStep * sliderStepValue;
    
    
}

-(void)CaptureAndSaveNotingWithName:(NSString*)noteTitle
{
    //Get the size of the screen
    CGRect screenRect = [_captureView frame];
    
    //Create a bitmap-based graphics context and make
    //it the current context passing in the screen size
    UIGraphicsBeginImageContext(screenRect.size);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [[UIColor blackColor] set];
    CGContextFillRect(ctx, screenRect);
    [_captureView.layer renderInContext:ctx];
    UIImage *newImage =UIGraphicsGetImageFromCurrentImageContext();
    
     [self.drawingView clear];
    _baseImageView.hidden=NO;
     [self.baseImageView setImage:newImage];
   
    //End the bitmap-based graphics context
    UIGraphicsEndImageContext();
    NSData* noteData = UIImagePNGRepresentation(newImage);
    NSDictionary *picInfo = @{@"noteName":noteTitle,@"noteImage":noteData}.mutableCopy;
    if(isNewNoting)
    {
     [notesNameArr addObject:picInfo];
    }
    else
    {
     [notesNameArr replaceObjectAtIndex:selIndexPath.row  withObject:picInfo];
    }
    [_tableView reloadData];
    _noteTitle.text=noteTitle.length>30 ? [noteTitle substringToIndex:30] : noteTitle;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Note" message:@"Note saved successfully" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
    
}
- (IBAction)saveFreeHandNote:(UIButton *)sender
{
    if(isNewNoting)
    {
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"save" message: @"Enter title for note" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
         {
             textField.placeholder = @"Enter title...";
             textField.textColor = [UIColor blackColor];
             textField.clearButtonMode = UITextFieldViewModeWhileEditing;
             textField.borderStyle = UITextBorderStyleRoundedRect;
         }];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSArray * textfields = alertController.textFields;
            UITextField * notetitle = textfields[0];
            if([notetitle.text stringByReplacingOccurrencesOfString:@" " withString:@""].length==0)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Save Note" message:@"Noting Title cannot be blank" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
            else
            {
                [self CaptureAndSaveNotingWithName:notetitle.text];
               // [self ClearNoting:nil];
                NSLog(@"%@",notetitle.text);
            }
            
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else
    {
        [self CaptureAndSaveNotingWithName:[notesNameArr[selIndexPath.row] valueForKey:@"noteName"]];
        
    
    }
    _drawingToolView.hidden=YES;
}
#pragma mark - ACEDrawing View Delegate

- (void)drawingView:(ACEDrawingView *)view didEndDrawUsingTool:(id<ACEDrawingTool>)tool;
{
    //[self updateButtonStatus];
}
- (IBAction)UndoAction:(UIButton *)sender {
    [self.drawingView undoLatestStep];
}
- (IBAction)redoAction:(UIButton *)sender {
    [self.drawingView redoLatestStep];
}
- (void)drawingView:(ACEDrawingView *)view willBeginDrawUsingTool:(id<ACEDrawingTool>)tool
{
    [UIView animateWithDuration:0.5 animations:^{
        _colorViewHeight.constant=0.0f;
        for (NSLayoutConstraint *constraint in self.colorHeight)
        {
            constraint.constant=0;
        }
        _sliderViewHeight.constant=0.0f;
        _sizeSlider.hidden=YES;
        _drawingToolView.hidden=NO;
        [self.view layoutIfNeeded];
    }];
    if(_tableviewXOrigin.constant==0)
    [self HideShowTableView:_expandButton];
    
    
}
- (IBAction)CancelFreeHandeEditing:(UIButton *)sender
{
    _drawingToolView.hidden=YES;
    if (isNewNoting)
    {
     [self ClearNoting:nil];
    }
    else
    {
        [self ClearNoting:nil];
        _baseImageView.image=[UIImage imageWithData:[notesNameArr[selIndexPath.row] valueForKey:@"noteImage"]];
      
    }
   
}
- (IBAction)ChooseToolsPressed:(UIButton *)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select a tool" delegate:self                                                    cancelButtonTitle:@"Cancel"                                               destructiveButtonTitle:nil                                                    otherButtonTitles:@"Pen", @"Line", @"Arrow",@"Rect (Stroke)", @"Rect (Fill)",@"Ellipse (Stroke)", @"Ellipse (Fill)",nil];
    
    [actionSheet showInView:self.view];
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (actionSheet.cancelButtonIndex != buttonIndex)
    {
        switch (buttonIndex) {
            case 0:
                self.drawingView.drawTool = ACEDrawingToolTypePen;                    break;
            case 1:
                self.drawingView.drawTool = ACEDrawingToolTypeLine;                    break;
            case 2:
                self.drawingView.drawTool = ACEDrawingToolTypeArrow;                    break;
            case 3:
                self.drawingView.drawTool = ACEDrawingToolTypeRectagleStroke;                    break;
            case 4:
                self.drawingView.drawTool = ACEDrawingToolTypeRectagleFill;                    break;
            case 5:
                self.drawingView.drawTool = ACEDrawingToolTypeEllipseStroke;                    break;
            case 6:
                self.drawingView.drawTool = ACEDrawingToolTypeEllipseFill;                    break;
           
        }
    }
}
- (IBAction)imageChange:(id)sender
{
    UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Add Image" message:@"Choose media for proceed :"                                                                 preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* FromCamera = [UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault                                                              handler:^(UIAlertAction * action)
                                     {
                                         imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera ;
                                          [self presentViewController:imagePicker animated:YES completion:nil];
                                     }];
        UIAlertAction* fromGallery = [UIAlertAction actionWithTitle:@"Gallery" style:UIAlertActionStyleDefault                                                              handler:^(UIAlertAction * action)
                                      {
                                          imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                           [self presentViewController:imagePicker animated:YES completion:nil];
                                      }];
        UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive                                                              handler:^(UIAlertAction * action)
                                      {
                                          
                                      }];
        
        [alert addAction:FromCamera];
        [alert addAction:fromGallery];
        [alert addAction:cancel];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else
    {
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary ;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
   
}

- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary*)info
{
    [self.drawingView clear];
    UIImage* image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self.baseImageView setImage:image];
 
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
