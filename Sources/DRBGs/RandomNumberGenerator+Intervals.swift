//
// Copyright © 2016-2024 Stephen F. Booth <me@sbooth.org>
// Part of https://github.com/sbooth/DRBGs
// MIT license
//

// The code for unitDouble() was taken from https://prng.di.unimi.it
extension RandomNumberGenerator {
	/// Generates a floating-point number in the interval [0, 1)
	///
	/// - returns: A floating-point number *f* such that 0 ≤ *f* < 1
	public mutating func unitDouble() -> Double {
		let x = next()
		return Double((x >> 11)) * 0x1.0p-53
	}
}
