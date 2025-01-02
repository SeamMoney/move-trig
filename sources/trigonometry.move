module TrigonometryAddr::Trigonometry {
    use std::vector;
    use aptos_std::signer;

    /// Holds a table of 256 entries for approximating sine in [0..π/2].
    struct SineTable has key, drop {
        entries: vector<u32>
    }

    // Scaling for angles (1e18).
    const SCALE: u128 = 1_000_000_000_000_000_000;

    // Max signed 32-bit integer (2^31 - 1)
    const INT32_MAX: u128 = 2_147_483_647;

    // π in 1e18 fixed-point
    const PI: u128 = 3_141_592_653_589_793_238;

    // 2π in 1e18 fixed-point
    const TWO_PI: u128 = PI * 2;

    // π/2 in 1e18 fixed-point
    const PI_OVER_TWO: u128 = PI / 2;

    // Internal cycle size for angles (2^30).
    const ANGLES_IN_CYCLE: u64 = 1_073_741_824;

    // Quadrant bitmask for detecting whether in upper/lower half.
    const QUADRANT_HIGH_MASK: u64 = 536_870_912; // 2^29

    // Quadrant bitmask for differentiating odd/even quadrant.
    const QUADRANT_LOW_MASK: u64  = 268_435_456; // 2^28

    // Table size
    const SINE_TABLE_SIZE: u64 = 256;

    // Bits for table indexing
    const INDEX_WIDTH: u64 = 8;

    // Bits for interpolating between indices
    const INTERP_WIDTH: u64 = 16;

    // Derived offsets
    const INDEX_OFFSET: u64 = 28 - INDEX_WIDTH;    // 20
    const INTERP_OFFSET: u64 = INDEX_OFFSET - INTERP_WIDTH; // 4

    /// Creates and stores a 256-entry sine table resource in the signer's account.
    /// Replace these stub pushes with the full dataset (256 total entries).
    public fun publish_sine_table(account: &signer) {
        let table_data = vector::empty<u32>();
        // Example entries only:
        vector::push_back<u32>(&mut table_data, 0);
        vector::push_back<u32>(&mut table_data, 128);
        vector::push_back<u32>(&mut table_data, 256);
        // Continue until you have 256 values.

        move_to<SineTable>(account, SineTable {
            entries: table_data
        });
    }

    // Helper to borrow the resource. Adjust the address as needed for your deployment strategy.
    fun borrow_table(): &SineTable {
        &move_from<SineTable>(@0x2)
    }

    // Safely reads an entry from the table
    fun read_table_entry(table_ref: &SineTable, i: u64): u64 {
        let idx = if (i < SINE_TABLE_SIZE) { i } else { SINE_TABLE_SIZE - 1 };
        u64(vector::borrow<u32>(&table_ref.entries, idx))
    }

    // Integer-based sine function. Input: angle in [radians × 1e18]. Output: sin(angle) × 1e18.
    public fun sin(angle_raw: u128): i128 {
        let table_ref = borrow_table();

        // 1) Reduce into [0..2π)
        let angle_mod = mod_u128(angle_raw, TWO_PI);

        // 2) Map to [0..2^30)
        let angle_cycle = (u128::from_u64(ANGLES_IN_CYCLE) * angle_mod) / TWO_PI;
        let angle_64 = u64(angle_cycle);

        // Determine quadrant bits
        let is_negative_quadrant = (angle_64 & QUADRANT_HIGH_MASK) != 0;
        let is_odd_quadrant = (angle_64 & QUADRANT_LOW_MASK) == 0;

        // Retrieve index/interp bits
        let index = (angle_64 >> INDEX_OFFSET) & ((1 << INDEX_WIDTH) - 1);
        let interp = (angle_64 >> INTERP_OFFSET) & ((1 << INTERP_WIDTH) - 1);

        let mut final_index = index;
        if (!is_odd_quadrant) {
            final_index = SINE_TABLE_SIZE - 1 - final_index;
        };

        let x1 = read_table_entry(table_ref, final_index);
        let x2 = read_table_entry(table_ref, final_index + 1);

        // Interpolation
        let diff = if (x2 >= x1) { x2 - x1 } else { x1 - x2 };
        let approx_u128 = (u128::from_u64(diff) * u128::from_u64(interp)) >> INTERP_WIDTH;
        let mut approx_i64 = i64(approx_u128);
        if (x2 < x1) {
            approx_i64 = -approx_i64;
        };

        let base_val = if (is_odd_quadrant) {
            i64(x1)
        } else {
            i64(x2)
        };

        let mut sine_approx = base_val + approx_i64;
        if (is_negative_quadrant) {
            sine_approx = -sine_approx;
        };

        // Scale from a ~32-bit range to 1e18
        let scaled = (i128(sine_approx) * i128(SCALE)) / i128(INT32_MAX);
        scaled
    }

    // Integer-based cosine. Uses identity coθ = sin(θ + π/2).
    public fun cos(angle_raw: u128): i128 {
        sin(angle_raw + PI_OVER_TWO)
    }

    // Naively compute x % y in 128-bit space, works fine unless x is extremely large.
    fun mod_u128(x: u128, y: u128): u128 {
        let mut remainder = x;
        while (remainder >= y) {
            remainder = remainder - y;
        };
        remainder
    }
}