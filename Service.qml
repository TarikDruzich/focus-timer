import QtQuick

Item {
    id: root

    property string omarchyPath: ""
    property var shell: null
    property var manifest: null

    property int workDuration: 25 * 60
    property int breakDuration: 5 * 60
    property int remainingSeconds: workDuration

    property bool running: false
    property bool isBreak: false
}
