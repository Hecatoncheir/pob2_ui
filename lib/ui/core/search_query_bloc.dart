import 'package:flutter_bloc/flutter_bloc.dart';

final class SearchQueryChanged {
  const SearchQueryChanged(this.query);

  final String query;
}

class SearchQueryBloc extends Bloc<SearchQueryChanged, String> {
  SearchQueryBloc() : super('') {
    on<SearchQueryChanged>((event, emit) => emit(event.query.toLowerCase()));
  }
}
