import QtQuick
import qs.Commons
import qs.Ui

BarWidget {
    id: root

    property var timerService: shell
        ? shell.serviceFor("tarik.focus-timer")
        : null

    implicitWidth: vertical ? barSize : 120
    implicitHeight: vertical ? 120 : barSize

    Rectangle {
        id: track

        anchors.centerIn: parent

        width: vertical ? 6 : 105
        height: vertical ? 105 : 6

        radius: 3

        color: "#292929"

        Rectangle {
            id: progressFill

            radius: parent.radius
            color: "#f2c94c"

            width: vertical
                ? parent.width
                : parent.width * (
                    timerService
                    ? timerService.progress
                    : 1
                )

            height: vertical
                ? parent.height * (
                    timerService
                    ? timerService.progress
                    : 1
                )
                : parent.height

            anchors.left: vertical
                ? undefined
                : parent.left

            anchors.bottom: vertical
                ? parent.bottom
                : undefined

            Behavior on width {
                NumberAnimation {
                    duration: 250
                }
            }

            Behavior on height {
                NumberAnimation {
                    duration: 250
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            if (shell)
                shell.toggle("tarik.focus-timer")
        }
    }
}
