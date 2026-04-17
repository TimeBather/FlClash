// IResultInterface.aidl
package cn.timebather.flclash.tailscaled.service;

interface IResultInterface {
    oneway void onResult(in long runTime);
}