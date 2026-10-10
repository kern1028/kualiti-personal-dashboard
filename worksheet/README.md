# Kualiti

[English](README.md) | [Bahasa Indonesia](README.id.md)

Kualiti - Your Cozy Personal Dashboard.

Kualiti is a small Android app I made for myself, and now for anyone who wants a calm place to keep notes, tasks, timers, and links. Everything stays on your phone. No account, no server, no ads.

## What is inside

- **Notes.** Simple notepad with heading, bold, italic, underline, links, and bullet, numbered, or lettered lists. Search, pin, and tags. It saves as you type.
- **Tasks.** Due date and time, three priority levels, reminders, repeating tasks, and a history of what you finished. Filter by All, Today, Upcoming, Completed, or Repeating, and sort by due date, priority, or A-Z.
- **Timers.** Normal timers, stopwatch with laps, and focus and rest sessions for gaming, reading, and studying, each with recommended times you can change. There is also a 20-20-20 reminder to rest your eyes.
- **Quick links.** Save your favorite sites with their own icons.
- **Themes.** Default, Dark Mode, Aesthetic Brown, Vintage, Retro Windows XP, and Pixel.
- **Languages.** Indonesian and English. The app never mixes the two.

## Download

1. Open the [Releases page](https://github.com/kern1028/kualiti-personal-dashboard/releases).
2. Download the latest `Kualiti-vX.X.X.apk`.
3. Open the file on your phone. If Android asks, allow installs from your browser or file manager for this one time.
4. Open Kualiti, enter your name, pick a language and a theme, and you are done.

You need Android 8.0 or newer. You do not need to install anything else.

## Good to know

- **Notifications.** Task reminders and timers need notification permission. Kualiti asks only when it is needed, and you can say "later".
- **Sound and vibration.** Kualiti follows your phone. In vibrate mode it only vibrates. In normal mode it plays a short sound, which you can turn off in Settings so it only vibrates.
- **Battery saver.** Some phones (Xiaomi, Oppo, Vivo, and a few others) close apps in the background. If a reminder does not show up, set Kualiti to "no restrictions" in your battery settings.
- **Timers and recent apps.** Timers keep running when you press Home. If you swipe the app away from recent apps, timers stop. Task reminders still work.
- **Quick link icons.** Icons are downloaded once when you add a link, so that step needs internet. After that they work offline.

## Backup

Your data lives only on your phone. In Settings, use **Export to device** to save a file named `kualiti[yourname]backup.json`. To restore, use **Import backup** and pick that file. Backup to Google Drive is planned and shows as "Coming soon" for now.

## Build from source

You need Flutter installed.

```
git clone https://github.com/kern1028/kualiti-personal-dashboard.git
cd kualiti-personal-dashboard
flutter pub get
flutter run
```

To build an APK:

```
flutter build apk --release
```

The file ends up in `build/app/outputs/flutter-apk/`.

## Planned

- Backup to Google Drive
- More repeat patterns
- Subtasks
- Home screen widget

## Author

Made by Kern. Bug reports and ideas are welcome in the Issues tab.
