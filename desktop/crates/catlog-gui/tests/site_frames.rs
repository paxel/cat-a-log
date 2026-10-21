//! The desk's frames for the documentation site (#162), not a test
//! suite: every view and modal of the Desk track and every step of the
//! desk flows, drawn over the demo catalog in English and German and
//! written to `site/assets/frames/desk/<lang>/`. The clock stands still
//! and motion is off, so every run draws the same pictures; the frames are
//! not committed, the Pages workflow renders them on the runner through
//! `tool/frames.sh`. Ignored like the snapshots: they need a GPU or a
//! software Vulkan such as lavapipe.
//!
//! ```sh
//! UPDATE_SNAPSHOTS=force cargo test -p catlog-gui --test site_frames -- --ignored
//! ```

use std::path::PathBuf;
use std::sync::Arc;

use catlog_core::tiles::{TileCache, TileFetcher, TileId, TileSource};
use catlog_gui::documents_page::DocKind;
use catlog_gui::l10n::L10n;
use catlog_gui::pages::PageAction;
use catlog_gui::views::Modal;
use catlog_gui::{App, Selection, SettingsFile, View};
use egui_kittest::kittest::Queryable;
use egui_kittest::{Harness, SnapshotOptions, SnapshotResults};

/// Tiles that never come from the network: one flat grey square each.
struct GreyTiles;

impl TileSource for GreyTiles {
    fn fetch(&self, _tile: TileId) -> Result<Vec<u8>, String> {
        let img = image::DynamicImage::new_rgb8(256, 256);
        let mut out = Vec::new();
        img.write_to(&mut std::io::Cursor::new(&mut out), image::ImageFormat::Png)
            .map_err(|e| e.to_string())?;
        Ok(out)
    }
}

struct NoGeocoder;

impl catlog_core::geocode::Geocoder for NoGeocoder {
    fn search(&self, _query: &str) -> Result<Vec<catlog_core::geocode::GeoHit>, String> {
        Ok(Vec::new())
    }
}

fn frames_dir(lang: &str) -> PathBuf {
    let dir = PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .join("../../../site/assets/frames/desk")
        .join(lang);
    std::fs::create_dir_all(&dir).expect("frames dir");
    dir
}

/// The app over the demo catalog, in `lang`, on the demo's day.
fn app(dir: &std::path::Path, lang: &str) -> App {
    let mut file = SettingsFile::load(dir);
    file.settings.locale = Some(lang.into());
    file.settings.intro_seen = true;
    file.settings.author = Some("Alex".into());
    file.settings.eye_candy = false;
    file.settings.tips_seen = vec!["all".into()];
    let tiles = TileCache::open(&dir.join("tiles"), Box::new(GreyTiles)).expect("tiles");
    let tiles = TileFetcher::inline(Arc::new(tiles));
    let mut app = App::open_with(
        file,
        &dir.join("data"),
        Arc::new(tiles),
        Arc::new(NoGeocoder),
    )
    .expect("app");
    let fixture = PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("tests/demo/folder");
    app.store_mut()
        .import_folder(&fixture, None)
        .expect("demo folder");
    let at = chrono::NaiveDate::from_ymd_opt(2026, 10, 20)
        .expect("a day")
        .and_hms_opt(9, 0, 0)
        .expect("a time");
    app.now = Box::new(move || at);
    catlog_gui::tips::mark_all_seen(app.store());
    app
}

fn harness(app: App) -> Harness<'static, App> {
    let mut h = Harness::builder()
        .with_size(egui::vec2(1440.0, 900.0))
        .wgpu()
        .build_ui_state(
            |ui, app: &mut App| {
                App::install_theme(ui.ctx());
                app.show(ui);
            },
            app,
        );
    // A few steps, never "run": a page with a pulse (the hosting modal)
    // repaints for ever, which run() counts as a failure.
    h.run_steps(4);
    h
}

/// Writes the frame with `UPDATE_SNAPSHOTS=1`, else compares it with the
/// committed one the way the view snapshots are compared: a little slack
/// for how one GPU rasterises against another, a failure for a change.
fn shoot(h: &mut Harness<'static, App>, lang: &str, name: &str) {
    shoot_with(h, lang, name, 400);
}

/// A frame with a pair code or a PIN rolls new dice on every run: it is
/// written when the frames are updated and left alone when they are
/// compared.
fn shoot_lenient(h: &mut Harness<'static, App>, lang: &str, name: &str) {
    if std::env::var("UPDATE_SNAPSHOTS").is_ok() {
        shoot_with(h, lang, name, usize::MAX);
    } else {
        h.run_steps(4);
    }
}

fn shoot_with(h: &mut Harness<'static, App>, lang: &str, name: &str, pixels: usize) {
    h.run_steps(4);
    let dir = frames_dir(lang);
    if let Some(parent) = std::path::Path::new(name).parent() {
        std::fs::create_dir_all(dir.join(parent)).expect("flow dir");
    }
    let options = SnapshotOptions::default()
        .output_path(dir)
        .threshold(1.5)
        .failed_pixel_count_threshold(pixels);
    h.snapshot_options(name, &options);
}

fn cat_id(app: &App, name: &str) -> String {
    app.store()
        .cats(None)
        .expect("cats")
        .into_iter()
        .find(|c| c.name == name)
        .expect("a demo cat")
        .id
}

fn clowder_id(app: &App, name: &str) -> String {
    app.store()
        .clowders()
        .expect("clowders")
        .into_iter()
        .find(|c| c.name == name)
        .expect("a demo home")
        .id
}

/// A fresh app per frame, prepared by `prepare`, shot once.
fn page(lang: &str, results: &mut SnapshotResults, name: &str, prepare: impl FnOnce(&mut App)) {
    let dir = tempfile::tempdir().expect("temp dir");
    let mut app = app(dir.path(), lang);
    prepare(&mut app);
    let mut h = harness(app);
    shoot(&mut h, lang, name);
    results.extend_harness(&mut h);
}

fn click(h: &mut Harness<'static, App>, label: &str) {
    h.get_all_by_label(label).next().expect(label).click();
    h.run_steps(4);
}

fn frames(lang: &str) {
    let t = L10n::new(lang);
    // Every harness's comparisons end up here; one verdict at the end.
    let mut results = SnapshotResults::new();
    // ---- the views and modals, one frame each, named like the site's pages
    page(lang, &mut results, "home", |_| {});
    page(lang, &mut results, "cats", |app| app.open_view(View::Cats));
    page(lang, &mut results, "clowders", |app| {
        app.open_view(View::Clowders)
    });
    page(lang, &mut results, "family", |app| {
        app.open_view(View::Family)
    });
    page(lang, &mut results, "map", |app| app.open_view(View::Map));
    page(lang, &mut results, "agenda", |app| {
        app.open_view(View::Agenda)
    });
    page(lang, &mut results, "agenda-week", |app| {
        app.open_view(View::Agenda);
        let _ = app.store().set_local_setting("agendaCalendar", "week");
    });
    page(lang, &mut results, "vet", |app| app.open_view(View::Vet));
    page(lang, &mut results, "cards", |app| {
        app.open_view(View::Cats);
        let miezi = cat_id(app, "Herr Sonnenschein");
        let luna = cat_id(app, "Luna");
        app.select(Selection::Cat(miezi));
        app.select(Selection::Cat(luna));
    });
    page(lang, &mut results, "edit", |app| {
        let miezi = cat_id(app, "Herr Sonnenschein");
        app.open_record(miezi.clone());
        app.open_modal(Modal::Page(miezi));
    });
    page(lang, &mut results, "timeline", |app| {
        let miezi = cat_id(app, "Herr Sonnenschein");
        app.open_record(miezi.clone());
        app.open_modal(Modal::Timeline(miezi));
    });
    page(lang, &mut results, "history", |app| {
        let miezi = cat_id(app, "Herr Sonnenschein");
        app.open_record(miezi.clone());
        app.open_history(&miezi, "weight");
    });
    page(lang, &mut results, "documents", |app| {
        let miezi = cat_id(app, "Herr Sonnenschein");
        app.open_record(miezi.clone());
        app.act_page(PageAction::Document(DocKind::Card, miezi));
    });
    page(lang, &mut results, "capture", |app| {
        app.open_modal(Modal::Capture)
    });
    page(lang, &mut results, "sync", |app| {
        app.open_modal(Modal::Sync)
    });
    {
        let dir = tempfile::tempdir().expect("temp dir");
        let mut app = app(dir.path(), lang);
        app.open_modal(Modal::InPerson);
        let mut h = harness(app);
        shoot_lenient(&mut h, lang, "in-person");
        results.extend_harness(&mut h);
    }
    page(lang, &mut results, "conflicts", |app| {
        app.open_modal(Modal::Conflicts)
    });
    page(lang, &mut results, "duplicates", |app| {
        app.open_modal(Modal::Duplicates)
    });
    page(lang, &mut results, "moments", |app| {
        app.open_modal(Modal::Moments)
    });
    page(lang, &mut results, "archive", |app| {
        app.open_modal(Modal::Archive)
    });
    page(lang, &mut results, "backups", |app| {
        app.open_modal(Modal::Backups)
    });
    page(lang, &mut results, "restore", |app| {
        app.open_modal(Modal::Restore)
    });
    page(lang, &mut results, "moderation", |app| {
        app.open_modal(Modal::Moderation)
    });
    page(lang, &mut results, "settings", |app| {
        app.open_modal(Modal::Settings)
    });
    page(lang, &mut results, "achievements", |app| {
        app.open_modal(Modal::Achievements)
    });
    page(lang, &mut results, "catalogs", |app| {
        app.open_modal(Modal::Catalogs)
    });

    // ---- the flows: a frame per step, driven on the desk
    // Lay out cards on the desk.
    {
        let dir = tempfile::tempdir().expect("temp dir");
        let mut h = harness(app(dir.path(), lang));
        click(&mut h, t.clowders());
        shoot(&mut h, lang, "lay-out-cards/01");
        click(&mut h, "Foster Home South");
        h.key_press(egui::Key::Enter);
        shoot(&mut h, lang, "lay-out-cards/02");
        click(&mut h, t.cats());
        click(&mut h, "Herr Sonnenschein");
        h.key_press(egui::Key::Enter);
        click(&mut h, "Luna");
        h.key_press(egui::Key::Enter);
        shoot(&mut h, lang, "lay-out-cards/03");
        click(&mut h, t.desk_tile());
        shoot(&mut h, lang, "lay-out-cards/04");
        results.extend_harness(&mut h);
    }
    // Edit a value from a card.
    {
        let dir = tempfile::tempdir().expect("temp dir");
        let mut app = app(dir.path(), lang);
        let miezi = cat_id(&app, "Herr Sonnenschein");
        app.open_view(View::Cats);
        app.select(Selection::Cat(miezi.clone()));
        let mut h = harness(app);
        shoot(&mut h, lang, "edit-a-value/01");
        h.get_all_by_label(t.edit_value())
            .next()
            .expect("a pen")
            .click();
        h.run_steps(4);
        shoot(&mut h, lang, "edit-a-value/02");
        results.extend_harness(&mut h);
    }
    // Add a chore from the agenda.
    {
        let dir = tempfile::tempdir().expect("temp dir");
        let mut h = harness(app(dir.path(), lang));
        click(&mut h, t.agenda());
        shoot(&mut h, lang, "add-a-chore/01");
        click(&mut h, t.add_appointment());
        shoot(&mut h, lang, "add-a-chore/02");
        results.extend_harness(&mut h);
    }
    // Finish a vet run from the Vet view.
    {
        let dir = tempfile::tempdir().expect("temp dir");
        let mut h = harness(app(dir.path(), lang));
        click(&mut h, t.view_vet());
        shoot(&mut h, lang, "finish-a-vet-run/01");
        click(&mut h, t.finish_label());
        shoot(&mut h, lang, "finish-a-vet-run/02");
        results.extend_harness(&mut h);
    }
    // Print the card, build the report.
    {
        let dir = tempfile::tempdir().expect("temp dir");
        let mut app = app(dir.path(), lang);
        let miezi = cat_id(&app, "Herr Sonnenschein");
        app.open_record(miezi.clone());
        app.act_page(PageAction::Document(DocKind::Card, miezi.clone()));
        let mut h = harness(app);
        shoot(&mut h, lang, "print-the-card/01");
        let pumpkin = cat_id(h.state(), "Pumpkin");
        h.state_mut()
            .act_page(PageAction::Document(DocKind::VetReport, miezi.clone()));
        shoot(&mut h, lang, "print-the-card/02");
        h.state_mut()
            .act_page(PageAction::Document(DocKind::Poster, pumpkin));
        shoot(&mut h, lang, "print-the-card/03");
        results.extend_harness(&mut h);
    }
    // Host an in-person sync; export a bundle.
    {
        let dir = tempfile::tempdir().expect("temp dir");
        let mut app = app(dir.path(), lang);
        app.open_modal(Modal::Sync);
        let mut h = harness(app);
        shoot(&mut h, lang, "sync-with-a-phone/01");
        // The button sits below the fold of the modal: the action itself.
        h.state_mut().start_hosting();
        shoot_lenient(&mut h, lang, "sync-with-a-phone/02");
        results.extend_harness(&mut h);
    }
    // Merge two cats, transfer one.
    {
        let dir = tempfile::tempdir().expect("temp dir");
        let mut app = app(dir.path(), lang);
        let findus = cat_id(&app, "Findus");
        app.open_record(findus.clone());
        app.open_modal(Modal::Page(findus.clone()));
        let mut h = harness(app);
        shoot(&mut h, lang, "merge-two-cats/01");
        // "Merge this cat into…" from the page's Actions menu.
        h.state_mut().act_page(PageAction::MergeInto(findus));
        shoot(&mut h, lang, "merge-two-cats/02");
        results.extend_harness(&mut h);
    }
    // Go back to a moment; restore a backup.
    {
        let dir = tempfile::tempdir().expect("temp dir");
        let mut app = app(dir.path(), lang);
        let _ = app.store().add_moment(
            catlog_core::moments::cause::MANUAL,
            Some("Before the vet"),
            None,
        );
        app.open_modal(Modal::Moments);
        let mut h = harness(app);
        shoot(&mut h, lang, "go-back/01");
        results.extend_harness(&mut h);
    }
    let _ = clowder_id;
    results.unwrap();
}

#[test]
#[ignore = "writes the site's desk frames; needs a GPU or lavapipe"]
fn english() {
    frames("en");
}

#[test]
#[ignore = "writes the site's desk frames; needs a GPU or lavapipe"]
fn german() {
    frames("de");
}
