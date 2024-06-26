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

/* This is xoroshiro128+ 1.0, our best and fastest small-state generator
 for floating-point numbers, but its state space is large enough only
 for mild parallelism. We suggest to use its upper bits for
 floating-point generation, as it is slightly faster than
 xoroshiro128++/xoroshiro128**. It passes all tests we are aware of
 except for the four lower bits, which might fail linearity tests (and
 just those), so if low linear complexity is not considered an issue (as
 it is usually the case) it can be used to generate 64-bit outputs, too;
 moreover, this generator has a very mild Hamming-weight dependency
 making our test (http://prng.di.unimi.it/hwd.php) fail after 5 TB of
 output; we believe this slight bias cannot affect any application. If
 you are concerned, use xoroshiro128++, xoroshiro128** or xoshiro256+.

 We suggest to use a sign test to extract a random Boolean value, and
 right shifts to extract subsets of bits.

 The state must be seeded so that it is not everywhere zero. If you have
 a 64-bit seed, we suggest to seed a splitmix64 generator and use its
 output to fill s.

 NOTE: the parameters (a=24, b=16, b=37) of this version give slightly
 better results in our test than the 2016 version (a=55, b=14, c=36).
 */

/// An implementation of the xoroshiro128+ (XOR/rotate/shift/rotate) deterministic random bit generator
///
/// - seealso: https://prng.di.unimi.it
public struct Xoroshiro128Plus: RandomNumberGenerator {
	/// The type of internal state maintained by the generator
	public typealias StateType = (UInt64, UInt64)

	/// The current state of the generator
	public private(set) var state: StateType = (0, 0)

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
		state = (generator.next(), generator.next())
	}

	/// Initializes the generator with the specified seed
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
		let s0 = state.0
		var s1 = state.1
		let result = s0 &+ s1

		s1 ^= s0
		state.0 = s0.rotatedLeft(by: 24) ^ s1 ^ (s1 << 16)
		state.1 = s1.rotatedLeft(by: 37)

		return result
	}

	/// The jump function for the generator
	///
	/// It is equivalent to 2^64 calls to `next()`.  It can be used to generate
	/// 2^64 non-overlapping subsequences for parallel computations.
	public mutating func jump() {
		let magic: [UInt64] = [0xdf900294d8f554a5, 0x170865df4b3201fc]

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

		state = (s0, s1)
	}

	/// The long-jump function for the generator
	///
	/// It is equivalent to 2^96 calls to `next()`.  It can be used to generate
	/// 2^32 starting points, from each of which `jump()` will generate 2^32
	/// non-overlapping subsequences for parallel distributed computations.
	public mutating func long_jump() {
		let magic: [UInt64] = [0xd2a98b26625eee7b, 0xdddf9b1090aa7ac1]

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

		state = (s0, s1)
	}
}

extension Xoroshiro128Plus: Equatable {
	/// Compares two `Xoroshiro128Plus` objects for equality
	///
	/// Two `Xoroshiro128Plus` objects are equal if their 128-bit state is the same.
	///
	/// - parameter lhs: lhs
	/// - parameter rhs: rhs
	///
	/// - returns: `true` if the two objects have the same state, `false` otherwise
	public static func ==(lhs: Xoroshiro128Plus, rhs: Xoroshiro128Plus) -> Bool {
		lhs.state == rhs.state
	}
}
