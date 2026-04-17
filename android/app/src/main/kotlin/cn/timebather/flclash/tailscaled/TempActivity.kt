package cn.timebather.flclash.tailscaled

import android.app.Activity
import android.os.Bundle
import cn.timebather.flclash.tailscaled.common.QuickAction
import cn.timebather.flclash.tailscaled.common.action
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch

class TempActivity : Activity(),
    CoroutineScope by CoroutineScope(SupervisorJob() + Dispatchers.Default) {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        when (intent.action) {
            QuickAction.START.action -> {
                launch {
                    State.handleStartServiceAction()
                }
            }

            QuickAction.STOP.action -> {
                launch {
                    State.handleStopServiceAction()
                }
            }

            QuickAction.TOGGLE.action -> {
                launch {
                    State.handleToggleAction()
                }
            }
        }
        finish()
    }
}