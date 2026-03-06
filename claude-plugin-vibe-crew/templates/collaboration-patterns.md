# Collaboration & Real-time Pattern Reference

Agent-facing reference for multi-user collaboration interfaces — presence, collaborative editing, communication, version history, real-time sync, and permissions. The Builder reads this during the Design Phase; the Code Reviewer checks compliance during review.
**Principle:** Real-time features must sync reliably, degrade gracefully offline, and announce changes accessibly via ARIA live regions without overwhelming screen readers.

## 1. Presence

### Online Status Indicator
- **When:** Multi-user apps where knowing who is active matters — chat, project management, support.
- **What:** Circular badge on avatar: green (online), yellow (away), red (busy), gray (offline). WebSocket heartbeat (30s ping, 10s timeout). Auto-away after 5 min idle.
- **A11y:** aria-label on avatar: "Alice — Online." Color must not be the sole indicator (WCAG 1.4.1) — pair with text labels.
- **Anti-pattern:** Never show exact "last seen" timestamps without user consent. Never update status so frequently it causes visual flicker.

### Avatar Stack
- **When:** Compact participant display — document headers, card metadata, room listings.
- **What:** Overlapping avatars with negative margin (-8px to -12px). White border separation. "+N" overflow count. Click to expand full list.
- **A11y:** Container: role="group" aria-label="5 active participants". Overflow: aria-label="3 more participants". Click target: <button>.
- **Anti-pattern:** Never show more than 5 overlapping avatars — it becomes unreadable.

### Participant List
- **When:** Full user list in shared spaces — documents, channels, meetings.
- **What:** Sidebar/Sheet with avatar, name, status, role. Sort: online first. Real-time join/leave animations. Search for large teams (50+).
- **A11y:** role="list" aria-label="Participants". Announce joins/leaves via aria-live="polite" — batch rapid joins.
- **Anti-pattern:** Never show a raw user ID instead of display name. Never auto-scroll the list on every join/leave.

### Typing Indicator
- **When:** Chat, comments, collaborative inputs.
- **What:** "Alice is typing..." with animated dots. Throttle: send typing event once per 3s, stop after 5s idle. Format: 1 user = name, 2 = both, 3+ = count.
- **A11y:** Container: aria-live="polite" role="status". Announce "Alice is typing" — do not announce "stopped typing."
- **Anti-pattern:** Never send typing events on every keystroke without throttling. Never show typing indicator for more than 10 seconds without fresh input.

### User Cursor
- **When:** Spatial collaboration — design tools, whiteboards, shared spreadsheets.
- **What:** Remote cursor as SVG arrow + name label. Broadcast position via WebSocket (throttled to 60fps). CSS transition for smooth interpolation. Color-coded per user.
- **A11y:** aria-hidden="true" on remote cursors — they are supplementary. Provide "Hide cursors" toggle. Respect prefers-reduced-motion.
- **Anti-pattern:** Never show cursors on text-only editors where selection highlighting is more appropriate.

## 2. Collaborative Editing

### Collaborative Text Editing
- **When:** Multiple users editing the same document simultaneously.
- **What:** Use Yjs (CRDT) with Tiptap/ProseMirror for rich text. Awareness protocol for cursor sharing. Persist Y.Doc snapshots on disconnect.
- **A11y:** Standard rich text a11y (role="textbox", aria-multiline). Announce collaboration events: "Alice started editing." Do not announce every character change.
- **Anti-pattern:** Never use OT for new projects when CRDTs offer offline support and better open-source libraries.

### Selection Highlighting
- **When:** Showing where other users are working in a shared document.
- **What:** Colored highlights per user (20% opacity background). Name label at selection anchor. Same color palette as cursors. y-prosemirror CollaborationCursor extension.
- **A11y:** aria-hidden="true" on decoration elements. Local selection always visually dominant (higher z-index).
- **Anti-pattern:** Never make remote selections interactive — they are visual-only indicators.

### Conflict Resolution Dialog
- **When:** Automatic merge fails or save-and-sync systems detect concurrent edits.
- **What:** Side-by-side diff with "Keep mine," "Keep theirs," "Merge manually." Use diff-match-patch. Auto-merge non-overlapping changes.
- **A11y:** role="alertdialog" aria-label="Edit conflict detected." Diff highlights: use +/- prefixes, not color alone.
- **Anti-pattern:** Never silently discard changes. Never use last-write-wins without informing the user.

### Optimistic Update with Rollback
- **When:** Any mutation where server round-trip latency would feel sluggish.
- **What:** Apply change instantly, save snapshot, send to server. On failure: restore snapshot + error toast. CRDT systems handle this automatically.
- **A11y:** Rollback: aria-live="assertive" announcing "Change could not be saved and was reverted." Pending state: aria-live="polite" with "Saving..."
- **Anti-pattern:** Never show success state before server confirmation for destructive operations (deletes, payments).

### Locking & Editing Permissions
- **When:** Structured content where free concurrent editing is inappropriate — forms, CMS blocks, spreadsheets.
- **What:** Pessimistic or section-based locking with TTL auto-release. "Locked by Alice" banner. WebSocket broadcast of lock state changes.
- **A11y:** Lock status: aria-live="polite". Disabled controls: aria-disabled="true" with aria-describedby explaining the lock. Locked sections remain readable.
- **Anti-pattern:** Never lock an entire document when section-level locking is possible. Never leave stale locks after user disconnection.

## 3. Communication

### Inline Comments
- **When:** Comments attached to specific content — text selections, UI elements, code lines.
- **What:** Highlight markers + sidebar panel. States: open, resolved, re-opened. Click highlight to scroll sidebar; click comment to scroll content.
- **A11y:** Highlight: role="button" aria-label="Comment by Alice: [first line]." Sidebar: role="list". Navigate between comments with keyboard shortcuts.
- **Anti-pattern:** Never lose comment anchors when content is edited. Use range-based anchoring that adapts to edits.

### @Mention Autocomplete
- **When:** Referencing team members in text inputs — comments, messages, tasks.
- **What:** "@" triggers a Popover with filtered user list. Arrow keys navigate, Enter selects. Insert non-editable mention node. Notify mentioned user.
- **A11y:** Dropdown: role="listbox" aria-label="Mention suggestions." Input: aria-expanded, aria-activedescendant. Inserted mention: role="link".
- **Anti-pattern:** Never require exact username match — search by display name too. Never trigger autocomplete in code blocks.

### Emoji Reactions
- **When:** Lightweight responses to messages, comments, or content items.
- **What:** Horizontal pills below content: emoji + count + active state. Toggle on click. Emoji picker for adding. Tooltip showing who reacted.
- **A11y:** Each pill: <button aria-label="thumbs up, 5 reactions" aria-pressed>. Emoji picker: role="grid" with labeled buttons.
- **Anti-pattern:** Never allow unlimited unique emojis per item — cap at 20. Never show reaction animations that violate prefers-reduced-motion.

### Activity Feed
- **When:** Chronological event stream — edits, comments, status changes, joins.
- **What:** Vertical timeline with avatar, action, target, timestamp. Group events by actor within 5-min window. Infinite scroll. Real-time prepend via WebSocket.
- **A11y:** Container: role="feed" aria-label="Activity feed." Each entry: role="article". New events: aria-live="polite" region.
- **Anti-pattern:** Never show every keystroke as a separate event. Always group related actions.

### Threaded Replies
- **When:** Sub-conversations within comments or messages.
- **What:** Inline (indented, collapsible) or side panel (Slack-style). Parent shows reply count + latest preview. Collapse after 3 replies with "Show N more."
- **A11y:** Toggle: aria-expanded. Nested: role="list" within role="listitem". Reply input: aria-label="Reply in thread."
- **Anti-pattern:** Never force all replies into threads — simple reactions should not require a thread.

## 4. History & Versioning

### Version History
- **When:** Browsing and restoring previous document states.
- **What:** Immutable snapshots with metadata. Sidebar list, newest first. Preview on click. "Restore" creates a new version (non-destructive).
- **A11y:** List: role="list" aria-label="Version history." Restore button: confirm dialog before action. Announce result.
- **Anti-pattern:** Never overwrite the current version on restore — always create a new version. Never show more than 100 versions without pagination.

### Diff Visualization
- **When:** Comparing two versions of content.
- **What:** Unified or side-by-side view. Additions (green), deletions (red), unchanged (default). Word-level diffs. Navigation between changes.
- **A11y:** Use +/- prefixes and labels, not color alone. Screen reader labels: "Added text: [content]." Summary with aria-live.
- **Anti-pattern:** Never show diffs without context lines — surrounding content is needed for comprehension.

### Undo/Redo Stack
- **When:** Application-level undo/redo beyond text editing — drag/drop, settings, list reordering.
- **What:** Two stacks (undo/redo). Push {previousState, newState} per action. Group multi-item operations. Cap at 50-100 entries.
- **A11y:** Toolbar buttons: aria-label + aria-disabled when empty. Announce via aria-live: "Undone: deleted item restored."
- **Anti-pattern:** Never clear the undo stack on save. Never make destructive operations un-undoable without warning.

### Audit Log
- **When:** Security compliance (SOC 2, GDPR), debugging, accountability.
- **What:** Append-only table: timestamp, actor, action, resource, metadata. Admin-only. Filter by date/user/action. Export CSV. Retain 1-7 years.
- **A11y:** Accessible data table with <thead>, <th scope="col">. Expandable rows: aria-expanded. Filter controls with labels.
- **Anti-pattern:** Never update or delete audit log entries. Never expose audit logs to non-admin users without explicit permission.

### Restore Point
- **When:** User-created named checkpoints before risky changes.
- **What:** "Create restore point" button with name input. Displayed prominently in version history (star icon). Restore creates new version.
- **A11y:** aria-label including custom name. Confirm dialog before restore. Announce creation via aria-live.
- **Anti-pattern:** Never auto-create restore points — they are intentional user actions. Never mix auto-saves and restore points visually.

## 5. Real-time Sync

### WebSocket Connection
- **When:** High-frequency bidirectional real-time communication.
- **What:** Persistent full-duplex channel. Message protocol: {type, payload}. Channels/rooms for scoping. JWT authentication. Ping/pong keep-alive.
- **A11y:** No direct a11y impact — ensure delivered updates follow aria-live patterns. Provide "Pause live updates" toggle.
- **Anti-pattern:** Never use WebSocket for request/response patterns where HTTP suffices. Never send unstructured messages.

### Reconnection Strategy
- **When:** WebSocket connection drops — network changes, server restarts, mobile backgrounding.
- **What:** Exponential backoff (1s, 2s, 4s, 8s, max 30s) with jitter. "Reconnecting..." banner. On reconnect: replay from last event ID.
- **A11y:** Banner: role="alert". Disconnection: aria-live="assertive". Reconnection: aria-live="polite". "Retry now" button.
- **Anti-pattern:** Never use fixed-interval retry — exponential backoff prevents thundering herd. Never hide disconnection state from the user.

### Offline Mode
- **When:** Users on intermittent connectivity or mobile.
- **What:** Queue mutations in IndexedDB. "Pending sync" indicators. On reconnect: replay queue. CRDTs merge automatically. "You're offline" banner.
- **A11y:** Banner: role="status" aria-live="polite". Pending indicators: aria-label="Pending sync." Sync result: aria-live announcement.
- **Anti-pattern:** Never disable all controls when offline — only server-dependent features. Never lose queued changes on app restart.

### Event Sourcing
- **When:** Systems needing complete history, time-travel, and replay.
- **What:** Append-only event log. Current state from event replay. Periodic snapshots for performance. Client sends commands; server appends events.
- **A11y:** Backend pattern — a11y surfaces through Version History, Undo/Redo, Audit Log, and Activity Feed patterns.
- **Anti-pattern:** Never mutate events. Never rely solely on event replay without snapshots for large histories.

### Broadcast Updates
- **When:** Pushing changes from one user to all others in real-time.
- **What:** WebSocket broadcast per room. Highlight animation on changed elements (yellow flash, 1.5s). Slide-in for additions, fade-out for deletions.
- **A11y:** aria-live="polite" for important changes. Batch announcements: "3 items updated by Alice." Respect prefers-reduced-motion.
- **Anti-pattern:** Never announce every field-level edit — too noisy. Never highlight more than 5 items simultaneously.

## 6. Permissions & Roles

### Role-Based Access Control
- **When:** Multi-user systems with different access levels.
- **What:** Roles: Owner > Admin > Editor > Commenter > Viewer. Server middleware checks permissions. Client: conditionally render controls. Disabled (not hidden) for insufficient permissions.
- **A11y:** Disabled controls: aria-disabled with aria-describedby explaining restriction. Include role in user menu.
- **Anti-pattern:** Never hide controls without indication — users should understand what higher permissions enable.

### Share Dialog
- **When:** Sharing documents/resources with other users or via link.
- **What:** Dialog with: email invite form + role selector, people list with role dropdowns, link sharing toggle. Copy link button. Batch invite support.
- **A11y:** role="dialog" aria-label="Share [name]." Focus trap. Copy button: announce "Link copied." Remove button: aria-label="Remove Alice's access."
- **Anti-pattern:** Never default link sharing to "Editor" — default to most restrictive (Viewer). Never share without confirmation.

### Permission Indicator
- **When:** Showing current user's access level in the UI.
- **What:** Badge in toolbar: "View only" (eye), "Can edit" (pencil), "Can comment" (comment). Mode switcher for users with edit access.
- **A11y:** aria-label="Your access level: Editor." Mode switcher: role="radiogroup." Announce mode changes via aria-live.
- **Anti-pattern:** Never show edit controls to view-only users. Never allow mode switching without immediate visual feedback.

### Guest Access
- **When:** External users accessing shared content without accounts.
- **What:** Share token in URL. Optional password protection. Expiring links. Guest banner with sign-in CTA. Activity tracking for owner.
- **A11y:** Guest banner: role="banner." Password prompt: accessible form. Same a11y standards as authenticated content.
- **Anti-pattern:** Never grant guest users edit permissions by default. Never create non-expiring links without owner awareness.

### Access Request
- **When:** User navigates to a resource they don't have permission to view.
- **What:** Friendly page showing document title + owner + reason form + "Request access" button. Owner notified with Approve/Deny options.
- **A11y:** Clear heading "You need access." Form with labeled reason input. Success state: "Access requested."
- **Anti-pattern:** Never show a generic 403 page — always show what the resource is and how to request access. Never auto-approve requests.
