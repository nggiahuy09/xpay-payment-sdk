/// Authentication mode for a request.
///
/// | Type        | Authentication | Use case                        |
/// |-------------|----------------|---------------------------------|
/// | [public]    | None           | Public endpoints, health checks |
/// | [user]      | Ride payment session (`X-Ride-Payment`) | Authenticated payment operations |
enum APIType { public, user }
