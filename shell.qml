// shell.qml
// Workspace Switcher + Clock for Hyprland

import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

ShellRoot {
    PanelWindow {
        id: dock
        color: "transparent"

        anchors {
            top: true
            left: true
            right: true
        }

        margins {
            top: 8
            left: 8
            right: 8
        }

        implicitHeight: 42

        Rectangle {
            anchors.fill: parent
            color: "#1d1e22" // A dark, slightly transparent background
            radius: 12
            
            // --- Workspace Switcher ---
            RowLayout {
                id: workspaceRow
                spacing: 6

                anchors {
                    left: parent.left
                    leftMargin: 12
                    verticalCenter: parent.verticalCenter
                }

                Repeater {
                    // This is the list of all available workspaces provided by Hyprland
                    model: Hyprland.workspaces

                    delegate: Rectangle {
                        id: wsButton
                        // The modelData here is a HyprlandWorkspace object for each workspace
                        
                        // Use property bindings for clean, reactive styling
                        readonly property bool isFocused: modelData.focused
                        readonly property bool isActive: modelData.active
                        
                        // NOTE: We check lastIpcObject for window count as it's the only
                        // way shown in the provided docs. This might not update instantly.
                        // We check for the object's existence first to be safe.
                        readonly property bool hasWindows: modelData.lastIpcObject && modelData.lastIpcObject.windows > 0

                        implicitWidth: 34
                        implicitHeight: 34
                        radius: 8
                        
                        // --- State-based Coloring ---
                        // 1. Focused: Bright and prominent
                        // 2. Active (on another monitor): Visible but less prominent
                        // 3. Has Windows: A subtle fill to show it's occupied
                        // 4. Empty: Just a faint border
                        color: {
                            if (isFocused) return "#89b4fa"; // Blue
                            if (isActive) return "#45475a"; // Muted Gray
                            if (hasWindows) return "#313244"; // Darker Gray
                            return "transparent";
                        }
                        
                        border.width: hasWindows || isFocused || isActive ? 0 : 1
                        border.color: "#45475a"

                        // Smooth color transitions
                        Behavior on color { ColorAnimation { duration: 200 } }

                        Text {
                            text: modelData.name
                            anchors.centerIn: parent
                            font.family: "FiraCode Nerd Font"
                            font.bold: true
                            font.pixelSize: 14
                            
                            // Change text color for better contrast on the focused button
                            color: wsButton.isFocused ? "#1e1e2c" : "#cdd6f4"
                            
                            Behavior on color { ColorAnimation { duration: 200 } }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                // Use the activate() function from the HyprlandWorkspace object
                                modelData.activate()
                            }
                        }
                    }
                }
            }


            // --- Clock ---
            Row {
                id: clockRow
                spacing: 2

                anchors {
                    right: parent.right
                    rightMargin: 16
                    verticalCenter: parent.verticalCenter
                }

                Text {
                    id: hourText
                    font.family: "FiraCode Nerd Font"
                    font.pixelSize: 16
                    color: "#ff7070"
                }
                Text { text: ":"; font.family: "FiraCode Nerd Font"; font.pixelSize: 16; color: "white" }
                Text {
                    id: minuteText
                    font.family: "FiraCode Nerd Font"
                    font.pixelSize: 16
                    color: "#92e492"
                }
                Text { text: ":"; font.family: "FiraCode Nerd Font"; font.pixelSize: 16; color: "white" }
                Text {
                    id: secondText
                    font.family: "FiraCode Nerd Font"
                    font.pixelSize: 16
                    color: "#92e4e4"
                }

                Timer {
                    interval: 1000
                    running: true
                    repeat: true
                    onTriggered: {
                        var now = new Date();
                        hourText.text = now.getHours().toString().padStart(2, '0');
                        minuteText.text = now.getMinutes().toString().padStart(2, '0');
                        secondText.text = now.getSeconds().toString().padStart(2, '0');
                    }
                    Component.onCompleted: triggered()
                }
            }
        }
    }
}