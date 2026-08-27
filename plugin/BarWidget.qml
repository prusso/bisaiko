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

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "󰍛"
    tooltipText: "Bisaikō · hover to preview · click to pin"

    onTooltipHoveredChanged: {
      root.invoke(tooltipHovered ? "enter" : "leave")
      if (tooltipHovered) tooltipDismissTimer.restart()
      else tooltipDismissTimer.stop()
    }

    onPressed: function(mouseButton) {
      if (mouseButton === Qt.LeftButton) root.invoke("toggle")
    }
  }
}
