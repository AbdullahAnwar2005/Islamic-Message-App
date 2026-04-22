# App Analytics Runbook

## Overview
The "App Analytics" system is designed to be **offline-first** and **privacy-centric**, using Drift for local queueing and Supabase Edge Functions for ingestion.

## Key Components
- **Local Queue**: `AnalyticsEventQueue` (Drift table). Stores events until flushed.
- **Service**: `AnalyticsService` (Singleton). Handles tracking, batching, and retries.
- **Ingestion**: Supabase Edge Function `ingest-events` (Public endpoint, `verify_jwt=false`).

## Verification Steps

### 1. Offline Queueing
**Goal**: Verify events are queued when offline and not lost.
1.  **Disable Internet** on your device/emulator.
2.  Open the app and perform actions:
    - Navigate to different screens.
    - Open a message.
    - Play audio.
3.  Navigate to the **Analytics Debug Screen** (add entry point or inspect logs/DB).
4.  **Confirm**: Queue size should be increasing (e.g., > 0).

### 2. Online Flush
**Goal**: Verify queued events are sent when online.
1.  **Enable Internet**.
2.  Wait 60 seconds (auto-flush) OR press "Flush Now" on the Debug Screen.
3.  **Confirm**:
    - Debug Screen status shows "Success".
    - Queue size drops to 0.

### 3. Data Validation (Supabase)
**Goal**: Verify events arrived in the backend.
1.  Access Supabase Dashboard > Table Editor > `analytics_events`.
2.  Filter by `occurred_at` (descending).
3.  **Confirm**:
    - New rows exist.
    - `client_event_id` matches your device log (if verified).
    - `payload` JSON contains expected properties.
    - `anon_user_id` is consistent for your session.

## Troubleshooting

### Flush Fails ("Network Error" / "Function Failed")
- **Cause**: No internet, or Edge Function is down/misconfigured.
- **Action**:
    - Check internet connection.
    - Check if `ingest-events` is deployed and `verify_jwt=false`.
    - Check `AnalyticsRemoteDatasource` error logs.
    - The system will **automatically retry** with exponential backoff.

### Events Not Appearing in Backend
- **Cause**: Flush reported success, but ingestion logic filtered them.
- **Action**:
    - Check Edge Function logs for "Validation Error" or "Dropped".
    - Verify `schema_version` matches backend expectation.
    - Verify `event_name` is in the whitelist.

### Queue Growing Excessively (> 5000)
- **Cause**: Persistent offline state or high-volume spam.
- **Action**:
    - The system automatically **prunes** the oldest events when queue > 5000 to protect storage.
    - Check `AnalyticsQueueDao.prune()` logic if suspected.
