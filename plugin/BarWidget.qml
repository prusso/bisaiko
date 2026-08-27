import QtQuick
import qs.Ui

BarWidget {
  id: root
  moduleName: "prusso.bisaiko"

  function openBtop() {
    if (root.bar)
      root.bar.run("omarchy-launch-floating-terminal-with-presentation btop")
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "󰍛"
    tooltipText: "Bisaikō: open btop"

    onPressed: function(mouseButton) {
      if (mouseButton === Qt.LeftButton) root.openBtop()
    }
  }
}
