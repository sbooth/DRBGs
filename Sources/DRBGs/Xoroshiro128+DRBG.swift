//
// Copyright © 2016-2024 Stephen F. Booth <me@sbooth.org>
// Part of https://github.com/sbooth/DRBGs
// MIT license
//

#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#else
#error("Unsupported Platform")
#endif

/// An implementation of the Xoroshiro128+ deterministic random bit generator
///
/// - seealso: http://prng.di.unimi.it
public struct Xoroshiro128PlusDRBG: RandomNumberGenerator {
	/// The type of internal state maintained by the DRBG
	public typealias StateType = (UInt64, UInt64)

	/// The current state of the DRBG
	public private(set) var state: StateType = (0, 0)

	/// Initializes the DRBG with a random seed
	public init() {
		let fd = open("/dev/urandom", O_RDONLY)
		precondition(fd >= 0, "Unable to open /dev/urandom")
		defer {
			close(fd)
		}
		read(fd, &state, MemoryLayout<StateType>.size)
	}

	/// Initializes the DRBG with a random seed generated by a `RandomNumberGenerator`
	///
	///  - parameter drbg: A `RandomNumberGenerator` used to seed the DRBG
	///
	/// - parameter seed: The initial state
	public init(drbg: inout RandomNumberGenerator) {
		state.0 = drbg.next()
		state.1 = drbg.next()
	}

	/// Initializes the DRBG with the specified seed
	///
	/// - parameter seed: The initial state
	///
	/// - precondition: `seed` != (0, 0)
	public init(seed: StateType) {
		precondition(seed != (0, 0), "Seed may not be zero")
		state = seed
	}

	/// Generates an unsigned integer in the interval [0, `UInt64.max`]
	///
	/// - returns: An unsigned integer *u* such that 0 ≤ *u* ≤ `UInt64.max`
	public mutating func next() -> UInt64 {
		let (l, k0, k1, k2): (UInt64, UInt64, UInt64, UInt64) = (64, 55, 14, 36)

		let result = state.0 &+ state.1
		let x = state.0 ^ state.1
		state.0 = ((state.0 << k0) | (state.0 >> (l - k0))) ^ x ^ (x << k1)
		state.1 = (x << k2) | (x >> (l - k2))

		return result
	}

	/// The jump function for the generator
	///
	/// It is equivalent to 2^64 calls to `next()`.  It can be used to generate 
	/// 2^64 non-overlapping subsequences for parallel computations.
	public mutating func jump() {
		let magic: [UInt64] = [0xbeac0467eba5facb, 0xd86b048b86aa9922]

		var s0: UInt64 = 0
		var s1: UInt64 = 0

		for val in magic {
			for bit: UInt64 in 0 ..< 64 {
				if (val & (UInt64(1) << bit)) != 0 {
					s0 ^= state.0
					s1 ^= state.1
				}
				_ = next()
			}
		}

		state.0 = s0
		state.1 = s1
	}
}

extension Xoroshiro128PlusDRBG: Equatable {
	/// Compares two `Xoroshiro128PlusDRBG` objects for equality
	///
	/// Two `Xoroshiro128PlusDRBG` objects are equal if their 128-bit state is the same.
	///
	/// - parameter lhs: lhs
	/// - parameter rhs: rhs
	///
	/// - returns: `true` if the two objects have the same state, `false` otherwise
	public static func ==(lhs: Xoroshiro128PlusDRBG, rhs: Xoroshiro128PlusDRBG) -> Bool {
		lhs.state == rhs.state
	}
}
