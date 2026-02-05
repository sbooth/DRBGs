//
// SPDX-FileCopyrightText: 2024 Stephen F. Booth <contact@sbooth.dev>
// SPDX-License-Identifier: MIT
//
// Part of https://github.com/sbooth/DRBGs
//

extension FixedWidthInteger where Self: UnsignedInteger {
	/// Performs a left bitwise rotation of `self` by `shift` and returns the result
	///
	/// - precondition: 0 < `shift` < `Self.bitWidth`
	///
	/// - parameter shift: The length of the rotation
	///
	/// - returns: The left bitwise rotation of `self` by `shift`
	func rotatedLeft(by shift: Int) -> Self {
		(self << shift) | (self >> (Self.bitWidth - shift))
	}

	/// Rotates the bits of `self` left by `shift`
	///
	/// - precondition: 0 < `shift` < `Self.bitWidth`
	///
	/// - parameter shift: The length of the rotation
	///
	/// - returns: The left bitwise rotation of `self` by `shift`
	mutating func rotateLeft(by shift: Int) {
		self = self.rotatedLeft(by: shift)
	}
}

extension FixedWidthInteger where Self: UnsignedInteger {
	/// Performs a right bitwise rotation of `self` by `shift` and returns the result
	///
	/// - precondition: 0 < `shift` < `Self.bitWidth`
	///
	/// - parameter shift: The length of the rotation
	///
	/// - returns: The right bitwise rotation of `self` by `shift`
	func rotatedRight(by shift: Int) -> Self {
		(self >> shift) | (self << (Self.bitWidth - shift))
	}

	/// Rotates the bits of `self` right by `shift`
	///
	/// - precondition: 0 < `shift` < `Self.bitWidth`
	///
	/// - parameter shift: The length of the rotation
	///
	/// - returns: The right bitwise rotation of `self` by `shift`
	mutating func rotateRight(by shift: Int) {
		self = self.rotatedRight(by: shift)
	}
}
