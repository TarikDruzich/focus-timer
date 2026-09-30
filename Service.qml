import QtQuick

Item {
    id: root

    property string omarchyPath: ""
    property var shell: null
    property var manifest: null

    property int workDuration: 25 * 60
    property int breakDuration: 5 * 60

    property bool isBreak: false
    property bool running: false

    property int remainingSeconds: isBreak
        ? breakDuration
        : workDuration

    readonly property int totalSeconds: isBreak
        ? breakDuration
        : workDuration

    readonly property real progress: totalSeconds > 0
        ? 1.0 - (remainingSeconds / totalSeconds)
        : 0

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

        remainingSeconds = isBreak
            ? breakDuration
            : workDuration
    }

    function switchMode() {
        running = false
        isBreak = !isBreak

        remainingSeconds = isBreak
            ? breakDuration
            : workDuration
    }

    function finishCurrentSession() {
        isBreak = !isBreak

        remainingSeconds = isBreak
            ? breakDuration
            : workDuration

        running = false
    }

    Timer {
        interval: 1000
        repeat: true
        running: root.running

        onTriggered: {
            if (root.remainingSeconds > 0) {
                root.remainingSeconds--
            }

            if (root.remainingSeconds <= 0) {
                root.finishCurrentSession()
            }
        }
    }
}
