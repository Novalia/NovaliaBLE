# NovaliaBLE

[![CI Status](http://img.shields.io/travis/Andrew Sage/NovaliaBLE.svg?style=flat)](https://travis-ci.org/Andrew Sage/NovaliaBLE)
[![Version](https://img.shields.io/cocoapods/v/NovaliaBLE.svg?style=flat)](http://cocoapods.org/pods/NovaliaBLE)
[![License](https://img.shields.io/cocoapods/l/NovaliaBLE.svg?style=flat)](http://cocoapods.org/pods/NovaliaBLE)
[![Platform](https://img.shields.io/cocoapods/p/NovaliaBLE.svg?style=flat)](http://cocoapods.org/pods/NovaliaBLE)

## Building a NovaliaBLE based app for iOS

To run the example project, clone the repo, and run `pod install` from the Example directory first

Create a new Universal Swift application in Xcode.

Close the project in Xcode.

## Pod Installation

Ensure you have [CocoaPods](http://cocoapods.org) installed.

In Terminal, go to the project directory and run:

```
pod init
```

Edit `Podfile` and add the following line to the target section:

```ruby
pod 'NovaliaBLE', :git => 'https://github.com/tirami/NovaliaBLE.git'
```

Ensure the `use_frameworks!` line is uncommented to ensure it works with Swift.
Uncomment the `platform` line and set the required iOS version.

Run:

```
pod install
```

Use the Xcode workspace instead of the project file from now on.

```
open App.xcworkspace
```

