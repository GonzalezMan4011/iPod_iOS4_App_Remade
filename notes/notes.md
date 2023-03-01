# Notes

This is some stuff I learnt or figured out whilst making the app.

## Playback of music from the media library
You can query the media library for songs as `[MPMediaItem]`, and you can get the assetURL property of an `MPMediaItem`. 
This looks something like `ipod-library://item/item.m4a?id=1584388628414106172`

Only AVFoundation objects can access this. So you can export it using `AVAssetExportSession`, or give the URL to something like `AVPlayer` or `AVAudioPlayer`. I put it in an `AVAudioPlayerNode` which is used in conjunction with `AVAudioEngine` and `AVAudioUnitEQ` to provide the EQ functionality.

## Queues

This was a real pain, I made an array of UInt64 (`MPMediaItem` persistent id's) and I watch for when the audio player executes a callback that is called when playback ends, this runs some code to play the next id in the queue and push the current song to the end of another array for playback history. This callback is executed whenever playback finishes or `stop()` is called on `AVAudioPlayerNode`, but I needed to do something else when `stop()` is called so I used a boolean variable to stop the callback doing normal stuff so I can call `stop()` as needed.

This is a terrible way to do queues and stuff but I just don't care, `AVAudioPlayerNode` sucks.

## Playback Progress

`AVAudioPlayerNode` does not have an easy way to get the current playhead location or whatever you'd like to call it. Here's how you get it.
Assuming your `AVAudioPlayerNode` is in a variable named `player`:
> Get your `player.lastRenderTime`, note that this is optional and won't be available when it's paused. I store this in a variable named `nodeTime`
> Declare playerTime with `player.playerTime(forNodeTime: nodeTime)`, this is optional too.
> You can now get the number of seconds your player has read into with `Double(playerTime.sampleTime) / playerTime.sampleRate`!
