// ICallbackInterface.aidl
package cn.timebather.flclash.tailscaled.service;

import cn.timebather.flclash.tailscaled.service.IAckInterface;

interface ICallbackInterface {
    oneway void onResult(in byte[] data,in boolean isSuccess, in IAckInterface ack);
}