//
// SPDX-FileCopyrightText: 2025 Stephen F. Booth <contact@sbooth.dev>
// SPDX-License-Identifier: MIT
//
// Part of https://github.com/sbooth/DRBGs
//

extension RandomNumberGenerator {
	/// Generates a floating-point number in the interval [0, 1)
	///
	/// - returns: A floating-point number *f* such that 0 ≤ *f* < 1
	@inlinable public mutating func unitFloat() -> Float {
		let x = next()
		return Float(x >> 40) * 0x1.0p-24
	}
}
