---
applyTo: '**'
---
Pictorial – Technical Specification (Spec‑Driven Development)

1. Project Overview

Name: PictorialCategory: Real‑time chat application with message‑embedded drawingsPrimary Inspiration: Nintendo DS PictoChatSecondary Inspiration: Modern chat platforms (servers, channels, voice)Architecture Choice: Single authoritative backend server (non‑federated)

Pictorial is a drawing‑first chat platform where users send messages composed of text with an optional hand‑drawn overlay. Drawings are not live nor collaborative; they are created locally and transmitted once, atomically, as part of a message.

2. Core Design Principles

PictoChat‑accurate behavior – Drawings are message‑scoped and not shared live

Atomic messages – Text and drawing are sent together as a single payload

Event‑driven backend – Each message is a single immutable event

Low latency – Minimal server processing on the hot path

Storage efficiency – Compact message representation, minimal DB growth

Simplicity first – Avoid unnecessary real‑time complexity

Scalable by design – Stateless real‑time layer

3. Functional Features

3.1 User Accounts

Account creation & authentication

Persistent identity

Online / offline presence

3.2 Servers & Channels

Servers (community containers)

Channels per server:

Text + drawing channels (default)

Voice channels

Role‑based permissions (bitmask‑based)

3.3 PictoMessages (Core Feature)

A PictoMessage is the fundamental unit of communication.

Characteristics:

Composed locally by the sender

Contains:

A text layer

An optional drawing layer (overlay)

No live drawing visibility while composing

Sent once, atomically

Immutable after sending (except deletion)

Other users only ever receive the final composed message.

3.4 Text Messaging

Real‑time delivery

Message deletion (soft delete)

No edit history (optional overwrite only)

Typing indicators (ephemeral, non‑persistent)

3.5 Drawing System (Message‑Scoped)

Drawing canvas attached to message composer

User draws before sending

Drawing is serialized and attached to the message

No shared canvas

No real‑time stroke streaming

3.6 Voice Communication

Voice channels using WebRTC

Peer‑to‑peer audio

Server handles signaling only

No audio persistence by default

4. Non‑Functional Requirements

Server processing latency < 50 ms per message

Support ≥ 10,000 concurrent WebSocket connections on a single node

Database growth must remain linear and bounded

Server restart must not corrupt message history

5. Client Architecture

5.1 Platforms

Web (primary)

Desktop via Tauri (future)

Mobile via React Native (future)

5.2 Client Technologies

React + TypeScript

HTML Canvas (raw Canvas or Konva.js)

WebSocket (binary frames)

WebRTC (voice)

5.3 Client Responsibilities

Message composition (text + drawing)

Drawing input capture

Drawing serialization & compression

Binary protocol encoding/decoding

WebRTC peer handling

6. Backend Architecture

6.1 Language & Runtime

Go (primary backend language)

Single‑binary deployment

6.2 Network Stack

net/http + WebSocket library (gorilla/websocket or nhooyr)

One goroutine per connection

Binary WebSocket frames only

6.3 Backend Responsibilities

Authentication & authorization

Channel membership validation

Message validation

Message persistence

Message fan‑out

Voice signaling relay

7. Data Encoding & Protocol

7.1 Encoding Format

MessagePack (binary)

Fixed schema per event type

7.2 Event Types

chat.message

chat.delete

presence.update

voice.signal

7.3 PictoMessage Payload Schema

Fields:

message_id

channel_id

sender_id

timestamp

text_content (UTF‑8 string)

drawing_blob (optional binary)

The drawing blob is transmitted only once per message.

8. Drawing Blob Format

8.1 Representation

Vector‑based strokes

Each stroke contains:

Color

Width

Point list

8.2 Compression Techniques

Quantized coordinates (uint16)

Delta‑encoded points

Style de‑duplication per stroke

Binary compression (zstd)

8.3 Storage Rules

Drawing blobs are stored only with their message

No per‑stroke or per‑point persistence

9. Real‑Time Message Flow

Client → WebSocket → Validate → Persist → Broadcast → Clients

No database reads on send

Single database write per message

Broadcast is channel‑scoped

10. Database Design

10.1 Database Engine

PostgreSQL

10.2 Stored Data

Users

Servers

Channels

Roles & permissions

PictoMessages (text + drawing blob)

10.3 Explicitly Not Stored

Live drawing data

Partial messages

Typing indicators

Presence state

Voice data

10.4 Optimization Strategies

One row per message

Compressed drawing blobs

Minimal indexing

Optional message archival

11. Performance & Scalability Notes

No live drawing dramatically reduces bandwidth

Message‑scoped drawings simplify consistency

Backend CPU usage dominated by I/O, not computation

Architecture supports horizontal scaling if needed

12. Out‑of‑Scope (Explicitly)

Federated servers

End‑to‑end encryption (initially)

Live collaborative drawing

Message revision history

