package cn.timebather.flclash.tailscaled

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import cn.timebather.flclash.tailscaled.common.BroadcastAction
import cn.timebather.flclash.tailscaled.common.GlobalState
import cn.timebather.flclash.tailscaled.common.action
import kotlinx.coroutines.launch

class BroadcastReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent?) {
        when (intent?.action) {
            BroadcastAction.SERVICE_CREATED.action -> {
                GlobalState.log("Receiver service created")
                GlobalState.launch {
                    State.handleStartServiceAction()
                }
            }

            BroadcastAction.SERVICE_DESTROYED.action -> {
                GlobalState.log("Receiver service destroyed")
                GlobalState.launch {
                    State.handleStopServiceAction()
                }
            }
        }
    }
}