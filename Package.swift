// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "AppleMusicAnime",
    dependencies: [
        .package(url: "https://github.com/scottrhoyt/Cider.git", from: "0.10.0"),
        .package(url: "https://github.com/tid-kijyun/Kanna.git", from: "4.0.0")
    ],
    targets: [
        .target(
	    name: "AppleMusicAnime",
	    dependencies: ["Cider", "Kanna"],
	    path: "Sources")
    ]
)
