package inet.queueing.scheduler;

import inet.queueing.base.PacketSchedulerBase;
import inet.queueing.contract.IPacketScheduler;

// This module implements Deficit Round Robin (DRR) scheduling.

simple DrrScheduler extends PacketSchedulerBase like IPacketScheduler
{
    parameters:
        string quantums;
        @class(DrrScheduler);
}
