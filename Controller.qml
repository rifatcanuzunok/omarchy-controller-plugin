import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui
import "I18n.js" as I18n

Panel {
  id: root
  moduleName: "rifatcanuzunok.controller"
  ipcTarget: "rifatcanuzunok.controller"
  manageIpc: true

  property bool connected: false
  property string devName: "Xbox Controller"
  property string connType: "none"
  property int battery: -1
  property string batteryText: "—"
  property string address: ""

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight
  width: implicitWidth
  height: implicitHeight

  readonly property string tooltip: {
    if (!connected) return I18n.t("tooltip_disconnected")
    var connStr = connType === "bluetooth" ? I18n.t("type_bt") : I18n.t("type_wired")
    return devName + "\n" + I18n.t("tooltip_status") + " (" + connStr + ")\n" + I18n.t("label_battery") + ": " + batteryText
  }

  function helperPath() {
    return decodeURIComponent(Qt.resolvedUrl("controller-status").toString().replace(/^file:\/\//, ""))
  }

  function refresh() {
    if (!statusProc.running) statusProc.running = true
  }

  function connectController() {
    Quickshell.execDetached([root.helperPath(), "--connect"])
    retryTimer.restart()
  }

  function disconnectController() {
    Quickshell.execDetached([root.helperPath(), "--disconnect"])
    retryTimer.restart()
  }

  function handleStatusJson(rawText) {
    var text = String(rawText || "").trim()
    if (text === "") return
    try {
      var data = JSON.parse(text)
      root.connected = !!data.connected
      root.devName = data.name || I18n.t("title")
      root.connType = data.type || "none"
      root.battery = data.battery !== undefined ? data.battery : -1
      root.batteryText = data.battery_text || "—"
      root.address = data.address || ""
    } catch (e) {
      // ignore parse errors
    }
  }

  onOpenedChanged: {
    if (opened) root.refresh()
  }

  Process {
    id: statusProc
    command: [root.helperPath(), "--json"]
    running: false
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.handleStatusJson(text)
    }
  }

  Timer {
    id: pollTimer
    interval: 5000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.refresh()
  }

  Timer {
    id: retryTimer
    interval: 1800
    running: false
    repeat: false
    onTriggered: root.refresh()
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "󰊴"
    tooltipText: root.tooltip
    onPressed: function(b) {
      if (b === Qt.RightButton && !root.connected) {
        root.connectController()
      } else {
        root.toggle()
      }
    }
  }

  KeyboardPanel {
    id: panel
    anchorItem: button
    owner: root
    bar: root.bar
    open: root.opened
    focusTarget: keyCatcher
    contentWidth: panel.fittedContentWidth(Style.space(340))
    contentHeight: panel.fittedContentHeight(column.implicitHeight)

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }

      Column {
        id: column
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        spacing: Style.space(14)

        // ---------- Hero: Gamepad icon · Title/Status · Percentage ----------
        Item {
          width: parent.width
          implicitHeight: Math.max(heroIcon.implicitHeight, heroLabels.implicitHeight, heroPercent.implicitHeight)

          Text {
            id: heroIcon
            textFormat: Text.PlainText
            text: "󰊴"
            color: root.connected ? (root.bar ? root.bar.foreground : Color.foreground) : Qt.darker(root.bar ? root.bar.foreground : Color.foreground, 1.6)
            font.family: root.bar ? root.bar.fontFamily : Style.font.family
            font.pixelSize: Style.font.display
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
          }

          Column {
            id: heroLabels
            anchors.left: heroIcon.right
            anchors.leftMargin: Style.space(14)
            anchors.right: heroPercent.left
            anchors.rightMargin: Style.space(10)
            anchors.verticalCenter: parent.verticalCenter
            spacing: Style.space(2)

            Text {
              text: I18n.t("title")
              color: root.bar ? root.bar.foreground : Color.foreground
              font.family: root.bar ? root.bar.fontFamily : Style.font.family
              font.pixelSize: Style.font.title
              font.bold: true
              elide: Text.ElideRight
              width: parent.width
            }

            Text {
              id: heroStatus
              textFormat: Text.PlainText
              text: root.connected ? (root.connType === "bluetooth" ? I18n.t("status_bt") : I18n.t("status_wired")) : I18n.t("status_disconnected")
              color: root.connected ? Color.accent : Color.muted
              font.family: root.bar ? root.bar.fontFamily : Style.font.family
              font.pixelSize: Style.font.caption
              font.bold: true
              font.letterSpacing: 1.1
              elide: Text.ElideRight
              width: parent.width
            }
          }

          Text {
            id: heroPercent
            textFormat: Text.PlainText
            text: root.connected ? root.batteryText : "—"
            color: root.connected && root.battery <= 20 && root.battery >= 0 ? Color.urgent : (root.bar ? root.bar.foreground : Color.foreground)
            font.family: root.bar ? root.bar.fontFamily : Style.font.family
            font.pixelSize: Style.font.title
            font.bold: true
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
          }
        }

        // ---------- Battery Gauge ----------
        Item {
          visible: root.connected && root.battery >= 0
          width: parent.width
          implicitHeight: Style.space(6)

          Rectangle {
            id: barTrack
            anchors.fill: parent
            radius: height / 2
            color: Qt.rgba(root.bar ? root.bar.foreground.r : 1, root.bar ? root.bar.foreground.g : 1, root.bar ? root.bar.foreground.b : 1, 0.12)
          }

          Rectangle {
            id: barFill
            anchors.left: barTrack.left
            anchors.verticalCenter: barTrack.verticalCenter
            height: barTrack.height
            radius: barTrack.radius
            color: root.battery <= 20 ? Color.urgent : (root.bar ? root.bar.foreground : Color.foreground)
            width: Math.max(barTrack.height, barTrack.width * Math.max(0, Math.min(1, root.battery / 100.0)))

            Behavior on width { NumberAnimation { duration: 320; easing.type: Easing.OutCubic } }
          }
        }

        // ---------- Details Divider ----------
        PanelSeparator {
          foreground: root.bar ? root.bar.foreground : Color.foreground
        }

        // ---------- Info Details ----------
        Column {
          width: parent.width
          spacing: Style.space(8)

          InfoPair {
            label: I18n.t("label_model")
            value: root.devName
          }

          InfoPair {
            label: I18n.t("label_connection")
            value: root.connType === "bluetooth" ? I18n.t("type_bt") : (root.connType === "wired" ? I18n.t("type_wired") : I18n.t("type_none"))
          }

          InfoPair {
            label: I18n.t("label_battery")
            value: root.connected ? root.batteryText : "—"
          }
        }

        // ---------- Actions Divider ----------
        PanelSeparator {
          foreground: root.bar ? root.bar.foreground : Color.foreground
        }

        // ---------- Action Buttons ----------
        Row {
          width: parent.width
          spacing: Style.space(8)

          Button {
            width: (parent.width - parent.spacing) / 2
            text: root.connected && root.connType === "bluetooth" ? I18n.t("btn_disconnect") : I18n.t("btn_connect")
            iconText: root.connected && root.connType === "bluetooth" ? "󰂲" : "󰂱"
            fontSize: Style.font.bodySmall
            foreground: root.bar ? root.bar.foreground : Color.foreground
            fontFamily: root.bar ? root.bar.fontFamily : Style.font.family
            bordered: true
            active: !root.connected
            onClicked: {
              if (root.connected && root.connType === "bluetooth") {
                root.disconnectController()
              } else {
                root.connectController()
              }
            }
          }

          Button {
            width: (parent.width - parent.spacing) / 2
            text: I18n.t("btn_refresh")
            iconText: "\uf021"
            fontSize: Style.font.bodySmall
            foreground: root.bar ? root.bar.foreground : Color.foreground
            fontFamily: root.bar ? root.bar.fontFamily : Style.font.family
            bordered: true
            onClicked: root.refresh()
          }
        }
      }
    }
  }

  component InfoPair: Row {
    property string label: ""
    property string value: ""

    width: parent.width
    spacing: Style.space(8)

    Text {
      textFormat: Text.PlainText
      color: root.bar ? root.bar.foreground : Color.foreground
      opacity: 0.6
      font.family: root.bar ? root.bar.fontFamily : Style.font.family
      font.pixelSize: Style.font.bodySmall
      text: label
    }

    Item {
      width: Math.max(0, parent.width - parent.children[0].implicitWidth - parent.children[2].implicitWidth - parent.spacing * 2)
      height: 1
    }

    Text {
      textFormat: Text.PlainText
      color: root.bar ? root.bar.foreground : Color.foreground
      font.family: root.bar ? root.bar.fontFamily : Style.font.family
      font.pixelSize: Style.font.bodySmall
      font.bold: true
      elide: Text.ElideRight
      text: value
    }
  }
}
