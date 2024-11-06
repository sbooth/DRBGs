import XCTest
@testable import DRBGs

final class DRBGsTests: XCTestCase {
	func testRotate() throws {
		let u: UInt32 = 0xABCDEF
		for shift in 1 ..< u.bitWidth {
			XCTAssertEqual(u.rotatedLeft(by: shift), u.rotatedRight(by: u.bitWidth - shift))
			XCTAssertEqual(u.rotatedRight(by: shift), u.rotatedLeft(by: u.bitWidth - shift))
		}
	}

	func testRotateLeft() throws {
		var u: UInt32 = 0xABCD
		u.rotateLeft(by: 16)
		XCTAssertEqual(u, 0xABCD0000)
		u.rotateLeft(by: 16)
		XCTAssertEqual(u, 0xABCD)
		u.rotateLeft(by: 3)
		XCTAssertEqual(u, 0x55E68)
	}

	func testRotateRight() throws {
		var u: UInt32 = 0xABCD
		u.rotateRight(by: 16)
		XCTAssertEqual(u, 0xABCD0000)
		u.rotateRight(by: 16)
		XCTAssertEqual(u, 0xABCD)
		u.rotateRight(by: 3)
		XCTAssertEqual(u, 0xA0001579)
	}

	func testSplitMix64() throws {
		var sm = SplitMix64(seed: UInt64.max)
		XCTAssertEqual(sm.next(), 16490336266968443936)
	}

	func testXoroshiro128PlusPlus() throws {
		var xo = Xoroshiro128PlusPlus(seed: (UInt64.max, UInt64.max))
		XCTAssertEqual(xo.next(), 18446744073709420542)
	}
}
