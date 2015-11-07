# RACPhotos

[![CI Status](http://img.shields.io/travis/Alejandro Martínez/RACPhotos.svg?style=flat)](https://travis-ci.org/Alejandro Martínez/RACPhotos)
[![Version](https://img.shields.io/cocoapods/v/RACPhotos.svg?style=flat)](http://cocoapods.org/pods/RACPhotos)
[![License](https://img.shields.io/cocoapods/l/RACPhotos.svg?style=flat)](http://cocoapods.org/pods/RACPhotos)
[![Platform](https://img.shields.io/cocoapods/p/RACPhotos.svg?style=flat)](http://cocoapods.org/pods/RACPhotos)

RACPhotos is a small wrapper of the Photos.framework using ReactiveCocoa 4. It let's you declare what you want to do with the Photos library and forget about the async APIs and the callback hell.

It was developed as part of [BWallpapers](https://itunes.apple.com/es/app/bwallpapers/id926031600?mt=8&uo=4).

You can read the [blog post](http://alejandromp.com/blog/2015/8/19/photos-framework-ReactiveCocoa).

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

It's a wrapper of Photos.framework so it requires iOS 8.0 and later.

Requires Swift 2. Xcode 7.

## Installation

RACPhotos is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "RACPhotos"
```

## TODO or NOT TODO

RACPhotos only covers a small part of the Photos.framework. Mainly the part that I needed. Nothing less, nothing more.

## Author

Alejandro Martínez, alexito4@gmail.com

## License

RACPhotos is available under the MIT license. See the LICENSE file for more info.
