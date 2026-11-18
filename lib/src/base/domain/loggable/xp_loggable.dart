/// Contract for use-case input classes so they can be serialized for business
/// logging (`XPRemoteLogger().logBusiness(input: input.toLog(), ...)`).
///
/// Map all fields; skip nulls with collection-if.
abstract interface class XPLoggable {
  Map<String, dynamic> toLog();
}
