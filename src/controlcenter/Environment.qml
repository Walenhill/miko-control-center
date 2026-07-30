import QtQuick
import Quickshell
import qs.modules.common
import qs.modules.common.functions

QtObject {
    readonly property string home: FileUtils.trimFileProtocol(Directories.home)
    readonly property string configHome: FileUtils.trimFileProtocol(Directories.config)
    readonly property string stateHome:
        Quickshell.env("XDG_STATE_HOME") || home + "/.local/state"
    readonly property string dataHome: home + "/.local/share"
    readonly property string localBin: home + "/.local/bin"

    readonly property string controlCenterState:
        stateHome + "/miko-control-center"
    readonly property string resilienceRoot:
        dataHome + "/miko-resilience/repo"
    readonly property string resilienceBin:
        resilienceRoot + "/bin"

    readonly property string displayControl:
        resilienceBin + "/miko-display-control"
    readonly property string portInspect:
        resilienceBin + "/miko-port-inspect"
    readonly property string networkSnapshot:
        resilienceBin + "/miko-network-snapshot"
    readonly property string mikoWatch:
        localBin + "/miko-watch"
    readonly property string servicesState:
        controlCenterState + "/services.json"
}
