// swift-tools-version: 6.0

// WARNING:
// This file is automatically generated.
// Do not edit it by hand because the contents will be replaced.

import PackageDescription
import AppleProductTypes

let package = Package(
    name: "Gugu",
    platforms: [
        .iOS("16.0")
    ],
    products: [
        .iOSApplication(
            name: "Gugu",
            targets: ["AppModule"],
            bundleIdentifier: "HELLO.Planner-port",
            teamIdentifier: "338QV5HWU4",
            displayVersion: "1.0",
            bundleVersion: "1",
            appIcon: .asset("AppIcon"),
            accentColor: .presetColor(.teal),
            supportedDeviceFamilies: [
                .pad,
                .phone
            ],
            supportedInterfaceOrientations: [
                .portrait,
                .landscapeRight,
                .landscapeLeft,
                .portraitUpsideDown(.when(deviceFamilies: [.pad]))
            ],
            capabilities: [
                .fileAccess(.pictureFolder, mode: .readWrite),
                .fileAccess(.musicFolder, mode: .readWrite),
                .fileAccess(.moviesFolder, mode: .readWrite),
                .fileAccess(.userSelectedFiles, mode: .readWrite),
                .fileAccess(.downloadsFolder, mode: .readWrite)
            ],
            appCategory: .healthcareFitness
        )
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            path: "."
        )
    ],
    swiftLanguageVersions: [.version("6")]
)