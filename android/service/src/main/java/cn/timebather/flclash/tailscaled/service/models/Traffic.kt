package cn.timebather.flclash.tailscaled.service.models

import cn.timebather.flclash.tailscaled.common.GlobalState
import cn.timebather.flclash.tailscaled.common.formatBytes
import cn.timebather.flclash.tailscaled.core.Core
import com.google.gson.Gson

data class Traffic(
    val up: Long,
    val down: Long,
)

val Traffic.speedText: String
    get() = "${up.formatBytes}/s↑  ${down.formatBytes}/s↓"

fun Core.getSpeedTrafficText(onlyStatisticsProxy: Boolean): String {
    try {
        val res = getTraffic(onlyStatisticsProxy)
        val traffic = Gson().fromJson(res, Traffic::class.java)
        return traffic.speedText
    } catch (e: Exception) {
        GlobalState.log(e.message + "")
        return ""
    }
}