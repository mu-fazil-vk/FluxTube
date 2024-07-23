import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/application/search/search_bloc.dart';

class SearchBarSection extends StatelessWidget {
  const SearchBarSection({
    super.key,
    required TextEditingController textEditingController,
    required this.theme,
  }) : _textEditingController = textEditingController;

  final TextEditingController _textEditingController;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10, bottom: 5),
      child: CupertinoSearchTextField(
        controller: _textEditingController,
        style: theme.textTheme.bodyMedium!.copyWith(fontSize: 16),
        prefixIcon: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            CupertinoIcons.search,
            color: theme.iconTheme.color,
          ),
        ),
        suffixIcon: Icon(
          CupertinoIcons.clear_circled_solid,
          color: theme.iconTheme.color,
        ),
        onChanged: (value) {
          EasyDebounce.debounce(
              'suggestions', // <-- An ID for this particular debouncer
              const Duration(milliseconds: 500), // <-- The debounce duration
              () => BlocProvider.of<SearchBloc>(context)
                      .add(SearchEvent.getSearchSuggestion(
                    query: _textEditingController.text,
                  )) // <-- The target method
              );
        },
        onSubmitted: (value) {
          if (value == '') {
            return;
          }
          EasyDebounce.cancel('suggestions');
          BlocProvider.of<SearchBloc>(context).add(SearchEvent.getSearchResult(
              query: _textEditingController.text, filter: "all"));
        },
      ),
    );
  }
}
