package cn.timebather.flclash.tailscaled

import android.app.Application
import android.content.Context
import cn.timebather.flclash.tailscaled.common.GlobalState

class Application : Application() {

    override fun attachBaseContext(base: Context?) {
        super.attachBaseContext(base)
        GlobalState.init(this)
    }
}
