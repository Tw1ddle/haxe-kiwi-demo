# haxe-kiwi Demo

Demo of the [Haxe port](https://github.com/Tw1ddle/haxe-kiwi) of the [Kiwi](https://github.com/nucleic/kiwi) constraint solver. Kiwi is an efficient implementation of the [Cassowary algorithm](http://constraints.cs.washington.edu/cassowary/) based on the seminal Cassowary paper.

## Usage

This demo requires HaxeFlixel and Actuate, so install these first:
```bash
haxelib git flixel https://github.com/HaxeFlixel/flixel dev # Else try stable branch of HaxeFlixel: haxelib install flixel
haxelib install actuate
```

Build the app and tap the buttons at the bottom of the screen to play with it.

![](screenshots/layout_demo.png?raw=true)

![](screenshots/equalities_demo.png?raw=true)

Configure the ```<set>``` tag at the top of ```Project.xml``` to run optional unit tests.

Edit the JSON constraint definitions in ```assets/data``` to modify the demos.

## Notes
* This demo supports all the targets supported by HaxeFlixel.
* If the demo does not look or work like it should then contact me or open an issue.