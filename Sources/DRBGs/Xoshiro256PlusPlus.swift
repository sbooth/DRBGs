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

/* This is xoshiro256++ 1.0, one of our all-purpose, rock-solid generators.
 It has excellent (sub-ns) speed, a state (256 bits) that is large
 enough for any parallel application, and it passes all tests we are
 aware of.

 For generating just floating-point numbers, xoshiro256+ is even faster.

 The state must be seeded so that it is not everywhere zero. If you have
 a 64-bit seed, we suggest to seed a splitmix64 generator and use its
 output to fill s. */

/// An implementation of the xoshiro256++ (XOR/shift/rotate) deterministic random bit generator
///
/// - seealso: https://prng.di.unimi.it
public struct Xoshiro256PlusPlus: RandomNumberGenerator {
	/// The type of internal state maintained by the generator
	public typealias StateType = (UInt64, UInt64, UInt64, UInt64)

	/// The current state of the generator
	public private(set) var state: StateType = (0, 0, 0, 0)

	/// Initializes the generator with a random seed
	public init() {
		let fd = open("/dev/urandom", O_RDONLY)
		precondition(fd >= 0, "Unable to open /dev/urandom")
		defer {
			close(fd)
		}
		read(fd, &state, MemoryLayout<StateType>.size)
	}

	/// Initializes the generator with a random seed generated by a `RandomNumberGenerator`
	///
	///  - parameter generator: A `RandomNumberGenerator` used to seed the generator
	///
	/// - parameter seed: The initial state
	public init(generator: inout RandomNumberGenerator) {
		state = (generator.next(), generator.next(), generator.next(), generator.next())
	}

	/// Initializes the generator with the specified seed
	///
	/// - parameter seed: The initial state
	///
	/// - precondition: `seed` != (0, 0, 0, 0)
	public init(seed: StateType) {
		precondition(seed != (0, 0, 0, 0), "Seed may not be zero")
		state = seed
	}

	/// Generates an unsigned integer in the interval [0, `UInt64.max`]
	///
	/// - returns: An unsigned integer *u* such that 0 ≤ *u* ≤ `UInt64.max`
	public mutating func next() -> UInt64 {
		let result = (state.0 &+ state.3).rotatedLeft(by: 23) &+ state.0
		let t = state.1 << 17

		state.2 ^= state.0
		state.3 ^= state.1
		state.1 ^= state.2
		state.0 ^= state.3

		state.2 ^= t

		state.3.rotateLeft(by: 45)

		return result
	}

	/// The jump function for the generator
	///
	/// It is equivalent to 2^128 calls to `next()`.  It can be used to generate
	/// 2^128 non-overlapping subsequences for parallel computations.
	public mutating func jump() {
		let magic: [UInt64] = [0x180ec6d33cfd0aba, 0xd5a61266f0c9392c, 0xa9582618e03fc9aa, 0x39abdc4529b1661c]

		var s0: UInt64 = 0
		var s1: UInt64 = 0
		var s2: UInt64 = 0
		var s3: UInt64 = 0

		for val in magic {
			for bit: UInt64 in 0 ..< 64 {
				if (val & (UInt64(1) << bit)) != 0 {
					s0 ^= state.0
					s1 ^= state.1
					s2 ^= state.2
					s3 ^= state.3
				}
				_ = next()
			}
		}

		state = (s0, s1, s2, s3)
	}

	/// The long-jump function for the generator
	///
	/// It is equivalent to 2^192 calls to `next()`.  It can be used to generate
	/// 2^64 starting points, from each of which `jump()` will generate 2^64
	/// non-overlapping subsequences for parallel distributed computations.
	public mutating func long_jump() {
		let magic: [UInt64] = [0x76e15d3efefdcbbf, 0xc5004e441c522fb3, 0x77710069854ee241, 0x39109bb02acbe635]

		var s0: UInt64 = 0
		var s1: UInt64 = 0
		var s2: UInt64 = 0
		var s3: UInt64 = 0

		for val in magic {
			for bit: UInt64 in 0 ..< 64 {
				if (val & (UInt64(1) << bit)) != 0 {
					s0 ^= state.0
					s1 ^= state.1
					s2 ^= state.2
					s3 ^= state.3
				}
				_ = next()
			}
		}

		state = (s0, s1, s2, s3)
	}
}

extension Xoshiro256PlusPlus: Equatable {
	/// Compares two `Xoshiro256PlusPlus` objects for equality
	///
	/// Two `Xoshiro256PlusPlus` objects are equal if their 256-bit state is the same.
	///
	/// - parameter lhs: lhs
	/// - parameter rhs: rhs
	///
	/// - returns: `true` if the two objects have the same state, `false` otherwise
	public static func ==(lhs: Xoshiro256PlusPlus, rhs: Xoshiro256PlusPlus) -> Bool {
		lhs.state == rhs.state
	}
}
