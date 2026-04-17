package cn.timebather.flclash.tailscaled.service

import android.app.Service
import android.content.Intent
import android.os.Binder
import android.os.IBinder
import cn.timebather.flclash.tailscaled.core.Core
import cn.timebather.flclash.tailscaled.service.modules.NetworkObserveModule
import cn.timebather.flclash.tailscaled.service.modules.NotificationModule
import cn.timebather.flclash.tailscaled.service.modules.SuspendModule
import cn.timebather.flclash.tailscaled.service.modules.moduleLoader
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers

class CommonService : Service(), IBaseService,
    CoroutineScope by CoroutineScope(Dispatchers.Default) {

    private val self: CommonService
        get() = this

    private val loader = moduleLoader {
        install(NetworkObserveModule(self))
        install(NotificationModule(self))
        install(SuspendModule(self))
    }

    override fun onCreate() {
        super.onCreate()
        handleCreate()
    }

    override fun onDestroy() {
        handleDestroy()
        super.onDestroy()
    }

    override fun onLowMemory() {
        Core.forceGC()
        super.onLowMemory()
    }

    private val binder = LocalBinder()

    inner class LocalBinder : Binder() {
        fun getService(): CommonService = this@CommonService
    }

    override fun onBind(intent: Intent): IBinder {
        return binder
    }

    override fun start() {
        try {
            loader.load()
        } catch (_: Exception) {
            stop()
        }
    }

    override fun stop() {
        loader.cancel()
        stopSelf()
    }
}