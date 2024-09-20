import 'package:flutter/material.dart';
import 'package:fluxtube/application/search/search_bloc.dart';
import 'package:fluxtube/core/constants.dart';

class InvidiousSearchSuggessionSection extends StatelessWidget {
  const InvidiousSearchSuggessionSection({
    super.key,
    required TextEditingController textEditingController,
    required this.state,
  }) : _textEditingController = textEditingController;

  final TextEditingController _textEditingController;
  final SearchState state;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        itemBuilder: (context, index) => GestureDetector(
              onTap: () => _textEditingController.value = TextEditingValue(
                  text: state.invidiousSuggestionResult[index] ?? ''),
              child: Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Text(state.invidiousSuggestionResult[index]),
              ),
            ),
        separatorBuilder: (context, index) => kHeightBox10,
        itemCount: state.invidiousSuggestionResult.length);
  }
}
