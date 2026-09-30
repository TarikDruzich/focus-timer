import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Commons
import qs.Ui

Item {
    id: root

    property string omarchyPath: ""
    property var shell: null
    property var manifest: null
    property var service: null

    property bool panelOpen: false
    property int activeTab: 0

    width: 290
    height: activeTab === 0 ? 230 : 360

    function open(payloadJson) {
        panelOpen = true
        visible = true
    }

    function close() {
        panelOpen = false
        visible = false
    }

    function formatTime(seconds) {
        var minutes = Math.floor(seconds / 60)
        var secs = seconds % 60

        return minutes.toString().padStart(2, "0")
            + ":"
            + secs.toString().padStart(2, "0")
    }

    visible: panelOpen

    Rectangle {
        anchors.fill: parent

        radius: 12
        color: "#151515"
        border.color: "#f2c94c"
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 14

            RowLayout {
                Layout.fillWidth: true

                Button {
                    text: "Pomodoro"

                    onClicked:
                        root.activeTab = 0
                }

                Button {
                    text: "Config"

                    onClicked:
                        root.activeTab = 1
                }

                Item {
                    Layout.fillWidth: true
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                Column {
                    visible: root.activeTab === 0

                    anchors.centerIn: parent
                    spacing: 12

                    Text {
                        anchors.horizontalCenter:
                            parent.horizontalCenter

                        text: service
                            ? root.formatTime(
                                service.remainingSeconds
                              )
                            : "--:--"

                        color: "#f2c94c"

                        font.family: "monospace"
                        font.pixelSize: 34
                        font.bold: true
                    }

                    Text {
                        anchors.horizontalCenter:
                            parent.horizontalCenter

                        text: service
                            ? service.phaseName
                            : "FOCUS"

                        color: "#f2c94c"

                        font.family: "monospace"
                        font.pixelSize: 11
                        font.letterSpacing: 3
                    }

                    Row {
                        anchors.horizontalCenter:
                            parent.horizontalCenter

                        spacing: 10

                        Button {
                            text: "↻"

                            onClicked: {
                                if (service)
                                    service.reset()
                            }
                        }

                        Button {
                            text: service &&
                                  service.running
                                ? "Ⅱ"
                                : "▶"

                            onClicked: {
                                if (service)
                                    service.toggle()
                            }
                        }

                        Button {
                            text: "»"

                            onClicked: {
                                if (service)
                                    service.skip()
                            }
                        }
                    }
                }

                Column {
                    visible: root.activeTab === 1

                    anchors.fill: parent
                    spacing: 15

                    ConfigRow {
                        label: "Focus time"
                        value: service
                            ? service.workMinutes
                            : 25

                        options: [
                            15,
                            20,
                            25,
                            30,
                            45,
                            50,
                            60
                        ]

                        onValueSelected: function(v) {
                            service.workMinutes = v
                            service.applyDurations()
                        }
                    }

                    ConfigRow {
                        label: "Short break"
                        value: service
                            ? service.shortBreakMinutes
                            : 5

                        options: [
                            5,
                            10,
                            15
                        ]

                        onValueSelected: function(v) {
                            service.shortBreakMinutes = v
                            service.applyDurations()
                        }
                    }

                    ConfigRow {
                        label: "Long break"
                        value: service
                            ? service.longBreakMinutes
                            : 15

                        options: [
                            10,
                            15,
                            20,
                            30
                        ]

                        onValueSelected: function(v) {
                            service.longBreakMinutes = v
                            service.applyDurations()
                        }
                    }

                    ConfigRow {
                        label: "Cycles"
                        value: service
                            ? service.cyclesUntilLongBreak
                            : 4

                        options: [
                            2,
                            3,
                            4,
                            5,
                            6
                        ]

                        onValueSelected: function(v) {
                            service.cyclesUntilLongBreak = v
                        }
                    }

                    RowLayout {
                        width: parent.width

                        Text {
                            text:
                                "Auto-start next phase"

                            color: "#f2c94c"
                            font.family: "monospace"
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        CheckBox {
                            checked: service
                                ? service.autoStart
                                : false

                            onToggled: {
                                if (service)
                                    service.autoStart =
                                        checked
                            }
                        }
                    }
                }
            }
        }
    }

    component ConfigRow: RowLayout {
        id: configRow

        property string label: ""
        property int value: 0
        property var options: []

        signal valueSelected(int value)

        width: parent.width

        Text {
            text: configRow.label

            color: "#f2c94c"
            font.family: "monospace"
        }

        Item {
            Layout.fillWidth: true
        }

        ComboBox {
            model: configRow.options

            currentIndex:
                Math.max(
                    0,
                    configRow.options.indexOf(
                        configRow.value
                    )
                )

            onActivated: {
                configRow.valueSelected(
                    configRow.options[
                        currentIndex
                    ]
                )
            }
        }
    }
}
