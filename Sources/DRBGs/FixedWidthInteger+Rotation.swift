//
// Copyright © 2024 Stephen F. Booth <me@sbooth.org>
// Part of https://github.com/sbooth/DRBGs
// MIT license
//

extension FixedWidthInteger {
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
