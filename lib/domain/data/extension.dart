import 'package:e1547/domain/data/domain.dart';
import 'package:e1547/identity/identity.dart';
import 'package:e1547/traits/traits.dart';
import 'package:flutter/foundation.dart';

extension DomainPersonaExtension on Domain {
  /// The identity of this domain.
  Identity get identity => persona.identity;

  /// The traits for the identity of this domain.
  ValueNotifier<Traits> get traits => persona.traits;

  /// Whether this domain has an identity with login information.
  bool get hasLogin => identity.username != null;
}
