# Idea: possibly-mutable

The language itself should somehow obviate the need for things like `index[]`
and `index_mut[]` being implemented separately. This means that there needs to
be a way to denote a "possibly-`mut`" receiver and "forward" the mutability
through the method and onto the return type.

Suggestion: have a way of "naming" the CV-qualifications (to use a C++ term) of
input paramters, then referring to them later.

# Misc
* 'must_use' on `type` alias: https://github.com/rust-lang/rust/issues/26281
* VSCode Rust debugging:
  * https://github.com/editor-rs/vscode-rust/blob/master/doc/debugging.md
  * https://github.com/vadimcn/vscode-lldb/blob/master/MANUAL.md#rust-language-support
* Try compiling with this "audit" crate: https://crates.io/crates/cargo-audit
* Look into errors for invalid `cfg` values.
  * Seems `cfg(foobar)` doesn't give a warning or error?
  * What about `cfg(feature = "foobar")`?
