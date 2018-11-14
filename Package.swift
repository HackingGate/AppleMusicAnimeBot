// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "AppleMusicAnime",
    dependencies: [
        .package(url: "https://github.com/scottrhoyt/Cider.git", from: "0.10.0")
    ],
    targets: [
        .target(
	    name: "AppleMusicAnime",
	    dependencies: ["Cider"],
	    path: "Sources")
    ]
)
