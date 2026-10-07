# LeanPaws

LeanPaws helps owners of overweight dogs follow their vet's diet and exercise plan at home: logging meals, treats, walks and weigh-ins, and seeing how the day is tracking from the Home Screen, the Lock Screen and an evening check-in notification.

Built with SwiftUI, Core Data, WidgetKit and a Notification Content Extension for Advanced iOS Development, Assessment 3.

---

## Domain context

**Primary stakeholder:** an owner whose vet has identified their dog as overweight and recommended diet and exercise changes to carry out at home.

**The problem:** vets often give general advice such as "feed less and exercise more" with no daily numbers attached. At home, treats go uncounted, walks get shortened, and the owner can't tell whether the day is on plan. Weight-loss programmes commonly fail through owner non-compliance, and adherence fades as progress slows (Porsani et al., 2020; German, 2016). LeanPaws turns the vet's advice into daily targets the owner can track at the moment decisions are made, such as when a treat is about to be handed over or a walk is being cut short.

Full problem statement, evidence and design justification are in the Required Document (PDF).

---

## Features

The screens follow the owner's workflow, from the vet visit to daily logging:

| Screen | Purpose |
|---|---|
| **Set up the vet's plan** | Enter the dog and the vet's targets: current and goal weight, daily food allowance (treats included), daily walking goal, next vet check |
| **Today** | Food eaten against the allowance and minutes walked against the goal, with owner-friendly empty and over-allowance states |
| **Log food** | Record a meal or treat in grams |
| **Log a walk** | Record walk minutes |
| **Weight progress** | Record a weigh-in (one per day) and see the weight trend against the vet's goal (Swift Charts) |

---

## Architecture summary

```
Views (SwiftUI) → ViewModels (@Observable) → Use Cases → Repository protocols → Core Data (App Group)
```

- **Semantic domain models:** `Dog`, `WeightPlan`, `FoodEntry`, `WalkEntry`, `WeighIn`, `DailyProgress`, plain Swift structs with no Core Data or SwiftUI imports.
- **Use cases (6):** `AddDog`, `CreatePlan`, `LogFood`, `LogWalk`, `RecordWeighIn`, `CheckDailyProgress`. Each enforces domain business rules and has a typed error enum whose messages explain what went wrong and what the owner can do next.
- **Repositories:** `DogProfileRepository`, `ActivityLogRepository` and `WeighInRepository` are protocols. Core Data implementations are used by the app and both extensions; in-memory mock implementations are used by unit tests and SwiftUI previews.
- **Shared code:** the `Shared` folder (domain models, use cases, repositories, Core Data stack) is compiled into all three targets, so the app, widget and notification extension apply exactly the same business rules to the same data.
- **Composition root:** `AppContainer` builds the repositories and use cases once and hands them to the ViewModels. ViewModels call use cases only and never touch Core Data.

The full architecture diagram is Section 3 of the Required Document.

---

## Extensions and justification

### Widget Extension (Home Screen + Lock Screen)
**Scenario:** it's dinner time and someone asks whether the dog can have a treat. The owner glances at the Lock Screen and sees how much of today's food allowance is left and how many minutes have been walked, without unlocking the phone, at the exact moment the decision is made.

- Families: `systemSmall` (food and walking progress bars) and `accessoryRectangular` (food left and minutes walked).
- Reads today's progress from the shared App Group store through `CheckDailyProgressUseCase` (read only).
- The app reloads the widget (`WidgetCenter.shared.reloadAllTimelines()`) after every food, walk and plan save, and the notification extension reloads it after logging a walk. The timeline also refreshes just after midnight so each day starts fresh.

### Notification Content Extension (evening check-in)
**Scenario:** at 7pm the owner gets a check-in. Expanding it shows how the dog's day is actually going (food left and walking still to do) instead of a generic reminder. If they've just walked the dog, they type the minutes into **Log a walk** and the walk is saved without opening the app.

- Custom SwiftUI view for the `DAILY_CHECK_IN` category, reading live progress when the notification is opened.
- The text-input action saves through the same `LogWalkUseCase` as the app, so invalid entries (e.g. 0 minutes) show the same owner-friendly errors inside the notification.

---

## Database choice: Core Data

Core Data was chosen because the data is **private to one owner and one dog**, logging must **work offline** (often mid-walk), and the widget and notification need **fast local reads**. CloudKit would allow syncing and household sharing, but that adds sync complexity and requires a paid Apple Developer account. Household sharing is noted as future work.

**Schema:** `DogEntity` has a to-one `plan` (`WeightPlanEntity`) and to-many `foodEntries`, `walkEntries` and `weighIns`, all with cascade delete; each child has a required to-one `dog` relationship (nullify).

**Key domain query:** *this dog's entries between midnight and the start of the next day*:
```
dog.id == %@ AND eatenAt >= %@ AND eatenAt < %@
```
This is used by the Today screen, the widget and the notification, so each only loads one day of data.

---

## App Group identifier

```
group.com.brandon.leanpaws
```
Enabled on the **LeanPaws**, **LeanPawsWidgetExtension** and **LeanPawsNotification** targets. The Core Data store (`LeanPaws.sqlite`) lives in this shared container.

---

## Setup instructions

**Requirements:** Xcode 26.4 or later, iOS 26.4 Simulator (developed on iPhone 17e).

1. Clone the repository and open `LeanPaws.xcodeproj`.
2. For each of the three targets, open **Signing & Capabilities** and select your own Team (a free Personal Team works in the Simulator). If needed, change the App Group to one available to your team and update `PersistenceController.appGroupID` to match.
3. Select the **LeanPaws** scheme and an iPhone Simulator, then **Run** (⌘R).
4. A new install starts on **Set up the vet's plan**. Enter a dog and plan to begin.

**Optional: start with example data.** In **Product › Scheme › Edit Scheme › Run › Arguments**, tick `-seedSampleData`. Delete the app from the Simulator and run again to load an example dog ("Max") with a plan, meals and a walk for today.

**Trying the extensions:**
- **Widget:** long-press the Home Screen › Edit › Add Widget › LeanPaws. For the Lock Screen widget, enable Features › Face ID › Enrolled, lock (⌘L), wake (⇧⌘H), long-press › Customize › Lock Screen.
- **Check-in notification:** allow notifications when prompted on the Today screen. Tap **Send Test in 5 Seconds** (Debug builds only), go to the Home Screen (⇧⌘H), then long-press the notification and use **Log a walk**.

**Running tests:** select the LeanPaws scheme and press ⌘U.

---

## Testing

- **33 unit tests** (Swift Testing) cover every use case's happy paths, boundary conditions (e.g. eating exactly the allowance is not "over", a 1-minute walk is accepted, one weigh-in per day) and domain error cases, using **mock repositories** rather than the Core Data stack.
- Extensions and Core Data integration were tested manually end-to-end in the Simulator, including on a freshly erased Simulator: logging in the app updates the widget, and logging a walk from the check-in notification updates both the app and the widget.

---

## Version control

- **Branching:** GitHub Flow. Each feature or extension was built on its own branch (`feature/domain-layer`, `feature/core-data`, `feature/widget`, `feature/screens`, `feature/notification`, `chore/release-prep`) and merged into `main` through a pull request only after it built and the tests passed, so `main` always holds stable, working code.
- **Commits:** Conventional Commits (`feat:`, `fix:`, `test:`, `docs:`, `chore:`).

---

## Known limitations and future work

- One owner and one dog per device; household sharing would need CloudKit.
- One editable plan per dog; a revision history to revisit earlier plans was designed but left out for time.
- The check-in is fixed at 7pm. iOS notifications must be scheduled ahead, so the app can't fire a reminder the moment walking falls behind. Letting owners choose the time, or skipping reminders on days the target is met, is future work.

---

## Attribution

- **Apple documentation and sample code:** WidgetKit (*Creating a widget extension*, *Keeping a widget up to date*), User Notifications (*Declaring your actionable notification types*, *Customizing the appearance of notifications*), Core Data (*Setting up a Core Data stack*), Xcode (*Configuring app groups*), Swift Charts and Swift Testing documentation.
- **AI assistance:** Claude (Anthropic) was used for planning, checking the design against the assessment specification, Xcode and Git setup guidance, code scaffolds that I completed, and larger code drafts (Core Data repositories, screens, widget, notification extension) that I reviewed, tested and adjusted, as well as a first draft of the architecture diagram. Full details are in Section 4 of the Required Document.
- **Third-party libraries:** none. Only Apple frameworks are used.
