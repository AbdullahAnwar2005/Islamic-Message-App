# Analytics Event Mapping

## Common Properties
All events include:
- `client_event_id` (UUID)
- `occurred_at` (ISO UTC)
- `anon_user_id` (UUID, persistent)
- `session_id` (UUID, per launch)
- `event_name`
- `platform`, `app_version`

## Screen Events

### Global
| Event Name | Trigger | Properties |
| :--- | :--- | :--- |
| `screen_view` | Navigation to a screen | `screen_name`, `route` |

### Reader (Message Viewer)
| Event Name | Trigger | Properties |
| :--- | :--- | :--- |
| `message_open` | Opening a message/chapter | `message_id`, `section_id`, `language_code` |
| `message_read_end`| Exiting a message | `message_id`, `section_id`, `language_code`, `time_spent_ms`, `completion_ratio` (0..1), `completed` (bool) |

### Audio Player
| Event Name | Trigger | Properties |
| :--- | :--- | :--- |
| `audio_play_start`| Playback starts | `message_id`, `language_code` |
| `audio_play_end` | Playback stops/completes | `message_id`, `language_code`, `time_listened_ms`, `completion_ratio`, `completed` |
| `audio_error` | Playback error | `message_id`, `error_code` |

### Contact Da'iah Funnel
| Event Name | Trigger | Properties |
| :--- | :--- | :--- |
| `contact_view` | Viewing Contact Us form | - |
| `contact_submit_success` | Successfully submitting form | - |

### Shahada Funnel
| Event Name | Trigger | Properties |
| :--- | :--- | :--- |
| `shahada_view` | Viewing Intro Step | - |
| `shahada_step_complete`| Completing a step (Start, Next, Confirm) | `step_index` (0=Intro, 1=Learn, 2=Readiness) |
| `shahada_finish` | Viewing Confirmed Step | - |
