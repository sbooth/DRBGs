// swift-tools-version: 5.6
//
// SPDX-FileCopyrightText: 2024 Stephen F. Booth <contact@sbooth.dev>
// SPDX-License-Identifier: MIT
//
// Part of https://github.com/sbooth/DRBGs
//

import PackageDescription

let package = Package(
	name: "DRBGs",
	products: [
		// Products define the executables and libraries a package produces, making them visible to other packages.
		.library(
			name: "DRBGs",
			targets: [
				"DRBGs",
			]),
	],
	targets: [
		// Targets are the basic building blocks of a package, defining a module or a test suite.
		// Targets can depend on other targets in this package and products from dependencies.
		.target(
			name: "DRBGs"),
		.testTarget(
			name: "DRBGsTests",
			dependencies: [
				"DRBGs",
			]),
	]
)
