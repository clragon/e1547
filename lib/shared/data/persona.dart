import 'package:e1547/identity/identity.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/traits/traits.dart';
import 'package:flutter/foundation.dart';

// ignore: non_constant_identifier_names
final PersonaRef = Ref<Persona>();

typedef Persona = ({Identity identity, ValueNotifier<Traits> traits});
