import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';

final authProvider = StateProvider<User?>((ref) => null);
