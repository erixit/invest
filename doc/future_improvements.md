# Future Improvements

## Messaging Boundaries

- The `messaging` service currently performs Yahoo calls and writes shared files directly.
- In the final architecture, messaging-related work should go through clearer microservice boundaries instead of direct service/file access.
- The Yahoo response capture feature highlighted this code smell, because Debian needed a direct shared-volume mount for `messaging` just to expose those files on the host.

## Consult UI Closed Positions

- In `consultui`, the actual portfolio has both a list view and a graph view.
- Closed gains and closed losses currently only have graph views.
- Needed improvement: also provide list views for closed gains and closed losses.

## Slow Refresh Of Open Positions

- Refreshing the list of open positions takes a very long time, and the intermediate results are untrustworthy while calculation is still running.
- Proposed fix: replace the refresh button with an explicit background job: `Recalculate positions`.
