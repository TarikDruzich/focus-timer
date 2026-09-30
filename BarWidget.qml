import QtQuick
import qs.Commons
import qs.Ui

BarWidget {
    id: root

    property var timerService: shell
        ? shell.serviceFor("tarik.focus-timer")
        : null

    implicitWidth: vertical
        ? barSize
        : contentRow.implicitWidth + 16

    implicitHeight: vertical
        ? contentRow.implicitHeight
        : barSize

    function formatTime(seconds) {
        var minutes = Math.floor(seconds / 60)
        var secs = seconds % 60

        return minutes.toString().padStart(2, "0")
            + ":"
            + secs.toString().padStart(2, "0")
    }

    Row {
        id: contentRow

        anchors.centerIn: parent
        spacing: 6

        Text {
            text: timerService && timerService.isBreak
                ? "☕"
                : "◉"

            color: Color.foreground
        }

        Text {
            text: timerService
                ? root.formatTime(timerService.remainingSeconds)
                : "--:--"

            color: Color.foreground
        }
    }

    MouseArea {
        anchors.fill: parent

        onClicked: {
            if (timerService)
                timerService.toggle()
        }

        onDoubleClicked: {
            if (timerService)
                timerService.reset()
        }
    }
}
