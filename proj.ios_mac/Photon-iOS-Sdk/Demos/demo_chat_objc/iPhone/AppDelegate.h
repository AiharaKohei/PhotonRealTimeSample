#import "NetworkLogic.h"
#import "Console.h"

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITextFieldDelegate, ChatDemoView>
{
@private
	NetworkLogic* app;
	UIView* mViewChat;
    UILabel* mLabelState;
    UITextField* mInputUserId;
    UITextField* mInputMessage;
    UIButton* mButtConnect;
    UIButton* mButtDisconnect;
    UIButton* mButtSubscribe;
    UIButton* mButtSetFriends;
	Console* console;
}

@property (strong, nonatomic) UIWindow* window;
@property (strong, nonatomic) ViewController* viewController;

@end