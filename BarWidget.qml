import QtQuick
import qs.Commons
import qs.Ui

BarWidget {
    id: root

    implicitWidth: vertical ? barSize : label.implicitWidth + 12
    implicitHeight: vertical ? label.implicitHeight : barSize

    Text {
        id: label
        anchors.centerIn: parent

        text: "FT"
        color: Color.foreground
    }
}
