# haxe-kiwi Demo

Demo of the [Haxe port](https://github.com/Tw1ddle/haxe-kiwi) of the [Kiwi](https://github.com/nucleic/kiwi) constraint solver. Kiwi is an efficient implementation of the algorithm based on the seminal Cassowary paper.

### Usage ###

This demo requires HaxeFlixel and Actuate, so install those first:
```bash
haxelib install flixel
haxelib install actuate
```
Open the project in FlashDevelop and build for your preferred target. Haxe-kiwi supports all targets.

Build the app. Follow the text instructions to use it. Edit the constraint definitions in ```data/equalities.json``` to modify the system. This demo is a system of equalities with some external edit variables such as the mouse position and current time which modify the system.

![](screenshots/equalities_demo.png?raw=true)

### Notes ###
If the demo does not look like it should, crashes or whatever then please contact me or open an issue.