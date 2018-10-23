# Matlab tools for event-based vision
This repo contains basic functions to get you going quickly when dealing with event-based recordings, which are typically recorded with cameras such as the DVS, ATIS or DAVIS.

## Representation within Matlab
Depending on the recording, there are different event types available. Currently supported are only the basic ones: **x**, **y**, timestamp **ts** and polarity **p**. Each event type is added as a field to a structure array. In the following an example of a recording with 2 million events:
```Matlab
struct with fields:
    ts: [1×2282307 double]
     x: [1×2282307 double]
     y: [1×2282307 double]
     p: [1×2282307 double]
 ```

## Functions/scripts
#### load recording
supported formats are **.es** ([the eventstream format](https://github.com/neuromorphic-paris/event_stream)) and **.dat**. In case your primary goal is to convert files, have a look at [utilities](https://github.com/neuromorphic-paris/utilities).

#### quick view
a simple viewer that accumulates the events for display purposes. Slow. Try to use [better tools](https://github.com/neuromorphic-paris/tutorials/wiki/4.-ATIS-event-stream-viewer).

#### spatial and temporal cropping
crop recordings in space (x,y) and time (ts).

#### activity
add a new field to the recording that displays activity over the whole input frame for each event.

#### shannonise
sometimes it is necessary to convert a sparse event representation into one that is sampled regurlarly. Currently this works well with the activity, this could however be adapted to accumulate events for frames (boohh) etc.

#### merging streams of events
useful if you have multiple streams of events such as in a grid, all events are sorted by timestamp. 
