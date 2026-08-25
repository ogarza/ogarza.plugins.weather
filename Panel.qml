import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Ui
import "Model.js" as Model

Panel {
  id: root
  moduleName: Model.pluginId
  ipcTarget: Model.pluginId
  manageIpc: false

  property var anchorItem: null
  property var hostWidget: null
  readonly property var barIdentity: hostWidget || root

  readonly property var fx: bar && bar.shell && typeof bar.shell.serviceFor === "function"
    ? bar.shell.serviceFor(Model.pluginId) : null

  readonly property var modeList: Model.modes
  readonly property var liveModeList: Model.modesForPanel(false)
  readonly property var manualModeList: Model.modesForPanel(true)
  readonly property var exclusiveList: Model.exclusivePresets
  readonly property var mixShaderList: Model.customLayerEntries()
  readonly property var resolutionList: Model.resolutionLevels
  readonly property var detailList: Model.detailLevels
  readonly property var settingsFields: Model.fieldsForSettings()
  readonly property var settingsLodRows: Model.settingsLodRows()
  property int lodRowIndex: 0
  property bool settingsOpen: false
  readonly property bool exclusiveMode: !!(fx && fx.mode === "exclusive") && !root.settingsOpen
  readonly property bool customMode: !!(fx && fx.mode === "custom") && !root.settingsOpen
  readonly property string tweakPreset: {
    if (!fx) return ""
    if (fx.mode === "follow") return fx.weatherPreset || ""
    if (fx.mode === "exclusive") return fx.exclusivePreset
    return fx.mode
  }
  readonly property var tweakFields: fx ? Model.fieldsForPanel(tweakPreset, fx.customShaderA, fx.customShaderB, fx.customShaderC, fx.params) : []
  readonly property var layerFieldsA: fx ? Model.fieldsForVisualLayer(tweakPreset, 0, fx.customShaderA, fx.customShaderB, fx.customShaderC, fx.params) : []
  readonly property var layerFieldsB: fx ? Model.fieldsForVisualLayer(tweakPreset, 1, fx.customShaderA, fx.customShaderB, fx.customShaderC, fx.params) : []
  readonly property var layerFieldsC: fx ? Model.fieldsForVisualLayer(tweakPreset, 2, fx.customShaderA, fx.customShaderB, fx.customShaderC, fx.params) : []
  readonly property int paramCols: root.settingsOpen ? 1
    : (root.layerFieldsA.length > 0 ? 1 : 0)
    + (root.layerFieldsB.length > 0 ? 1 : 0)
    + (root.layerFieldsC.length > 0 ? 1 : 0)
  readonly property string layerHeadingA: Model.layerHeading(tweakPreset, 0, fx ? fx.customShaderA : "", fx ? fx.customShaderB : "", fx ? fx.customShaderC : "")
  readonly property string layerHeadingB: Model.layerHeading(tweakPreset, 1, fx ? fx.customShaderA : "", fx ? fx.customShaderB : "", fx ? fx.customShaderC : "")
  readonly property string layerHeadingC: Model.layerHeading(tweakPreset, 2, fx ? fx.customShaderA : "", fx ? fx.customShaderB : "", fx ? fx.customShaderC : "")
  readonly property bool showTweaks: !root.settingsOpen && root.tweakFields.length > 0
  readonly property int tweakRowCount: root.tweakFields.length
  readonly property string tweakHeading: {
    if (!root.showTweaks) return "Parameters"
    var night = fx ? fx.nightFactor : 0
    return Model.labelForPreset(root.tweakPreset, night)
  }
  readonly property string tweakBlurb: {
    var night = fx ? fx.nightFactor : 0
    var note = ""
    if (fx && fx.mode === "exclusive")
      note = "The overlay stays on only when local weather matches this type. This panel previews it until you close."
    var desc = ""
    if (fx && fx.mode === "follow" && !root.tweakPreset)
      desc = "Waiting for the current forecast."
    else if (!root.tweakPreset)
      desc = Model.descriptionForPreset(fx ? fx.mode : "none", night)
    else
      desc = Model.descriptionForPreset(root.tweakPreset, night)
    if (note && desc) return note + "\n\n" + desc
    return note || desc
  }

  property string focusSection: "modes"
  property int modeIndex: 0
  property int trackIndex: 0
  property int layerAIndex: 0
  property int layerBIndex: 0
  property int layerCIndex: 0
  property int tweakIndex: 0
  property int resolutionIndex: 2
  property int detailIndex: 2
  property bool cursorActive: false

  readonly property color foreground: bar ? bar.foreground : Color.foreground
  readonly property color dim: Qt.darker(foreground, 1.55)
  readonly property string fontFamily: bar ? bar.fontFamily : Style.font.family
  readonly property bool headerHasCursor: cursorActive && focusSection === "header"
  readonly property color iconColor: fx && fx.active ? foreground : dim
  readonly property string toggleHint: fx && fx.active ? "Turn overlay off" : "Turn overlay on"
  readonly property string heroMeta: fx ? fx.statusText : "Post processing"

  function syncPanelOpen() {
    if (root.fx) root.fx.panelOpen = root.opened === true
  }

  function open() {
    if (root.fx && typeof root.fx.scanShaders === "function") root.fx.scanShaders()
    root.syncCursorToMode()
    root.controller.show()
  }

  onOpenedChanged: root.syncPanelOpen()
  onFxChanged: root.syncPanelOpen()

  function switchPanel(direction) {
    if (root.bar && typeof root.bar.switchPanelFrom === "function")
      return root.bar.switchPanelFrom(root.barIdentity, direction)
    return false
  }

  function setHeaderCursor() {
    root.cursorActive = true
    root.focusSection = "header"
  }

  function syncCursorToMode() {
    if (!root.fx) return
    for (var i = 0; i < root.modeList.length; i++) {
      if (root.modeList[i].value === root.fx.mode) {
        root.modeIndex = i
        break
      }
    }
    for (var j = 0; j < root.exclusiveList.length; j++) {
      if (root.exclusiveList[j].value === root.fx.exclusivePreset) {
        root.trackIndex = j
        break
      }
    }
    for (var a = 0; a < root.mixShaderList.length; a++) {
      if (root.mixShaderList[a].value === root.fx.customShaderA) {
        root.layerAIndex = a
        break
      }
    }
    for (var b = 0; b < root.mixShaderList.length; b++) {
      if (root.mixShaderList[b].value === root.fx.customShaderB) {
        root.layerBIndex = b
        break
      }
    }
    for (var c = 0; c < root.mixShaderList.length; c++) {
      if (root.mixShaderList[c].value === root.fx.customShaderC) {
        root.layerCIndex = c
        break
      }
    }
    root.resolutionIndex = Model.indexOfResolution(root.fx.resolution)
    root.detailIndex = Model.indexOfDetail(root.fx.detail)
    if (root.fx.mode === "none")
      root.settingsOpen = true
  }

  function clampCursor() {
    if (root.focusSection === "track" && !root.exclusiveMode)
      root.focusSection = "modes"
    if ((root.focusSection === "layerA" || root.focusSection === "layerB" || root.focusSection === "layerC") && !root.customMode)
      root.focusSection = "modes"
    if ((root.focusSection === "tweaks" || root.focusSection === "reset") && !root.showTweaks)
      root.focusSection = root.customMode ? "layerC" : (root.exclusiveMode ? "track" : "modes")
    if ((root.focusSection === "resolution" || root.focusSection === "lod" || root.focusSection === "detail") && !root.settingsOpen)
      root.focusSection = "modes"
    if (root.modeIndex < 0) root.modeIndex = 0
    if (root.modeIndex >= root.modeList.length)
      root.modeIndex = Math.max(0, root.modeList.length - 1)
    if (root.trackIndex < 0) root.trackIndex = 0
    if (root.trackIndex >= root.exclusiveList.length)
      root.trackIndex = Math.max(0, root.exclusiveList.length - 1)
    if (root.layerAIndex < 0) root.layerAIndex = 0
    if (root.layerAIndex >= root.mixShaderList.length)
      root.layerAIndex = Math.max(0, root.mixShaderList.length - 1)
    if (root.layerBIndex < 0) root.layerBIndex = 0
    if (root.layerBIndex >= root.mixShaderList.length)
      root.layerBIndex = Math.max(0, root.mixShaderList.length - 1)
    if (root.layerCIndex < 0) root.layerCIndex = 0
    if (root.layerCIndex >= root.mixShaderList.length)
      root.layerCIndex = Math.max(0, root.mixShaderList.length - 1)
    if (root.tweakIndex < 0) root.tweakIndex = 0
    if (root.tweakIndex >= root.tweakRowCount)
      root.tweakIndex = Math.max(0, root.tweakRowCount - 1)
    if (root.resolutionIndex < 0) root.resolutionIndex = 0
    if (root.resolutionIndex >= root.resolutionList.length)
      root.resolutionIndex = Math.max(0, root.resolutionList.length - 1)
    if (root.detailIndex < 0) root.detailIndex = 0
    if (root.detailIndex >= root.detailList.length)
      root.detailIndex = Math.max(0, root.detailList.length - 1)
    if (root.lodRowIndex < 0) root.lodRowIndex = 0
    if (root.lodRowIndex >= root.settingsLodRows.length)
      root.lodRowIndex = Math.max(0, root.settingsLodRows.length - 1)
  }

  function lodLevelForRow(row) {
    var spec = root.settingsLodRows[row]
    if (!root.fx || !spec) return "high"
    if (!spec.shader) {
      if (!Model.shaderDetailAllEqual(root.fx.shaderDetail)) return ""
      return root.fx.detail
    }
    return Model.detailForShader(root.fx.shaderDetail, spec.shader, root.fx.detail)
  }

  function applyLodRow(row, level) {
    if (!root.fx) return
    var spec = root.settingsLodRows[row]
    if (!spec) return
    if (!spec.shader) root.fx.setDetail(level)
    else root.fx.setShaderDetail(spec.shader, level)
  }

  function adjustTweak(dir) {
    if (!root.fx || !root.showTweaks) return
    var field = root.tweakFields[root.tweakIndex]
    if (!field) return
    var preset = field.preset || root.tweakPreset
    root.fx.nudgeParam(preset, field.key, dir, Model.fieldNudgeStep(field))
  }

  function moveCursor(dx, dy) {
    root.cursorActive = true
    root.clampCursor()
    if (root.focusSection === "tweaks" && dx !== 0) {
      root.adjustTweak(dx)
      return
    }
    if (root.focusSection === "resolution" && dx !== 0) {
      var nextR = root.resolutionIndex + dx
      if (nextR < 0) nextR = 0
      if (nextR >= root.resolutionList.length) nextR = root.resolutionList.length - 1
      root.resolutionIndex = nextR
      if (root.fx && root.resolutionList[nextR])
        root.fx.setResolution(root.resolutionList[nextR].value)
      return
    }
    if (root.focusSection === "lod" && dx !== 0) {
      var nextL = root.detailIndex + dx
      if (nextL < 0) nextL = 0
      if (nextL >= root.detailList.length) nextL = root.detailList.length - 1
      root.detailIndex = nextL
      if (root.detailList[nextL])
        root.applyLodRow(root.lodRowIndex, root.detailList[nextL].value)
      return
    }
    if (root.focusSection === "target" && dx !== 0) {
      if (root.fx) root.fx.setOverlayTarget(root.fx.wallpaperTarget ? "screen" : "wallpaper")
      return
    }
    if (root.focusSection === "hypr" && dx !== 0) {
      if (root.fx) root.fx.setHyprEnabled(!root.fx.hyprEnabled)
      return
    }
    if (dx > 0 && root.settingsOpen && root.focusSection !== "resolution" && root.focusSection !== "lod" && root.focusSection !== "hypr" && root.focusSection !== "target") {
      root.focusSection = "resolution"
      root.resolutionIndex = root.fx ? Model.indexOfResolution(root.fx.resolution) : root.resolutionIndex
      return
    }
    if (dx > 0 && root.showTweaks && root.focusSection !== "tweaks" && root.focusSection !== "reset" && root.focusSection !== "hypr" && root.focusSection !== "target") {
      root.focusSection = "reset"
      return
    }
    if (dy === 0) return

    if (root.focusSection === "header") {
      if (dy > 0) {
        root.focusSection = "target"
      }
      return
    }

    if (root.focusSection === "target") {
      if (dy < 0) {
        root.focusSection = "header"
        return
      }
      root.focusSection = "hypr"
      return
    }

    if (root.focusSection === "hypr") {
      if (dy < 0) {
        root.focusSection = "target"
        return
      }
      root.focusSection = "modes"
      root.modeIndex = 0
      return
    }

    if (root.focusSection === "resolution") {
      if (dy < 0) {
        root.focusSection = "modes"
        root.modeIndex = 0
        return
      }
      root.focusSection = "lod"
      root.lodRowIndex = 0
      root.detailIndex = Model.indexOfDetail(root.lodLevelForRow(0))
      return
    }

    if (root.focusSection === "lod") {
      if (dy < 0) {
        if (root.lodRowIndex <= 0) {
          root.focusSection = "resolution"
          root.resolutionIndex = root.fx ? Model.indexOfResolution(root.fx.resolution) : root.resolutionIndex
          return
        }
        root.lodRowIndex = root.lodRowIndex - 1
        root.detailIndex = Model.indexOfDetail(root.lodLevelForRow(root.lodRowIndex))
        return
      }
      if (root.lodRowIndex < root.settingsLodRows.length - 1) {
        root.lodRowIndex = root.lodRowIndex + 1
        root.detailIndex = Model.indexOfDetail(root.lodLevelForRow(root.lodRowIndex))
      }
      return
    }

    if (root.focusSection === "modes") {
      if (dy < 0) {
        if (root.modeIndex <= 0) {
          root.focusSection = "hypr"
          return
        }
        root.modeIndex = root.modeIndex - 1
        return
      }
      if (root.modeIndex < root.modeList.length - 1) {
        root.modeIndex = root.modeIndex + 1
        return
      }
      if (root.customMode) {
        root.focusSection = "layerA"
        root.layerAIndex = 0
        return
      }
      if (root.exclusiveMode) {
        root.focusSection = "track"
        root.trackIndex = 0
        return
      }
      if (root.showTweaks) {
        root.focusSection = "reset"
        return
      }
      return
    }

    if (root.focusSection === "track") {
      if (dy < 0) {
        if (root.trackIndex <= 0) {
          root.focusSection = "modes"
          root.modeIndex = root.modeList.length - 1
          return
        }
        root.trackIndex = root.trackIndex - 1
        return
      }
      if (root.trackIndex < root.exclusiveList.length - 1) {
        root.trackIndex = root.trackIndex + 1
        return
      }
      if (root.showTweaks) {
        root.focusSection = "reset"
        return
      }
      return
    }

    if (root.focusSection === "layerA") {
      if (dy < 0) {
        if (root.layerAIndex <= 0) {
          root.focusSection = "modes"
          root.modeIndex = root.modeList.length - 1
          return
        }
        root.layerAIndex = root.layerAIndex - 1
        return
      }
      if (root.layerAIndex < root.mixShaderList.length - 1) {
        root.layerAIndex = root.layerAIndex + 1
        return
      }
      root.focusSection = "layerB"
      root.layerBIndex = 0
      return
    }

    if (root.focusSection === "layerB") {
      if (dy < 0) {
        if (root.layerBIndex <= 0) {
          root.focusSection = "layerA"
          root.layerAIndex = root.mixShaderList.length - 1
          return
        }
        root.layerBIndex = root.layerBIndex - 1
        return
      }
      if (root.layerBIndex < root.mixShaderList.length - 1) {
        root.layerBIndex = root.layerBIndex + 1
        return
      }
      root.focusSection = "layerC"
      root.layerCIndex = 0
      return
    }

    if (root.focusSection === "layerC") {
      if (dy < 0) {
        if (root.layerCIndex <= 0) {
          root.focusSection = "layerB"
          root.layerBIndex = root.mixShaderList.length - 1
          return
        }
        root.layerCIndex = root.layerCIndex - 1
        return
      }
      if (root.layerCIndex < root.mixShaderList.length - 1) {
        root.layerCIndex = root.layerCIndex + 1
        return
      }
      if (root.showTweaks) {
        root.focusSection = "reset"
        return
      }
      return
    }

    if (root.focusSection === "reset") {
      if (dy < 0) {
        if (root.customMode) {
          root.focusSection = "layerC"
          root.layerCIndex = root.mixShaderList.length - 1
          return
        }
        if (root.exclusiveMode) {
          root.focusSection = "track"
          root.trackIndex = root.exclusiveList.length - 1
          return
        }
        root.focusSection = "modes"
        root.modeIndex = root.modeList.length - 1
        return
      }
      if (root.showTweaks) {
        root.focusSection = "tweaks"
        root.tweakIndex = 0
      }
      return
    }

    if (root.focusSection === "tweaks") {
      if (dy < 0) {
        if (root.tweakIndex <= 0) {
          root.focusSection = "reset"
          return
        }
        root.tweakIndex = root.tweakIndex - 1
        return
      }
      if (root.tweakIndex < root.tweakRowCount - 1)
        root.tweakIndex = root.tweakIndex + 1
    }
  }

  function activateCursor() {
    if (!root.fx) return
    if (root.focusSection === "header") {
      root.fx.toggle()
      return
    }
    if (root.focusSection === "resolution") {
      var res = root.resolutionList[root.resolutionIndex]
      if (res) root.fx.setResolution(res.value)
      return
    }
    if (root.focusSection === "lod") {
      var lod = root.detailList[root.detailIndex]
      if (lod) root.applyLodRow(root.lodRowIndex, lod.value)
      return
    }
    if (root.focusSection === "target") {
      root.fx.setOverlayTarget(root.fx.wallpaperTarget ? "screen" : "wallpaper")
      return
    }
    if (root.focusSection === "hypr") {
      root.fx.setHyprEnabled(!root.fx.hyprEnabled)
      return
    }
    if (root.focusSection === "modes") {
      var entry = root.modeList[root.modeIndex]
      if (!entry) return
      if (entry.value === "none") {
        root.settingsOpen = true
        return
      }
      root.settingsOpen = false
      root.fx.setMode(entry.value)
      return
    }
    if (root.focusSection === "track") {
      var track = root.exclusiveList[root.trackIndex]
      if (track) root.fx.setExclusivePreset(track.value)
      return
    }
    if (root.focusSection === "layerA") {
      var layerA = root.mixShaderList[root.layerAIndex]
      if (layerA) root.fx.setCustomShader(0, layerA.value)
      return
    }
    if (root.focusSection === "layerB") {
      var layerB = root.mixShaderList[root.layerBIndex]
      if (layerB) root.fx.setCustomShader(1, layerB.value)
      return
    }
    if (root.focusSection === "layerC") {
      var layerC = root.mixShaderList[root.layerCIndex]
      if (layerC) root.fx.setCustomShader(2, layerC.value)
      return
    }
    if (root.focusSection === "tweaks") {
      var tweak = root.tweakFields[root.tweakIndex]
      if (tweak && tweak.kind === "check") {
        var on = Model.paramValue(root.fx.params, tweak.preset || root.tweakPreset, tweak.key, 0) >= 0.5
        root.fx.setParam(tweak.preset || root.tweakPreset, tweak.key, on ? 0 : 1, true)
      }
      return
    }
    if (root.focusSection === "reset")
      root.fx.resetParams()
  }

  onShowTweaksChanged: root.clampCursor()
  onExclusiveModeChanged: root.clampCursor()
  onCustomModeChanged: root.clampCursor()
  onParamColsChanged: root.clampCursor()

  KeyboardPanel {
    id: panel
    anchorItem: root.anchorItem
    owner: root.barIdentity
    bar: root.bar
    open: root.opened
    focusTarget: keyCatcher
    contentWidth: panel.fittedContentWidth(root.settingsOpen
      ? Style.space(1000)
      : (root.paramCols > 0 || root.customMode || root.exclusiveMode
      ? Style.space(((root.customMode || root.exclusiveMode) ? 680 : 520) + 220 * Math.max(1, root.paramCols))
      : Style.space(560)))
    contentHeight: panel.fittedContentHeight(column.implicitHeight)

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      onMoveRequested: function(dx, dy) {
        if (!root.cursorActive) { root.cursorActive = true; return }
        root.moveCursor(dx, dy)
      }
      onActivateRequested: if (root.cursorActive) root.activateCursor()
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }

      Flickable {
        id: panelFlick
        anchors.fill: parent
        contentWidth: width
        contentHeight: column.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.VerticalFlick
        interactive: contentHeight > height

        Column {
          id: column
          width: panelFlick.width
          spacing: Style.space(12)

          Item {
            id: header
            width: parent.width
            implicitHeight: hero.implicitHeight
            readonly property bool ringVisible: root.headerHasCursor
            function focusHero() { root.setHeaderCursor() }

            PanelHero {
              id: hero
              width: parent.width
              title: Model.pluginId
              meta: root.heroMeta
              foreground: root.foreground
              fontFamily: root.fontFamily
              iconOpacity: root.fx && root.fx.active ? 1.0 : 0.5
              iconComponent: Component {
                Text {
                  text: root.fx ? root.fx.icon : "󰖗"
                  color: root.iconColor
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.display
                }
              }
              trailingControl: Component {
                ToggleSwitch {
                  id: powerSwitch
                  checked: root.fx ? root.fx.active === true : false
                  hasCursor: header.ringVisible
                  foreground: hero.foreground
                  onHovered: function(on) { if (on) header.focusHero() }
                  onToggled: if (root.fx) root.fx.toggle()

                  PanelToolTip {
                    visible: powerSwitch.containsMouse
                    text: root.toggleHint
                    fontFamily: hero.fontFamily
                  }
                }
              }
            }
          }

          CursorSurface {
            width: parent.width
            implicitHeight: targetSwitch.implicitHeight
            hasCursor: root.cursorActive && root.focusSection === "target"
            foreground: root.foreground
            outline: true

            MouseArea {
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onEntered: {
                root.cursorActive = true
                root.focusSection = "target"
              }
              onClicked: if (root.fx) root.fx.setOverlayTarget(root.fx.wallpaperTarget ? "screen" : "wallpaper")
            }

            Row {
              width: parent.width
              spacing: Style.space(12)
              anchors.verticalCenter: parent.verticalCenter
              anchors.left: parent.left
              anchors.leftMargin: Style.space(6)

              ToggleSwitch {
                id: targetSwitch
                checked: root.fx ? root.fx.wallpaperTarget === true : false
                interactive: false
                hasCursor: root.cursorActive && root.focusSection === "target"
                foreground: root.foreground
              }

              Text {
                text: "Wallpaper only"
                color: root.dim
                font.family: root.fontFamily
                font.pixelSize: Style.font.caption
                font.bold: true
                width: parent.width - targetSwitch.width - Style.space(12)
                wrapMode: Text.WordWrap
              }
            }
          }

          CursorSurface {
            width: parent.width
            implicitHeight: hyprSwitch.implicitHeight
            hasCursor: root.cursorActive && root.focusSection === "hypr"
            foreground: root.foreground
            outline: true

            MouseArea {
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onEntered: {
                root.cursorActive = true
                root.focusSection = "hypr"
              }
              onClicked: if (root.fx) root.fx.setHyprEnabled(!root.fx.hyprEnabled)
            }

            Row {
              width: parent.width
              spacing: Style.space(12)
              anchors.verticalCenter: parent.verticalCenter
              anchors.left: parent.left
              anchors.leftMargin: Style.space(6)

              ToggleSwitch {
                id: hyprSwitch
                checked: root.fx ? root.fx.hyprEnabled === true : true
                interactive: false
                hasCursor: root.cursorActive && root.focusSection === "hypr"
                foreground: root.foreground
              }

              Text {
                text: "Distortion"
                color: root.dim
                font.family: root.fontFamily
                font.pixelSize: Style.font.caption
                font.bold: true
                anchors.verticalCenter: parent.verticalCenter
              }
            }
          }

          Text {
            width: parent.width
            visible: !!(root.fx && root.fx.qsbBakerWarning)
            text: root.fx ? root.fx.qsbBakerWarning : ""
            color: root.dim
            font.family: root.fontFamily
            font.pixelSize: Style.font.caption
            wrapMode: Text.WordWrap
          }

          Text {
            width: parent.width
            visible: !!(root.fx && root.fx.hyprShaderRivalWarning)
            text: root.fx ? root.fx.hyprShaderRivalWarning : ""
            color: root.dim
            font.family: root.fontFamily
            font.pixelSize: Style.font.caption
            wrapMode: Text.WordWrap
          }

          Row {
            width: parent.width
            spacing: Style.space(16)

            Column {
              width: (root.customMode || root.exclusiveMode)
                ? parent.width * 0.22 - Style.space(8)
                : (root.paramCols > 0 ? parent.width * 0.28 - Style.space(8) : parent.width * 0.58 - Style.space(16))
              spacing: Style.space(6)

              Repeater {
                model: root.liveModeList

                ModeRow {
                  required property var modelData
                  required property int index
                  width: parent.width
                  entry: modelData
                  rowIndex: Model.indexOfMode(modelData.value)
                }
              }

              Column {
                width: parent.width
                spacing: Style.space(6)

                PanelSeparator {
                  foreground: root.foreground
                }

                Text {
                  width: parent.width
                  text: "Manual only"
                  color: root.dim
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.caption
                  font.bold: true
                }

                Repeater {
                  model: root.manualModeList

                  ModeRow {
                    required property var modelData
                    required property int index
                    width: parent.width
                    entry: modelData
                    rowIndex: Model.indexOfMode(modelData.value)
                  }
                }
              }

            }

            Column {
              visible: root.exclusiveMode
              width: visible ? parent.width * 0.22 - Style.space(8) : 0
              height: visible ? implicitHeight : 0
              spacing: Style.space(6)

              Text {
                width: parent.width
                text: "Track only"
                color: root.dim
                font.family: root.fontFamily
                font.pixelSize: Style.font.caption
                font.bold: true
              }

              Repeater {
                model: root.exclusiveList

                TrackRow {
                  required property var modelData
                  required property int index
                  width: parent.width
                  entry: modelData
                  rowIndex: index
                }
              }
            }

            Column {
              visible: root.customMode
              width: visible ? parent.width * 0.22 - Style.space(8) : 0
              height: visible ? implicitHeight : 0
              spacing: Style.space(8)

              LayerPickStack {
                heading: "A"
                section: "layerA"
                slot: 0
              }

              LayerPickStack {
                heading: "B"
                section: "layerB"
                slot: 1
              }

              LayerPickStack {
                heading: "C"
                section: "layerC"
                slot: 2
              }
            }

            Column {
              visible: root.settingsOpen
              width: visible ? parent.width * 0.68 - Style.space(16) : 0
              height: visible ? implicitHeight : 0
              spacing: Style.space(12)

              Text {
                width: parent.width
                text: "Settings"
                color: root.dim
                font.family: root.fontFamily
                font.pixelSize: Style.font.caption
                font.bold: true
              }

              Text {
                width: parent.width
                text: Model.descriptionForPreset("none", 0)
                color: root.dim
                font.family: root.fontFamily
                font.pixelSize: Style.font.caption
                wrapMode: Text.WordWrap
              }

              SettingRow {
                axis: "resolution"
                title: "Resolution"
                blurb: root.settingsFields[0].hint
              }

              Repeater {
                model: root.settingsLodRows

                SettingRow {
                  required property var modelData
                  required property int index
                  axis: "lod"
                  lodRow: index
                  lodShader: String(modelData.shader || "")
                  title: modelData.title
                  blurb: modelData.cost + ". " + modelData.body
                }
              }
            }

            LayerTweaks {
              heading: root.layerHeadingA
              fields: root.layerFieldsA
              indexOffset: 0
              showBlurb: !root.customMode
            }

            LayerTweaks {
              heading: root.layerHeadingB
              fields: root.layerFieldsB
              indexOffset: root.layerFieldsA.length
            }

            LayerTweaks {
              heading: root.layerHeadingC
              fields: root.layerFieldsC
              indexOffset: root.layerFieldsA.length + root.layerFieldsB.length
            }
          }
        }
      }
    }
  }

  component LayerPickStack: Column {
    id: pickStack
    property string heading: "A"
    property string section: "layerA"
    property int slot: 0
    width: parent.width
    spacing: Style.space(4)

    Text {
      width: parent.width
      text: pickStack.heading
      color: root.dim
      font.family: root.fontFamily
      font.pixelSize: Style.font.caption
      font.bold: true
    }

    Repeater {
      model: root.mixShaderList

      MixPickRow {
        required property var modelData
        required property int index
        width: pickStack.width
        entry: modelData
        rowIndex: index
        section: pickStack.section
        slot: pickStack.slot
      }
    }
  }

  component LayerTweaks: Column {
    id: layerTweaks
    property string heading: ""
    property var fields: []
    property int indexOffset: 0
    property bool showBlurb: false
    visible: !root.settingsOpen && layerTweaks.fields && layerTweaks.fields.length > 0
    width: visible
      ? (parent.width * ((root.customMode || root.exclusiveMode) ? 0.48 : 0.62) - Style.space(16)) / Math.max(1, root.paramCols)
      : 0
    height: visible ? implicitHeight : 0
    spacing: Style.space(8)

    Text {
      width: parent.width
      text: layerTweaks.heading
      color: root.dim
      font.family: root.fontFamily
      font.pixelSize: Style.font.caption
      font.bold: true
    }

    Text {
      width: parent.width
      visible: layerTweaks.showBlurb && root.tweakBlurb !== ""
      text: root.tweakBlurb
      color: root.dim
      font.family: root.fontFamily
      font.pixelSize: Style.font.caption
      wrapMode: Text.WordWrap
    }

    ResetRow {
      visible: layerTweaks.indexOffset === 0
      width: parent.width
    }

    Repeater {
      model: layerTweaks.fields

      TweakField {
        required property var modelData
        required property int index
        width: layerTweaks.width
        field: modelData
        rowIndex: layerTweaks.indexOffset + index
      }
    }
  }

  component SettingRow: Row {
    id: settingRow
    property string axis: "resolution"
    property int lodRow: 0
    property string lodShader: ""
    property string title: ""
    property string blurb: ""
    width: parent.width
    spacing: Style.space(16)

    Column {
      width: parent.width * 0.48 - Style.space(8)
      spacing: Style.space(6)

      Text {
        width: parent.width
        text: settingRow.title
        color: root.dim
        font.family: root.fontFamily
        font.pixelSize: Style.font.caption
        font.bold: true
      }

      Row {
        width: parent.width
        spacing: Style.space(6)

        Repeater {
          model: settingRow.axis === "resolution" ? root.resolutionList : root.detailList

          QualityChip {
            required property var modelData
            required property int index
            width: (parent.width - Style.space(6) * 3) / 4
            entry: modelData
            rowIndex: index
            axis: settingRow.axis
            lodRow: settingRow.lodRow
            lodShader: settingRow.lodShader
          }
        }
      }
    }

    Text {
      width: parent.width * 0.52 - Style.space(8)
      text: settingRow.blurb
      color: root.dim
      font.family: root.fontFamily
      font.pixelSize: Style.font.caption
      wrapMode: Text.WordWrap
      verticalAlignment: Text.AlignVCenter
    }
  }

  component QualityChip: CursorSurface {
    id: qualityChip
    property var entry: null
    property int rowIndex: 0
    property string axis: "resolution"
    property int lodRow: 0
    property string lodShader: ""
    readonly property string value: entry ? String(entry.value) : ""
    readonly property string label: entry ? String(entry.label) : ""
    readonly property bool selected: {
      if (!root.fx) return false
      if (qualityChip.axis === "lod")
        return root.lodLevelForRow(qualityChip.lodRow) === qualityChip.value
      return root.fx.resolution === qualityChip.value
    }

    hasCursor: root.cursorActive && root.focusSection === qualityChip.axis && (
      qualityChip.axis === "lod"
        ? (root.lodRowIndex === qualityChip.lodRow && root.detailIndex === rowIndex)
        : root.resolutionIndex === rowIndex)
    current: selected
    foreground: root.foreground

    implicitHeight: qualityLabel.implicitHeight + Style.space(10)

    MouseArea {
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onEntered: {
        root.cursorActive = true
        root.focusSection = qualityChip.axis
        if (qualityChip.axis === "lod") {
          root.lodRowIndex = qualityChip.lodRow
          root.detailIndex = qualityChip.rowIndex
        } else {
          root.resolutionIndex = qualityChip.rowIndex
        }
      }
      onClicked: {
        if (!root.fx) return
        if (qualityChip.axis === "lod")
          root.applyLodRow(qualityChip.lodRow, qualityChip.value)
        else
          root.fx.setResolution(qualityChip.value)
      }
    }

    Text {
      id: qualityLabel
      anchors.centerIn: parent
      text: qualityChip.label
      color: root.foreground
      font.family: root.fontFamily
      font.pixelSize: Style.font.body
      font.bold: qualityChip.selected
    }
  }

  component ModeRow: CursorSurface {
    id: modeRow
    property var entry: null
    property int rowIndex: 0
    readonly property string value: entry ? String(entry.value) : ""
    readonly property string label: entry ? String(entry.label) : ""
    readonly property string glyph: entry ? String(entry.icon) : ""
    readonly property bool isSettings: modeRow.value === "none"
    readonly property bool modeActive: root.fx && root.fx.mode === modeRow.value
    readonly property bool selected: modeRow.isSettings ? root.settingsOpen : modeRow.modeActive

    hasCursor: root.cursorActive && root.focusSection === "modes" && root.modeIndex === rowIndex
    current: modeRow.isSettings ? root.settingsOpen : (!root.settingsOpen && modeRow.modeActive)
    foreground: root.foreground

    implicitHeight: modeContent.implicitHeight + Style.space(10)

    MouseArea {
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onEntered: {
        root.cursorActive = true
        root.focusSection = "modes"
        root.modeIndex = modeRow.rowIndex
      }
      onClicked: {
        if (!root.fx) return
        if (modeRow.isSettings) {
          root.settingsOpen = true
          return
        }
        root.settingsOpen = false
        root.fx.setMode(modeRow.value)
      }
    }

    RowLayout {
      id: modeContent
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      anchors.leftMargin: Style.space(10)
      anchors.rightMargin: Style.space(10)
      spacing: Style.space(10)

      Text {
        text: modeRow.glyph
        color: root.foreground
        font.family: root.fontFamily
        font.pixelSize: Style.font.icon
        Layout.alignment: Qt.AlignVCenter
      }

      Text {
        Layout.fillWidth: true
        text: modeRow.label
        color: root.foreground
        font.family: root.fontFamily
        font.pixelSize: Style.font.body
        font.bold: modeRow.isSettings ? root.settingsOpen : modeRow.modeActive
        elide: Text.ElideRight
      }
    }
  }

  component TrackRow: CursorSurface {
    id: trackRow
    property var entry: null
    property int rowIndex: 0
    readonly property string value: entry ? String(entry.value) : ""
    readonly property string label: entry ? String(entry.label) : ""
    readonly property string glyph: entry ? String(entry.icon) : ""
    readonly property bool selected: root.fx && root.fx.exclusivePreset === trackRow.value

    hasCursor: root.cursorActive && root.focusSection === "track" && root.trackIndex === rowIndex
    current: selected
    foreground: root.foreground

    implicitHeight: trackContent.implicitHeight + Style.space(10)

    MouseArea {
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onEntered: {
        root.cursorActive = true
        root.focusSection = "track"
        root.trackIndex = trackRow.rowIndex
      }
      onClicked: if (root.fx) root.fx.setExclusivePreset(trackRow.value)
    }

    RowLayout {
      id: trackContent
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      anchors.leftMargin: Style.space(10)
      anchors.rightMargin: Style.space(10)
      spacing: Style.space(10)

      Text {
        text: trackRow.glyph
        color: root.foreground
        font.family: root.fontFamily
        font.pixelSize: Style.font.icon
        Layout.alignment: Qt.AlignVCenter
      }

      Text {
        Layout.fillWidth: true
        text: trackRow.label
        color: root.foreground
        font.family: root.fontFamily
        font.pixelSize: Style.font.body
        font.bold: trackRow.selected
        elide: Text.ElideRight
      }
    }
  }

  component MixPickRow: CursorSurface {
    id: mixRow
    property var entry: null
    property int rowIndex: 0
    property string section: "layerA"
    property int slot: 0
    readonly property string value: entry ? String(entry.value) : ""
    readonly property string label: entry ? String(entry.label) : ""
    readonly property string glyph: entry ? String(entry.icon) : ""
    readonly property bool selected: {
      if (!root.fx) return false
      if (mixRow.slot === 2) return root.fx.customShaderC === mixRow.value
      if (mixRow.slot === 1) return root.fx.customShaderB === mixRow.value
      return root.fx.customShaderA === mixRow.value
    }
    readonly property int cursorIndex: mixRow.section === "layerC"
      ? root.layerCIndex
      : (mixRow.section === "layerB" ? root.layerBIndex : root.layerAIndex)

    hasCursor: root.cursorActive && root.focusSection === mixRow.section && mixRow.cursorIndex === mixRow.rowIndex
    current: selected
    foreground: root.foreground

    implicitHeight: mixContent.implicitHeight + Style.space(10)

    MouseArea {
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onEntered: {
        root.cursorActive = true
        root.focusSection = mixRow.section
        if (mixRow.section === "layerC") root.layerCIndex = mixRow.rowIndex
        else if (mixRow.section === "layerB") root.layerBIndex = mixRow.rowIndex
        else root.layerAIndex = mixRow.rowIndex
      }
      onClicked: if (root.fx) root.fx.setCustomShader(mixRow.slot, mixRow.value)
    }

    RowLayout {
      id: mixContent
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      anchors.leftMargin: Style.space(10)
      anchors.rightMargin: Style.space(10)
      spacing: Style.space(10)

      Text {
        text: mixRow.glyph
        color: root.foreground
        font.family: root.fontFamily
        font.pixelSize: Style.font.icon
        Layout.alignment: Qt.AlignVCenter
      }

      Text {
        Layout.fillWidth: true
        text: mixRow.label
        color: root.foreground
        font.family: root.fontFamily
        font.pixelSize: Style.font.body
        font.bold: mixRow.selected
        elide: Text.ElideRight
      }
    }
  }

  component ResetRow: CursorSurface {
    id: resetRow
    hasCursor: root.cursorActive && root.focusSection === "reset"
    current: false
    foreground: root.foreground

    implicitHeight: resetContent.implicitHeight + Style.space(10)

    MouseArea {
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onEntered: {
        root.cursorActive = true
        root.focusSection = "reset"
      }
      onClicked: if (root.fx) root.fx.resetParams()
    }

    RowLayout {
      id: resetContent
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      anchors.leftMargin: Style.space(10)
      anchors.rightMargin: Style.space(10)
      spacing: Style.space(10)

      Text {
        text: "󰑓"
        color: root.foreground
        font.family: root.fontFamily
        font.pixelSize: Style.font.icon
        Layout.alignment: Qt.AlignVCenter
      }

      Text {
        Layout.fillWidth: true
        text: "Reset to defaults"
        color: root.foreground
        font.family: root.fontFamily
        font.pixelSize: Style.font.body
        elide: Text.ElideRight
      }
    }
  }

  component TweakField: Column {
    id: tweakCol
    property var field: null
    property int rowIndex: 0
    spacing: Style.space(4)

    readonly property string paramKey: field ? String(field.key) : ""
    readonly property string paramPreset: field && field.preset ? String(field.preset) : root.tweakPreset
    readonly property string label: field ? String(field.label) : ""
    readonly property real maximum: field && field.max ? field.max : Model.fieldMaximum(tweakCol.paramPreset, tweakCol.paramKey)
    readonly property real minimum: field && field.min !== undefined && field.min !== null
      ? field.min
      : Model.fieldMinimum(tweakCol.paramPreset, tweakCol.paramKey)
    readonly property bool isCheck: !!(field && field.kind === "check")
    readonly property bool isTemp: !!(field && field.format === "temp")
    readonly property bool imperial: Model.shouldUseImperial(Qt.locale().name)
    readonly property real paramValue: root.fx
      ? Model.paramValue(root.fx.params, tweakCol.paramPreset, tweakCol.paramKey, tweakCol.isCheck ? 0 : 1)
      : (tweakCol.isCheck ? 0 : 1)
    readonly property real displayMin: tweakCol.isTemp ? (tweakCol.imperial ? 50 : 10) : tweakCol.minimum
    readonly property real displayMax: tweakCol.isTemp ? (tweakCol.imperial ? 120 : 49) : tweakCol.maximum
    readonly property real displayValue: tweakCol.isTemp
      ? (tweakCol.imperial ? Model.celsiusToFahrenheit(tweakCol.paramValue) : tweakCol.paramValue)
      : tweakCol.paramValue
    readonly property bool deferLive: tweakCol.paramPreset === "motes" || tweakCol.paramPreset === "pollen"
    readonly property bool rowCursor: root.cursorActive && root.focusSection === "tweaks" && root.tweakIndex === tweakCol.rowIndex
    property bool sliding: false
    property real draftDisplay: 0
    readonly property bool checked: tweakCol.paramValue >= 0.5

    function commit(v, persist) {
      var stored = v
      if (tweakCol.isTemp && tweakCol.imperial)
        stored = Model.fahrenheitToCelsius(v)
      if (root.fx) root.fx.setParam(tweakCol.paramPreset, tweakCol.paramKey, stored, persist)
    }

    function focusRow() {
      root.cursorActive = true
      root.focusSection = "tweaks"
      root.tweakIndex = tweakCol.rowIndex
    }

    Text {
      width: parent.width
      text: tweakCol.isCheck
        ? (tweakCol.label + (tweakCol.checked ? "  On" : "  Off"))
        : tweakCol.isTemp
          ? (tweakCol.label + "  " + Math.round(tweakCol.sliding ? tweakCol.draftDisplay : tweakCol.displayValue) + (tweakCol.imperial ? "°F" : "°C"))
          : (tweakCol.label + "  " + Math.round((tweakCol.sliding ? tweakCol.draftDisplay : tweakCol.paramValue) * 100) + "%")
      color: root.dim
      font.family: root.fontFamily
      font.pixelSize: Style.font.caption
      font.bold: true
    }

    CursorSurface {
      visible: tweakCol.isCheck
      width: parent.width
      height: visible ? checkSwitch.implicitHeight + Style.spacing.controlGap : 0
      hasCursor: tweakCol.rowCursor
      foreground: root.foreground
      outline: true

      MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: tweakCol.focusRow()
        onClicked: tweakCol.commit(tweakCol.checked ? 0 : 1, true)
      }

      ToggleSwitch {
        id: checkSwitch
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: Style.space(6)
        checked: tweakCol.checked
        interactive: false
        hasCursor: tweakCol.rowCursor
        foreground: root.foreground
      }
    }

    CursorSurface {
      visible: !tweakCol.isCheck
      width: parent.width
      height: visible ? slider.implicitHeight + Style.spacing.controlGap : 0
      hasCursor: tweakCol.rowCursor
      foreground: root.foreground
      outline: true

      PanelSlider {
        id: slider
        bar: root.bar
        anchors.fill: parent
        anchors.leftMargin: Style.space(6)
        anchors.rightMargin: Style.space(6)
        minimum: tweakCol.displayMin
        maximum: tweakCol.displayMax
        step: tweakCol.isTemp ? 1 : (tweakCol.maximum > 1 ? 0.1 : 0.05)
        value: tweakCol.sliding ? tweakCol.draftDisplay : tweakCol.displayValue
        onMoved: function(v) {
          tweakCol.sliding = true
          tweakCol.draftDisplay = v
          if (!tweakCol.deferLive)
            tweakCol.commit(v, false)
        }
        onReleased: function(v) {
          tweakCol.sliding = false
          tweakCol.commit(v, true)
        }
      }

      HoverHandler {
        onHoveredChanged: if (hovered) tweakCol.focusRow()
      }
    }
  }
}
