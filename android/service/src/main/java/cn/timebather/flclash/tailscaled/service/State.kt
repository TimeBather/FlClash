package cn.timebather.flclash.tailscaled.service

import android.content.Intent
import cn.timebather.flclash.tailscaled.common.ServiceDelegate
import cn.timebather.flclash.tailscaled.service.models.NotificationParams
import cn.timebather.flclash.tailscaled.service.models.VpnOptions
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.sync.Mutex

object State {
    var options: VpnOptions? = null
    var notificationParamsFlow: MutableStateFlow<NotificationParams?> = MutableStateFlow(
        NotificationParams()
    )

    val runLock = Mutex()
    var runTime: Long = 0L

    var delegate: ServiceDelegate<IBaseService>? = null

    var intent: Intent? = null
}