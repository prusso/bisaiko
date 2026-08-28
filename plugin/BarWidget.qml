import QtQuick
import Quickshell
import Quickshell.Io
import qs.Ui
import qs.Commons

BarWidget {
  id: root
  moduleName: "prusso.bisaiko"

  readonly property int defaultOpenDelayMs: 50
  readonly property int defaultPollMs: 80
  readonly property string defaultPopupPosition: "top-center"
  readonly property string defaultBarSection: "center"
  readonly property var positionOptions: [
    { label: "Upper left", value: "top-left" },
    { label: "Top middle", value: "top-center" },
    { label: "Upper right", value: "top-right" },
    { label: "Left middle", value: "middle-left" },
    { label: "Center", value: "center" },
    { label: "Right middle", value: "middle-right" },
    { label: "Lower left", value: "bottom-left" },
    { label: "Bottom middle", value: "bottom-center" },
    { label: "Lower right", value: "bottom-right" }
  ]

  property bool settingsOpen: false
  property string actualBarSection: ""

  readonly property string helperPath: decodeURIComponent(
    Qt.resolvedUrl("bisaiko").toString().replace(/^file:\/\//, "")
  )

  function invoke(action) {
    if (root.bar) root.bar.run("'" + helperPath.replace(/'/g, "'\\''") + "' " + action)
  }

  function invokeWithSettings(action) {
    root.invoke(action + " " + persisted.popupPosition + " " + persisted.pollMs)
  }

  function close() {
    settingsOpen = false
  }

  function refreshBarSection() {
    if (!barSectionProcess.running) barSectionProcess.running = true
  }

  function moveIcon(section) {
    settingsOpen = false
    if (section === root.actualBarSection || !root.bar) return
    actualBarSection = section
    root.bar.run("omarchy bar move " + root.moduleName + " --section " + section)
    // Confirm against the layout Omarchy actually wrote, in case the move
    // was rejected (e.g. the shell was not ready to answer).
    barSectionConfirmTimer.restart()
  }

  function resetDefaults() {
    persisted.popupPosition = defaultPopupPosition
    persisted.openDelayMs = defaultOpenDelayMs
    persisted.pollMs = defaultPollMs
    root.invoke("close")
    Qt.callLater(function() { root.moveIcon(defaultBarSection) })
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  Component.onDestruction: root.invoke("close")
  Component.onCompleted: {
    if (persisted.settingsVersion < 1) {
      if (persisted.pollMs === 78) persisted.pollMs = defaultPollMs
    }
    if (persisted.settingsVersion < 2 && persisted.popupPosition === "top-right")
      persisted.popupPosition = defaultPopupPosition
    persisted.settingsVersion = 2
    root.refreshBarSection()
  }

  PersistentProperties {
    id: persisted
    reloadableId: "prusso-bisaiko-settings"
    property string popupPosition: root.defaultPopupPosition
    property int openDelayMs: root.defaultOpenDelayMs
    property int pollMs: root.defaultPollMs
    property int settingsVersion: 0
  }

  Process {
    id: barSectionProcess
    running: false
    command: [root.helperPath, "bar-section", root.moduleName]

    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        var section = text.trim()
        if (["left", "center", "right"].indexOf(section) !== -1)
          root.actualBarSection = section
      }
    }
  }

  Timer {
    id: barSectionConfirmTimer
    interval: 600
    repeat: false
    onTriggered: root.refreshBarSection()
  }

  Timer {
    id: tooltipDismissTimer
    interval: 200
    repeat: false
    onTriggered: if (root.bar) root.bar.hideTooltip(button)
  }

  Timer {
    id: hoverOpenTimer
    interval: persisted.openDelayMs
    repeat: false
    onTriggered: root.invokeWithSettings("enter")
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "󰍛"
    tooltipText: "Bisaikō · hover to preview · click to pin"

    onTooltipHoveredChanged: {
      if (tooltipHovered) {
        if (!root.settingsOpen) hoverOpenTimer.restart()
        tooltipDismissTimer.restart()
      } else {
        hoverOpenTimer.stop()
        tooltipDismissTimer.stop()
        root.invoke("leave")
      }
    }

    onPressed: function(mouseButton) {
      if (mouseButton === Qt.LeftButton) {
        hoverOpenTimer.stop()
        root.settingsOpen = false
        root.invokeWithSettings("toggle")
      } else if (mouseButton === Qt.RightButton) {
        hoverOpenTimer.stop()
        tooltipDismissTimer.stop()
        root.invoke("close")
        root.refreshBarSection()
        root.settingsOpen = !root.settingsOpen
      }
    }
  }

  PopupCard {
    id: settingsPopup
    anchorItem: button
    bar: root.bar
    owner: root
    open: root.settingsOpen
    contentWidth: settingsPopup.fittedContentWidth(Style.space(390))
    contentHeight: settingsPopup.fittedContentHeight(settingsColumn.implicitHeight, Style.space(620))

    Column {
      id: settingsColumn
      anchors.fill: parent
      spacing: Style.space(10)

      Text {
        text: "Bisaikō settings"
        color: root.bar.foreground
        font.family: root.bar.fontFamily
        font.pixelSize: Style.font.subtitle
        font.bold: true
      }

      Text {
        text: "Window position"
        color: root.bar.foreground
        font.family: root.bar.fontFamily
        font.pixelSize: Style.font.body
        font.bold: true
      }

      Grid {
        id: positionGrid
        width: parent.width
        columns: 3
        spacing: Style.space(5)

        Repeater {
          model: root.positionOptions

          Button {
            required property var modelData
            width: (positionGrid.width - positionGrid.spacing * 2) / 3
            text: modelData.label
            selected: persisted.popupPosition === modelData.value
            foreground: root.bar.foreground
            fontSize: Style.font.caption
            horizontalPadding: Style.space(5)
            onClicked: {
              persisted.popupPosition = modelData.value
              root.invoke("close")
            }
          }
        }
      }

      Text {
        text: "Icon placement"
        color: root.bar.foreground
        font.family: root.bar.fontFamily
        font.pixelSize: Style.font.body
        font.bold: true
      }

      Row {
        width: parent.width
        spacing: Style.space(6)

        Button {
          width: (parent.width - parent.spacing * 2) / 3
          text: "Left side"
          selected: root.actualBarSection === "left"
          foreground: root.bar.foreground
          onClicked: root.moveIcon("left")
        }

        Button {
          width: (parent.width - parent.spacing * 2) / 3
          text: "Middle"
          selected: root.actualBarSection === "center"
          foreground: root.bar.foreground
          onClicked: root.moveIcon("center")
        }

        Button {
          width: (parent.width - parent.spacing * 2) / 3
          text: "Right side"
          selected: root.actualBarSection === "right"
          foreground: root.bar.foreground
          onClicked: root.moveIcon("right")
        }
      }

      Text {
        text: "Timing"
        color: root.bar.foreground
        font.family: root.bar.fontFamily
        font.pixelSize: Style.font.body
        font.bold: true
      }

      Row {
        width: parent.width
        spacing: Style.space(6)

        Text {
          width: parent.width - openLess.width - openValue.width - openMore.width - parent.spacing * 3
          anchors.verticalCenter: parent.verticalCenter
          text: "Opening delay"
          color: root.bar.foreground
          font.family: root.bar.fontFamily
          font.pixelSize: Style.font.bodySmall
        }
        Button {
          id: openLess
          text: "−"
          foreground: root.bar.foreground
          onClicked: persisted.openDelayMs = Math.max(0, persisted.openDelayMs - 5)
        }
        Text {
          id: openValue
          width: Style.space(58)
          anchors.verticalCenter: parent.verticalCenter
          horizontalAlignment: Text.AlignHCenter
          text: persisted.openDelayMs + " ms"
          color: root.bar.foreground
          font.family: root.bar.fontFamily
          font.pixelSize: Style.font.bodySmall
        }
        Button {
          id: openMore
          text: "+"
          foreground: root.bar.foreground
          onClicked: persisted.openDelayMs = Math.min(500, persisted.openDelayMs + 5)
        }
      }

      Row {
        width: parent.width
        spacing: Style.space(6)

        Text {
          width: parent.width - pollLess.width - pollValue.width - pollMore.width - parent.spacing * 3
          anchors.verticalCenter: parent.verticalCenter
          text: "Dismissal polling"
          color: root.bar.foreground
          font.family: root.bar.fontFamily
          font.pixelSize: Style.font.bodySmall
        }
        Button {
          id: pollLess
          text: "−"
          foreground: root.bar.foreground
          onClicked: persisted.pollMs = Math.max(10, persisted.pollMs - 1)
        }
        Text {
          id: pollValue
          width: Style.space(58)
          anchors.verticalCenter: parent.verticalCenter
          horizontalAlignment: Text.AlignHCenter
          text: persisted.pollMs + " ms"
          color: root.bar.foreground
          font.family: root.bar.fontFamily
          font.pixelSize: Style.font.bodySmall
        }
        Button {
          id: pollMore
          text: "+"
          foreground: root.bar.foreground
          onClicked: persisted.pollMs = Math.min(500, persisted.pollMs + 1)
        }
      }

      Button {
        width: parent.width
        text: "Reset Bisaikō defaults"
        foreground: root.bar.foreground
        bordered: true
        onClicked: root.resetDefaults()
      }
    }
  }
}
