//
//  SDGDTableViewCell.h
//  GoogleDriveBrowser
//
//  Created by shourov datta on 3/21/18.
//

#import <UIKit/UIKit.h>

@interface SDGDTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgFileIcon;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblSubtitle;
@property (weak, nonatomic) IBOutlet UIImageView *imgDownload;
@property (weak, nonatomic) IBOutlet UIButton *btnDownload;


@end
