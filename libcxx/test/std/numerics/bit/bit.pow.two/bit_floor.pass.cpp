//===----------------------------------------------------------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is dual licensed under the MIT and the University of Illinois Open
// Source Licenses. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
// UNSUPPORTED: c++03, c++11, c++14, c++17

// template <class T>
//   constexpr T bit_floor(T x) noexcept;

// Returns: If x == 0, 0; otherwise the maximal value y such that bit_floor(y) is true and y <= x.
// Remarks: This function shall not participate in overload resolution unless
//	T is an unsigned integer type

#include <bit>
#include <cstdint>
#include <type_traits>
#include <cassert>

#include "test_macros.h"

class A{};
enum       E1 : unsigned char { rEd };
enum class E2 : unsigned char { red };

template <typename T>
constexpr bool constexpr_test()
{
	return std::bit_floor(T(0)) == T(0)
	   &&  std::bit_floor(T(1)) == T(1)
	   &&  std::bit_floor(T(2)) == T(2)
	   &&  std::bit_floor(T(3)) == T(2)
	   &&  std::bit_floor(T(4)) == T(4)
	   &&  std::bit_floor(T(5)) == T(4)
	   &&  std::bit_floor(T(6)) == T(4)
	   &&  std::bit_floor(T(7)) == T(4)
	   &&  std::bit_floor(T(8)) == T(8)
	   &&  std::bit_floor(T(9)) == T(8)
	   ;
}


template <typename T>
void runtime_test()
{
	ASSERT_SAME_TYPE(T, decltype(std::bit_floor(T(0))));
	ASSERT_NOEXCEPT(             std::bit_floor(T(0)));

	assert( std::bit_floor(T(121)) == T(64));
	assert( std::bit_floor(T(122)) == T(64));
	assert( std::bit_floor(T(123)) == T(64));
	assert( std::bit_floor(T(124)) == T(64));
	assert( std::bit_floor(T(125)) == T(64));
	assert( std::bit_floor(T(126)) == T(64));
	assert( std::bit_floor(T(127)) == T(64));
	assert( std::bit_floor(T(128)) == T(128));
	assert( std::bit_floor(T(129)) == T(128));
	assert( std::bit_floor(T(130)) == T(128));
}

int main(int, char**)
{

    {
    auto lambda = [](auto x) -> decltype(std::bit_floor(x)) {};
    using L = decltype(lambda);

    static_assert( std::is_invocable_v<L, unsigned char>, "");
    static_assert( std::is_invocable_v<L, unsigned int>, "");
    static_assert( std::is_invocable_v<L, unsigned long>, "");
    static_assert( std::is_invocable_v<L, unsigned long long>, "");

    static_assert( std::is_invocable_v<L, uint8_t>, "");
    static_assert( std::is_invocable_v<L, uint16_t>, "");
    static_assert( std::is_invocable_v<L, uint32_t>, "");
    static_assert( std::is_invocable_v<L, uint64_t>, "");
    static_assert( std::is_invocable_v<L, size_t>, "");

    static_assert( std::is_invocable_v<L, uintmax_t>, "");
    static_assert( std::is_invocable_v<L, uintptr_t>, "");


    static_assert(!std::is_invocable_v<L, int>, "");
    static_assert(!std::is_invocable_v<L, signed int>, "");
    static_assert(!std::is_invocable_v<L, long>, "");
    static_assert(!std::is_invocable_v<L, long long>, "");

    static_assert(!std::is_invocable_v<L, int8_t>, "");
    static_assert(!std::is_invocable_v<L, int16_t>, "");
    static_assert(!std::is_invocable_v<L, int32_t>, "");
    static_assert(!std::is_invocable_v<L, int64_t>, "");
    static_assert(!std::is_invocable_v<L, ptrdiff_t>, "");

    static_assert(!std::is_invocable_v<L, bool>, "");
    static_assert(!std::is_invocable_v<L, signed char>, "");
    static_assert(!std::is_invocable_v<L, char16_t>, "");
    static_assert(!std::is_invocable_v<L, char32_t>, "");

#ifndef _LIBCPP_HAS_NO_INT128
    static_assert( std::is_invocable_v<L, __uint128_t>, "");
    static_assert(!std::is_invocable_v<L, __int128_t>, "");
#endif

    static_assert(!std::is_invocable_v<L, A>, "");
    static_assert(!std::is_invocable_v<L, E1>, "");
    static_assert(!std::is_invocable_v<L, E2>, "");
    }

	static_assert(constexpr_test<unsigned char>(),      "");
	static_assert(constexpr_test<unsigned short>(),     "");
	static_assert(constexpr_test<unsigned>(),           "");
	static_assert(constexpr_test<unsigned long>(),      "");
	static_assert(constexpr_test<unsigned long long>(), "");

	static_assert(constexpr_test<uint8_t>(),   "");
	static_assert(constexpr_test<uint16_t>(),  "");
	static_assert(constexpr_test<uint32_t>(),  "");
	static_assert(constexpr_test<uint64_t>(),  "");
	static_assert(constexpr_test<size_t>(),    "");
	static_assert(constexpr_test<uintmax_t>(), "");
#ifndef __CHERI_PURE_CAPABILITY__
	static_assert(constexpr_test<uintptr_t>(), "");
#endif

#ifndef _LIBCPP_HAS_NO_INT128
	static_assert(constexpr_test<__uint128_t>(),        "");
#endif

	runtime_test<unsigned char>();
	runtime_test<unsigned>();
	runtime_test<unsigned short>();
	runtime_test<unsigned long>();
	runtime_test<unsigned long long>();

	runtime_test<uint8_t>();
	runtime_test<uint16_t>();
	runtime_test<uint32_t>();
	runtime_test<uint64_t>();
	runtime_test<size_t>();
	runtime_test<uintmax_t>();
	runtime_test<uintptr_t>();

#ifndef _LIBCPP_HAS_NO_INT128
	runtime_test<__uint128_t>();

	{
	__uint128_t val = 128;
	val <<= 32;
	assert( std::bit_floor(val-1) == val/2);
	assert( std::bit_floor(val)   == val);
	assert( std::bit_floor(val+1) == val);
	val <<= 2;
	assert( std::bit_floor(val-1) == val/2);
	assert( std::bit_floor(val)   == val);
	assert( std::bit_floor(val+1) == val);
	val <<= 3;
	assert( std::bit_floor(val-1) == val/2);
	assert( std::bit_floor(val)   == val);
	assert( std::bit_floor(val+1) == val);
	}
#endif

    return 0;
}
