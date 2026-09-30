import QtQuick

Item {
    id: root

    property string omarchyPath: ""
    property var shell: null
    property var manifest: null

    property int workMinutes: 25
    property int shortBreakMinutes: 5
    property int longBreakMinutes: 15
    property int cyclesUntilLongBreak: 4

    property int completedCycles: 0

    property bool isBreak: false
    property bool isLongBreak: false
    property bool running: false
    property bool autoStart: false

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

        return remainingSeconds / totalSeconds
    }

    readonly property string phaseName: {
        if (!isBreak)
            return "FOCUS"

        if (isLongBreak)
            return "LONG BREAK"

        return "SHORT BREAK"
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
        finishCurrentSession()
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

    function finishCurrentSession() {
        running = false

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
    }

    Timer {
        interval: 1000
        repeat: true
        running: root.running

        onTriggered: {
            if (root.remainingSeconds > 0)
                root.remainingSeconds--

            if (root.remainingSeconds <= 0)
                root.finishCurrentSession()
        }
    }
}
