# GCD Modernisation Review

There are a few GCD usages worth modernising.

## Completed

- [`NetworkInMemoryCache.swift`](Energy%20Stats%20Core/Network/NetworkInMemoryCache.swift)

  Converted `NetworkInMemoryCache` from a class protected by a serial dispatch queue to an `actor`. Cache reads, writes, and invalidations are now actor-isolated, so the cache is protected consistently rather than only serialising writes.

- [`NetworkThrottlerFacade.swift`](Energy%20Stats%20Core/Network/NetworkThrottlerFacade.swift)

  Converted `ThrottleManager` to an `actor` and replaced its dispatch queue with actor-isolated state. Throttle slots are now reserved before suspension, preventing concurrent callers from observing the same last-call time and proceeding together.

## Remaining highest priority

- [`NetworkInMemoryCache.swift:29`](Energy%20Stats%20Core/Network/NetworkInMemoryCache.swift:29)

  Replace the serial queue with an `actor`. The current queue only protects writes; reads such as line 46 access `cache` unsafely, so this is a concurrency bug rather than just dated syntax.

- [`NetworkThrottlerFacade.swift:164`](Energy%20Stats%20Core/Network/NetworkThrottlerFacade.swift:164)

  `ThrottleManager` is a good candidate for an `actor`. Its `lastCallTime` read and `didInvoke` write are separately synchronized, so concurrent calls can still race semantically.

## Straightforward syntax modernisations

- [`UserManager.swift:81`](Energy%20Stats/Login/UserManager.swift:81)

  Use `try? await Task.sleep(for: .seconds(1))` inside the existing `@MainActor` async method instead of `DispatchQueue.main.asyncAfter`.

- UI deferrals such as:

  - [`View+ReadSize.swift:16`](Energy%20Stats%20Core/Extensions/View+ReadSize.swift:16)
  - [`EqualWidthButtonStyle.swift:29`](Energy%20Stats/Extensions/EqualWidthButtonStyle.swift:29)
  - [`LoadedPowerFlowView.swift:93`](Energy%20Stats/Tabs/Power%20Flow/LoadedPowerFlowView.swift:93)
  - [`ErrorAlertView.swift:96`](Energy%20Stats/Error%20Alert/ErrorAlertView.swift:96)

  can generally become:

  ```swift
  Task { @MainActor in
      // state update
  }
  ```

  Keep the deferral where it is intentionally avoiding mutation during layout; in some cases the binding can be updated directly.

- The two preview-only `asyncAfter` calls:

  - [`PowerFlowView.swift:111`](Energy%20Stats/Tabs/Power%20Flow/PowerFlowView.swift:111)
  - [`SolarPowerView.swift:101`](Energy%20Stats/Tabs/Power%20Flow/Power%20Views/SolarPowerView.swift:101)

  could use `Task.sleep(for: .milliseconds(10))`. Since these are previews, they are low priority.

## Additional review

`.receive(on: DispatchQueue.main)` appears in view models already using `@MainActor`, notably `SettingsTabViewModel` and the Watch view model. These may be removable after confirming the publishers’ callbacks are isolated correctly.

## Overall recommendation

Modernise the cache and throttler for correctness first; the main-queue calls are mostly incremental cleanup.
