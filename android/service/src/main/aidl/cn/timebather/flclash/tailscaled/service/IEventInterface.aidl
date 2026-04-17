// IEventInterface.aidl
package cn.timebather.flclash.tailscaled.service;

import cn.timebather.flclash.tailscaled.service.IAckInterface;

interface IEventInterface {
    oneway void onEvent(in String id, in byte[] data,in boolean isSuccess, in IAckInterface ack);
}