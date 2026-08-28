import QtQuick
import qs.Ui

BarWidget {
  id: root
  moduleName: "prusso.bisaiko"

  readonly property string helperPath: decodeURIComponent(
    Qt.resolvedUrl("bisaiko").toString().replace(/^file:\/\//, "")
  )

  function invoke(action) {
    if (root.bar) root.bar.run("'" + helperPath.replace(/'/g, "'\\''") + "' " + action)
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  Component.onDestruction: root.invoke("close")

  Timer {
    id: tooltipDismissTimer
    interval: 200
    repeat: false
    onTriggered: if (root.bar) root.bar.hideTooltip(button)
  }

  Timer {
    id: hoverOpenTimer
    interval: 50
    repeat: false
    onTriggered: root.invoke("enter")
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "󰍛"
    tooltipText: "Bisaikō · hover to preview · click to pin"

    onTooltipHoveredChanged: {
      if (tooltipHovered) {
        hoverOpenTimer.restart()
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
        root.invoke("toggle")
      }
    }
  }
}
