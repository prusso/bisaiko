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

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "󰍛"
    tooltipText: "Bisaikō · hover to preview · click to pin"

    onTooltipHoveredChanged: {
      root.invoke(tooltipHovered ? "enter" : "leave")
    }

    onPressed: function(mouseButton) {
      if (mouseButton === Qt.LeftButton) root.invoke("toggle")
    }
  }
}
