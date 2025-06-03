import 'dart:ui';

import 'package:sliver_expansion_tile/sliver_expansion_tile_new.dart'
    show SliverExpansionTileController;

class ColorPalette {
  final String name;
  final String description;
  final List<Color> colors;
  final SliverExpansionTileController controller;

  ColorPalette(this.name, this.description, this.colors, this.controller);
}

final palettes = [
  ColorPalette(
    'Nature',
    'Hues drawn from the heart of nature.',
    [
      const Color(0xff16423C),
      const Color(0xff6A9C89),
      const Color(0xffC4DAD2),
      const Color(0xffE9EFEC),
      const Color(0xffDEF9C4),
      const Color(0xff9CDBA6),
      const Color(0xffEF5A6F),
      const Color(0xffFFF1DB),
      const Color(0xff536493),
      const Color(0xff3AA6B9),
      const Color(0xffFFD0D0),
      const Color(0xffFF9EAA),
      const Color(0xff8E7AB5),
      const Color(0xffB784B7),
      const Color(0xffE493B3),
      const Color(0xffEEA5A6),
    ],
    SliverExpansionTileController(),
  ),
  ColorPalette('Sky', 'Shades of the endless sky above.', [
    const Color(0xffB6FFFA),
    const Color(0xff98E4FF),
    const Color(0xff80B3FF),
    const Color(0xff687EFF),
  ], SliverExpansionTileController()),
  ColorPalette(
    'Vintage',
    'Timeless tones with a touch of nostalgia.',
    [
      const Color(0xffEF5A6F),
      const Color(0xffFFF1DB),
      const Color(0xff536493),
      const Color(0xff3AA6B9),
      const Color(0xffFFD0D0),
      const Color(0xffFF9EAA),
      const Color(0xff8E7AB5),
      const Color(0xffB784B7),
      const Color(0xffE493B3),
      const Color(0xffEEA5A6),
    ],
    SliverExpansionTileController(),
  ),
];

const activites = [
  [
    'Read a Harry Potter book',
    'Watch a Movie',
    'Weekend Activities',
    'Have a breakfast',
    'Go to the gym',
    'Walk to the park',
  ],
  [
    'Groceries shopping',
    'Lunch with my best friend',
    'Karaoke night',
    'Take vitamins',
  ],
  [
    'Call your cousin',
    'Invite your friends to dinner',
    'Birthday party',
    'Prepare for Fluttercon',
    'Explore New York City',
    'Mingle with people',
    'Have a nap',
  ],
];
