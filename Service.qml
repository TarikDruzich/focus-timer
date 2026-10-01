import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property string omarchyPath: ""
    property var shell: null
    property var manifest: null

    readonly property string home:
        Quickshell.env("HOME")

    readonly property string statsPath:
        home + "/.local/share/focus-timer/stats.json"

    readonly property string configPath:
        home + "/.local/share/focus-timer/config.json"

    readonly property string soundPath:
        home + "/.config/omarchy/plugins/tarik.focus-timer/assets/end.wav"

    property var statsData: ({
        "days": {}
    })

    property int statsRevision: 0

    property int workMinutes: 25
    property int shortBreakMinutes: 5
    property int longBreakMinutes: 15
    property int cyclesUntilLongBreak: 4

    property int completedCycles: 0

    property bool isBreak: false
    property bool isLongBreak: false
    property bool running: false
    property bool autoStart: false
    property bool soundEnabled: true

    property int remainingSeconds: workMinutes * 60

    readonly property int totalSeconds: {
        if (!isBreak)
            return workMinutes * 60

        if (isLongBreak)
            return longBreakMinutes * 60

        return shortBreakMinutes * 60
    }

    readonly property real progress: {
        if (totalSeconds <= 0)
            return 0

        return Math.max(
            0,
            Math.min(
                1,
                remainingSeconds / totalSeconds
            )
        )
    }

    readonly property string phaseName: {
        if (!isBreak)
            return "FOCUS"

        if (isLongBreak)
            return "LONG BREAK"

        return "SHORT BREAK"
    }

    function dateKey(dateObj) {
        var y = dateObj.getFullYear()
        var m = String(dateObj.getMonth() + 1).padStart(2, "0")
        var d = String(dateObj.getDate()).padStart(2, "0")

        return y + "-" + m + "-" + d
    }

    function todayKey() {
        return dateKey(new Date())
    }

    function ensureDay(key) {
        if (!statsData.days)
            statsData.days = {}

        if (!statsData.days[key]) {
            statsData.days[key] = {
                focusSessions: 0,
                focusSeconds: 0,
                breakSessions: 0
            }
        }
    }

    function saveStats() {
        statsFile.setText(
            JSON.stringify(statsData, null, 2) + "\n"
        )
    }

    function saveConfig() {
        configFile.setText(
            JSON.stringify({
                workMinutes: workMinutes,
                shortBreakMinutes: shortBreakMinutes,
                longBreakMinutes: longBreakMinutes,
                cyclesUntilLongBreak: cyclesUntilLongBreak,
                autoStart: autoStart,
                soundEnabled: soundEnabled
            }, null, 2) + "\n"
        )
    }

    function loadConfig(data) {
        if (!data)
            return

        if (data.workMinutes !== undefined)
            workMinutes = data.workMinutes

        if (data.shortBreakMinutes !== undefined)
            shortBreakMinutes = data.shortBreakMinutes

        if (data.longBreakMinutes !== undefined)
            longBreakMinutes = data.longBreakMinutes

        if (data.cyclesUntilLongBreak !== undefined)
            cyclesUntilLongBreak = data.cyclesUntilLongBreak

        if (data.autoStart !== undefined)
            autoStart = data.autoStart

        if (data.soundEnabled !== undefined)
            soundEnabled = data.soundEnabled

        remainingSeconds = totalSeconds
    }

    function playCompletionSound() {
        if (!soundEnabled)
            return

        Quickshell.execDetached([
            "pw-play",
            soundPath
        ])
    }

    function recordCompletedFocus() {
        var key = todayKey()

        ensureDay(key)

        statsData.days[key].focusSessions += 1
        statsData.days[key].focusSeconds += workMinutes * 60

        statsRevision++
        saveStats()
    }

    function recordCompletedBreak() {
        var key = todayKey()

        ensureDay(key)

        statsData.days[key].breakSessions += 1

        statsRevision++
        saveStats()
    }

    function statsForToday() {
        var key = todayKey()

        ensureDay(key)

        var revision = statsRevision

        return statsData.days[key]
    }

    function statsForMonth() {
        var revision = statsRevision

        var now = new Date()
        var y = now.getFullYear()
        var m = String(now.getMonth() + 1).padStart(2, "0")
        var prefix = y + "-" + m + "-"

        var result = {
            focusSessions: 0,
            focusSeconds: 0,
            breakSessions: 0
        }

        for (var key in statsData.days) {
            if (!key.startsWith(prefix))
                continue

            var day = statsData.days[key]

            result.focusSessions += day.focusSessions || 0
            result.focusSeconds += day.focusSeconds || 0
            result.breakSessions += day.breakSessions || 0
        }

        return result
    }

    function statsForYear() {
        var revision = statsRevision

        var y = new Date().getFullYear()
        var prefix = y + "-"

        var result = {
            focusSessions: 0,
            focusSeconds: 0,
            breakSessions: 0
        }

        for (var key in statsData.days) {
            if (!key.startsWith(prefix))
                continue

            var day = statsData.days[key]

            result.focusSessions += day.focusSessions || 0
            result.focusSeconds += day.focusSeconds || 0
            result.breakSessions += day.breakSessions || 0
        }

        return result
    }

    function statsAllTime() {
        var revision = statsRevision

        var result = {
            focusSessions: 0,
            focusSeconds: 0,
            breakSessions: 0
        }

        for (var key in statsData.days) {
            var day = statsData.days[key]

            result.focusSessions += day.focusSessions || 0
            result.focusSeconds += day.focusSeconds || 0
            result.breakSessions += day.breakSessions || 0
        }

        return result
    }

    function start() {
        running = true
    }

    function pause() {
        running = false
    }

    function toggle() {
        running = !running
    }

    function reset() {
        running = false
        remainingSeconds = totalSeconds
    }

    function skip() {
        finishCurrentSession(false)
    }

    function switchToFocus() {
        isBreak = false
        isLongBreak = false
        remainingSeconds = workMinutes * 60
    }

    function switchToBreak() {
        completedCycles++

        isBreak = true

        isLongBreak =
            completedCycles % cyclesUntilLongBreak === 0

        remainingSeconds = isLongBreak
            ? longBreakMinutes * 60
            : shortBreakMinutes * 60
    }

    function finishCurrentSession(countStats) {
        running = false

        if (countStats) {
            if (isBreak)
                recordCompletedBreak()
            else
                recordCompletedFocus()

            playCompletionSound()
        }

        if (isBreak)
            switchToFocus()
        else
            switchToBreak()

        if (autoStart)
            running = true
    }

    function applyDurations() {
        if (!running)
            remainingSeconds = totalSeconds

        saveConfig()
    }

    FileView {
        id: configFile

        path: root.configPath
        watchChanges: false
        atomicWrites: true
        printErrors: true

        onLoaded: {
            try {
                root.loadConfig(
                    JSON.parse(text())
                )
            } catch (error) {
                console.warn(
                    "Focus Timer: failed to parse config:",
                    error
                )
            }
        }

        onLoadFailed: function(error) {
            console.warn(
                "Focus Timer: config not found, creating defaults"
            )

            root.saveConfig()
        }
    }

    FileView {
        id: statsFile

        path: root.statsPath
        watchChanges: false
        atomicWrites: true
        printErrors: true

        onLoaded: {
            try {
                var parsed = JSON.parse(text())

                if (parsed && parsed.days)
                    root.statsData = parsed
                else
                    root.statsData = ({
                        "days": {}
                    })

                root.statsRevision++

            } catch (error) {
                console.warn(
                    "Focus Timer: failed to parse stats:",
                    error
                )

                root.statsData = ({
                    "days": {}
                })

                root.statsRevision++
            }
        }

        onLoadFailed: function(error) {
            console.warn(
                "Focus Timer: failed to load stats:",
                error
            )

            root.statsData = ({
                "days": {}
            })

            root.statsRevision++
            root.saveStats()
        }
    }

    Timer {
        interval: 1000
        repeat: true
        running: root.running

        onTriggered: {
            if (root.remainingSeconds > 0)
                root.remainingSeconds--

            if (root.remainingSeconds <= 0)
                root.finishCurrentSession(true)
        }
    }
}
