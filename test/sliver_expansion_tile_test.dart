import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sliver_expansion_tile/sliver_expansion_tile.dart';

void main() {
  testWidgets('SliverExpansionTile test', (WidgetTester tester) async {
    tester.pumpWidget(
      MaterialApp(
        home: CustomScrollView(
          slivers: [
            SliverExpansionTile(
              title: Text('Title'),
              delegate: SliverChildBuilderDelegate((context, index) {
                return Container();
              }, childCount: 5),
            ),
          ],
        ),
      ),
    );
  });
}
