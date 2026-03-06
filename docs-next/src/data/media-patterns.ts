export interface MediaPattern {
  name: string;
  category: 'image' | 'video' | 'audio' | 'upload' | 'preview' | 'optimization';
  description: string;
  implementation: string;
  a11y: string;
  docsUrl: string | null;
}

export const categoryLabels: Record<MediaPattern['category'], string> = {
  image: 'Image',
  video: 'Video',
  audio: 'Audio',
  upload: 'Upload',
  preview: 'Preview',
  optimization: 'Optimization',
};

export const categoryOrder: MediaPattern['category'][] = [
  'image', 'video', 'audio', 'upload', 'preview', 'optimization',
];

export const mediaPatterns: MediaPattern[] = [
  // --- Image ---
  {
    name: 'Image Gallery Grid',
    category: 'image',
    description: 'A uniform grid of images with consistent cell sizes. Best for collections where images share the same aspect ratio — product catalogs, headshots, portfolio thumbnails. Predictable, easy to scan, and performs reliably. Use CSS Grid with fixed column widths and aspect-ratio or object-fit: cover to handle mixed dimensions gracefully. Clicking a thumbnail opens the image in a lightbox or detail view.',
    implementation: 'CSS Grid with grid-template-columns: repeat(auto-fill, minmax(200px, 1fr)). Each cell uses aspect-ratio: 1 (or 4/3, 16/9) with object-fit: cover on the <img>. Wrap in a <button> or <a> for click-to-enlarge. Add hover overlay with zoom icon. Use Next.js Image or Astro Image for automatic srcset generation. Paginate or infinite-scroll for large sets.',
    a11y: 'Each image needs descriptive alt text. Gallery container: role="list" or <ul>. Each item: role="listitem" or <li>. Click target: <button aria-label="View full size: [image title]">. Keyboard navigation with arrow keys between items. Focus visible outline on each thumbnail. Announce item count: "Image 3 of 24."',
    docsUrl: null,
  },
  {
    name: 'Masonry Layout',
    category: 'image',
    description: 'A Pinterest-style staggered grid where images retain their natural aspect ratios with fixed column widths and varying heights. Optimizes space by eliminating gaps between elements. Popularized by Pinterest (2010) and widely used for photography, social media feeds, and mixed-media galleries. More visually engaging than uniform grids but harder to scan in order. Use when image aspect ratios vary significantly.',
    implementation: 'CSS columns (column-count + column-gap) for simple cases. For dynamic reflow, use a JS library (masonry-layout, react-masonry-css) or CSS Grid with grid-template-rows: masonry (experimental). Items need break-inside: avoid. Calculate positions with ResizeObserver for responsive reflow. Combine with infinite scroll or "Load more" for large sets. Consider the quilted variant (Google Photos style) for editorial layouts.',
    a11y: 'Same accessibility as Image Gallery Grid — role="list", descriptive alt text, keyboard navigation. Visual reading order must match DOM order (CSS columns can reorder visually). If JS repositions items, ensure tabindex order matches visual flow. Announce gallery size and current position for screen readers.',
    docsUrl: null,
  },
  {
    name: 'Lightbox',
    category: 'image',
    description: 'A full-screen or near-full-screen overlay displaying a single image at maximum resolution with navigation controls. Opened by clicking a gallery thumbnail. Must support: keyboard navigation (arrow keys, Escape to close), swipe gestures on mobile, pinch-to-zoom, image counter ("3 of 24"), preloading adjacent images, and smooth transitions. The lightbox traps focus and prevents background scrolling.',
    implementation: 'Use a Dialog-based overlay with backdrop blur. Display the image with object-fit: contain for full visibility. Navigation: prev/next buttons + arrow key handlers + touch swipe (via pointer events or a swipe library). Preload adjacent images with <link rel="preload">. Show image counter, title, and optional caption. Close button fixed top-right. Animate entry/exit with scale + opacity transitions.',
    a11y: 'role="dialog" with aria-label="Image viewer". Trap focus within the lightbox (focus-trap library). Close on Escape. Prev/next buttons: aria-label="Previous image" / "Next image". Image: descriptive alt text. Counter: aria-live="polite" announcing "Image 3 of 24" on navigation. Return focus to the triggering thumbnail on close. Disable background scroll with inert attribute on body content.',
    docsUrl: null,
  },
  {
    name: 'Image Zoom',
    category: 'image',
    description: 'Magnification of image details — essential for e-commerce product images where users inspect textures, labels, and fine details. Three common patterns: (1) Hover zoom — a magnified view appears in a side panel on mouse hover, (2) Click zoom — clicking toggles between fit-to-container and full resolution with pan, (3) Pinch zoom — mobile touch gesture for progressive magnification. Baymard: 56% of users explore product images, and zoom is the #1 requested feature.',
    implementation: 'Hover zoom: track mouse position over the image, display a cropped high-res version in an adjacent panel (or lens overlay). Click zoom: toggle object-fit between contain and actual size, then track mouse/touch for panning. Pinch zoom: use touch events (touchstart/touchmove) to calculate pinch distance and apply CSS transform: scale(). Load a high-resolution source on zoom activation (not on page load).',
    a11y: 'Provide a button to activate zoom mode: aria-label="Zoom into image". Announce zoom state: "Zoomed in, use arrow keys to pan." Keyboard pan with arrow keys. Ensure zoom does not break at 200% browser zoom (WCAG 1.4.4). Pinch zoom must not conflict with browser zoom. Provide a "Reset zoom" button. For hover zoom, ensure the magnified panel is perceivable by screen readers with alt text describing visible details.',
    docsUrl: null,
  },
  {
    name: 'Image Cropping',
    category: 'image',
    description: 'An interactive tool for selecting a region of an image — used in profile photo uploads, cover images, thumbnails, and content creation. The crop box is resizable and draggable with optional aspect ratio constraints (1:1 for avatars, 16:9 for covers). Provide preset ratios for common targets (social media sizes, print formats). Show a grid overlay (rule of thirds) for composition guidance. Real-time preview of the cropped result.',
    implementation: 'Use react-image-crop or react-easy-crop. Display the image in a container with the crop overlay. Preset aspect ratios: free, 1:1, 4:3, 16:9, custom. Handle resize via corner/edge handles. Output crop coordinates (x, y, width, height) as percentages. Apply the crop server-side (sharp, canvas API) or client-side (OffscreenCanvas). Show a live preview thumbnail of the cropped area beside the editor.',
    a11y: 'Crop region must be keyboard-movable: arrow keys to reposition, Shift+arrows to resize. aria-label="Image crop region, use arrow keys to move, Shift+arrow keys to resize." Announce crop dimensions on change via aria-live="polite". Preset ratio buttons must be keyboard-accessible with aria-pressed state. Provide descriptive text: "Crop area: 400x400 pixels, centered."',
    docsUrl: null,
  },
  {
    name: 'Image Carousel',
    category: 'image',
    description: 'A horizontal sequence of images with prev/next navigation, often used for product image galleries, hero banners, and testimonials. NN/G research shows carousels have low engagement past the first slide — use sparingly and never auto-advance without user consent. Show navigation dots or thumbnails to indicate position and total count. Swipe support on mobile is mandatory. Performance warning: never use auto-rotating carousels as the hero/LCP element — when multiple slides compete to be the Largest Contentful Paint candidate, the browser cannot predict which is visible at paint time, severely degrading LCP scores.',
    implementation: 'Use Embla Carousel (lightweight, accessible) or shadcn Carousel component. Display one or multiple visible slides with overflow hidden. Navigation: prev/next arrow buttons + dot indicators + swipe gestures. Thumbnail strip below for product galleries. Disable auto-play by default; if enabled, pause on hover/focus and provide a pause button. Use scroll-snap-type for CSS-only fallback.',
    a11y: 'Container: role="region" aria-label="Image carousel" aria-roledescription="carousel". Each slide: role="group" aria-roledescription="slide" aria-label="Slide 2 of 5". Prev/next: aria-label="Previous slide" / "Next slide". Auto-play: must have a visible pause button. Dot navigation: aria-label="Go to slide 3". WCAG 2.2.2: auto-advancing content must be pausable. Announce current slide on navigation.',
    docsUrl: 'https://ui.shadcn.com/docs/components/radix/carousel',
  },

  // --- Video ---
  {
    name: 'Video Player Controls',
    category: 'video',
    description: 'Custom video player controls that improve on browser defaults — play/pause, progress scrubber, volume/mute, fullscreen toggle, playback speed, captions toggle, and quality selector. Use progressive disclosure: show minimal controls (play, progress, volume, fullscreen) by default, reveal advanced controls (speed, quality, captions) on interaction. Controls auto-hide during playback and reappear on mouse move or keyboard input.',
    implementation: 'Build on <video> element with custom controls (remove default with CSS or controls attribute omission). Use Media Session API for OS-level integration. Progress bar: <input type="range"> synced to currentTime. Volume: range input. Fullscreen: Fullscreen API. Speed: playbackRate property. Buffer indicator behind progress bar. Time display: current / duration. Keyboard: Space=play/pause, M=mute, F=fullscreen, arrows=seek.',
    a11y: 'W3C WAI: all media player controls must be keyboard operable. Play/pause: aria-label toggles between "Play" and "Pause". Progress slider: role="slider" with aria-valuenow (current time), aria-valuemin, aria-valuemax (duration), aria-label="Seek". Volume: role="slider" aria-label="Volume". Mute: aria-pressed. Fullscreen: aria-label="Enter fullscreen". All controls 44px minimum touch target. WCAG 1.2: captions and audio descriptions.',
    docsUrl: null,
  },
  {
    name: 'Video Captions & Subtitles',
    category: 'video',
    description: 'Text overlays synchronized with video content — captions (same language, include sound effects) and subtitles (translations). Required for accessibility (WCAG 1.2.2 Level A for prerecorded, 1.2.4 Level AA for live). Also used in noisy environments, by non-native speakers, and for SEO (searchable transcripts). 85% of Facebook videos are watched without sound — captions dramatically increase engagement.',
    implementation: 'Use WebVTT format for caption tracks. Add via <track kind="captions" src="file.vtt" srclang="en" label="English">. Support multiple languages with a track selector UI. Style with ::cue pseudo-element (font-size, color, background). For live captions, use Web Speech API or a third-party service. Provide a downloadable transcript as an alternative. Store caption files alongside video assets.',
    a11y: 'WCAG 1.2.2: provide captions for all prerecorded audio content. Captions must be synchronized, accurate, and include non-speech sounds [music], [applause]. Caption toggle button: aria-label="Enable captions" with aria-pressed. Language selector: aria-label="Caption language". Caption text must meet 4.5:1 contrast against video (use semi-transparent background). Users should be able to customize caption size and position.',
    docsUrl: null,
  },
  {
    name: 'Video Thumbnail Preview',
    category: 'video',
    description: 'A preview image that appears when hovering over the video progress bar, showing a frame from the hovered timestamp. YouTube popularized this pattern — it lets users scrub visually to find specific moments without playing. Generate thumbnails as a sprite sheet (grid of frames) at regular intervals (every 5-10 seconds). Display in a tooltip above the scrubber with the corresponding timestamp.',
    implementation: 'Generate a thumbnail sprite sheet at build time (ffmpeg -vf fps=0.2 -s 160x90). Store as a single image with CSS background-position to show individual frames. On hover over progress bar, calculate the timestamp from mouse position, compute the sprite offset, and position a tooltip with the preview frame. Use requestAnimationFrame for smooth updates. For HLS/DASH, use I-frame playlists.',
    a11y: 'Thumbnail preview is a visual enhancement — ensure the progress bar remains fully functional without it. The tooltip should not interfere with keyboard scrubbing. aria-hidden="true" on the preview tooltip (it is supplementary to the time display). Ensure the preview does not overlap other controls. Provide the timestamp as text within the tooltip for users who can perceive it.',
    docsUrl: null,
  },
  {
    name: 'Adaptive Streaming',
    category: 'video',
    description: 'Dynamically adjusting video quality based on network conditions — starts at a safe bitrate and scales up/down as bandwidth changes. HLS (HTTP Live Streaming) and DASH (Dynamic Adaptive Streaming over HTTP) are the two standards. The player fetches small chunks (2-10s segments) at the appropriate quality level. Users can also manually override quality. Essential for consistent playback on variable networks.',
    implementation: 'Encode video into multiple bitrate renditions (e.g., 360p, 720p, 1080p, 4K) with matching audio tracks. Generate HLS manifest (.m3u8) or DASH manifest (.mpd). Use hls.js for HLS playback in browsers without native support. Video.js or Shaka Player for full adaptive streaming. Quality selector UI showing available resolutions. Auto mode: let the ABR algorithm decide. Buffer health indicator for debugging.',
    a11y: 'Quality selector must be keyboard-accessible with clear labels: "Auto (720p)" showing current auto-selected quality. Announce quality changes via aria-live="polite": "Video quality changed to 1080p." Buffering indicator: aria-label="Video buffering" with aria-live="polite". Lower quality options benefit users on metered data plans — present this as a feature, not a limitation.',
    docsUrl: null,
  },
  {
    name: 'Picture-in-Picture',
    category: 'video',
    description: 'A floating, always-on-top mini player that allows users to continue watching video while navigating other content. The native Picture-in-Picture API places the video in an OS-level window. For in-page PiP, a sticky mini player appears in a corner when the original video scrolls out of view. Both patterns let users multitask without losing video context. Common on YouTube, Twitch, and streaming platforms.',
    implementation: 'Native PiP: HTMLVideoElement.requestPictureInPicture(). Document PiP: documentPictureInPicture.requestWindow() for arbitrary HTML content. In-page sticky player: detect when video leaves viewport (IntersectionObserver), show a fixed-position mini player in a corner with the same video source. Mini player includes play/pause, close, and "back to original" buttons. Animate entry/exit with CSS transitions.',
    a11y: 'PiP button: aria-label="Enter picture-in-picture" / "Exit picture-in-picture" with aria-pressed. Native PiP windows inherit OS accessibility. In-page sticky player must be keyboard-dismissible (Escape or close button). Announce mode changes via aria-live="polite": "Video now playing in mini player." Ensure the mini player does not obscure critical page content or other interactive elements.',
    docsUrl: null,
  },
  {
    name: 'Video Embed',
    category: 'video',
    description: 'Embedding third-party video (YouTube, Vimeo, Wistia) via <iframe> or a facade pattern. The facade pattern loads a static thumbnail with a play button first, then swaps in the iframe on click — saving 500KB+ of initial JS. Essential for performance on pages with multiple embeds. Provide aspect-ratio containers (16:9 default) to prevent layout shift. Include video title and source attribution.',
    implementation: 'Facade: show a <button> over the thumbnail image. On click, replace with <iframe src="..." allow="autoplay">. Use lite-youtube-embed or lite-vimeo-embed web components. Aspect ratio container: aspect-ratio: 16/9 on the wrapper with width: 100%. Add loading="lazy" on non-critical embeds. For YouTube, use youtube-nocookie.com domain for privacy. Pass relevant URL params (autoplay=1 after click, cc_load_policy=1 for captions).',
    a11y: 'Facade button: aria-label="Play video: [Video Title]". The thumbnail must have alt text describing the video. iframe: title="Video: [Video Title]". Ensure embedded player inherits focus after click. If the video auto-plays after facade click, it should do so muted or with prior user intent. Third-party player accessibility varies — prefer providers with accessible players (Vimeo > YouTube for accessibility).',
    docsUrl: null,
  },

  // --- Audio ---
  {
    name: 'Audio Player',
    category: 'audio',
    description: 'A custom audio player for podcasts, music, voice messages, and sound effects. Core controls: play/pause, progress scrubber, current time / duration, volume/mute, and playback speed (0.5x–2x). For podcasts, add skip forward/backward buttons (15s/30s). Compact variant for inline playback (voice messages in chat). Expanded variant with album art and metadata for dedicated listening views.',
    implementation: 'Build on <audio> element with custom controls. Progress bar: <input type="range"> synced to currentTime. Playback speed: audioElement.playbackRate with preset buttons (0.5, 1, 1.25, 1.5, 2). Skip buttons: currentTime += 15. Volume control with mute toggle. Display current time and duration formatted as mm:ss. For voice messages, use a compact single-line layout with waveform visualization.',
    a11y: 'Same WAI requirements as video player controls. Play/pause: aria-label toggles. Progress: role="slider" with time values. Speed selector: aria-label="Playback speed" with current value announced. Skip buttons: aria-label="Skip forward 15 seconds". Time display: aria-live="off" (do not announce every second). Ensure controls are operable with keyboard and meet 44px minimum touch targets.',
    docsUrl: null,
  },
  {
    name: 'Waveform Visualization',
    category: 'audio',
    description: 'A visual representation of an audio track\'s amplitude over time, replacing the standard progress bar. Popularized by SoundCloud — the waveform shows quiet and loud sections at a glance, enabling users to skip to the "good parts." Played portions are colored differently from unplayed. Clicking anywhere on the waveform seeks to that position. Commonly used for music, podcasts, and voice messages.',
    implementation: 'Use wavesurfer.js for full-featured waveform rendering (Canvas/WebGL). For lightweight needs, pre-generate waveform data server-side (audiowaveform CLI) and render as an SVG path or Canvas drawing. Two-color approach: played portion in accent color, unplayed in muted. Click-to-seek on the waveform. Responsive: redraw on container resize via ResizeObserver. For voice messages, use a mini waveform (40-60px height).',
    a11y: 'The waveform is a visual enhancement — it must sit alongside an accessible progress slider (role="slider" with aria-valuenow). Click-to-seek on the waveform needs a keyboard equivalent (the slider). aria-hidden="true" on the decorative waveform canvas. Screen readers interact with the underlying slider only. Ensure color contrast between played/unplayed portions meets 3:1 minimum (WCAG 1.4.11 non-text contrast).',
    docsUrl: null,
  },
  {
    name: 'Playlist',
    category: 'audio',
    description: 'An ordered list of audio or video tracks with sequential or shuffle playback. Shows track title, artist/source, duration, and play state (playing, paused, queued). Current track is visually highlighted. Click any track to play it immediately. Drag-to-reorder for user-created playlists. Support repeat (one, all, off) and shuffle modes. Auto-advance to next track on completion. Persist playlist state across sessions.',
    implementation: 'Render tracks as a list with the current track highlighted. Store playlist state (tracks, currentIndex, repeat, shuffle) in state/context. On track end, advance to next (or random for shuffle). Drag-to-reorder with dnd-kit or @hello-pangea/dnd. Persist to localStorage or server. Compact mode: collapsible track list below the player. Full mode: sidebar playlist with search/filter. Show queue count and total duration.',
    a11y: 'Track list: role="list" with aria-label="Playlist: [name]". Each track: role="listitem". Current track: aria-current="true". Play button per track: aria-label="Play [track title]". Drag-to-reorder: accessible via keyboard (space to grab, arrows to move, space to drop) with aria-roledescription="sortable" and live announcements. Repeat/shuffle toggles: aria-pressed. Announce track transitions: "Now playing: [title]."',
    docsUrl: null,
  },

  // --- Upload ---
  {
    name: 'Drag-and-Drop Upload',
    category: 'upload',
    description: 'A drop zone that accepts files dragged from the OS file manager. The zone changes appearance (border color, background, icon) when files hover over it. Always pair with a traditional "Browse files" button for users who prefer clicking or cannot drag. Show accepted file types and size limits upfront. Support both single and multi-file drops. Validate file type and size immediately on drop, before upload begins.',
    implementation: 'Use onDragOver (prevent default), onDragEnter/onDragLeave (toggle active state), onDrop (read files). Access files via event.dataTransfer.files. Validate type (file.type against accept list) and size (file.size < maxSize). Visual states: default, active (hovering), accepted, rejected. Pair with <input type="file" accept="..." multiple>. Use react-dropzone or Vue Dropzone for production. Apply dashed border + upload icon for the default state.',
    a11y: 'The drop zone must have a <button> or <input type="file"> as the primary interaction — drag-and-drop is an enhancement, not the only method. aria-label="Upload files, or drag and drop here". Announce drop result: "3 files selected" or "File type not supported" via aria-live="assertive". Show accepted types visually and via aria-describedby. Focus the file list after successful drop.',
    docsUrl: null,
  },
  {
    name: 'Upload Progress',
    category: 'upload',
    description: 'Visual feedback during file uploads — progress bar, percentage, file size, estimated time remaining, and upload speed. Each file in a multi-file upload has its own progress indicator with three states: waiting (queued), in progress (uploading), and complete (success/error). Allow canceling individual uploads. Show a summary bar for overall progress when uploading many files. NN/G: progress indicators reduce perceived wait time by 30%.',
    implementation: 'Use XMLHttpRequest.upload.onprogress or fetch with ReadableStream for progress tracking. Display per-file: filename, size, progress bar (<progress> or styled div), percentage, cancel button. Overall progress: sum of loaded bytes / total bytes. States: queued (gray), uploading (accent), complete (green check), error (red with retry). Animate the progress bar smoothly (use transition on width). Show upload speed (KB/s) for large files.',
    a11y: 'Progress bar: <progress> element or role="progressbar" with aria-valuenow, aria-valuemin="0", aria-valuemax="100", aria-label="Uploading [filename]: 45%". Announce completion via aria-live="polite": "[filename] uploaded successfully" or "[filename] upload failed." Cancel button: aria-label="Cancel upload: [filename]". File list uses role="list". Do not auto-dismiss error states — let users retry.',
    docsUrl: null,
  },
  {
    name: 'Multi-File Upload',
    category: 'upload',
    description: 'Uploading multiple files simultaneously with a queue, individual progress, and batch actions. Show a file list with thumbnails (for images), filenames, sizes, and status. Allow removing files from the queue before upload starts. Support adding more files to an existing queue. Upload in parallel (2-4 concurrent) for speed, with a configurable concurrency limit. Show overall progress alongside individual file progress.',
    implementation: 'Queue: store selected files in state array. Display as a list with thumbnail preview (URL.createObjectURL for images), name, size, status. Upload concurrently using Promise.allSettled with a pool (p-limit or manual semaphore). Remove from queue: filter out by index/id. Add more: concat new files to existing array. Chunk large files (5MB+) for resumable uploads. Sort by status: uploading first, then queued, then complete.',
    a11y: 'File list: role="list" aria-label="Selected files for upload". Each file: role="listitem" with filename and status announced. "Remove [filename]" button per file: aria-label="Remove [filename] from upload queue". Batch actions (Upload All, Clear) with descriptive labels. Announce queue changes: "4 files selected, 12.5 MB total" via aria-live="polite". After upload: summary announcement "3 of 4 files uploaded successfully."',
    docsUrl: null,
  },
  {
    name: 'Resumable Upload',
    category: 'upload',
    description: 'Upload protocol that survives network interruptions, browser crashes, and tab closures. The file is split into chunks (typically 5-10MB), each uploaded independently. The server tracks which chunks are received. On resume, the client queries the server for completed chunks and uploads only the remaining ones. Essential for large files (video, datasets, backups) on unreliable connections.',
    implementation: 'Use the tus protocol (tus.io) with tus-js-client for standardized resumable uploads. Alternative: custom chunked upload with a server endpoint that accepts ranges. Client: slice file with Blob.slice(), upload each chunk with Content-Range header. Server: store chunks, track progress in a session/DB. On resume: HEAD request to get offset, continue from there. Show chunk-level progress in the UI.',
    a11y: 'Same accessibility as Upload Progress. Additionally: if upload is interrupted, show a clear "Resume upload" button with aria-label="Resume upload: [filename], 65% complete." Announce interruption: "Upload paused. Click resume to continue." Persist upload state to localStorage so users can resume after browser restart. Progress bar should show the resumed position, not restart from zero.',
    docsUrl: null,
  },
  {
    name: 'File Type Validation',
    category: 'upload',
    description: 'Client-side validation of selected files before upload — checking MIME type, file extension, file size, image dimensions, and (for images) aspect ratio. Provide immediate feedback on invalid files with specific error messages: "File too large (15MB). Maximum allowed: 10MB" rather than generic "Invalid file." Accept attribute on the file input provides a first filter, but always validate programmatically too (users can bypass accept).',
    implementation: 'Validate on file selection (onChange) and on drop. Check: file.type against allowed MIME types, file.name extension, file.size against maxSize. For images: load into an Image() to check naturalWidth/naturalHeight against min/max dimensions. For aspect ratio: compare width/height ratio. Display validation results per-file in the queue with specific error messages. Block upload button until all files are valid.',
    a11y: 'Show accepted file types and limits before selection: "Accepted: JPG, PNG, WebP. Max size: 10MB. Min dimensions: 800x600." via aria-describedby on the file input. Announce validation errors via aria-live="assertive": "[filename] rejected: file size exceeds 10MB limit." Error messages must be associated with the specific file in the list. Provide a "Remove" action for invalid files.',
    docsUrl: null,
  },

  // --- Preview ---
  {
    name: 'Image Preview',
    category: 'preview',
    description: 'Showing a preview of selected images before uploading — lets users verify they picked the right files, check orientation, and remove unwanted selections. Use URL.createObjectURL() for instant client-side previews without uploading. For existing uploaded images, show the stored URL. Include image metadata (filename, dimensions, file size) below the preview. Support click-to-enlarge in a lightbox.',
    implementation: 'On file selection, create previews with URL.createObjectURL(file). Display in a grid with object-fit: cover. Show filename, dimensions (via Image().naturalWidth/Height), and file size (formatted). Remove button overlaid on each preview. Revoke object URLs on removal (URL.revokeObjectURL) to prevent memory leaks. For existing images, use the server URL directly. Add a loading skeleton while preview generates.',
    a11y: 'Each preview: <img alt="Preview of [filename]"> within a figure with <figcaption> showing metadata. Remove button: aria-label="Remove [filename]". Preview grid: role="list" aria-label="Image previews". Announce preview count: "3 images selected for upload." If preview fails (corrupted file), show a placeholder with error text rather than a broken image. Click-to-enlarge uses the same lightbox accessibility as the Image Gallery.',
    docsUrl: null,
  },
  {
    name: 'Document Viewer',
    category: 'preview',
    description: 'In-browser rendering of documents — PDF, Word, spreadsheet, and text files — without requiring download. PDFs are the most common; use PDF.js (Mozilla) for reliable rendering with built-in text selection, search, and zoom. For other formats, convert server-side to PDF or use a document viewer service. Toolbar: page navigation, zoom, download, print, search, and fullscreen. Show loading progress for large documents.',
    implementation: 'PDF: use react-pdf (built on PDF.js) or @react-pdf-viewer/core for React. Render pages as Canvas elements with text layer overlay for selection/search. Toolbar: page input (1 of 12), zoom slider (fit-width, fit-page, 50%-200%), download button, print button, search dialog. For Office docs: convert server-side via LibreOffice or use Google Docs Viewer iframe. Show page thumbnails in a sidebar for navigation.',
    a11y: 'PDF viewer must support text selection and search (text layer, not just image rendering). Page navigation: aria-label="Page 3 of 12". Zoom controls: role="slider" or discrete buttons with aria-label="Zoom: 125%". Document container: role="document". Ensure the text layer is in the accessibility tree for screen readers. Download button: aria-label="Download document: [filename]". Keyboard: Page Up/Down for page navigation.',
    docsUrl: null,
  },
  {
    name: 'Video Preview Thumbnail',
    category: 'preview',
    description: 'A static thumbnail image representing a video before playback — the first frame, a key frame, or a custom-selected poster image. Essential for video lists and galleries where auto-playing all videos would be prohibitive. Show a play button overlay to indicate the item is playable. For longer content, show duration badge (e.g., "12:34") positioned bottom-right. Hover-to-preview (animated GIF or short loop) for richer browsing.',
    implementation: 'Use the poster attribute on <video> for the static thumbnail. Generate thumbnails with ffmpeg (ffmpeg -i video.mp4 -ss 00:00:05 -frames:v 1 thumb.jpg). Duration badge: absolutely positioned <span> with formatted time. Hover preview: preload a short WebP animation or use the video element with preload="metadata" and play on mouseenter (muted, loop, low quality). Play overlay: centered SVG play icon.',
    a11y: 'Thumbnail container: <button aria-label="Play video: [title], duration 12 minutes 34 seconds">. Play icon must not be the only indicator — include text or aria-label. Duration badge: aria-hidden="true" (covered by the button label). Hover-to-preview should not auto-play with sound (WCAG 1.4.2). If hover preview uses <video>, it must be muted. Ensure thumbnails have meaningful alt text when displayed as images.',
    docsUrl: null,
  },
  {
    name: 'File Icon Mapping',
    category: 'preview',
    description: 'Displaying appropriate icons for non-previewable file types — documents, spreadsheets, archives, code files — based on MIME type or extension. Each file type gets a recognizable icon (PDF = red document, ZIP = folder with zipper, MP3 = music note). Consistent iconography helps users identify file types at a glance in file lists, upload queues, and attachment displays. Use a finite set of icons covering the most common types with a generic fallback.',
    implementation: 'Map file extensions to icon components: { pdf: PdfIcon, doc/docx: WordIcon, xls/xlsx: ExcelIcon, ppt/pptx: PowerPointIcon, zip/rar: ArchiveIcon, mp3/wav: AudioIcon, mp4/mov: VideoIcon, jpg/png/webp: ImageIcon, default: FileIcon }. Use lucide-react or react-icons for consistent icon sets. Color-code by category (red for PDF, blue for Word, green for Excel). Display alongside filename in file lists.',
    a11y: 'Icons must be decorative (aria-hidden="true") when accompanied by a filename that includes the extension. If the icon is the only indicator of file type, provide aria-label="PDF document" or sr-only text. Ensure icon color is not the sole differentiator — combine with shape differences or labels. In file lists, include the file type in the accessible name: "Annual Report.pdf, PDF document, 2.4 MB."',
    docsUrl: null,
  },

  // --- Optimization ---
  {
    name: 'Lazy Loading Media',
    category: 'optimization',
    description: 'Deferring the loading of off-screen images, videos, and iframes until the user scrolls near them. Reduces initial page weight and speeds up Largest Contentful Paint (LCP) — studies show 22% LCP improvement and 26% page weight reduction. Use native loading="lazy" for images and iframes below the fold. CRITICAL: never lazy-load elements visible in the initial viewport — this is a web performance anti-pattern that delays LCP and causes visible pop-in. The hero image, logo, above-the-fold product images, and any media in the first screenful must load eagerly. Combine with a placeholder (blur, dominant color, skeleton) to prevent layout shift.',
    implementation: 'Below the fold: <img loading="lazy" decoding="async">. Iframes: <iframe loading="lazy">. For more control, use IntersectionObserver with a rootMargin (e.g., 200px) to start loading before the element enters the viewport. The LCP image (exactly one per page) must use loading="eager" with fetchpriority="high". If the LCP image cannot be discovered by the browser\'s preload scanner (e.g., CSS background-image, JS-rendered, or inside a Web Component), add <link rel="preload" as="image" href="hero.webp" fetchpriority="high"> in the <head> with media queries matching responsive breakpoints. Only apply fetchpriority="high" to a single image — marking multiple images as high priority defeats the purpose. Avoid auto-rotating hero sliders where multiple images compete to be the LCP candidate — the browser cannot predict which slide will be visible at paint time, degrading LCP. Similarly, avoid placing multiple same-sized images above the fold (e.g., a 3-column feature grid) without designating one as the LCP — when images share identical dimensions the browser has no signal to prioritize one over the others, causing all of them to compete and none to load fast. Design layouts so one image is visually dominant (larger hero, featured product) or explicitly mark one with fetchpriority="high" and the rest with fetchpriority="low". Framework components (Next.js Image priority prop, Astro Image) handle eager loading and preload hints automatically. Set explicit width/height or aspect-ratio on every media element to prevent CLS. Placeholder: use a tiny blur-up image (LQIP), a dominant color swatch, or a skeleton.',
    a11y: 'Lazy loading is invisible to assistive technology — it does not affect accessibility. Ensure placeholder content does not confuse screen readers: blur-up images should have the same alt text as the final image, not "loading" or "placeholder." Skeleton placeholders: aria-hidden="true". When the real image loads, it should simply replace the placeholder with no announcement needed.',
    docsUrl: null,
  },
  {
    name: 'Responsive Images',
    category: 'optimization',
    description: 'Serving different image sizes and formats based on the user\'s device, viewport width, and pixel density. A 4K desktop gets a 2000px image; a mobile phone gets 400px. Prevents wasting bandwidth on oversized images. Use srcset for resolution switching and <picture> with <source> for art direction (different crops for different screens). Modern formats (WebP, AVIF) save 25-50% over JPEG with equal quality.',
    implementation: '<img srcset="small.webp 400w, medium.webp 800w, large.webp 1600w" sizes="(max-width: 640px) 100vw, (max-width: 1024px) 50vw, 33vw" src="fallback.jpg" alt="...">. For art direction: <picture><source media="(max-width: 640px)" srcset="mobile-crop.webp"><img src="desktop.webp" alt="..."></picture>. Use Next.js Image, Astro Image, or a CDN (Cloudinary, imgix) for automatic resizing and format negotiation.',
    a11y: 'Responsive images do not change accessibility requirements — alt text, decorative vs informative distinction, and long description patterns all apply equally. Ensure art-directed crops do not remove meaningful content visible in other viewport sizes. If a mobile crop omits important detail, provide it in the alt text or caption. Test alt text relevance across all responsive variants.',
    docsUrl: null,
  },
  {
    name: 'Image Format Optimization',
    category: 'optimization',
    description: 'Choosing and converting to modern image formats — AVIF (best compression, slow encode), WebP (good compression, wide support), JPEG (universal fallback), PNG (lossless, transparency). Serve modern formats with <picture> fallbacks. A single image pipeline: source → AVIF + WebP + JPEG at multiple sizes. AVIF saves ~50% vs JPEG, WebP saves ~30%. SVG for icons and illustrations (infinitely scalable, tiny file size).',
    implementation: 'Build pipeline: use sharp (Node.js) or squoosh for format conversion. Generate AVIF, WebP, and JPEG for each source image at multiple widths (400, 800, 1600, 3200). Serve via <picture><source type="image/avif" srcset="..."><source type="image/webp" srcset="..."><img src="fallback.jpg"></picture>. CDNs (Cloudinary, imgix, Vercel Image Optimization) automate this with URL parameters. Use SVG for icons — inline for small counts, sprite sheet for many.',
    a11y: 'Image format has zero impact on accessibility. All formats support alt text equally via the <img> element. Ensure SVG icons include role="img" and aria-label when used as meaningful content, or aria-hidden="true" when decorative. Inline SVGs need <title> elements for screen readers. Format optimization benefits users on slow connections and assistive devices that may have limited processing power.',
    docsUrl: null,
  },
  {
    name: 'Blur-Up Placeholder (LQIP)',
    category: 'optimization',
    description: 'Low-Quality Image Placeholder — a tiny (20-40px wide), heavily blurred version of the image displayed instantly while the full image loads. Creates a smooth transition from blurry to sharp, providing immediate visual context and preventing layout shift. Facebook and Medium popularized this pattern. Alternative approaches: dominant color swatch (single color), BlurHash (compact hash string encoding), and traced SVG outlines.',
    implementation: 'Generate LQIP at build time: sharp(image).resize(20).blur(10).toBuffer(). Encode as base64 data URI and inline in the HTML. CSS: blur filter on the placeholder, transition to the full image on load. BlurHash alternative: encode with blurhash library (4-5 component), decode to canvas at display time. Dominant color: extract with sharp.stats() and use as background-color. Transition: crossfade from placeholder to loaded image.',
    a11y: 'Placeholders are transient visual states — they should not affect the accessibility tree. The <img> alt text applies to the final image regardless of load state. Do not announce loading/loaded transitions. BlurHash canvas: aria-hidden="true". Dominant color background: purely decorative. Ensure the placeholder does not cause a "flash" that could trigger photosensitive seizures (WCAG 2.3.1) — use smooth transitions, not abrupt changes.',
    docsUrl: null,
  },
  {
    name: 'CDN & Caching Strategy',
    category: 'optimization',
    description: 'Serving media from a Content Delivery Network (CDN) for faster global delivery, with appropriate cache headers for performance. Static media assets (images, fonts, CSS) get immutable caching with content-hashed filenames. User-uploaded media gets long Cache-Control with ETag-based revalidation. CDNs like Cloudflare, CloudFront, and Vercel Edge Cache reduce TTFB to <50ms globally. On-the-fly image transformation (resize, format, quality) via CDN URL parameters.',
    implementation: 'Static assets: Cache-Control: public, max-age=31536000, immutable with hashed filenames (image.abc123.webp). User uploads: Cache-Control: public, max-age=86400 with ETag for revalidation. CDN image transformation: ?w=800&q=80&fmt=auto for automatic format/size (Cloudinary, imgix, Cloudflare Images). Use <link rel="preconnect"> to the CDN domain. Serve from a cookieless domain to reduce header overhead.',
    a11y: 'CDN and caching are transparent to users and assistive technology — they do not affect accessibility. However, CDN-transformed images must preserve alt text and ARIA attributes from the source markup. If using CDN URL parameters for responsive images, ensure the srcset and sizes attributes are correctly set for each transformation. Performance benefits from CDN directly improve the experience for users on assistive devices with limited bandwidth.',
    docsUrl: null,
  },
  {
    name: 'Media Preloading',
    category: 'optimization',
    description: 'Proactively loading media assets that the user is likely to need next — the LCP image, the next gallery image, or a video poster. Use <link rel="preload"> for critical above-the-fold images. Preload adjacent lightbox images when viewing a gallery. Prefetch video poster images in a video list. Balance: preloading too aggressively wastes bandwidth; preloading strategically eliminates perceived latency.',
    implementation: '<link rel="preload" as="image" href="hero.webp" type="image/webp" fetchpriority="high"> in <head> for LCP images. For galleries: preload current+1 and current-1 images on lightbox open. Use requestIdleCallback or IntersectionObserver to preload off-screen content during idle time. Video: preload="metadata" for poster + duration without downloading the full file. Avoid preloading below-the-fold images — use lazy loading instead.',
    a11y: 'Preloading is invisible to assistive technology and does not affect accessibility. The benefit is indirect: faster loads mean users on assistive devices spend less time waiting. Ensure preloaded resources do not trigger unexpected audio or video playback (WCAG 1.4.2). Only preload what the user is likely to need — excessive preloading can slow down the page for users on metered connections.',
    docsUrl: null,
  },
  {
    name: 'Data-Saver Awareness',
    category: 'optimization',
    description: 'Respecting the user\'s preference for reduced data usage via the Save-Data HTTP client hint. When Save-Data: On is sent, the user has explicitly opted into data-saving mode in their browser or OS — typically on metered mobile connections or in regions with expensive bandwidth. The server and client should respond by serving lighter media: smaller images, lower video quality, skipping decorative content, and avoiding non-essential preloads. This is progressive enhancement in reverse — start with the full experience and gracefully reduce for data-constrained users.',
    implementation: 'Server-side: check the Save-Data request header. If "On", serve smaller image variants (?q=60&w=800 instead of ?q=80&w=1600), skip video preloading, disable auto-play, and omit decorative background images. Client-side: detect via navigator.connection?.saveData (Network Information API). Conditionally skip: LQIP blur-up (use dominant color instead — zero extra bytes), adjacent image preloading in galleries, hover-to-preview animations on video thumbnails, and high-res zoom sources. CSS: @media (prefers-reduced-data: reduce) is experimental with near-zero browser support — use JS detection instead. Always preserve core content — data-saver should reduce fidelity, never remove functionality.',
    a11y: 'Data-saver mode must not remove content that is required for understanding — alt text, captions, and transcripts must always be served regardless of Save-Data preference. If images are replaced with placeholders in extreme data-saving mode, the alt text becomes the primary content — ensure it is descriptive. Announce data-saver adaptations if they affect the UI: "Images shown at reduced quality to save data" via a dismissible banner.',
    docsUrl: null,
  },
];
