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

/// An implementation of the splitmix64 deterministic random bit generator
public struct SplitMix64: RandomNumberGenerator {
	/// The current state of the generator
	public private(set) var state: UInt64 = 0

	/// Initializes the generator with a random seed
	public init() {
		let fd = open("/dev/urandom", O_RDONLY)
		precondition(fd >= 0, "Unable to open /dev/urandom")
		defer {
			close(fd)
		}
		read(fd, &state, MemoryLayout<UInt64>.size)
	}

	/// Initializes the generator with a random seed generated by a `RandomNumberGenerator`
	///
	///  - parameter generator: A `RandomNumberGenerator` used to seed the generator
	///
	/// - parameter seed: The initial state
	public init(generator: inout RandomNumberGenerator) {
		state = generator.next()
	}

	/// Initializes the generator with the specified seed
	///
	/// - parameter seed: The initial state
	public init(seed: UInt64) {
		state = seed
	}

	/// Generates an unsigned integer in the interval [0, `UInt64.max`]
	///
	/// - returns: An unsigned integer *u* such that 0 ≤ *u* ≤ `UInt64.max`
	public mutating func next() -> UInt64 {
		state += 0x9e3779b97f4a7c15
		var result = state
		result = (result ^ (result >> 30)) &* 0xbf58476d1ce4e5b9
		result = (result ^ (result >> 27)) &* 0x94d049bb133111eb
		return result ^ (result >> 31)
	}
}

extension SplitMix64: Equatable {
	/// Compares two `SplitMix64` objects for equality
	///
	/// Two `SplitMix64` objects are equal if their 64-bit state is the same.
	///
	/// - parameter lhs: lhs
	/// - parameter rhs: rhs
	///
	/// - returns: `true` if the two objects have the same state, `false` otherwise
	public static func ==(lhs: SplitMix64, rhs: SplitMix64) -> Bool {
		lhs.state == rhs.state
	}
}
