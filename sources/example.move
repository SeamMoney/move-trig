module TrigonometryAddr::ExampleUsage {
    use TrigonometryAddr::Trigonometry;

    /// Demonstrates calling sin(), cos(), arcsin() from the Trigonometry library.
    ///
    /// angle_scaled = an angle in radians * 1e18 (e.g., π ~ 3_141_592_653_589_793_238).
    /// returns (val_sin, val_cos, val_asin) for demonstration.
    public fun compute_some_trig(angle_scaled: u128): (i128, i128, u128) {
        let val_sin = Trigonometry::sin(angle_scaled);
        let val_cos = Trigonometry::cos(angle_scaled);

        // For arcsin, ensure the input is in [-1e18, +1e18].
        // We'll show arcsin of the sine result (common identity: arcsin(sin(x)) = x mod range).
        // Real usage might differ, but this is just an example.
        let val_asin = Trigonometry::arcsin(val_sin);

        (val_sin, val_cos, val_asin)
    }
}