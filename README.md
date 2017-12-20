![tpg offline logo](banner.png)

[![Build Status](https://travis-ci.org/RemyDCF/tpg-offline.svg?branch=master)](https://travis-ci.org/RemyDCF/tpg-offline)

## Presentation

tpg offline is an iOS app that allows you to travel in Geneva by bus and tramay without cellular data. This application is available on the [iOS App Store](https://itunes.apple.com/us/app/tpg-offline/id1001560047?l=fr&ls=1&mt=8)

## Running
This project was built in Swift 4, so you will need Xcode 9, and Carthage.

Also, be sure to add somewhere in your code this struct, with your API keys:

```swift
struct API {
    static let googleMaps = "" // Put your Google Maps Geocoding API key here
    static let tpg = "" // Put your tpg API key here
}
```

## Localization

You can help by translating the app on [Transifex](https://www.transifex.com/remydcf/tpg-offline/)

## Author

Rémy Da Costa Faro

## License

tpg offline is available under the MIT license. See the LICENCE file for more information.
