import 'package:flutter_bloc/flutter_bloc.dart';

mixin BlocHelper<T, S> on Bloc<T, S> {
  multiCall(List<T> events) {
    for (var event in events) {
      add(event);
    }
    return this;
  }
}
