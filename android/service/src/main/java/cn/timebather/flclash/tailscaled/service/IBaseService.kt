package cn.timebather.flclash.tailscaled.service

import cn.timebather.flclash.tailscaled.common.BroadcastAction
import cn.timebather.flclash.tailscaled.common.GlobalState
import cn.timebather.flclash.tailscaled.common.sendBroadcast

interface IBaseService {
    fun handleCreate() {
        GlobalState.log("Service create")
        BroadcastAction.SERVICE_CREATED.sendBroadcast()
    }

    fun handleDestroy() {
        GlobalState.log("Service destroy")
        BroadcastAction.SERVICE_DESTROYED.sendBroadcast()
    }

    fun start()

    fun stop()
}