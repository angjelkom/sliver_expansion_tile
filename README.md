# sliver_expansion_tile

[![pub package](https://img.shields.io/pub/v/sliver_expansion_tile.svg)](https://pub.dev/packages/sliver_expansion_tile) [![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

A Flutter sliver widget that mimics `ExpansionTile`, allowing items within a `CustomScrollView` to expand and collapse as a sliver.
  
This was part of the talk [The Dark Arts of RenderSliver: Mastering Custom Slivers in Flutter](https://www.droidcon.com/2024/10/17/the-dark-arts-of-rendersliver-mastering-custom-slivers-in-flutter/) at Fluttercon USA 2024.

## Features

- Expand/collapse content inside a sliver list  
- Fully customizable header, border, and border radius  
- Programmatic control via `SliverExpansionTileController`  
- Smooth animation with adjustable duration  
- No external dependencies beyond Flutter SDK

https://github.com/user-attachments/assets/aba0acd6-1537-4d71-b2a9-050a9ad8b8f6

## Getting Started

### Installation

Add the latest version of `sliver_expansion_tile` to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  sliver_expansion_tile: ^<latest_version>
```

Then run:

```bash
flutter pub get
```

### Import

```dart
import 'package:sliver_expansion_tile/sliver_expansion_tile.dart';
```

## Usage

Wrap your sliver content in a `SliverExpansionTile`:

```dart
CustomScrollView(
  slivers: [
    SliverAppBar(title: Text('Sliver Expansion Tile')),
    
    // A normal sliver list above
    SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => ListTile(title: Text(items[index])),
        childCount: items.length,
      ),
    ),
    
    // The expandable tile
    SliverExpansionTile(
      title: Text('More Colors'),
      subtitle: Text('Tap to expand'),
      leading: Icon(Icons.palette),
      children: [
        for (final color in colorList)
          Container(
            height: 60,
            color: color,
          ),
      ],
      border: BorderSide(color: Colors.grey.shade300, width: 2),
      borderRadius: Radius.circular(8),
    ),
    
    // Additional slivers...
  ],
);
```

## Example

See the [example](https://github.com/your_username/sliver_expansion_tile/tree/main/example) directory for a complete demo, including programmatic expansion/collapse using `SliverExpansionTileController`:

```dart
final controller = SliverExpansionTileController();

// In your build:
SliverExpansionTile(
  controller: controller,
  title: Text('Controlled Tile'),
  children: [ /* ... */ ],
);

// Elsewhere (e.g. in a FAB):
FloatingActionButton(
  child: Icon(Icons.expand_more),
  onPressed: () => controller.expand(),
),
```

## API Reference

### `SliverExpansionTile`

| Property            | Type                             | Description                                                  |
| ------------------- | -------------------------------- | ------------------------------------------------------------ |
| `title`             | `Widget`                         | Primary widget displayed in the header                       |
| `subtitle`          | `Widget?`                        | Optional subheader below the title                           |
| `leading`           | `Widget?`                        | Optional widget displayed before the title                   |
| `trailing`          | `Widget?`                        | Custom widget displayed after the title (defaults to arrow)  |
| `children`          | `List<Widget>`                   | Widgets revealed when tile is expanded                       |
| `initiallyExpanded` | `bool`                           | Whether the tile is expanded on first build (default: false) |
| `controller`        | `SliverExpansionTileController?` | Controller for programmatic expansion/collapse               |
| `border`            | `BorderSide?`                    | Optional border drawn around expanded area                   |
| `borderRadius`      | `Radius`                         | Corner radius applied to the clip and border (default: zero) |

### `SliverExpansionTileController`

Control the expansion state from code:

```dart
final controller = SliverExpansionTileController();

// Expand
controller.expand();

// Collapse
controller.collapse();

// Toggle
controller.toggle();

// Check state
if (controller.isExpanded) { ... }
```

You can also retrieve the controller from the widget tree:

```dart
final controller = SliverExpansionTileController.of(context);
```

## Customization

- **Animation duration**: Modify the `AnimationController` duration by forking the package or submitting a feature request.  
- **Theming**: The tile header uses your app’s `ThemeData.colorScheme.onSurface` colors by default. Override the `titleColor` to change background or text colors.

## Contributing

1. Fork the repository  
2. Create your feature branch (`git checkout -b feature/fooBar`)  
3. Commit your changes (`git commit -am 'Add some fooBar'`)  
4. Push to the branch (`git push origin feature/fooBar`)  
5. Open a pull request  

Please ensure all tests pass and follow the [effective Dart style guide](https://dart.dev/guides/language/effective-dart).

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
