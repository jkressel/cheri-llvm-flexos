//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

// <complex>

// complex& operator/=(const complex& rhs);

#include <complex>
#include <cassert>

#include "test_macros.h"

template <class T>
void
test()
{
    std::complex<T> c(-4, 7.5);
    const std::complex<T> c2(1.5, 2.5);
    assert(c.real() == -4);
    assert(c.imag() == 7.5);
    c /= c2;
    assert(c.real() == 1.5);
    assert(c.imag() == 2.5);
    c /= c2;
    assert(c.real() == 1);
    assert(c.imag() == 0);

    std::complex<T> c3;

    c3 = c;
    std::complex<int> ic (1,1);
    c3 /= ic;
    assert(c3.real() ==  0.5);
    assert(c3.imag() == -0.5);

    c3 = c;
    std::complex<float> fc (1,1);
    c3 /= fc;
    assert(c3.real() ==  0.5);
    assert(c3.imag() == -0.5);

}

int main(int, char**)
{
    test<float>();
    test<double>();
#ifndef _LIBCPP_HAS_NEWLIB
    test<long double>();
#endif // ! _LIBCPP_HAS_NEWLIB

  return 0;
}
