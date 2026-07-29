# Global Search

Added by: architecture review (see chat history) — not in the original
PDF spec, requested by the client during UI review.

## What it does

Lets a signed-in user search across their own scheduled posts, campaigns,
media, and templates from one place, instead of hunting through each
feature separately.

## How it works

1. **Index maintenance (backend, automatic).**
   `functions/src/search/indexSearchableEntities.ts` registers four
   Firestore triggers — one each for `scheduledPosts`, `campaigns`,
   `media`, `postTemplates` — that fire on every create/update/delete and
   upsert a corresponding entry into `users/{userId}/searchIndex/{indexId}`.
   The client never writes to this collection (`firestore.rules`: read-only
   to the owner).

2. **Reading (frontend).**
   `SearchRepository.search(userId, query)`
   (`frontend/lib/shared/repositories/search_repository.dart`) reads the
   whole `searchIndex` subcollection and filters client-side. This is
   intentionally simple and fine at current scale (one user's own
   content, rarely more than a few hundred items). If result volume ever
   grows large enough that a full-collection read becomes slow, swap this
   repository's internals for a hosted search service (Algolia/Typesense)
   — the call site (`searchRepositoryProvider.search(...)`) doesn't need
   to change.

3. **UI.**
   `GlobalSearchScreen` (`frontend/lib/features/global_search/`) is used
   two ways:
   - **Desktop:** opened as a centered dialog via the "Search…" button at
     the top of `SidebarNav` (`GlobalSearchScreen.showAsDialog(context)`).
   - **Mobile:** registered as a full-screen route at `AppRoutes.globalSearch`
     (`/search`). **Not yet wired to a visible entry point on mobile** —
     `BottomNav` intentionally keeps a curated 5-item list per its existing
     design comment, and adding a 6th icon there is a UX call, not
     something to change unilaterally. Until a teammate decides where it
     belongs on mobile (a 6th bottom-nav icon vs. a Settings menu item vs.
     something else), it's reachable by direct navigation
     (`context.push(AppRoutes.globalSearch)`) but has no on-screen entry
     point yet on small widths.

## Known limitations / next steps

- Tapping a result currently just closes the search dialog/screen
  (see the `TODO` in `search_result_tile.dart`) rather than deep-linking to
  the specific post/campaign/media detail — none of those features
  currently expose a single-item detail route to link to. Add that once
  they do.
- No debounced server-side query — everything is a client-side filter over
  an already-small dataset. Revisit if that assumption stops holding.
