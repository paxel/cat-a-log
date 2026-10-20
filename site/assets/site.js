// cat(a)log documentation site: theme toggle, sidebar, search, copy-link anchors, the stepper.
// No dependencies. Everything degrades: without storage the theme follows the
// system, without clipboard the link is copied through a selection.
(function () {
  "use strict";

  const root = document.documentElement;
  const siteRoot = root.getAttribute("data-root") || "";
  const lang = root.getAttribute("data-lang") || "en";
  const THEME_KEY = "catlog-theme";
  // The chrome's words in the page's language, written by the build.
  let I18N = {};
  try {
    I18N = JSON.parse(root.getAttribute("data-i18n") || "{}");
  } catch {
    I18N = {};
  }
  function tr(key, fallback) {
    return I18N[key] || fallback;
  }
  const live = document.getElementById("live");

  function announce(text) {
    if (!live) return;
    live.textContent = "";
    window.setTimeout(function () {
      live.textContent = text;
    }, 50);
  }

  // ---------- theme ----------

  const themeToggle = document.querySelector(".theme-toggle");
  const darkQuery = window.matchMedia ? window.matchMedia("(prefers-color-scheme: dark)") : null;

  function effectiveTheme() {
    const chosen = root.getAttribute("data-theme");
    if (chosen === "light" || chosen === "dark") return chosen;
    return darkQuery && darkQuery.matches ? "dark" : "light";
  }

  function labelThemeToggle() {
    if (!themeToggle) return;
    const next = effectiveTheme() === "dark" ? "light" : "dark";
    themeToggle.setAttribute("aria-label", next === "dark" ? tr("toDark", "Switch to dark theme") : tr("toLight", "Switch to light theme"));
  }

  function setTheme(theme) {
    root.setAttribute("data-theme", theme);
    try {
      window.localStorage.setItem(THEME_KEY, theme);
    } catch {
      // Storage unavailable (private mode, blocked): the choice lasts for this page only.
    }
    labelThemeToggle();
  }

  if (themeToggle) {
    themeToggle.addEventListener("click", function () {
      setTheme(effectiveTheme() === "dark" ? "light" : "dark");
    });
    if (darkQuery && darkQuery.addEventListener)
      darkQuery.addEventListener("change", labelThemeToggle);
    labelThemeToggle();
  }

  // ---------- sidebar (narrow screens) ----------

  const navToggle = document.querySelector(".nav-toggle");
  const sidebar = document.getElementById("sidebar");

  function sidebarIsOpen() {
    return Boolean(sidebar && sidebar.classList.contains("is-open"));
  }

  function sidebarFocusables() {
    return [navToggle].concat(Array.prototype.slice.call(sidebar.querySelectorAll("a[href]")));
  }

  function setSidebar(open) {
    if (!sidebar || !navToggle) return;
    sidebar.classList.toggle("is-open", open);
    navToggle.setAttribute("aria-expanded", String(open));
    navToggle.setAttribute("aria-label", open ? tr("closeNav", "Close navigation") : tr("openNav", "Open navigation"));
    if (open) {
      const first = sidebar.querySelector("a[href]");
      if (first) first.focus();
    } else {
      navToggle.focus();
    }
  }

  if (navToggle && sidebar) {
    navToggle.addEventListener("click", function () {
      setSidebar(!sidebarIsOpen());
    });
    document.addEventListener("click", function (event) {
      if (!sidebarIsOpen()) return;
      if (sidebar.contains(event.target) || navToggle.contains(event.target)) return;
      setSidebar(false);
    });
    document.addEventListener("keydown", function (event) {
      if (!sidebarIsOpen()) return;
      if (event.key === "Escape") {
        setSidebar(false);
        event.preventDefault();
        return;
      }
      if (event.key !== "Tab") return;
      // Keep Tab inside the open panel (toggle button + its links).
      const focusables = sidebarFocusables();
      const first = focusables[0];
      const last = focusables[focusables.length - 1];
      if (event.shiftKey && document.activeElement === first) {
        last.focus();
        event.preventDefault();
      } else if (!event.shiftKey && document.activeElement === last) {
        first.focus();
        event.preventDefault();
      } else if (
        !sidebar.contains(document.activeElement) &&
        document.activeElement !== navToggle
      ) {
        first.focus();
        event.preventDefault();
      }
    });
  }

  // ---------- copy link on heading anchors ----------

  function selectHeadingText(anchor) {
    const heading = anchor.parentElement;
    if (!heading || !window.getSelection) return;
    const range = document.createRange();
    range.selectNodeContents(heading);
    range.setEndBefore(anchor);
    const selection = window.getSelection();
    selection.removeAllRanges();
    selection.addRange(range);
  }

  function flashCopied(anchor) {
    anchor.setAttribute("data-copied", "");
    announce(tr("linkCopied", "Link copied"));
    window.setTimeout(function () {
      anchor.removeAttribute("data-copied");
    }, 1600);
  }

  // Without the async clipboard: select the URL in a scratch field and copy it;
  // if even that fails, leave the heading text selected for a manual copy.
  function copyThroughSelection(anchor, url) {
    const field = document.createElement("textarea");
    field.value = url;
    field.setAttribute("readonly", "");
    field.className = "sr-only";
    document.body.appendChild(field);
    field.select();
    let copied = false;
    try {
      copied = document.execCommand("copy");
    } catch {
      copied = false;
    }
    document.body.removeChild(field);
    if (copied) {
      flashCopied(anchor);
    } else {
      selectHeadingText(anchor);
      announce(tr("copyFailed", "Could not copy automatically; the heading is selected"));
    }
  }

  document.addEventListener("click", function (event) {
    const anchor = event.target.closest && event.target.closest("a.anchor");
    if (!anchor) return;
    const url = window.location.href.split("#")[0] + anchor.getAttribute("href");
    if (navigator.clipboard && navigator.clipboard.writeText) {
      navigator.clipboard.writeText(url).then(
        function () {
          flashCopied(anchor);
        },
        function () {
          copyThroughSelection(anchor, url);
        },
      );
    } else {
      copyThroughSelection(anchor, url);
    }
  });

  // ---------- table of contents: mark the section in view ----------

  const tocLinks = Array.prototype.slice.call(document.querySelectorAll(".toc a[href^='#']"));
  if (tocLinks.length && "IntersectionObserver" in window) {
    const byId = {};
    tocLinks.forEach(function (link) {
      byId[link.getAttribute("href").slice(1)] = link;
    });
    const observer = new IntersectionObserver(
      function (entries) {
        entries.forEach(function (entry) {
          if (!entry.isIntersecting) return;
          tocLinks.forEach(function (l) {
            l.removeAttribute("aria-current");
          });
          const link = byId[entry.target.id];
          if (link) link.setAttribute("aria-current", "true");
        });
      },
      { rootMargin: "-10% 0px -75% 0px" },
    );
    Object.keys(byId).forEach(function (id) {
      const el = document.getElementById(id);
      if (el) observer.observe(el);
    });
  }

  // ---------- recorded walkthroughs: the stepper and the story graph ----------
  //
  // A story page holds one `.story` with the steps as `section.step` elements
  // (ids `step-1`, `step-2`, …) and, optionally, a `.story-graph` figure whose
  // parts carry `data-g="<name>"`. A step lists the parts that exist at that
  // point in `data-graph` and the parts that changed in `data-graph-highlight`
  // (comma-separated). Without the script every step is simply visible.

  const story = document.querySelector(".story");
  const steps = story ? Array.prototype.slice.call(story.querySelectorAll(".step")) : [];
  if (steps.length) {
    const graphParts = Array.prototype.slice.call(story.querySelectorAll(".story-graph [data-g]"));
    const nav = story.querySelector(".stepper-nav");
    const prev = nav ? nav.querySelector(".step-prev") : null;
    const next = nav ? nav.querySelector(".step-next") : null;
    const counter = nav ? nav.querySelector(".step-counter") : null;
    const list = document.createElement("ol");
    list.className = "step-list";
    const listLinks = steps.map(function (step, i) {
      const li = document.createElement("li");
      const a = document.createElement("a");
      a.href = "#step-" + (i + 1);
      const heading = step.querySelector("h2");
      a.textContent = heading
        ? heading.textContent
            .replace(/^\s*\d+\.\s*/, "")
            .replace(/#\s*$/, "")
            .trim()
        : tr("step", "Step") + " " + (i + 1);
      li.appendChild(a);
      list.appendChild(li);
      return a;
    });
    if (nav) nav.insertAdjacentElement("afterend", list);
    else story.insertBefore(list, steps[0]);

    let current = -1;

    function names(step, attr) {
      const value = step.getAttribute(attr);
      return value
        ? value.split(",").map(function (n) {
            return n.trim();
          })
        : [];
    }

    // Below the figure's minimum width it scrolls sideways: bring the first
    // highlighted part into view so the change is never off-screen.
    function revealInFigure(part) {
      const figure = story.querySelector(".story-graph");
      if (!figure || figure.scrollWidth <= figure.clientWidth + 1) return;
      const box = part.getBoundingClientRect();
      const frame = figure.getBoundingClientRect();
      if (box.left >= frame.left && box.right <= frame.right) return;
      figure.scrollLeft += box.left - frame.left - (frame.width - box.width) / 2;
    }

    function applyGraph(step) {
      const shown = names(step, "data-graph");
      const marked = names(step, "data-graph-highlight");
      let first = null;
      graphParts.forEach(function (part) {
        const name = part.getAttribute("data-g");
        part.classList.toggle("is-hidden", shown.indexOf(name) < 0);
        const highlighted = marked.indexOf(name) >= 0;
        part.classList.toggle("is-highlight", highlighted);
        if (highlighted && !first) first = part;
      });
      const caption = story.querySelector(".story-graph figcaption");
      if (caption && step.hasAttribute("data-graph-caption")) {
        caption.textContent = step.getAttribute("data-graph-caption");
      }
      if (first) revealInFigure(first);
    }

    function show(index, options) {
      const opts = options || {};
      if (index < 0 || index >= steps.length || index === current) return;
      current = index;
      steps.forEach(function (step, i) {
        step.hidden = i !== index;
      });
      listLinks.forEach(function (a, i) {
        if (i === index) a.setAttribute("aria-current", "step");
        else a.removeAttribute("aria-current");
      });
      if (prev) prev.disabled = index === 0;
      if (next) next.disabled = index === steps.length - 1;
      if (counter)
        counter.textContent = tr("stepOf", "Step {n} of {m}")
          .replace("{n}", String(index + 1))
          .replace("{m}", String(steps.length));
      applyGraph(steps[index]);
      // Navigation pushes a history entry, so Back returns to the previous
      // step; the initial step and hash-driven changes only replace it.
      if (opts.hash !== false && window.history && window.history.pushState) {
        const url = "#step-" + (index + 1);
        if (opts.replace) window.history.replaceState(null, "", url);
        else window.history.pushState(null, "", url);
      }
      if (opts.focus) {
        const heading = steps[index].querySelector("h2");
        if (heading) {
          heading.setAttribute("tabindex", "-1");
          heading.focus({ preventScroll: true });
        }
        if (nav) nav.scrollIntoView({ block: "nearest" });
      }
    }

    // `#step-N` opens a step; a hash naming an element inside a step opens
    // that step first, so links from the table of contents and search work.
    function stepFromHash() {
      const hash = window.location.hash.slice(1);
      if (!hash) return -1;
      const m = /^step-(\d+)$/.exec(hash);
      if (m) return Math.min(steps.length, Math.max(1, Number(m[1]))) - 1;
      const target = document.getElementById(hash);
      if (!target) return -1;
      return steps.findIndex(function (step) {
        return step.contains(target);
      });
    }

    if (prev)
      prev.addEventListener("click", function () {
        show(current - 1, { focus: true });
      });
    if (next)
      next.addEventListener("click", function () {
        show(current + 1, { focus: true });
      });
    list.addEventListener("click", function (event) {
      const a = event.target.closest && event.target.closest("a[href^='#step-']");
      if (!a) return;
      show(Number(a.getAttribute("href").slice(6)) - 1, { focus: true });
      event.preventDefault();
    });
    // The address changed by hand, by a link, or by Back/Forward.
    function syncFromHash() {
      const index = stepFromHash();
      if (index < 0) return;
      show(index, { hash: false, focus: true });
      const hash = window.location.hash.slice(1);
      const target = document.getElementById(hash);
      if (target && !/^step-\d+$/.test(hash)) target.scrollIntoView({ block: "start" });
    }
    window.addEventListener("hashchange", syncFromHash);
    window.addEventListener("popstate", syncFromHash);
    // Arrow keys work while the focus is inside the story (a control, a step
    // heading), and never steal them from a field or a scrollable block.
    story.addEventListener("keydown", function (event) {
      if (event.ctrlKey || event.metaKey || event.altKey) return;
      const target = event.target;
      const typing =
        target &&
        (target.tagName === "INPUT" ||
          target.tagName === "TEXTAREA" ||
          target.tagName === "SELECT" ||
          target.isContentEditable);
      if (typing) return;
      const scrollable =
        target &&
        target !== story &&
        (target.scrollWidth > target.clientWidth || target.scrollHeight > target.clientHeight);
      if (scrollable) return;
      if (event.key === "ArrowRight") show(current + 1, { focus: true });
      else if (event.key === "ArrowLeft") show(current - 1, { focus: true });
      else return;
      event.preventDefault();
    });

    story.classList.add("is-enhanced");
    const initial = stepFromHash();
    show(initial >= 0 ? initial : 0, { hash: initial >= 0, replace: true });
    if (initial >= 0) {
      const hash = window.location.hash.slice(1);
      const target = document.getElementById(hash);
      if (target && !/^step-\d+$/.test(hash)) target.scrollIntoView({ block: "start" });
    }
  }

  // ---------- search ----------

  const input = document.getElementById("search");
  const results = document.getElementById("search-results");
  if (!input || !results) return;

  let indexPromise = null;
  let items = [];
  let active = -1;

  function loadIndex() {
    if (!indexPromise) {
      indexPromise = window
        .fetch(siteRoot + lang + "/search-index.json")
        .then(function (res) {
          if (!res.ok) throw new Error("search index: HTTP " + res.status);
          return res.json();
        })
        .catch(function (err) {
          indexPromise = null; // retry on the next keystroke
          throw err;
        });
    }
    return indexPromise;
  }

  function escapeHtml(text) {
    return String(text)
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;");
  }

  function escapeRegExp(text) {
    return text.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
  }

  function highlight(text, query) {
    const re = new RegExp("(" + escapeRegExp(query) + ")", "ig");
    return text
      .split(re)
      .map(function (part, i) {
        return i % 2 === 1 ? "<mark>" + escapeHtml(part) + "</mark>" : escapeHtml(part);
      })
      .join("");
  }

  function snippet(text, query) {
    const at = text.toLowerCase().indexOf(query.toLowerCase());
    if (at < 0) return text.slice(0, 120);
    const start = Math.max(0, at - 50);
    const end = Math.min(text.length, at + query.length + 90);
    return (start > 0 ? "…" : "") + text.slice(start, end) + (end < text.length ? "…" : "");
  }

  // Heading matches outrank body matches; a page-title match outranks both.
  function search(index, query) {
    const q = query.toLowerCase();
    const found = [];
    index.forEach(function (page, pageNo) {
      const pageLabel = page.track ? page.track + " · " + page.title : page.title;
      if (page.title.toLowerCase().indexOf(q) >= 0) {
        found.push({
          score: 3,
          order: pageNo,
          url: page.url,
          title: page.title,
          meta: page.track || "Page",
          snippet: page.summary || page.intro || "",
        });
      } else if ((page.intro || "").toLowerCase().indexOf(q) >= 0) {
        found.push({
          score: 1,
          order: pageNo,
          url: page.url,
          title: page.title,
          meta: page.track || "Page",
          snippet: snippet(page.intro, query),
        });
      }
      (page.headings || []).forEach(function (h) {
        const inHeading = h.text.toLowerCase().indexOf(q) >= 0;
        const inBody = (h.body || "").toLowerCase().indexOf(q) >= 0;
        if (!inHeading && !inBody) return;
        found.push({
          score: inHeading ? 2 : 1,
          order: pageNo,
          url: page.url + "#" + h.id,
          title: h.text,
          meta: pageLabel,
          snippet: snippet(h.body || "", query),
        });
      });
    });
    found.sort(function (a, b) {
      return b.score - a.score || a.order - b.order;
    });
    return found.slice(0, 8);
  }

  function close() {
    results.hidden = true;
    results.innerHTML = "";
    input.setAttribute("aria-expanded", "false");
    input.removeAttribute("aria-activedescendant");
    items = [];
    active = -1;
  }

  function setActive(i) {
    items.forEach(function (li, n) {
      li.setAttribute("aria-selected", String(n === i));
    });
    active = i;
    if (i >= 0) {
      input.setAttribute("aria-activedescendant", items[i].id);
      items[i].scrollIntoView({ block: "nearest" });
    } else {
      input.removeAttribute("aria-activedescendant");
    }
  }

  function open(html) {
    results.innerHTML = html;
    results.hidden = false;
    input.setAttribute("aria-expanded", "true");
    items = Array.prototype.slice.call(results.querySelectorAll("li[role='option']"));
    active = -1;
  }

  function render(hits, query) {
    if (!hits.length) {
      open('<li class="search-empty" role="presentation">' + escapeHtml(tr("noMatches", "No matches")) + "</li>");
      announce(tr("noMatches", "No matches"));
      return;
    }
    open(
      hits
        .map(function (hit, i) {
          return (
            '<li id="search-hit-' +
            i +
            '" role="option" aria-selected="false"><a href="' +
            escapeHtml(siteRoot + lang + "/" + hit.url) +
            '"><span class="result-title">' +
            highlight(hit.title, query) +
            '</span><span class="result-meta">' +
            escapeHtml(hit.meta) +
            "</span>" +
            (hit.snippet
              ? '<span class="result-snippet">' + highlight(hit.snippet, query) + "</span>"
              : "") +
            "</a></li>"
          );
        })
        .join(""),
    );
    announce(hits.length + " " + (hits.length === 1 ? tr("result", "result") : tr("results", "results")));
  }

  let pending = 0;
  function runSearch() {
    const query = input.value.trim();
    if (query.length < 2) {
      close();
      return;
    }
    const ticket = ++pending;
    loadIndex().then(
      function (index) {
        if (ticket !== pending || input.value.trim() !== query) return;
        render(search(index, query), query);
      },
      function () {
        if (ticket !== pending) return;
        open('<li class="search-empty" role="presentation">' + escapeHtml(tr("searchUnavailable", "Search unavailable")) + "</li>");
        announce(tr("searchUnavailable", "Search unavailable"));
      },
    );
  }

  input.addEventListener("focus", function () {
    loadIndex().catch(function () {
      // Reported when the reader actually searches.
    });
  });
  input.addEventListener("input", runSearch);
  input.addEventListener("keydown", function (event) {
    if (event.key === "Escape") {
      if (results.hidden) input.blur();
      else close();
      event.preventDefault();
    } else if (event.key === "ArrowDown" && items.length) {
      setActive((active + 1) % items.length);
      event.preventDefault();
    } else if (event.key === "ArrowUp" && items.length) {
      setActive((active - 1 + items.length) % items.length);
      event.preventDefault();
    } else if (event.key === "Enter" && items.length) {
      const link = items[active >= 0 ? active : 0].querySelector("a");
      if (link) window.location.href = link.href;
      event.preventDefault();
    }
  });

  document.addEventListener("click", function (event) {
    if (!results.hidden && !input.parentElement.contains(event.target)) close();
  });

  document.addEventListener("keydown", function (event) {
    if (event.key !== "/" || event.ctrlKey || event.metaKey || event.altKey) return;
    const target = event.target;
    const typing =
      target &&
      (target.tagName === "INPUT" || target.tagName === "TEXTAREA" || target.isContentEditable);
    if (typing) return;
    input.focus();
    input.select();
    event.preventDefault();
  });
})();
