import 'dart:math';

import 'package:example/data.dart';
import 'package:flutter/material.dart';
import 'package:sliver_expansion_tile/sliver_expansion_tile_new.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: Scaffold(
        backgroundColor: const Color(0xffE9EFEC),
        floatingActionButtonLocation:
            FloatingActionButtonLocation.miniCenterFloat,
        floatingActionButton: Wrap(
          alignment: WrapAlignment.center,
          children: [
            for (final palette in palettes) ...[
              FloatingActionButton.small(
                backgroundColor: palette.colors.last,
                child: const Icon(Icons.arrow_downward),
                onPressed: () {
                  palette.controller.expand();
                },
              ),
              FloatingActionButton.small(
                backgroundColor: palette.colors.last,
                child: const Icon(Icons.arrow_upward),
                onPressed: () {
                  palette.controller.collapse();
                },
              ),
              FloatingActionButton.small(
                backgroundColor: palette.colors.last,
                child: const Icon(Icons.stop),
                onPressed: () {
                  palette.controller.stop();
                },
              ),
            ],
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CustomScrollView(
            slivers: [
              const SliverAppBar(title: Text('Sliver Expansion Tile')),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) =>
                      ListTile(title: Text(activites.first[index])),
                  childCount: activites.first.length,
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => ListTile(title: Text('Item $index')),
                  childCount: 20,
                ),
              ),
              _PaletteTile(palette: palettes.first),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => ListTile(title: Text('Item $index')),
                  childCount: 20,
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) =>
                      ListTile(title: Text(activites[1][index])),
                  childCount: activites[1].length,
                ),
              ),
              // _PaletteTile(palette: palettes[1]),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) =>
                      ListTile(title: Text(activites.last[index])),
                  childCount: activites.last.length,
                ),
              ),
              // _PaletteTile(palette: palettes.last),
              SliverPadding(
                padding: EdgeInsets.all(
                  MediaQuery.viewPaddingOf(context).bottom + 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaletteTile extends StatelessWidget {
  const _PaletteTile({required this.palette});

  final ColorPalette palette;

  @override
  Widget build(BuildContext context) {
    final textColor = palette.colors.last.contrast;
    return SliverExpansionTile(
      key: ValueKey(palette.name),
      border: BorderSide(
        color: palette.colors[palette.colors.length - 2],
        width: 6.0,
      ),
      borderRadius: const Radius.circular(8.0),
      titleColor: palette.colors.last,
      controller: palette.controller,
      title: Text(palette.name, style: TextStyle(color: textColor)),
      subtitle: Text(palette.description, style: TextStyle(color: textColor)),
      children: [
        for (final (index, color) in palette.colors.indexed)
          _ColorPaletteBox(
            key: ValueKey(color),
            color: color,
            index: index + 1,
          ),
      ],
    );
  }
}

class _ColorPaletteBox extends StatelessWidget {
  const _ColorPaletteBox({required this.color, required this.index, super.key});

  final Color color;
  final int index;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    double height = 200.0 * pow(0.8, index);
    double textSize = max(1, 4.0 * pow(.6, index));
    final hexColor =
        '#${color.toARGB32().toRadixString(16).padLeft(8, '0')}'.toUpperCase();

    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: color,
            duration: const Duration(seconds: 1),
            content: Text(hexColor),
          ),
        );
      },
      child: Container(
        height: max(height, 48.0),
        color: color,
        child: Center(
          child: Text(
            hexColor,
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.apply(
              fontSizeFactor: textSize,
              color: color.contrast,
            ),
          ),
        ),
      ),
    );
  }
}

extension ContrastTextColor on Color {
  Color get contrast {
    double luma = ((0.299 * r) + (0.587 * g) + (0.114 * b)) / 255;

    // Return black for bright colors, white for dark colors
    return luma > 0.5 ? Colors.black : Colors.white;
  }
}
