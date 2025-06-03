import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt5Compat.GraphicalEffects

Item {
    id: usernameField

    height: root.font.pointSize * 4.5
    width: parent.width / 2
    anchors.horizontalCenter: parent.horizontalCenter

    property var selectedUser: selectUser.currentIndex
    property alias user: username.text

    TextField {
        id: username
        text: config.ForceLastUser == "true" ? selectUser.currentText : null
        font.capitalization: Font.Capitalize
        anchors.centerIn: parent
        height: root.font.pointSize * 3
        width: parent.width
        placeholderText: config.TranslateUsernamePlaceholder || textConstants.userName
        selectByMouse: true
        horizontalAlignment: TextInput.AlignHCenter
        renderType: Text.QtRendering
        background: Rectangle {
            color: "transparent"
            border.color: "transparent"
            border.width: parent.activeFocus ? 2 : 1
            radius: config.RoundCorners || 0
        }
        Keys.onReturnPressed: loginButton.clicked()
        KeyNavigation.down: password
        z: 1

        states: [
            State {
                name: "focused"
                when: username.activeFocus
                PropertyChanges {
                    target: username.background
                    border.color: root.palette.highlight
                }
                PropertyChanges {
                    target: username
                    color: root.palette.highlight
                }
            }
        ]
    }

}
