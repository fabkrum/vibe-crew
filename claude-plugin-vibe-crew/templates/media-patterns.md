# Media Pattern Reference

Agent-facing reference for media-rich interfaces — image galleries, video players, audio experiences, file uploads, and media optimization. The Builder reads this during the Design Phase; the Code Reviewer checks compliance during review.
**Principle:** Media must load fast, play reliably, and remain accessible. Lazy-load off-screen content, serve responsive formats, and ensure every media control is keyboard-operable with proper ARIA attributes.

## 1. Image

### Image Gallery Grid
- **When:** Collections with consistent aspect ratios — product catalogs, portfolios, headshots.
- **What:** CSS Grid with `auto-fill, minmax(200px, 1fr)`. `aspect-ratio` + `object-fit: cover`. Click-to-enlarge via lightbox.
- **A11y:** Gallery: `role="list"`. Each thumbnail: button with `aria-label="View full size: [title]"`. Keyboard arrow navigation. Focus visible outline.
- **Anti-pattern:** Never display images without explicit dimensions (causes CLS). Never rely on hover-only interactions.

### Masonry Layout
- **When:** Mixed aspect ratios — photography, social feeds, Pinterest-style galleries.
- **What:** CSS columns or JS library (masonry-layout, react-masonry-css). Items: `break-inside: avoid`. Responsive reflow via ResizeObserver.
- **A11y:** DOM order must match visual reading order. Same list semantics as grid gallery.
- **Anti-pattern:** Never reorder DOM for visual effect without maintaining tab order.

### Lightbox
- **When:** Full-size image viewing from a gallery. Always paired with a gallery.
- **What:** Dialog overlay with `object-fit: contain`. Arrow key + swipe navigation. Preload adjacent images. Image counter. Escape to close.
- **A11y:** `role="dialog"` with focus trap. Prev/next: `aria-label`. Counter: `aria-live="polite"`. Return focus to trigger on close. `inert` on background.
- **Anti-pattern:** Never open lightbox without focus trap. Never lose scroll position.

### Image Zoom
- **When:** E-commerce product images. 56% of users explore images (Baymard).
- **What:** Hover zoom (magnified panel), click zoom (toggle fit/actual), pinch zoom (touch). Load high-res on activation, not on page load.
- **A11y:** Button to activate zoom: `aria-label="Zoom into image"`. Keyboard pan with arrow keys. Must not break at 200% browser zoom (WCAG 1.4.4).
- **Anti-pattern:** Never load full-resolution images on page load for zoom. Never block browser zoom.

### Image Cropping
- **When:** Profile photo uploads, cover images, thumbnail creation.
- **What:** Interactive crop box with aspect ratio constraints. Preset ratios (1:1, 4:3, 16:9). Rule-of-thirds grid overlay. Live preview.
- **A11y:** Keyboard-movable crop region (arrows to move, Shift+arrows to resize). Announce dimensions via `aria-live`.
- **Anti-pattern:** Never crop without showing a preview. Never force a single aspect ratio without options.

### Image Carousel
- **When:** Product galleries, hero banners. NN/G: low engagement past slide 1 — use sparingly.
- **What:** Embla Carousel or shadcn Carousel. Prev/next arrows + dots + swipe. Disable auto-play by default.
- **A11y:** Container: `aria-roledescription="carousel"`. Slides: `aria-roledescription="slide"`. Auto-play must have pause button (WCAG 2.2.2).
- **Anti-pattern:** Never auto-advance without user consent and pause control. Never use auto-rotating carousels as the hero/LCP element — multiple slides competing as LCP candidates degrades performance because the browser cannot predict which slide is visible at paint time.

## 2. Video

### Video Player Controls
- **When:** Any custom video playback. Replace browser defaults for consistent UX.
- **What:** Play/pause, progress scrubber, volume/mute, fullscreen, speed, captions toggle, quality selector. Progressive disclosure for advanced controls. Auto-hide during playback. **Never autoplay content videos** — always require explicit user interaction (WCAG 1.4.2). Always provide a `poster` attribute with a representative frame (not a black frame).
- **A11y:** All controls keyboard-operable. Play/pause: toggling `aria-label`. Progress: `role="slider"`. 44px minimum touch targets. WCAG 1.2: captions and audio descriptions.
- **Anti-pattern:** Never autoplay content videos. Never omit the poster image. Never remove keyboard controls. Never hide captions toggle.

### Video Captions & Subtitles
- **When:** All prerecorded video (WCAG 1.2.2 Level A). 85% of Facebook videos watched without sound.
- **What:** WebVTT format via `<track>`. Multiple languages. Customizable styling via `::cue`. Downloadable transcript alternative.
- **A11y:** Synchronized, accurate captions including non-speech sounds. 4.5:1 contrast with semi-transparent background. Customizable size/position.
- **Anti-pattern:** Never auto-generate captions without review. Never use images for captions.

### Video Thumbnail Preview
- **When:** Video progress bars. Shows frame at hovered timestamp.
- **What:** Sprite sheet generated with ffmpeg. CSS `background-position` per frame. Tooltip above scrubber.
- **A11y:** Visual enhancement only — `aria-hidden="true"`. Must not interfere with keyboard scrubbing.

### Adaptive Streaming
- **When:** Video longer than 30s on variable networks. HLS or DASH.
- **What:** Multiple bitrate renditions. hls.js or Shaka Player. Quality selector with "Auto" mode. Buffer health indicator.
- **A11y:** Quality selector keyboard-accessible. Announce changes via `aria-live="polite"`.

### Picture-in-Picture
- **When:** Long-form video where users multitask.
- **What:** Native PiP API or in-page sticky player (IntersectionObserver). Mini player with play/pause + close.
- **A11y:** PiP button: `aria-label` with `aria-pressed`. Sticky player keyboard-dismissible. Announce mode changes.
- **Anti-pattern:** Never obscure critical page content with the mini player.

### Video Embed
- **When:** Third-party video (YouTube, Vimeo). Use facade pattern to save 500KB+ JS.
- **What:** Static thumbnail + play button, swap to iframe on click. `aspect-ratio: 16/9`. `loading="lazy"`. Privacy-enhanced domain.
- **A11y:** Facade button: `aria-label="Play video: [title]"`. Thumbnail: descriptive alt text. iframe: `title` attribute.
- **Anti-pattern:** Never load heavy iframe embeds on page load without facade.

## 3. Audio

### Audio Player
- **When:** Podcasts, music, voice messages, sound effects.
- **What:** Custom controls on `<audio>`. Play/pause, progress, time, volume, speed (0.5x-2x). Skip buttons for podcasts (15s/30s). Compact variant for voice messages.
- **A11y:** Same WAI requirements as video controls. Speed selector with current value announced. 44px touch targets.

### Waveform Visualization
- **When:** Music, podcasts, voice messages. SoundCloud-style amplitude display.
- **What:** wavesurfer.js or pre-generated SVG/Canvas. Two-color (played/unplayed). Click-to-seek. Responsive redraw.
- **A11y:** Visual enhancement — `aria-hidden="true"`. Underlying accessible slider for keyboard users. 3:1 contrast between played/unplayed (WCAG 1.4.11).

### Playlist
- **When:** Multiple audio/video tracks with sequential playback.
- **What:** Ordered list with current track highlighted. Repeat/shuffle modes. Drag-to-reorder. Auto-advance. Persist state.
- **A11y:** Track list: `role="list"`. Current: `aria-current="true"`. Drag: keyboard-accessible with live announcements. Announce track transitions.

## 4. Upload

### Drag-and-Drop Upload
- **When:** Any file upload. Always pair with a "Browse files" button.
- **What:** Drop zone with visual states (default, active, accepted, rejected). Validate type/size on drop. react-dropzone for production.
- **A11y:** Primary interaction: `<input type="file">`. Drop zone is an enhancement. Announce drop result via `aria-live`.
- **Anti-pattern:** Never make drag-and-drop the only upload method.

### Upload Progress
- **When:** Any file upload. Show per-file progress with states.
- **What:** `<progress>` or `role="progressbar"`. Per-file: name, size, bar, percentage, cancel. States: queued, uploading, complete, error. Smooth animation.
- **A11y:** `aria-valuenow`, `aria-label="Uploading [filename]: 45%"`. Announce completion via `aria-live`. Error states persist for retry.

### Multi-File Upload
- **When:** Batch uploads. Image galleries, document attachments.
- **What:** File queue with thumbnails, status, remove action. Parallel upload (2-4 concurrent). Add more files to existing queue.
- **A11y:** File list: `role="list"`. Remove button: `aria-label="Remove [filename]"`. Announce queue changes.

### Resumable Upload
- **When:** Large files (video, datasets) on unreliable connections.
- **What:** tus protocol or custom chunked upload. Resume from last completed chunk. Persist state to localStorage.
- **A11y:** Clear "Resume upload" button with progress context. Announce interruption and resume state.

### File Type Validation
- **When:** Every file upload. Validate before upload starts.
- **What:** Check MIME type, extension, size, dimensions. Specific error messages per validation failure. Block upload until all valid.
- **A11y:** Show accepted types via `aria-describedby`. Announce errors via `aria-live="assertive"`.
- **Anti-pattern:** Never show generic "Invalid file" — specify what's wrong.

## 5. Preview

### Image Preview
- **When:** After file selection, before upload. Verify correct files.
- **What:** `URL.createObjectURL()` for instant previews. Grid display with metadata. Remove button. Revoke URLs on removal.
- **A11y:** `<img alt="Preview of [filename]">`. Remove: `aria-label="Remove [filename]"`. Announce preview count.

### Document Viewer
- **When:** In-browser PDF/document rendering without download.
- **What:** PDF.js via react-pdf. Page navigation, zoom, search, download, print. Text layer for selection. Page thumbnails sidebar.
- **A11y:** Text selection support. Page nav: `aria-label="Page 3 of 12"`. Document: `role="document"`. Keyboard: Page Up/Down.

### Video Preview Thumbnail
- **When:** Video lists and galleries. Static poster image with play button overlay.
- **What:** `poster` attribute. Duration badge bottom-right. Hover-to-preview (muted, low quality).
- **A11y:** Container: `<button aria-label="Play video: [title], duration [time]">`. Hover preview must be muted.

### File Icon Mapping
- **When:** Non-previewable files in lists, queues, attachments.
- **What:** Extension-to-icon map (PDF=red, Word=blue, Excel=green). lucide-react or react-icons. Generic fallback.
- **A11y:** Icons: `aria-hidden="true"` when filename visible. Include file type in accessible name when icon is sole indicator.

## 6. Optimization

### Lazy Loading Media
- **When:** Images, videos, and iframes **below the fold only**. 22% LCP improvement.
- **What:** `loading="lazy"` for below-fold images/iframes. IntersectionObserver with `rootMargin` for early loading. Set explicit `width`/`height` or `aspect-ratio` on every media element. Placeholder (blur, color, skeleton) to prevent CLS. The LCP image (exactly one per page) must use `loading="eager"` with `fetchpriority="high"`. If the LCP image is not discoverable by the preload scanner (CSS background, JS-rendered), add `<link rel="preload" as="image" fetchpriority="high">` with responsive `media` queries. Only mark ONE image as high priority.
- **A11y:** Transparent to assistive tech. Placeholder alt text matches final image.
- **Anti-pattern:** **NEVER lazy-load elements visible in the initial viewport** — this delays LCP and causes visible pop-in. Never apply `fetchpriority="high"` to multiple images. Never use auto-rotating hero sliders where multiple images compete as LCP candidates. Never place multiple same-sized images above the fold without designating one as LCP — when images share identical dimensions the browser cannot prioritize, so design one image as visually dominant or mark one `fetchpriority="high"` and the rest `fetchpriority="low"`. Never omit width/height (causes CLS).

### Responsive Images
- **When:** Every meaningful image. Serve appropriate size per device.
- **What:** `srcset` + `sizes` for resolution switching. `<picture>` for art direction. WebP/AVIF via CDN or build pipeline. **Cap at 2x DPR** — human eyes cannot distinguish 2x from 3x on mobile screens (Twitter/X saved ~45% image weight with no perceivable loss). Never generate or serve 3x variants.
- **A11y:** Alt text applies across all variants. Art-directed crops must not remove meaningful content.
- **Anti-pattern:** Never serve 3x image variants. Never generate images larger than 2x the CSS display size.

### Image Format Optimization
- **When:** Every image pipeline. AVIF saves ~50%, WebP ~30% vs JPEG.
- **What:** `<picture>` with AVIF, WebP, JPEG sources. Build pipeline: sharp or squoosh. CDN auto-format. Quality: JPEG/WebP at 80, AVIF at 75 — reducing from 100 to 80 halves file size with no visible difference (SSIM-confirmed). **Never use animated GIFs** — for any looping/animated visual, use `<video autoplay muted loop playsinline>` with MP4/WebM sources (80-90% smaller, hardware decoded). Convert with ffmpeg: `ffmpeg -i anim.gif -movflags +faststart -pix_fmt yuv420p output.mp4`.
- **A11y:** Format has zero accessibility impact. SVG icons: `role="img"` + `aria-label` when meaningful. Silent autoloop videos: `role="img"` + `aria-label`, pause on `prefers-reduced-motion`.
- **Anti-pattern:** Never use animated GIF. Never use quality 100 in production. Never serve 3x image variants.

### Blur-Up Placeholder (LQIP)
- **When:** Image-heavy pages. Instant visual context while loading.
- **What:** Tiny (20-40px) blurred image as base64 data URI. BlurHash or dominant color alternatives. Crossfade transition to loaded image.
- **A11y:** `aria-hidden="true"` on placeholder. Same alt text on final image. Smooth transitions (no seizure risk, WCAG 2.3.1).

### CDN & Caching Strategy
- **When:** All production media. Reduces TTFB to <50ms globally.
- **What:** Static: immutable caching + content-hashed filenames. Uploads: long cache + ETag. CDN image transformation via URL params. `<link rel="preconnect">`.
- **A11y:** Transparent to users. CDN transforms must preserve markup attributes.

### Media Preloading
- **When:** Critical above-the-fold images. Adjacent gallery images.
- **What:** `<link rel="preload" as="image" fetchpriority="high">`. Preload current+1 in lightbox. `preload="metadata"` for video.
- **A11y:** Invisible to assistive tech. Must not trigger unexpected playback (WCAG 1.4.2).
- **Anti-pattern:** Never preload below-the-fold images. Never preload excessively on metered connections.

### Data-Saver Awareness
- **When:** Any media-rich page. Respect `Save-Data: On` HTTP client hint.
- **What:** Server: serve smaller images, skip video preload, disable auto-play. Client: detect via `navigator.connection?.saveData`. Skip LQIP blur-up (use dominant color), skip adjacent preloads, skip hover-to-preview animations. CSS `@media (prefers-reduced-data: reduce)` has near-zero browser support — use JS detection. Reduce fidelity, never remove functionality.
- **A11y:** Alt text, captions, and transcripts must always be served regardless of `Save-Data`. If images become placeholders, alt text becomes primary content — ensure it is descriptive.
- **Anti-pattern:** Never strip essential content for data-saver users. Never ignore the `Save-Data` header on media-heavy pages.

### Web Font Optimization
- **When:** Any project using custom web fonts. Prevents FOIT and CLS from font swap.
- **What:** Serve WOFF2 only (30% smaller than WOFF, 97%+ browser support). Use `font-display: swap` for primary text, `font-display: optional` for secondary/decorative fonts. Preload 1-2 critical fonts: `<link rel="preload" href="font.woff2" as="font" type="font/woff2" crossorigin>`. Eliminate CLS with CSS @font-face override descriptors: `size-adjust`, `ascent-override`, `descent-override`, `line-gap-override` on a fallback @font-face to match web font metrics. Use fontpie, Fontaine (npm), or next/font for automatic calculation. Self-host fonts (avoid Google Fonts extra DNS lookup). Subset to needed character ranges.
- **A11y:** CLS from font swap disorients screen magnifier users — metric overrides improve accessibility. Never use `font-display: block` (up to 3s invisible text). Icon fonts: use SVGs instead; if unavoidable, `aria-hidden="true"` with text alternatives.
- **Anti-pattern:** Never use `font-display: block`. Never serve WOFF/TTF/EOT (obsolete). Never load Google Fonts from CDN when self-hosting is possible. Never skip metric overrides — fallback-to-webfont reflow causes measurable CLS.
