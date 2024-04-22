## Description

This repository contains an example project to demonstrate the BUG related on the [150](https://github.com/JaffaKetchup/flutter_map_tile_caching/issues/150) issue of `flutter_map_tile_caching` plugin.
It contains the minimum code needed to reproduce the problem.

## The BUG
The 9.0.0 version of the `flutter_map_tile_caching` plugin doesn't work properly when it runs with the `background_location_tracker` plugin.
When the app's running on background and the application returns to foreground, the `main.dart` file runs and the flutter_map_tile_caching try to initialize. However, it generates the follow error:

> StateError (Bad state: failed to create store: Cannot open store: another store is still open using the same path: "/data/data/com.example.app_name/app_flutter/fmtc" (OBX_ERROR code 10001))

That, makes the map screen doesn't be displayed and generates the follow exception:

> RootUnavailable (RootUnavailable: The requested backend/root was unavailable)

# How to reproduce
This repository has a file called [release_example.mkv](./release_example.mkv). It's a video recorded from an Pixel 8 emulator with Android 14. It demonstrates the step-by-step necessary to reproduce the bug.

Additionally, all steps are described here:

- Run the application in Android devices (emulators or real real devices)
- Allow the location permission for "While using the app"
- Allow the location permission for "All the time"
    * That's required to the app runs on background mode
- Click on the play floating button 
    * It starts the background service
- Click on the device home button
    * Required to don't kill the application completely 
- Click on the device recent apps button and remove the app from recent apps
- Open the app again
