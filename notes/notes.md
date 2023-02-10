# Notes

This is some stuff I learnt or figured out whilst making the app.

## Playback of music from the media library
You can query the media library for songs as `[MPMediaItem]`, and you can get the assetURL property of an `MPMediaItem`. 
This looks something like `ipod-library://item/item.m4a?id=1584388628414106172`

Only AVFoundation objects can access this. So you can export it using `AVAssetExportSession`, or give the URL to something like `AVPlayer` or `AVAudioPlayer`. I put it in an `AVAudioPlayer` which is used in conjunction with `AVAudioEngine` and `AVAudioUnitEQ` to provide the EQ functionality.


