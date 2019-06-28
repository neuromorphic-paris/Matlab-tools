# Matlab tools for event-based vision
This repo contains basic functions to get you going quickly when dealing with event-based recordings, which are typically recorded with cameras such as the DVS or ATIS.

## Representation within Matlab
Depending on the recording, there are different properties of an event available. Currently supported are **x**, **y**, timestamp **ts** and polarity **p** for DVS events and is_threshold_crossing **tc** and **delta_t** properties for ATIS events, which encode grey-level values. Each event is added as a field to a structure array. In the following an example of a recording with 2 million events:
```Matlab
 struct with fields:
     ts: [1×2282307 double]
      x: [1×2282307 double]
      y: [1×2282307 double]
      p: [1×2282307 double]
     tc: [1×2282307 double]
delta_t: [1×2282307 double]
 ```

## Functions/scripts
#### load recording
supported formats are **.es** ([the eventstream format](https://github.com/neuromorphic-paris/event_stream)) and **.dat**. In case your primary goal is to convert files, have a look at [loris](https://github.com/neuromorphic-paris/loris).

#### quick view
a simple viewer that accumulates the events for display purposes. Slow and not very pretty. Try to use [better tools](https://github.com/neuromorphic-paris/tutorials/wiki/4.-ATIS-event-stream-viewer).

#### spatial and temporal cropping
crop recordings in space (x,y) and time (ts).

#### activity
add a new field to the recording that displays activity for all events given. By default it will split activity for On and Off events respectively. You may also choose the type of decay as `'exponential'` (default) or `'linear'`

#### shannonise
sometimes it is necessary to convert a sparse event representation into one that is sampled regurlarly. Currently this works well with the activity, this could however be adapted to accumulate events for frames (boohh) etc.

#### merging streams of events
useful if you have multiple streams of events such as in a grid. All events are sorted by timestamp.
