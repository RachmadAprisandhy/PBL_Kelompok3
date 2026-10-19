import 'package:flutter_bloc/flutter_bloc.dart';

class NavigationState {
  const NavigationState({required this.index, required this.historyVersion});

  final int index;
  final int historyVersion;
}

class NavigationCubit extends Cubit<NavigationState> {
  NavigationCubit() : super(const NavigationState(index: 0, historyVersion: 0));

  void selectTab(int index) {
    emit(NavigationState(
      index: index,
      historyVersion: index == 1 ? state.historyVersion + 1 : state.historyVersion,
    ));
  }
}
