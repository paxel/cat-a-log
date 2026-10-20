/// The clock the app reads (#161). [clockNow] is [DateTime.now] in the
/// app; the frame generators set [nowProvider] to a fixed day, so a
/// picture of a page is the same on every run and a stale frame is seen
/// as a diff.
DateTime Function() nowProvider = DateTime.now;

/// Now, as the app sees it.
DateTime clockNow() => nowProvider();
