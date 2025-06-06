//
// Copyright © 2024 Stephen F. Booth <me@sbooth.org>
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

/* This is xoroshiro128++ 1.0, one of our all-purpose, rock-solid,
 small-state generators. It is extremely (sub-ns) fast and it passes all
 tests we are aware of, but its state space is large enough only for
 mild parallelism.

 For generating just floating-point numbers, xoroshiro128+ is even
 faster (but it has a very mild bias, see notes in the comments).

 The state must be seeded so that it is not everywhere zero. If you have
 a 64-bit seed, we suggest to seed a splitmix64 generator and use its
 output to fill s. */

/// An implementation of the xoroshiro128++ (XOR/rotate/shift/rotate) deterministic random bit generator
///
/// - seealso: https://prng.di.unimi.it
public struct Xoroshiro128PlusPlus: RandomNumberGenerator {
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
		let result = (s0 &+ s1).rotatedLeft(by: 17) &+ s0

		s1 ^= s0
		state.0 = s0.rotatedLeft(by: 49) ^ s1 ^ (s1 << 21)
		state.1 = s1.rotatedLeft(by: 28)

		return result
	}

	/// The jump function for the generator
	///
	/// It is equivalent to 2^64 calls to `next()`.  It can be used to generate
	/// 2^64 non-overlapping subsequences for parallel computations.
	public mutating func jump() {
		let magic: [UInt64] = [0x2bd7a6a6e99c2ddc, 0x0992ccaf6a6fca05]

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
		let magic: [UInt64] = [0x360fd5f2cf8d5d99, 0x9c6e6877736c46e3]

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

extension Xoroshiro128PlusPlus: Equatable {
	/// Compares two `Xoroshiro128PlusPlus` objects for equality
	///
	/// Two `Xoroshiro128PlusPlus` objects are equal if their 128-bit state is the same.
	///
	/// - parameter lhs: lhs
	/// - parameter rhs: rhs
	///
	/// - returns: `true` if the two objects have the same state, `false` otherwise
	public static func ==(lhs: Xoroshiro128PlusPlus, rhs: Xoroshiro128PlusPlus) -> Bool {
		lhs.state == rhs.state
	}
}
