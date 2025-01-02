# Move Trigonometry Library

This repository provides a Move module implementing basic trigonometry functionalities (sine, cosine, and inverse trig) on the Aptos blockchain. The goal is to allow on-chain calculations of sin/cos/arcsin, where inputs and outputs are scaled by 1e18.

--------------------------------------------------------------------------------

# Overview

-   Implements the sine and cosine functions in Move, accepts angles in radian form, scaled by 1e18.
    - All angles are assumed to be in radians multiplied by 1e18. For instance, π (3.14159...) is stored internally as 3,141,592,653,589,793,238 (about “3.14159... × 10^18”)
    - Because sin(θ) is periodic, values above 2π can be wrapped around. For best precision in this integer-based approximation, ensure angles remain within a reasonable multiple of 2π (e.g., up to a few thousand multiples of 2π).
-   A lookup table reduces expensive calculations by providing precomputed sin() values over the range [0..π/2]. Because of trigonometric symmetry, the remaining regions of the unit circle can be derived.
-   Includes an optional inverse sine (arcsin) function, also operating with 1e18 fixed-point inputs/outputs.
- Integer math in Move is deterministic and can be cheaper than floating-point calculations on a Aptos since Move does not have dedicated floating-point operations.

--------------------------------------------------------------------------------
# References & Credits
-   mds1/solidity-trigonometry (GitHub) – Original Solidity library from which this approach is derived.
-   Sikorkaio/sikorka – Contains Lefteris Karapetsas’ original trigonometry library.
-   Dave Dribin’s trigint C library – Integer-based trig approximations in C.
--------------------------------------------------------------------------------
