// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "AppleMusicAnime",
    dependencies: [
        .package(url: "https://github.com/HackingGate/Cider.git", from: "0.1.0"),
        .package(url: "https://github.com/tid-kijyun/Kanna.git", from: "5.0.0")
    ],
    targets: [
        .target(
	    name: "AppleMusicAnime",
	    dependencies: ["Cider", "Kanna"],
	    path: "Sources")
    ]
)
