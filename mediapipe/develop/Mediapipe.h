#import <Foundation/Foundation.h>
#import <CoreVideo/CoreVideo.h>

@class Landmark;

@protocol TrackerDelegate <NSObject>
@optional
- (void)didReceived: (NSArray<Landmark *> *)landmarks;
@end

@interface Tracker : NSObject
- (instancetype)init;
- (void)startGraph;
- (void)processVideoFrame:(CVPixelBufferRef)imageBuffer;
@property (weak, nonatomic) id <TrackerDelegate> delegate;
@end

@interface Landmark: NSObject
@property(nonatomic, readonly) float x;
@property(nonatomic, readonly) float y;
@property(nonatomic, readonly) float z;
@end
