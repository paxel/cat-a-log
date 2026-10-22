import 'package:catalog_core/catalog_core.dart';
import 'package:flutter/material.dart';

import '../l10n.dart';
import '../layout.dart';
import '../toys/toy.dart';
import 'toy_screen.dart';

/// This device's choice for the toys' sounds; on unless switched off.
const toySoundsKey = 'toySounds';

/// The toys for the cat (#172): a laser dot and a mouse, each started
/// with one tap, and how the last game went.
class PlayScreen extends StatefulWidget {
  final CatalogStore store;

  /// Opens a toy; a test stands in for the full-screen game.
  final Future<ToyResult?> Function(BuildContext, ToyKind, bool sounds)? open;

  const PlayScreen({super.key, required this.store, this.open});

  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  ToyResult? _last;

  bool get _sounds => widget.store.localSetting(toySoundsKey) != 'off';

  Future<void> _start(ToyKind kind) async {
    final open = widget.open ??
        (context, kind, sounds) => Navigator.of(context).push<ToyResult>(
              MaterialPageRoute(
                builder: (_) => ToyScreen(kind: kind, sounds: sounds),
              ),
            );
    final result = await open(context, kind, _sounds);
    if (!mounted || result == null) return;
    setState(() => _last = result);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final last = _last;
    return Scaffold(
      appBar: pageBar(
        context,
        title: Text(t.playToys),
        help: PageHelp('play', store: widget.store),
      ),
      body: ListView(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(t.playIntro),
        ),
        if (last != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              t.toyLastGame(
                t.toyCatches(last.catches),
                t.toyMinutes(last.played.inMinutes),
              ),
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
        ListTile(
          leading: const Icon(Icons.adjust, color: Color(0xFFE53935)),
          title: Text(t.toyLaserDot),
          subtitle: Text(t.toyLaserDotHint),
          onTap: () => _start(ToyKind.laserDot),
        ),
        ListTile(
          leading: const Icon(Icons.pest_control_rodent_outlined),
          title: Text(t.toyMouse),
          subtitle: Text(t.toyMouseHint),
          onTap: () => _start(ToyKind.mouse),
        ),
        const Divider(),
        SwitchListTile(
          secondary: const Icon(Icons.volume_up_outlined),
          title: Text(t.toySounds),
          value: _sounds,
          onChanged: (on) => setState(() => widget.store
              .setLocalSetting(toySoundsKey, on ? 'on' : 'off')),
        ),
      ]),
    );
  }
}
