[![Project logo](https://github.com/Tw1ddle/haxe-kiwi-demo/blob/master/screenshots/logo.png?raw=true "Haxe Kiwi Demo - an implementation of the Cassowary constraint solving algorithm")](https://tw1ddle.github.io/haxe-kiwi-demo/)

[![License](https://img.shields.io/:license-mit-blue.svg?style=flat-square)](https://github.com/Tw1ddle/haxe-kiwi-demo/blob/master/LICENSE)
[![Build Status Badge](https://ci.appveyor.com/api/projects/status/github/Tw1ddle/haxe-kiwi-demo)](https://ci.appveyor.com/project/Tw1ddle/haxe-kiwi-demo)

Demo of my [Haxe port](https://github.com/Tw1ddle/haxe-kiwi) of the [Kiwi](https://github.com/nucleic/kiwi) constraint solver. Kiwi is an efficient implementation of the [Cassowary algorithm](https://constraints.cs.washington.edu/cassowary/) based on the seminal Cassowary paper.

Run it [in your browser](https://tw1ddle.github.io/haxe-kiwi-demo/).

## Usage

This demo requires HaxeFlixel and Actuate, so install these first:
```bash
haxelib install actuate
haxelib install flixel
```

Build the app and tap the buttons at the bottom of the screen to play with it.

![](screenshots/layout_animation.gif?raw=true)

![](screenshots/candies_animation.gif?raw=true)

![](screenshots/equalities_demo.png?raw=true)

Edit the JSON constraint definitions in ```assets/data``` to modify the demos.

## Notes
* This demo supports all the targets supported by HaxeFlixel.
* Got an idea or suggestion? Open an issue on GitHub, or send Sam a message on [Twitter](https://twitter.com/Sam_Twidale).