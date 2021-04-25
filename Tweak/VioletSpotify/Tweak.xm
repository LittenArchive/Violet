#import "VioletSpotify.h"

BOOL enabled;
BOOL enableSpotifyApplicationSection;

// Spotify Application

%group VioletSpotify

%hook MPNowPlayingInfoCenter

- (void)setNowPlayingInfo:(id)arg1 { // post notification to dynamically change artwork
	
	%orig;

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.4 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Violet-setSpotifyArtwork" object:nil];
    });

}

%end

%hook SPTNowPlayingViewController

%new
- (void)setArtwork { // get and set the artwork

	if (!spotifyArtworkBackgroundSwitch) return;
	MRMediaRemoteGetNowPlayingInfo(dispatch_get_main_queue(), ^(CFDictionaryRef information) {
		NSDictionary* dict = (__bridge NSDictionary *)information;
		if (dict) {
			if (dict[(__bridge NSString *)kMRMediaRemoteNowPlayingInfoArtworkData]) {
				currentArtwork = [UIImage imageWithData:[dict objectForKey:(__bridge NSString*)kMRMediaRemoteNowPlayingInfoArtworkData]];
				if (currentArtwork) {
					[spotifyArtworkBackgroundImageView setImage:currentArtwork];
					[spotifyArtworkBackgroundImageView setHidden:NO];
					if ([spotifyArtworkBlurMode intValue] != 0) [spotifyBlurView setHidden:NO];
				}
			}
      	}
  	});

}

- (void)viewDidLoad { // add artwork background

	%orig;

	if (!spotifyArtworkBackgroundSwitch) return;
	if (!spotifyArtworkBackgroundImageView) spotifyArtworkBackgroundImageView = [[UIImageView alloc] initWithFrame:[[self view] bounds]];
	[spotifyArtworkBackgroundImageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	[spotifyArtworkBackgroundImageView setContentMode:UIViewContentModeScaleAspectFill];
	[spotifyArtworkBackgroundImageView setHidden:NO];
	[spotifyArtworkBackgroundImageView setClipsToBounds:YES];
	[spotifyArtworkBackgroundImageView setAlpha:[spotifyArtworkOpacityValue doubleValue]];
	if (![spotifyArtworkBackgroundImageView isDescendantOfView:[self view]]) [[self view] insertSubview:spotifyArtworkBackgroundImageView atIndex:0];

	if ([spotifyArtworkBlurMode intValue] != 0) {
		if (!spotifyBlur) {
			if ([spotifyArtworkBlurMode intValue] == 1)
				spotifyBlur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
			else if ([spotifyArtworkBlurMode intValue] == 2)
				spotifyBlur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
			else if ([spotifyArtworkBlurMode intValue] == 3)
				spotifyBlur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular];
			spotifyBlurView = [[UIVisualEffectView alloc] initWithEffect:spotifyBlur];
			[spotifyBlurView setFrame:[spotifyArtworkBackgroundImageView bounds]];
			[spotifyBlurView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
			[spotifyBlurView setClipsToBounds:YES];
			[spotifyBlurView setAlpha:[spotifyArtworkBlurAmountValue doubleValue]];
			if (![spotifyBlurView isDescendantOfView:spotifyArtworkBackgroundImageView]) [spotifyArtworkBackgroundImageView addSubview:spotifyBlurView];
		}
		[spotifyBlurView setHidden:NO];
	}

	if ([spotifyArtworkDimValue doubleValue] != 0.0) {
		if (!spotifyDimView) spotifyDimView = [[UIView alloc] init];
		[spotifyDimView setFrame:[spotifyArtworkBackgroundImageView bounds]];
		[spotifyDimView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
		[spotifyDimView setClipsToBounds:YES];
		[spotifyDimView setBackgroundColor:[UIColor blackColor]];
		[spotifyDimView setAlpha:[spotifyArtworkDimValue doubleValue]];
		[spotifyDimView setHidden:NO];
		if (![spotifyDimView isDescendantOfView:spotifyArtworkBackgroundImageView]) [spotifyArtworkBackgroundImageView addSubview:spotifyDimView];
	}

	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setArtwork) name:@"Violet-setSpotifyArtwork" object:nil]; // add notification observer to dynamically change artwork

}

- (void)viewWillAppear:(BOOL)animated {

	%orig;

	[self setArtwork];

}

%end

%hook SPTNowPlayingCoverArtCell

- (void)didMoveToWindow { // hide artwork

	%orig;

	[self setHidden:hideArtworkSwitch];

}

%end

%hook SPTNowPlayingNextTrackButton

- (void)didMoveToWindow { // hide next track button

	%orig;

	[self setHidden:hideNextTrackButtonSwitch];

}

%end

%hook SPTNowPlayingPreviousTrackButton

- (void)didMoveToWindow { // hide previous track button

	%orig;

	[self setHidden:hidePreviousTrackButtonSwitch];

}

%end

%hook SPTNowPlayingPlayButtonV2

- (void)didMoveToWindow { // hide play/pause button

	%orig;

	[self setHidden:hidePlayButtonSwitch];

}

%end

%hook SPTNowPlayingShuffleButton

- (void)didMoveToWindow { // hide shuffle button

	%orig;

	[self setHidden:hideShuffleButtonSwitch];

}

%end

%hook SPTNowPlayingRepeatButton

- (void)didMoveToWindow { // hide repeat button

	%orig;

	[self setHidden:hideRepeatButtonSwitch];

}

%end

%hook SPTGaiaDevicesAvailableViewImplementation

- (void)didMoveToWindow { // hide devices button

	%orig;

	[self setHidden:hideDevicesButtonSwitch];

}

%end

%hook SPTNowPlayingQueueButton

- (void)didMoveToWindow { // hide queue button

	%orig;

	[self setHidden:hideDevicesButtonSwitch];

}

%end

%hook SPTNowPlayingSliderV2

- (void)didMoveToWindow { // hide time slider

	%orig;

	[self setHidden:hideTimeSliderSwitch];

}

%end

%hook SPTNowPlayingDurationViewV2

- (void)didMoveToWindow { // hide remaining and elapsed time label

	%orig;

	if (hideRemainingTimeLabelSwitch) {
		UILabel* remainingTimeLabel = MSHookIvar<UILabel *>(self, "_timeRemainingLabel");
		[remainingTimeLabel setHidden:YES];
	}

	if (hideElapsedTimeLabelSwitch) {
		UILabel* elapsedTimeLabel = MSHookIvar<UILabel *>(self, "_timeTakenLabel");
		[elapsedTimeLabel setHidden:YES];
	}

}

%end

%hook SPTNowPlayingAnimatedLikeButton

- (void)didMoveToWindow { // hide like button

	%orig;

	[self setHidden:hideLikeButtonSwitch];

}

%end

%hook SPTNowPlayingTitleButton

- (void)didMoveToWindow { // hide back button

	%orig;

	[self setHidden:hideBackButtonSwitch];

}

%end

%hook SPTContextMenuAccessoryButton

- (void)didMoveToWindow { // hide context button

	%orig;

	[self setHidden:hideContextButtonSwitch];

}

%end

%hook SPTNowPlayingNavigationBarViewV2

- (void)didMoveToWindow { // hide playlist title

	%orig;

	if (hidePlaylistTitleSwitch) {
		SPTNowPlayingMarqueeLabel* title = MSHookIvar<SPTNowPlayingMarqueeLabel *>(self, "_titleLabel");
		[title setHidden:YES];
	}

}

%end

%hook SPTNowPlayingMarqueeLabel

- (void)didMoveToWindow { // hide song title, artist name, playlist title

	%orig;

	if (hideSongTitleSwitch) {
		UILabel* songTitle = MSHookIvar<UILabel *>(self, "_label");
		[songTitle setHidden:YES];
	}

}

%end

%end

%ctor {

	preferences = [[HBPreferences alloc] initWithIdentifier:@"love.litten.violetpreferences"];

    [preferences registerBool:&enabled default:nil forKey:@"Enabled"];
	[preferences registerBool:&enableSpotifyApplicationSection default:nil forKey:@"EnableSpotifyApplicationSection"];

	// Spotify
	[preferences registerBool:&spotifyArtworkBackgroundSwitch default:NO forKey:@"spotifyArtworkBackground"];
	[preferences registerObject:&spotifyArtworkBlurMode default:@"0" forKey:@"spotifyArtworkBlur"];
	[preferences registerObject:&spotifyArtworkBlurAmountValue default:@"1.0" forKey:@"spotifyArtworkBlurAmount"];
	[preferences registerObject:&spotifyArtworkOpacityValue default:@"1.0" forKey:@"spotifyArtworkOpacity"];
	[preferences registerObject:&spotifyArtworkDimValue default:@"0.0" forKey:@"spotifyArtworkDim"];
	[preferences registerBool:&hideArtworkSwitch default:NO forKey:@"spotifyHideArtwork"];
	[preferences registerBool:&hideNextTrackButtonSwitch default:NO forKey:@"spotifyHideNextTrackButton"];
	[preferences registerBool:&hidePreviousTrackButtonSwitch default:NO forKey:@"spotifyHidePreviousTrackButton"];
	[preferences registerBool:&hidePlayButtonSwitch default:NO forKey:@"spotifyHidePlayButton"];
	[preferences registerBool:&hideShuffleButtonSwitch default:NO forKey:@"spotifyHideShuffleButton"];
	[preferences registerBool:&hideRepeatButtonSwitch default:NO forKey:@"spotifyHideRepeatButton"];
	[preferences registerBool:&hideDevicesButtonSwitch default:NO forKey:@"spotifyHideDevicesButton"];
	[preferences registerBool:&hideQueueButtonSwitch default:NO forKey:@"spotifyHideQueueButton"];
	[preferences registerBool:&hideSongTitleSwitch default:NO forKey:@"spotifyHideSongTitle"];
	[preferences registerBool:&hideTimeSliderSwitch default:NO forKey:@"spotifyHideTimeSlider"];
	[preferences registerBool:&hideRemainingTimeLabelSwitch default:NO forKey:@"spotifyHideRemainingTimeLabel"];
	[preferences registerBool:&hideElapsedTimeLabelSwitch default:NO forKey:@"spotifyHideElapsedTimeLabel"];
	[preferences registerBool:&hideLikeButtonSwitch default:NO forKey:@"spotifyHideLikeButton"];
	[preferences registerBool:&hideBackButtonSwitch default:NO forKey:@"spotifyHideBackButton"];
	[preferences registerBool:&hideContextButtonSwitch default:NO forKey:@"spotifyHideContextButton"];
	[preferences registerBool:&hidePlaylistTitleSwitch default:NO forKey:@"spotifyHidePlaylistTitle"];

	if (enabled) {
		if (enableSpotifyApplicationSection) %init(VioletSpotify);
		return;
    }

}