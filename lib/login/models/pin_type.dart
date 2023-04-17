/// Descibes the type of pin. When user signs in with a camo pin, their
/// true balances are not shown.
///
/// This enum is suffixed with "Name" to avoid potential future conflicts if we
/// add a model class for validating pin type input.
enum PinTypeName { camo, normal }
