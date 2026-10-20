import 'package:catalog_core/catalog_core.dart';
import 'package:flutter/material.dart';

import 'help.dart';
import 'hidden.dart';
import 'l10n.dart';
import 'spotlight.dart';

/// Width where the app stops being a stretched phone app: list pane
/// left, detail pane right. Purely width-based — iPad landscape and
/// resized desktop windows switch live; phones never see it.
const desktopBreakpoint = 840.0;

/// A page the wide layout can show in its detail pane.
///
/// [id] is the page's identity: the pane keeps its state while the id
/// stays the same and rebuilds when it changes, so re-opening the page
/// already shown does nothing.
class PanePage {
  final String id;
  final WidgetBuilder build;

  const PanePage({required this.id, required this.build});

  /// Whether this page still belongs in the pane of [store].
  ///
  /// Its builder captured a store when it was made, so a page outlives
  /// the catalog it was opened in unless somebody asks. A clowder page
  /// also goes when its clowder is deleted or hidden.
  bool stillBelongs(CatalogStore store, {required Object? openedIn}) {
    if (!identical(openedIn, store)) return false;
    final id = clowderId;
    return id == null || store.visibleClowders().any((c) => c.id == id);
  }

  /// The pane's page for a Clowder. Deleting or hiding that Clowder
  /// vacates the pane, which is why its id is recognisable.
  static PanePage clowder(String clowderId, WidgetBuilder build) =>
      PanePage(id: clowderId_(clowderId), build: build);

  /// The page id a Clowder gets. One place owns the format.
  static String clowderId_(String clowderId) => 'clowder:$clowderId';

  /// The Clowder this page shows, or null for every other page.
  String? get clowderId =>
      id.startsWith('clowder:') ? id.substring('clowder:'.length) : null;
}

/// Height of the second line an app bar gains on a narrow screen.
const _titleLineHeight = 44.0;

/// Width of one button on the icon row below [desktopBreakpoint]: at
/// the default 48dp six buttons and a back arrow overflow a 360dp bar.
const _compactSlot = 40.0;

/// Width of one button in the ordinary bar.
const _slot = 48.0;

/// What the title keeps beside the buttons in the ordinary bar.
const _minTitleWidth = 160.0;

/// An action a page offers in its bar (#171).
///
/// With an [icon] it is a button on the bar, or a row in the ⋮ when the
/// bar is full. Without one it is a labelled text button (Save, Skip)
/// that never leaves the bar. With [menu] it opens a menu of its own
/// (the sort on a cat list) and stays on the bar too.
class PageAction {
  final IconData? icon;
  final String label;
  final VoidCallback? onPressed;

  /// The tip that points at this button, see `spotlight.dart`.
  final String? spotlightId;

  /// Drawn instead of the icon or the words while the action runs.
  final Widget? busy;

  /// The entries of an action that is a menu itself; [onSelected] gets
  /// the chosen value.
  final List<(String value, String label)>? menu;
  final ValueChanged<String>? onSelected;

  const PageAction({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.spotlightId,
    this.busy,
  })  : menu = null,
        onSelected = null;

  const PageAction.labelled({
    required this.label,
    required this.onPressed,
    this.busy,
  })  : icon = null,
        spotlightId = null,
        menu = null,
        onSelected = null;

  const PageAction.menu({
    required IconData this.icon,
    required this.label,
    required List<(String, String)> this.menu,
    required this.onSelected,
  })  : onPressed = null,
        spotlightId = null,
        busy = null;

  /// Pinned actions never overflow: a labelled button has no icon to
  /// stand in a row, a menu cannot nest in the ⋮.
  bool get pinned => icon == null || menu != null;
}

/// The help "?" of a page, first on its bar; absent when the screen has
/// no help text — better absent than empty.
class PageHelp {
  final CatalogStore? store;
  final String screenId;
  const PageHelp(this.screenId, {this.store});
}

/// The one app bar of every page (#171).
///
/// Below [desktopBreakpoint] the title moves to its own line under the
/// buttons, which sit at 40dp, so a cat's name is read in full; from
/// there up it is the ordinary bar with the title beside them. Either
/// way the bar shows [actions] in their order as far as they fit at the
/// width it has, and the rest in a ⋮ at the end — which exists only
/// when something is in it, so a wide screen empties it. [help] is
/// first, a pinned action (labelled, or a menu) always stays.
///
/// [narrow] is for a screen that knows it is in a column rather than
/// the whole window: the list pane is 400px wide no matter how wide the
/// window around it is. [menuSpotlightId] is the tip pointing at the ⋮.
PreferredSizeWidget pageBar(
  BuildContext context, {
  required Widget title,
  List<PageAction> actions = const [],
  PageHelp? help,
  bool? narrow,
  PreferredSizeWidget? bottom,
  String? menuSpotlightId,
  Color? backgroundColor,
  Color? foregroundColor,
}) {
  final roomy =
      narrow ?? MediaQuery.sizeOf(context).width < desktopBreakpoint;
  final all = [
    if (help != null && helpTexts.containsKey(help.screenId))
      PageAction(
        icon: Icons.help_outline,
        label: context.t.helpTitle,
        onPressed: () => showHelp(context, help.store, help.screenId),
      ),
    ...actions,
  ];
  final height = kToolbarHeight +
      (roomy ? _titleLineHeight : 0) +
      (bottom?.preferredSize.height ?? 0);
  return PreferredSize(
    preferredSize: Size.fromHeight(height),
    child: LayoutBuilder(
      builder: (context, constraints) => _PageBar(
        title: title,
        actions: all,
        roomy: roomy,
        width: constraints.maxWidth,
        bottom: bottom,
        menuSpotlightId: menuSpotlightId,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
      ),
    ),
  );
}

class _PageBar extends StatelessWidget {
  final Widget title;
  final List<PageAction> actions;
  final bool roomy;
  final double width;
  final PreferredSizeWidget? bottom;
  final String? menuSpotlightId;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const _PageBar({
    required this.title,
    required this.actions,
    required this.roomy,
    required this.width,
    required this.bottom,
    required this.menuSpotlightId,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  /// The actions that fit the bar, and the ones that go into the ⋮.
  (List<PageAction>, List<PageAction>) _split(BuildContext context) {
    final slot = roomy ? _compactSlot : _slot;
    final leading = (ModalRoute.of(context)?.impliesAppBarDismissal ?? false)
        ? 56.0
        : 0.0;
    var budget = width - leading - 8 - (roomy ? 0 : _minTitleWidth);
    double widthOf(PageAction a) =>
        a.icon == null ? a.label.length * 8.0 + 24 : slot;
    final pinned =
        actions.where((a) => a.pinned).fold(0.0, (w, a) => w + widthOf(a));
    final icons = actions.where((a) => !a.pinned).length;
    if (pinned + icons * slot <= budget) return (actions, const []);
    // The ⋮ takes a slot; the pinned ones keep theirs; the rest fill up
    // in their order.
    budget -= pinned + slot;
    final bar = <PageAction>[], menu = <PageAction>[];
    for (final a in actions) {
      if (a.pinned) {
        bar.add(a);
      } else if (budget >= slot) {
        bar.add(a);
        budget -= slot;
      } else {
        menu.add(a);
      }
    }
    return (bar, menu);
  }

  Widget _button(PageAction a) {
    final Widget button;
    if (a.icon == null) {
      button = TextButton(
        onPressed: a.onPressed,
        child: a.busy ?? Text(a.label),
      );
    } else if (a.menu case final menu?) {
      button = PopupMenuButton<String>(
        icon: Icon(a.icon),
        tooltip: a.label,
        onSelected: a.onSelected,
        itemBuilder: (context) => [
          for (final (value, label) in menu)
            PopupMenuItem(value: value, child: Text(label)),
        ],
      );
    } else {
      button = IconButton(
        icon: a.busy ?? Icon(a.icon),
        tooltip: a.label,
        onPressed: a.onPressed,
      );
    }
    final id = a.spotlightId;
    return id == null ? button : Spotlight(id: id, child: button);
  }

  Widget _overflow(List<PageAction> menu) {
    final button = PopupMenuButton<int>(
      onSelected: (i) => menu[i].onPressed?.call(),
      itemBuilder: (context) => [
        for (final (i, a) in menu.indexed)
          PopupMenuItem(
            value: i,
            enabled: a.onPressed != null,
            child: Row(
              children: [
                a.busy ?? Icon(a.icon),
                const SizedBox(width: 12),
                Flexible(child: Text(a.label)),
              ],
            ),
          ),
      ],
    );
    final id = menuSpotlightId;
    return id == null ? button : Spotlight(id: id, child: button);
  }

  @override
  Widget build(BuildContext context) {
    final (bar, menu) = _split(context);
    final buttons = [
      for (final a in bar) _button(a),
      if (menu.isNotEmpty) _overflow(menu),
    ];
    if (!roomy) {
      return AppBar(
        title: title,
        actions: buttons,
        bottom: bottom,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
      );
    }
    final theme = Theme.of(context);
    final compact = IconButtonThemeData(
      style: IconButton.styleFrom(
        minimumSize: const Size(_compactSlot, _compactSlot),
        fixedSize: const Size(_compactSlot, 48),
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
      ),
    );
    final titleLine = SizedBox(
      height: _titleLineHeight,
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsetsDirectional.only(start: 16, end: 16),
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: DefaultTextStyle(
            style: (theme.appBarTheme.titleTextStyle ??
                    theme.textTheme.titleLarge!)
                .copyWith(
                    color: foregroundColor ?? theme.colorScheme.onSurface),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            child: title,
          ),
        ),
      ),
    );
    final below = bottom;
    return AppBar(
      actions: [
        for (final b in buttons) IconButtonTheme(data: compact, child: b),
      ],
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(
            _titleLineHeight + (below?.preferredSize.height ?? 0)),
        child: below == null
            ? titleLine
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [titleLine, below],
              ),
      ),
    );
  }
}
