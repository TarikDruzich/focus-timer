import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Commons
import qs.Ui

BarWidget {
    id: root

    property var timerService: shell
        ? shell.serviceFor("tarik.focus-timer")
        : null

    property bool opened: false
    property int activeTab: 0

    readonly property color yellow: "#f2c94c"
    readonly property color background: "#111111"
    readonly property color dark: "#1b1b1b"
    readonly property color muted: "#777777"

    implicitWidth: vertical ? barSize : 125
    implicitHeight: vertical ? 125 : barSize

    function open() {
        opened = true
    }

    function close() {
        opened = false
    }

    function toggle() {
        opened = !opened
    }

    function formatTime(seconds) {
        var mins = Math.floor(seconds / 60)
        var secs = seconds % 60

        return mins.toString().padStart(2, "0")
            + ":"
            + secs.toString().padStart(2, "0")
    }

    Item {
        id: clickTarget
        anchors.fill: parent

        Row {
            id: segmentedProgress

            anchors.centerIn: parent
            spacing: 4

            property int segments: 12

            property int activeSegments: root.timerService
                ? Math.floor((1-root.timerService.progress) * segments)
                : 0

            Repeater {
                model: segmentedProgress.segments

                Rectangle {
                    width: 6
                    height: 14
                    radius: 1

                    color: index < segmentedProgress.activeSegments
                        ? root.yellow
                        : "transparent"

                    border.width: 1

                    border.color: index < segmentedProgress.activeSegments
                        ? root.yellow
                        : "#6b5a1f"
                }
            }
        }

        MouseArea {
            anchors.fill: parent

            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked:
                root.toggle()
        }
    }

    KeyboardPanel {
        id: panel

        anchorItem: clickTarget
        owner: root
        bar: root.bar

        open: root.opened

        focusTarget: keyCatcher

        contentWidth:
            panel.fittedContentWidth(
                Style.space(330)
            )

        contentHeight:
            panel.fittedContentHeight(
                root.activeTab === 0
                ? Style.space(225)
                : root.activeTab === 1
                  ? Style.space(300)
                  : Style.space(315)
            )

        PanelKeyCatcher {
            id: keyCatcher

            anchors.fill: parent

            onCloseRequested:
                root.close()

            Rectangle {
                anchors.fill: parent

                color: root.background
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Style.space(18)
                spacing: Style.space(16)

                RowLayout {
                    Layout.fillWidth: true

                    Item {
                        Layout.fillWidth: true
                    }

                    Text {
                        text: "POMODORO"

                        color:
                            root.activeTab === 0
                            ? root.yellow
                            : root.muted

                        font.family:
                            root.bar
                            ? root.bar.fontFamily
                            : "monospace"

                        font.pixelSize: 12
                        font.bold: true

                        MouseArea {
                            anchors.fill: parent

                            cursorShape:
                                Qt.PointingHandCursor

                            onClicked:
                                root.activeTab = 0
                        }
                    }

                    Text {
                        text: "STATS"

                        color:
                            root.activeTab === 1
                            ? root.yellow
                            : root.muted

                        font.family:
                            root.bar
                            ? root.bar.fontFamily
                            : "monospace"

                        font.pixelSize: 12
                        font.bold: true

                        MouseArea {
                            anchors.fill: parent

                            cursorShape:
                                Qt.PointingHandCursor

                            onClicked:
                                root.activeTab = 1
                        }
                    }

                    Text {
                        text: "CONFIG"

                        color:
                            root.activeTab === 2
                            ? root.yellow
                            : root.muted

                        font.family:
                            root.bar
                            ? root.bar.fontFamily
                            : "monospace"

                        font.pixelSize: 12
                        font.bold: true

                        MouseArea {
                            anchors.fill: parent

                            cursorShape:
                                Qt.PointingHandCursor

                            onClicked:
                                root.activeTab = 2
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1

                    color: root.yellow
                    opacity: 0.35
                }

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Column {
                        visible:
                            root.activeTab === 0

                        anchors.centerIn: parent

                        spacing: Style.space(10)

                        Text {
                            anchors.horizontalCenter:
                                parent.horizontalCenter

                            text:
                                root.timerService
                                ? root.formatTime(
                                    root.timerService.remainingSeconds
                                  )
                                : "--:--"

                            color: root.yellow

                            font.family:
                                root.bar
                                ? root.bar.fontFamily
                                : "monospace"

                            font.pixelSize: 42
                            font.bold: true
                        }

                        Text {
                            anchors.horizontalCenter:
                                parent.horizontalCenter

                            text:
                                root.timerService
                                ? root.timerService.phaseName
                                : "FOCUS"

                            color: root.yellow

                            font.family:
                                root.bar
                                ? root.bar.fontFamily
                                : "monospace"

                            font.pixelSize: 11
                            font.bold: true

                            font.letterSpacing: 2
                        }

                        Row {
                            anchors.horizontalCenter:
                                parent.horizontalCenter

                            spacing: Style.space(10)

                            TimerButton {
                                label: "↻"

                                onPressed: {
                                    if (root.timerService)
                                        root.timerService.reset()
                                }
                            }

                            TimerButton {
                                label:
                                    root.timerService &&
                                    root.timerService.running
                                    ? "Ⅱ"
                                    : "▶"

                                onPressed: {
                                    if (root.timerService)
                                        root.timerService.toggle()
                                }
                            }

                            TimerButton {
                                label: "»"

                                onPressed: {
                                    if (root.timerService)
                                        root.timerService.skip()
                                }
                            }
                        }
                    }

                    Column {
                        visible:
                            root.activeTab === 1

                        anchors.fill: parent
                        spacing: Style.space(12)

                        property int revision:
                            root.timerService
                            ? root.timerService.statsRevision
                            : 0

                        StatsRow {
                            title: "TODAY"

                            sessions:
                                root.timerService
                                ? root.timerService.statsForToday().focusSessions
                                : 0

                            seconds:
                                root.timerService
                                ? root.timerService.statsForToday().focusSeconds
                                : 0
                        }

                        StatsRow {
                            title: "THIS MONTH"

                            sessions:
                                root.timerService
                                ? root.timerService.statsForMonth().focusSessions
                                : 0

                            seconds:
                                root.timerService
                                ? root.timerService.statsForMonth().focusSeconds
                                : 0
                        }

                        StatsRow {
                            title: "THIS YEAR"

                            sessions:
                                root.timerService
                                ? root.timerService.statsForYear().focusSessions
                                : 0

                            seconds:
                                root.timerService
                                ? root.timerService.statsForYear().focusSeconds
                                : 0
                        }

                        StatsRow {
                            title: "ALL TIME"

                            sessions:
                                root.timerService
                                ? root.timerService.statsAllTime().focusSessions
                                : 0

                            seconds:
                                root.timerService
                                ? root.timerService.statsAllTime().focusSeconds
                                : 0
                        }
                    }

                    Column {
                        visible:
                            root.activeTab === 2

                        anchors.fill: parent

                        spacing: Style.space(13)

                        ConfigRow {
                            rowLabel: "Focus time"

                            choices: [
                                15, 20, 25,
                                30, 45, 50, 60
                            ]

                            currentValue:
                                root.timerService
                                ? root.timerService.workMinutes
                                : 25

                            onSelected: function(v) {
                                if (!root.timerService)
                                    return

                                root.timerService.workMinutes = v
                                root.timerService.applyDurations()
                            }
                        }

                        ConfigRow {
                            rowLabel: "Short break"

                            choices: [
                                5, 10, 15
                            ]

                            currentValue:
                                root.timerService
                                ? root.timerService.shortBreakMinutes
                                : 5

                            onSelected: function(v) {
                                if (!root.timerService)
                                    return

                                root.timerService.shortBreakMinutes = v
                                root.timerService.applyDurations()
                            }
                        }

                        ConfigRow {
                            rowLabel: "Long break"

                            choices: [
                                10, 15, 20, 30
                            ]

                            currentValue:
                                root.timerService
                                ? root.timerService.longBreakMinutes
                                : 15

                            onSelected: function(v) {
                                if (!root.timerService)
                                    return

                                root.timerService.longBreakMinutes = v
                                root.timerService.applyDurations()
                            }
                        }

                        ConfigRow {
                            rowLabel: "Long break after"

                            choices: [
                                2, 3, 4, 5, 6
                            ]

                            currentValue:
                                root.timerService
                                ? root.timerService.cyclesUntilLongBreak
                                : 4

                            onSelected: function(v) {
                                if (root.timerService)
                                    root.timerService.cyclesUntilLongBreak = v
                            }
                        }

                        RowLayout {
                            width: parent.width

                            Text {
                                text:
                                    "Auto-start next phase"

                                color: root.yellow

                                font.family:
                                    root.bar
                                    ? root.bar.fontFamily
                                    : "monospace"

                                font.pixelSize: 12
                            }

                            Item {
                                Layout.fillWidth: true
                            }

                            Rectangle {
                                width: 48
                                height: 24

                                radius: 4

                                color:
                                    root.timerService &&
                                    root.timerService.autoStart
                                    ? root.yellow
                                    : root.dark

                                border.color:
                                    root.yellow

                                Text {
                                    anchors.centerIn:
                                        parent

                                    text:
                                        root.timerService &&
                                        root.timerService.autoStart
                                        ? "ON"
                                        : "OFF"

                                    color:
                                        root.timerService &&
                                        root.timerService.autoStart
                                        ? "#111111"
                                        : root.yellow

                                    font.bold: true
                                    font.pixelSize: 10
                                }

                                MouseArea {
                                    anchors.fill: parent

                                    cursorShape:
                                        Qt.PointingHandCursor

                                    onClicked: {
                                        if (root.timerService)
                                            root.timerService.autoStart =
                                                !root.timerService.autoStart
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    component TimerButton: Rectangle {
        id: button

        property string label: ""

        signal pressed()

        width: 46
        height: 34

        radius: 4

        color:
            mouse.containsMouse
            ? root.yellow
            : root.dark

        border.color:
            root.yellow

        border.width: 1

        Text {
            anchors.centerIn: parent

            text: button.label

            color:
                mouse.containsMouse
                ? "#111111"
                : root.yellow

            font.pixelSize: 17
            font.bold: true
        }

        MouseArea {
            id: mouse

            anchors.fill: parent

            hoverEnabled: true

            cursorShape:
                Qt.PointingHandCursor

            onClicked:
                button.pressed()
        }
    }

    component StatsRow: Rectangle {
        id: statsRow

        property string title: ""
        property int sessions: 0
        property int seconds: 0

        width: parent ? parent.width : 280
        height: 48

        color: root.dark
        radius: 4

        border.color: "#3d3518"
        border.width: 1

        function formatDuration(totalSeconds) {
            var hours = Math.floor(totalSeconds / 3600)
            var minutes = Math.floor(
                (totalSeconds % 3600) / 60
            )

            if (hours > 0)
                return hours + "h " + minutes + "m"

            return minutes + "m"
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12

            Column {
                spacing: 2

                Text {
                    text: statsRow.title

                    color: root.yellow
                    font.pixelSize: 10
                    font.bold: true

                    font.family:
                        root.bar
                        ? root.bar.fontFamily
                        : "monospace"
                }

                Text {
                    text:
                        statsRow.sessions
                        + (statsRow.sessions === 1
                           ? " session"
                           : " sessions")

                    color: "#d0d0d0"
                    font.pixelSize: 11

                    font.family:
                        root.bar
                        ? root.bar.fontFamily
                        : "monospace"
                }
            }

            Item {
                Layout.fillWidth: true
            }

            Text {
                text:
                    statsRow.formatDuration(
                        statsRow.seconds
                    )

                color: root.yellow
                font.pixelSize: 14
                font.bold: true

                font.family:
                    root.bar
                    ? root.bar.fontFamily
                    : "monospace"
            }
        }
    }

    component ConfigRow: RowLayout {
        id: configRow

        property string rowLabel: ""
        property var choices: []
        property int currentValue: 0

        signal selected(int value)

        width: parent.width

        Text {
            text: configRow.rowLabel

            color: root.yellow

            font.family:
                root.bar
                ? root.bar.fontFamily
                : "monospace"

            font.pixelSize: 12
        }

        Item {
            Layout.fillWidth: true
        }

        ComboBox {
            model:
                configRow.choices

            implicitWidth: 90
            implicitHeight: 30

            currentIndex:
                Math.max(
                    0,
                    configRow.choices.indexOf(
                        configRow.currentValue
                    )
                )

            onActivated: {
                configRow.selected(
                    Number(currentText)
                )
            }
        }
    }
}


