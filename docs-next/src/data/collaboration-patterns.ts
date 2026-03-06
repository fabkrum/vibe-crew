export interface CollaborationPattern {
  name: string;
  category: 'presence' | 'editing' | 'communication' | 'history' | 'sync' | 'permissions';
  description: string;
  implementation: string;
  a11y: string;
  docsUrl: string | null;
}

export const categoryLabels: Record<CollaborationPattern['category'], string> = {
  presence: 'Presence',
  editing: 'Collaborative Editing',
  communication: 'Communication',
  history: 'History & Versioning',
  sync: 'Real-time Sync',
  permissions: 'Permissions & Roles',
};

export const categoryOrder: CollaborationPattern['category'][] = [
  'presence', 'editing', 'communication', 'history', 'sync', 'permissions',
];

export const collaborationPatterns: CollaborationPattern[] = [
  // --- Presence ---
  {
    name: 'Online Status Indicator',
    category: 'presence',
    description: 'A small circular badge overlaid on a user\'s avatar showing their current availability: green for online, yellow for away, red for busy/do-not-disturb, gray for offline. Popularized by Slack and Microsoft Teams. Use WebSocket heartbeats (ping every 30s, pong timeout 10s) to determine liveness. Idle detection (no mouse/keyboard for 5 minutes) should auto-transition to "away." Store status ephemerally — it should not persist to a database. Privacy consideration: let users choose to share or hide their status.',
    implementation: 'WebSocket connection tracks user presence per room/channel. Send heartbeat pings every 30 seconds; mark as offline after 10s without pong. Detect idle state via mouse/keyboard inactivity timer (5 min default). Render a 12px circle badge positioned bottom-right on the avatar with CSS absolute positioning. Status colors: online (#22c55e), away (#eab308), busy (#ef4444), offline (#9ca3af). Use CSS outline instead of border to avoid shifting avatar dimensions.',
    a11y: 'Status badge requires aria-label on the avatar container: "Alice — Online." Color alone must not convey status (WCAG 1.4.1) — pair with text labels in tooltips or screen-reader-only text. Use distinct shapes if possible (filled circle for online, hollow for offline). In participant lists, include status as text: "Alice (Online)."',
    docsUrl: null,
  },
  {
    name: 'Avatar Stack',
    category: 'presence',
    description: 'Overlapping avatars showing multiple participants in a compact horizontal strip — used in document headers, channel indicators, card metadata, and room listings. Typically show 3-5 avatars with a "+N" overflow indicator for additional participants. Clicking the stack reveals a full participant list. Order by most recently active. Liveblocks, Supabase Realtime, and most collaboration tools use this pattern.',
    implementation: 'Flex container with negative margin-left (-8px to -12px) on each avatar after the first. Each avatar gets a white border (2px) to create visual separation. Z-index decreases left to right so the first avatar is on top. Overflow count rendered as a circular element with the same dimensions. Use Tooltip on each avatar to show the username. Clicking the stack opens a Popover with the full participant list.',
    a11y: 'Container: role="group" aria-label="5 active participants". Each avatar: aria-label="[username]". Overflow indicator: aria-label="3 more participants". Clickable stack: use a <button> wrapping the avatars. Full participant list in popover: role="list" with role="listitem" per entry. Keyboard: Enter/Space opens the list, Escape closes it.',
    docsUrl: null,
  },
  {
    name: 'Participant List',
    category: 'presence',
    description: 'A sidebar panel or dropdown listing all users currently in a shared space — documents, channels, meetings, or rooms. Shows avatar, name, status, and role (owner, editor, viewer). Sort by status (online first) then alphabetically. Include a search/filter for large teams (50+ participants). Real-time updates as users join or leave. Commonly seen in Google Docs, Figma, and video conferencing tools.',
    implementation: 'Render as a scrollable list in a sidebar or Sheet component. Each entry: Avatar + Name + Status Badge + Role badge. Subscribe to presence events (join/leave) via WebSocket. Animate entries in/out with height transitions. Sort: online users first, then away, then offline, alphabetically within each group. Add a search input for filtering by name in large lists. Show a count in the header: "12 people."',
    a11y: 'List: role="list" aria-label="Participants". Each entry: role="listitem" with full description "Alice, Editor, Online." Announce join/leave events via aria-live="polite" region: "Bob joined." Use aria-live sparingly — batch rapid joins (e.g., "3 people joined") to prevent announcement storms. Search input: aria-label="Search participants." Count: update aria-live region on change.',
    docsUrl: null,
  },
  {
    name: 'Typing Indicator',
    category: 'presence',
    description: 'A "user is typing..." indicator shown in chat, comments, or collaborative editors when another user is actively composing content. For single users: "Alice is typing..." with an animated ellipsis. For multiple users: "Alice and Bob are typing..." or "3 people are typing..." when more than two. Debounce typing events — send a "typing" signal on first keystroke, then throttle to every 3-5 seconds. Send a "stopped typing" signal after 5 seconds of inactivity.',
    implementation: 'Client: on keydown in the input field, send a "typing" event via WebSocket (throttled to once per 3 seconds). Set a 5-second inactivity timer; on timeout, send "stopped_typing." Server: broadcast typing state to other participants in the room. Client display: show the indicator below the message input with a CSS animation (three bouncing dots). Format: 1 user shows name, 2 users shows both names, 3+ shows count.',
    a11y: 'Typing indicator container: aria-live="polite" aria-atomic="true" so screen readers announce changes. Use role="status" for the indicator region. Keep announcements concise: "Alice is typing" not "Alice is typing..." (the ellipsis is visual only). When typing stops, clear the aria-live region (do not announce "stopped typing"). Ensure the animated dots do not trigger motion sensitivity issues — use subtle opacity changes rather than large movement.',
    docsUrl: null,
  },
  {
    name: 'User Cursor',
    category: 'presence',
    description: 'Displaying other users\' cursor positions in real-time on a shared canvas or document — the hallmark of Figma-style collaboration. Each cursor is color-coded with a small label showing the user\'s name. Cursor positions are broadcast via WebSocket and interpolated for smooth movement. Essential for spatial collaboration in design tools, whiteboards, and shared spreadsheets. Less useful in text-only editors where selection highlighting is more appropriate.',
    implementation: 'Track cursor position via mousemove events (throttled to 60fps or ~16ms). Broadcast {x, y, userId, color} via WebSocket. Receiving clients render each remote cursor as an absolutely positioned SVG arrow with a name label. Use CSS transitions (50-100ms) or linear interpolation for smooth movement between position updates. Assign colors from a palette (8-12 distinct colors). Remove cursors when users disconnect. Hide when user is idle for 30+ seconds.',
    a11y: 'Remote cursors are visual-only and should be aria-hidden="true" — they are supplementary to the content, not interactive elements. Screen reader users get collaboration awareness through the participant list and activity feed instead. Ensure cursors do not interfere with keyboard navigation or focus management. Provide a "Hide cursors" toggle in preferences for users who find them distracting. Respect prefers-reduced-motion by disabling cursor interpolation.',
    docsUrl: null,
  },

  // --- Editing ---
  {
    name: 'Collaborative Text Editing',
    category: 'editing',
    description: 'Multiple users editing the same text document simultaneously with real-time character-by-character synchronization. Two approaches: OT (Operational Transformation, used by Google Docs) transforms concurrent operations to maintain consistency; CRDTs (Conflict-free Replicated Data Types, used by Figma, Notion) merge edits mathematically without a central server. CRDTs are preferred for new projects — they work offline, scale peer-to-peer, and have robust open-source libraries (Yjs, Automerge).',
    implementation: 'Use Yjs with a Tiptap or ProseMirror editor for rich text. Yjs provides a Y.Doc CRDT that syncs via WebSocket (y-websocket), WebRTC (y-webrtc), or any transport. Each user gets a random color for their cursor/selection. Awareness protocol (y-protocols/awareness) shares cursor positions and user info. For plain text, use Yjs with a textarea binding. Persistence: save Y.Doc snapshots to the server periodically and on disconnect.',
    a11y: 'The editor itself follows standard rich text accessibility (role="textbox", aria-multiline="true", keyboard formatting shortcuts). Remote user selections should not interfere with the local user\'s assistive technology. Announce significant collaboration events via aria-live="polite": "Alice started editing." Do not announce every character change — this would overwhelm screen readers. Provide a non-real-time fallback mode for users who find simultaneous editing disorienting.',
    docsUrl: 'https://docs.yjs.dev/',
  },
  {
    name: 'Selection Highlighting',
    category: 'editing',
    description: 'Showing other users\' text selections in a shared document with colored highlights — each user gets a distinct color matching their cursor. The selected text is overlaid with a semi-transparent background color. A small label with the user\'s name appears at the selection anchor. Essential for collaborative text editors to show where each user is working and prevent accidental overwrites. Google Docs, Notion, and VS Code Live Share all use this pattern.',
    implementation: 'In Tiptap/ProseMirror with Yjs, use the y-prosemirror CollaborationCursor extension. It reads the Yjs awareness state and renders decorations for each remote user\'s selection range. Colors assigned from a palette (same as cursor colors). Selection background: user\'s color at 20% opacity. Name label: absolutely positioned above the selection start with the user\'s color as background. Update selections on every awareness change (throttled).',
    a11y: 'Selection highlights are visual-only — aria-hidden="true" on the decoration elements. Do not alter the document\'s accessibility tree with remote selections. Screen reader users learn about other users\' positions through the participant list. If a user selects text that overlaps with a remote user\'s selection, ensure the local selection is always visually dominant (higher z-index) so the user can see what they\'ve selected.',
    docsUrl: null,
  },
  {
    name: 'Conflict Resolution Dialog',
    category: 'editing',
    description: 'A UI for resolving edit conflicts when two users modify the same content and automatic merging fails — or when comparing manual save versions. Shows the two conflicting versions side by side (or inline diff) and lets the user choose "Keep mine," "Keep theirs," or manually merge. Common in git-style workflows, CMS platforms, and any system with optimistic offline editing. Google Docs avoids this by using OT for real-time merge, but save-and-sync systems need explicit conflict resolution.',
    implementation: 'Detect conflicts on save: compare the document\'s base version with the server\'s current version. If they differ, show a Dialog with two-panel diff view (left: "Your changes", right: "Their changes"). Highlight conflicting sections in red/green. Three resolution options: "Keep mine" (overwrite server), "Keep theirs" (discard local), "Merge manually" (open a merge editor). Use diff-match-patch or jsdiff for text diffing. Auto-merge non-overlapping changes when possible.',
    a11y: 'Conflict dialog: role="alertdialog" with aria-label="Edit conflict detected." Describe both versions clearly. Diff highlights must not rely on color alone — use text labels ("Your version" / "Their version") and line markers (+/-). Resolution buttons: clear aria-labels ("Keep my changes," "Keep their changes," "Merge manually"). Announce resolution result via aria-live: "Conflict resolved — your changes kept."',
    docsUrl: null,
  },
  {
    name: 'Optimistic Update with Rollback',
    category: 'editing',
    description: 'Applying the user\'s edit to the UI immediately before server confirmation, then rolling back if the server rejects it. Creates the illusion of zero-latency editing. The UI shows the change instantly, sends it to the server, and either confirms (no further action) or reverts (restore the previous state with an error notification). Essential for responsive collaboration UIs. Used extensively in Linear, Notion, and Figma. Rollbacks should be rare — design the system so most operations succeed.',
    implementation: 'On user action: (1) save current state snapshot, (2) apply change to local state immediately, (3) send mutation to server. On success: discard the snapshot. On failure: restore from snapshot, show error toast ("Failed to save — change reverted"). For list reordering, use a pending state with subtle opacity reduction. For text editing, CRDT-based systems handle this automatically. For REST APIs, use React Query\'s optimistic update API or SWR\'s mutate with optimisticData.',
    a11y: 'Rollback must be announced via aria-live="assertive": "Change could not be saved and was reverted." Ensure the UI does not flash or shift layout during rollback — use smooth transitions. Pending state indicators (e.g., reduced opacity, spinner) should have accessible labels: "Saving..." via aria-live="polite". Do not show conflicting success/error states — clearly resolve to one.',
    docsUrl: null,
  },
  {
    name: 'Locking & Editing Permissions',
    category: 'editing',
    description: 'Preventing multiple users from editing the same section simultaneously by locking the resource or section. Two approaches: (1) pessimistic locking — user must acquire a lock before editing, others see a "locked by Alice" indicator; (2) section-based locking — different sections of a document can be edited by different users, but each section has one editor at a time. Useful for structured content (forms, spreadsheets, CMS blocks) where CRDT-based free editing is inappropriate.',
    implementation: 'Server-side: store locks per resource/section with a TTL (auto-release after 5 minutes of inactivity). Lock API: POST /locks/{resourceId} returns 200 (acquired) or 409 (already locked by another user). Client: on edit intent, request lock. If acquired, enable editing. If locked, show read-only view with "Locked by Alice — editing disabled" banner. Auto-renew lock on activity. Release on save, navigate away, or TTL expiry. Broadcast lock state changes via WebSocket.',
    a11y: 'Lock status must be announced: aria-live="polite" with "Section locked by Alice" when lock is acquired by another user. Disabled edit controls: aria-disabled="true" with aria-describedby pointing to the lock status message. When lock is released: "Section unlocked — you can now edit." Ensure locked sections remain readable (do not gray out text, only disable edit affordances).',
    docsUrl: null,
  },

  // --- Communication ---
  {
    name: 'Inline Comments',
    category: 'communication',
    description: 'Comments attached to specific elements in a document, design, or codebase — text selections, UI elements, spreadsheet cells, or code lines. Users highlight content, click "Comment," and type their message. Comments appear as highlight markers in the content with a sidebar panel showing the comment thread. Google Docs, Figma, and GitHub all use this pattern. Comments have three states: open (active discussion), resolved (completed), and re-opened.',
    implementation: 'Store comments with: anchor (position in content — text range, element ID, or coordinates), author, timestamp, thread (array of replies), and status (open/resolved). Render highlight markers in the content (background color or icon). Sidebar: list all comments sorted by position, with ability to filter (open/resolved/all). Click a highlight to scroll the sidebar to that comment. Click a sidebar comment to scroll the content to that anchor. Use ResizeObserver to reposition markers on layout changes.',
    a11y: 'Highlight markers: role="button" aria-label="Comment by Alice: [first line of comment]" with keyboard activation. Sidebar comments: role="list" with role="listitem" per thread. Reply input: aria-label="Reply to comment." Resolve button: aria-label="Resolve comment." Comment count badge: aria-label="3 open comments." Announce new comments via aria-live="polite": "New comment from Bob on [context]." Navigate between comments with keyboard shortcuts (Ctrl+Alt+Arrow).',
    docsUrl: null,
  },
  {
    name: '@Mention Autocomplete',
    category: 'communication',
    description: 'Typing "@" in a text input triggers an autocomplete dropdown listing team members, with search filtering as the user types the name. Selecting a mention inserts a formatted token (highlighted name link) into the text and optionally notifies the mentioned user. Also support "#" for channel/issue linking and "/" for slash commands. Popularized by Slack, GitHub, and Notion. The autocomplete should be fast (<100ms) and keyboard-navigable.',
    implementation: 'Detect "@" character in the input (or Tiptap Mention extension). On trigger, show a Popover below the cursor with a filtered list of users. Filter by username and display name as the user types. Arrow keys navigate the list, Enter/Tab selects. Insert a non-editable mention node into the rich text (or a @[username] token in plain text). Style mentions with background color and make them clickable (link to profile). Server-side: create a notification for the mentioned user.',
    a11y: 'Autocomplete dropdown: role="listbox" with aria-label="Mention suggestions." Each option: role="option" with aria-selected on the focused item. Input: aria-expanded="true" when dropdown is visible, aria-activedescendant pointing to the focused option. Announce results: "5 suggestions available" via aria-live="polite". Inserted mention: role="link" with aria-label="Mentioned user: Alice." Keyboard: Escape dismisses the dropdown without selecting.',
    docsUrl: null,
  },
  {
    name: 'Emoji Reactions',
    category: 'communication',
    description: 'Quick emoji responses on messages, comments, tasks, or content items — a lightweight alternative to typing a reply. Show a "+" button to add a reaction, opening an emoji picker. Once added, reactions appear as horizontal pills below the content with the emoji and a count. Clicking an existing reaction toggles it (add/remove your reaction). Group identical reactions. Hover over a reaction pill to see who reacted. Used in Slack, GitHub, Linear, and Notion.',
    implementation: 'Render reactions as horizontal flex row of pills below the content. Each pill: emoji + count + active state (highlighted if current user reacted). "+" button opens an emoji picker (use @emoji-mart/react or a lightweight custom grid of common emojis). API: POST /reactions {emoji, contentId} toggles. Store reactions as: {emoji, userIds[]}. Animate adding/removing with scale transitions. Show a Tooltip on hover listing the usernames. Limit to 20 unique emojis per item.',
    a11y: 'Each reaction pill: <button aria-label="thumbs up, 5 reactions, click to toggle" aria-pressed="true/false">. Reaction add button: aria-label="Add reaction." Emoji picker: role="grid" with emoji buttons labeled by name (aria-label="grinning face"). Tooltip with reactor names: accessible via focus (not hover-only). Announce toggle result: "You reacted with thumbs up" / "You removed thumbs up reaction" via aria-live="polite".',
    docsUrl: null,
  },
  {
    name: 'Activity Feed',
    category: 'communication',
    description: 'A chronological stream of events showing what happened in a project, document, or workspace — edits, comments, status changes, file uploads, member joins, and other actions. Each entry shows: actor (avatar + name), action verb, target, and timestamp. Group related events ("Alice made 5 edits" instead of 5 separate entries). Support filtering by event type and participant. Used in GitHub, Linear, Notion, and every project management tool.',
    implementation: 'Store events as an append-only log: {actor, action, target, timestamp, metadata}. Render as a vertical timeline with avatar, description, and relative timestamp ("2 minutes ago"). Group consecutive events by the same actor within a time window (5 minutes). Infinite scroll or "Load more" for history. Filter tabs or checkboxes by event type (comments, edits, status changes). Real-time: prepend new events via WebSocket with a slide-down animation. Mark events as read/unread.',
    a11y: 'Feed container: role="feed" aria-label="Activity feed." Each entry: role="article" with aria-label summarizing the event ("Alice commented on Task-123, 2 minutes ago"). Timestamp: <time datetime="..."> with relative text. New events: aria-live="polite" region at the top for screen reader announcement. "Load more" button: aria-label="Load older activity." Filter controls: standard checkbox/radio accessibility. Mark as read: do not announce — visual only.',
    docsUrl: null,
  },
  {
    name: 'Threaded Replies',
    category: 'communication',
    description: 'Nested reply chains within comments or messages — a reply creates a sub-conversation attached to the parent message, keeping the main thread clean. Slack\'s thread model: click "Reply in thread" to open a side panel with the parent message and its replies. GitHub model: threaded replies inline under the parent comment with indentation. Threads can be collapsed/expanded. Show a reply count on the parent ("3 replies") with the latest reply preview.',
    implementation: 'Data model: each message has a parent_id (null for top-level). Replies share the parent\'s thread. Render threads either inline (indented, collapsible) or in a side panel (Slack-style). Parent message shows reply count badge + latest reply preview + "View thread" button. Thread panel: parent message pinned at top, replies below, input at bottom. Collapse threads by default after 3 replies with "Show N more replies." Sort replies chronologically within a thread.',
    a11y: 'Thread toggle button: aria-expanded="true/false" aria-label="3 replies, expand thread." Nested replies: maintain list semantics (role="list" within role="listitem"). Thread panel: role="complementary" or role="region" aria-label="Thread on: [parent message preview]." Collapse/expand: announce state change. Reply input: aria-label="Reply in thread." Ensure keyboard navigation between main feed and thread panel (focus management on open/close).',
    docsUrl: null,
  },

  // --- History ---
  {
    name: 'Version History',
    category: 'history',
    description: 'A chronological list of saved versions (snapshots) of a document or file, allowing users to browse, compare, and restore previous states. Each version shows: timestamp, author, optional title/description, and a preview. Google Docs auto-saves versions and groups them by editing session. Notion allows naming important versions. Figma saves version history per file with thumbnails. Always support restoring a previous version without destroying the current one (create a new version from the restore).',
    implementation: 'Store versions as immutable snapshots with metadata: {id, timestamp, author, title, content/diff, size}. Display in a sidebar or modal as a chronological list (newest first). Each entry: timestamp, author avatar, optional name, size delta (+2KB / -500B). Click a version to preview it (read-only). "Restore this version" creates a new version with the old content (never destructive). For CRDT-based editors: snapshot the Y.Doc state periodically. Limit: keep last 100 versions or 30 days.',
    a11y: 'Version list: role="list" aria-label="Version history." Each entry: role="listitem" with "Version from March 5 by Alice." Preview: role="document" aria-label="Preview of version from March 5." Restore button: aria-label="Restore version from March 5 — this creates a new version." Confirm dialog before restore: role="alertdialog." Announce restore result: "Version restored. A new version has been created."',
    docsUrl: null,
  },
  {
    name: 'Diff Visualization',
    category: 'history',
    description: 'Showing the differences between two versions of content — additions in green, deletions in red, unchanged content in default color. Two display modes: (1) unified diff — single column with additions and deletions interleaved; (2) side-by-side — two columns with aligned content. Used for code reviews (GitHub), document history (Google Docs "See changes"), and content comparison. Highlight changed words within lines for fine-grained diffs.',
    implementation: 'Use diff-match-patch (Google) or jsdiff for text diffing. For structured content (HTML, JSON): use specialized diffing (htmldiff.js, json-diff). Render: additions with green background, deletions with red background and strikethrough, unchanged as normal. Word-level diffs within lines for precision. Navigation: "Next change" / "Previous change" buttons to jump between diffs. Stats summary: "+15 added, -3 removed, 5 sections changed."',
    a11y: 'Do not rely on color alone for additions/deletions (WCAG 1.4.1). Use "+" and "-" prefixes, or text labels ("Added:" / "Removed:"). Screen reader: each diff block should have aria-label: "Added text: [content]" or "Removed text: [content]." Navigation buttons: aria-label="Next change" / "Previous change." Summary: aria-live="polite" with change count. Ensure red/green colors meet contrast requirements against the background.',
    docsUrl: null,
  },
  {
    name: 'Undo/Redo Stack',
    category: 'history',
    description: 'Application-level undo/redo supporting Ctrl+Z / Ctrl+Y (Cmd+Z / Cmd+Shift+Z on Mac) for reverting and re-applying user actions. Goes beyond text editor undo — covers drag-and-drop operations, setting changes, list reordering, delete operations, and multi-step workflows. Each undoable action is pushed onto a stack; undo pops the stack and applies the inverse operation. Redo re-applies undone actions. The stack is typically capped at 50-100 entries.',
    implementation: 'Maintain two stacks: undoStack and redoStack. On each user action: push {type, previousState, newState} onto undoStack, clear redoStack. On undo: pop from undoStack, apply previousState, push to redoStack. On redo: pop from redoStack, apply newState, push to undoStack. For complex operations (multi-item drag), group related actions into a single undo entry. Keyboard shortcuts: Ctrl+Z (undo), Ctrl+Y or Ctrl+Shift+Z (redo). Show undo/redo buttons in the toolbar with disabled state when stacks are empty.',
    a11y: 'Toolbar buttons: aria-label="Undo" / "Redo" with aria-disabled="true" when unavailable. Announce undo/redo actions via aria-live="polite": "Undone: deleted item restored" / "Redone: item deleted." Keyboard shortcuts must not conflict with browser or screen reader shortcuts — Ctrl+Z/Y are universally understood. For screen reader users, ensure the undo result is perceivable (focus returns to the restored element if applicable).',
    docsUrl: null,
  },
  {
    name: 'Audit Log',
    category: 'history',
    description: 'A detailed, tamper-resistant record of all user and system actions — who did what, when, and on which resource. Used for security compliance (SOC 2, GDPR), debugging, and accountability. Entries include: timestamp, actor (user or system), action (created, updated, deleted, exported, logged_in), target resource, IP address, and metadata (before/after values for changes). Admin-only access. Support filtering by date range, user, action type, and resource.',
    implementation: 'Append-only database table: {id, timestamp, actor_id, actor_type, action, resource_type, resource_id, metadata (JSONB), ip_address, user_agent}. Never delete or update audit log entries. Index on timestamp, actor_id, resource_id for query performance. UI: table view with filters (date range picker, user dropdown, action type checkboxes). Expandable rows showing metadata/diff details. Export to CSV for compliance reporting. Retain for 1-7 years based on compliance requirements.',
    a11y: 'Table: standard accessible data table with <thead>, <th scope="col">, <tbody>. Row expansion: aria-expanded="true/false" on the toggle button. Filters: standard form controls with labels. Date range: accessible date picker. Export button: aria-label="Export audit log to CSV." Pagination: standard pagination accessibility. Search: aria-label="Search audit log." Ensure timestamp format is unambiguous (ISO 8601 or locale-formatted with timezone).',
    docsUrl: null,
  },
  {
    name: 'Restore Point',
    category: 'history',
    description: 'A user-created named snapshot of the current state — a bookmark in the version history that can be returned to later. Unlike auto-saved versions, restore points are intentional checkpoints the user creates before risky changes ("Before major refactor," "Pre-launch version"). Prominently displayed in the version history timeline. Restoring creates a new version (non-destructive). Used in Figma (named versions), WordPress (revision save points), and database admin tools.',
    implementation: 'UI: "Create restore point" button with an input for the name/description. Store as a version entry with a flag is_restore_point: true and the user-provided name. Display restore points with a distinct visual treatment in the version history (star icon, bold name, different background color). Filter toggle to show only restore points. Restore action: create a new version from the restore point\'s content. Limit: 20 named restore points per document (auto-saved versions are separate).',
    a11y: 'Create button: aria-label="Create restore point." Name input: aria-label="Restore point name." In version history, restore points: visually distinct (icon + label) with aria-label including the custom name: "Restore point: Pre-launch version, created March 5 by Alice." Restore button: confirm dialog before action. Announce creation: "Restore point created: [name]" via aria-live="polite".',
    docsUrl: null,
  },

  // --- Sync ---
  {
    name: 'WebSocket Connection',
    category: 'sync',
    description: 'A persistent, full-duplex communication channel between client and server for real-time data exchange. The foundation for all real-time collaboration features — presence, live cursors, collaborative editing, and broadcast updates. Unlike HTTP polling, WebSocket maintains a single connection with minimal overhead per message. Use for high-frequency bidirectional communication. Libraries: Socket.IO (with fallbacks), ws (raw), Liveblocks, Supabase Realtime, Ably, Pusher.',
    implementation: 'Client: const ws = new WebSocket("wss://api.example.com/ws"). Handle events: onopen (authenticate, join rooms), onmessage (parse and dispatch), onclose (trigger reconnection), onerror (log and reconnect). Use a message protocol: {type: "cursor_move" | "typing" | "edit", payload: {...}}. Multiplexing: use channels/rooms to scope messages. Authentication: send JWT in the first message or via query parameter. Keep-alive: ping/pong every 30 seconds to detect dead connections.',
    a11y: 'WebSocket is a transport mechanism — it has no direct accessibility impact. However, the real-time updates it delivers must follow ARIA live region patterns: use aria-live="polite" for non-urgent updates (new messages, presence changes) and aria-live="assertive" for urgent ones (conflicts, errors). Throttle announcements to prevent overwhelming screen readers. Provide a way to pause live updates: "Pause real-time updates" toggle for users who find constant changes disorienting.',
    docsUrl: null,
  },
  {
    name: 'Reconnection Strategy',
    category: 'sync',
    description: 'Automatically reconnecting when a WebSocket connection drops due to network changes, server restarts, or mobile backgrounding. Use exponential backoff (1s, 2s, 4s, 8s, max 30s) with jitter (random 0-1s added) to prevent thundering herd when a server restarts and all clients reconnect simultaneously. Show a connection status banner ("Reconnecting...") during disconnection. On reconnect, sync missed events by replaying from the last known event ID.',
    implementation: 'On WebSocket close/error: start reconnection with exponential backoff. Delay formula: min(baseDelay * 2^attempt + random(0, 1000), maxDelay). Track connection state: connected, connecting, disconnected. Show a top-of-page banner during disconnection with a progress indicator. On reconnect: send the last received event ID to the server; server replays missed events. Reset backoff counter on successful connection. Max attempts: unlimited (keep trying). Use visibilitychange event to reconnect on tab focus.',
    a11y: 'Connection status banner: role="alert" (auto-announced by screen readers). States: "Connection lost — reconnecting..." / "Reconnected — you\'re back online." Use aria-live="assertive" for disconnection (urgent) and aria-live="polite" for reconnection (non-urgent). Ensure the banner does not push content down (use fixed positioning or overlay). Provide a "Retry now" button with aria-label for manual reconnection. Do not show a banner for brief disconnections (<2 seconds).',
    docsUrl: null,
  },
  {
    name: 'Offline Mode',
    category: 'sync',
    description: 'Enabling users to continue working when the network is unavailable, with automatic synchronization when connectivity returns. Queue mutations locally (IndexedDB, localStorage), mark the UI as "offline" (gray banner), and sync queued changes on reconnection. Conflict resolution is needed if another user modified the same data while this user was offline. CRDTs (Yjs, Automerge) handle this automatically. Essential for mobile apps and users with intermittent connectivity.',
    implementation: 'Detect offline/online status via navigator.onLine and online/offline events (supplement with periodic server pings for accuracy). When offline: queue mutations in IndexedDB with timestamps. Mark mutated items with a "pending sync" indicator (cloud icon with arrow). On reconnect: replay queued mutations in order. For CRDT-based data: merge automatically. For REST: use last-write-wins or conflict resolution dialog. Service Worker for offline-first web apps. Show a persistent banner: "You\'re offline — changes will sync when you\'re back."',
    a11y: 'Offline banner: role="status" aria-live="polite" with "You\'re offline — changes are saved locally." Pending sync indicators: aria-label="Pending sync" on affected items. On reconnect and sync: "Back online — 5 changes synced successfully" via aria-live="polite". If conflicts arise, use the Conflict Resolution Dialog pattern with full accessibility. Ensure all critical functionality works offline — do not disable controls, only indicate offline state.',
    docsUrl: null,
  },
  {
    name: 'Event Sourcing',
    category: 'sync',
    description: 'Storing every state change as an immutable event (append-only log) rather than overwriting the current state. The current state is derived by replaying all events. Enables: complete audit history, time-travel debugging, undo/redo, and conflict resolution by replaying events in order. Events are the source of truth — projections (read models) are derived. Used in collaborative tools where understanding the sequence of changes matters.',
    implementation: 'Events table: {id, stream_id, sequence, type, payload, timestamp, actor_id}. Append-only — never update or delete events. Current state: materialize by replaying events (or maintain a projection/snapshot for read performance). Snapshot periodically to avoid replaying thousands of events. Client: send commands to the server; server validates and appends events. Subscribe to event stream for real-time updates. Event types: "item.created", "item.updated", "item.moved", etc.',
    a11y: 'Event sourcing is a backend architecture pattern with no direct UI accessibility impact. Its benefits surface through other patterns: Version History (browse past states), Undo/Redo Stack (reverse events), Audit Log (event stream as the audit trail), and Activity Feed (events as feed entries). Ensure the UI patterns built on event sourcing follow their respective accessibility requirements.',
    docsUrl: null,
  },
  {
    name: 'Broadcast Updates',
    category: 'sync',
    description: 'Pushing changes made by one user to all other connected users in real-time — the content appears to update by itself. When Alice edits a task title, Bob sees it change instantly on his screen without refreshing. Show a brief highlight animation on updated content to draw attention ("flash yellow" pattern). For major changes (new items, deletions), use more prominent transitions. Throttle visual highlights to prevent flicker when many updates arrive simultaneously.',
    implementation: 'Server: on state change, broadcast the event to all connected clients in the room/channel (via WebSocket). Client: receive the event, update local state, and animate the changed element. Highlight: add a CSS class that applies a background-color transition (transparent → yellow → transparent over 1.5s). For list additions: slide-in animation. For deletions: fade-out with strikethrough. For reordering: smooth position transition with FLIP animation. Debounce rapid updates: batch highlights within 500ms.',
    a11y: 'Updated content: use aria-live="polite" regions for important changes (new items, status changes). Do not announce every field-level edit — too noisy. Highlight animations: respect prefers-reduced-motion by replacing animation with a static visual indicator (bold border). For screen readers, batch announcements: "3 items updated by Alice" rather than announcing each individually. Provide a way to review recent changes: link to the Activity Feed.',
    docsUrl: null,
  },

  // --- Permissions ---
  {
    name: 'Role-Based Access Control',
    category: 'permissions',
    description: 'Assigning users predefined roles (Owner, Admin, Editor, Commenter, Viewer) that determine what actions they can perform. Each role is a set of permissions — Viewer can read, Editor can read and write, Admin can manage members and settings. Roles are hierarchical: each level includes all permissions of lower levels. Show the user\'s role prominently in the UI and disable/hide controls they cannot use. Common roles in collaboration tools: Owner (full control + billing), Admin (manage members), Editor (modify content), Commenter (add comments only), Viewer (read-only).',
    implementation: 'Database: users_roles table with {user_id, resource_id, role}. Server: middleware checks role permissions on every API request. Client: fetch the current user\'s role on page load, store in context/state. Conditionally render UI elements: hide "Delete" for Viewers, show "Share" only for Admins+. Use disabled state (not hidden) for controls the user can see but not use — with a tooltip explaining why. Role hierarchy: Owner > Admin > Editor > Commenter > Viewer. Role assignment: Admin+ can invite users and set roles via a Share dialog.',
    a11y: 'Disabled controls: aria-disabled="true" with aria-describedby explaining the restriction: "You need Editor access to modify this item." Never hide interactive elements without indication — the user should understand what they could do with elevated permissions. Role display: include in the user menu or page header. Share dialog: accessible form with role selector (select/radio). Announce role changes via aria-live: "Alice\'s role changed to Editor."',
    docsUrl: null,
  },
  {
    name: 'Share Dialog',
    category: 'permissions',
    description: 'A modal for sharing a document, project, or resource with other users — inviting by email or link with configurable permissions. Shows the current sharing state: list of people with access and their roles, a link sharing toggle (anyone with the link can view/edit), and an invite form. Used in Google Docs, Notion, Figma, and Dropbox. The share dialog is one of the most critical UIs in collaboration tools — it must be clear, secure, and prevent accidental over-sharing.',
    implementation: 'Dialog with three sections: (1) Invite form — email input with autocomplete + role selector (Viewer/Editor/Admin) + "Invite" button. (2) People with access — list showing avatar, name/email, role dropdown, and "Remove" button. (3) Link sharing — toggle for "Anyone with the link" + permission level for link access. Copy link button. Batch invite: accept comma-separated emails. Send notification email on invite. Show pending invites with "Resend" option.',
    a11y: 'Dialog: role="dialog" aria-label="Share [document name]." Email input: aria-label="Invite by email" with autocomplete. Role selector: labeled select or radio group. People list: role="list" with each entry showing name, role, and actions. Remove button: aria-label="Remove Alice\'s access." Link toggle: aria-label="Allow anyone with the link to access" with aria-pressed. Copy button: announce "Link copied to clipboard" via aria-live. Focus management: trap focus in dialog, return focus on close.',
    docsUrl: null,
  },
  {
    name: 'Permission Indicator',
    category: 'permissions',
    description: 'Visual cues showing the current user\'s permission level and whether content is shared. A badge or icon in the document header indicating "View only," "Can edit," or "Can comment." For shared links: show a globe or link icon indicating public/restricted access. Change the editing toolbar state based on permissions — read-only users see a simplified toolbar without edit controls. Google Docs shows "Viewing" vs "Editing" vs "Suggesting" mode in the toolbar.',
    implementation: 'Render a badge in the page header/toolbar: {icon + text} matching the user\'s role. "View only" (eye icon, muted color), "Can edit" (pencil icon, accent color), "Can comment" (comment icon). For link-shared documents: globe icon for public, lock icon for restricted. Toolbar adaptation: hide formatting tools for Viewers, show suggestion mode for Commenters. Mode switcher for users with edit access: dropdown to switch between "Editing" and "Suggesting" modes.',
    a11y: 'Permission badge: aria-label="Your access level: Editor" or "Your access level: View only." Mode switcher: role="radiogroup" with aria-label="Editing mode" and options as radio buttons. Toolbar changes: ensure screen readers can discover available actions — use aria-label on the toolbar: "Document toolbar — View only mode, formatting controls unavailable." When switching modes, announce via aria-live: "Switched to Suggesting mode."',
    docsUrl: null,
  },
  {
    name: 'Guest Access',
    category: 'permissions',
    description: 'Allowing external users to access shared content without creating an account — via a shared link with optional password protection. Guests get a limited permission set (typically View or Comment only). Show a banner indicating guest status: "You\'re viewing as a guest. Sign in for full access." Track guest activity for the owner (who accessed via the link). Support expiring links (24 hours, 7 days, 30 days, never). Used in Google Docs, Notion, Figma, and most file sharing tools.',
    implementation: 'Generate a unique share token (UUID v4) stored with the resource. Link format: /doc/{id}?token={shareToken}. Server: validate token, grant limited session with guest permissions. Optional password: prompt on first access, verify against stored hash. Expiry: store expires_at timestamp, reject expired tokens. Guest banner: sticky top bar with sign-in CTA. Activity tracking: log guest access events (IP, timestamp, pages viewed). Revoke: owner can invalidate the token from the Share Dialog.',
    a11y: 'Guest banner: role="banner" with aria-label="Guest access — sign in for full access." Sign-in link: prominent, keyboard-accessible. Password prompt: accessible form with aria-label="Enter password to access [document name]." Error handling: "Incorrect password" or "This link has expired" with clear messaging. Ensure all guest-accessible content meets the same accessibility standards as authenticated content — no reduced a11y for guests.',
    docsUrl: null,
  },
  {
    name: 'Access Request',
    category: 'permissions',
    description: 'When a user navigates to a resource they don\'t have permission to view, showing a friendly "Request access" page instead of a generic 403 error. The user can send a message to the owner explaining why they need access. The owner receives a notification with "Approve" (choose role) or "Deny" options. Shows the document title and owner name so the user knows they have the right link. Used in Google Docs, Notion, Confluence, and most enterprise collaboration tools.',
    implementation: 'On 403 response: render an access request page showing the document title, owner avatar + name, and a form with: reason textarea (optional) + "Request access" button. Server: create an access_request record {requester_id, resource_id, message, status: pending}. Notify the owner via email and in-app notification. Owner sees a list of pending requests with "Approve" (role selector) and "Deny" buttons. On approval: create the user-role association and notify the requester.',
    a11y: 'Access request page: clear heading "You need access" with the document name. Form: aria-label on the reason input ("Why do you need access?"). Submit button: "Request access." Success state: "Access requested — the owner will be notified" with no further action needed. Owner notification: accessible notification with "Approve" and "Deny" buttons clearly labeled. On approval notification to requester: "Access granted to [document] — you can now view/edit."',
    docsUrl: null,
  },
];
