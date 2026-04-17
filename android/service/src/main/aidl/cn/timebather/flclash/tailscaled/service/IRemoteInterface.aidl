// IRemoteInterface.aidl
package cn.timebather.flclash.tailscaled.service;

import cn.timebather.flclash.tailscaled.service.ICallbackInterface;
import cn.timebather.flclash.tailscaled.service.IEventInterface;
import cn.timebather.flclash.tailscaled.service.IResultInterface;
import cn.timebather.flclash.tailscaled.service.IVoidInterface;
import cn.timebather.flclash.tailscaled.service.models.VpnOptions;
import cn.timebather.flclash.tailscaled.service.models.NotificationParams;

interface IRemoteInterface {
    void invokeAction(in String data, in ICallbackInterface callback);
    void quickSetup(in String initParamsString, in String setupParamsString, in ICallbackInterface callback, in IVoidInterface onStarted);
    void updateNotificationParams(in NotificationParams params);
    void startService(in VpnOptions options, in long runTime, in IResultInterface result);
    void stopService(in IResultInterface result);
    void setEventListener(in IEventInterface event);
    void setCrashlytics(in boolean enable);
    long getRunTime();
}