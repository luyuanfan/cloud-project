#ifndef __INET_DRRSCHEDULER_H
#define __INET_DRRSCHEDULER_H

#include "inet/queueing/base/PacketSchedulerBase.h"
#include "inet/queueing/contract/IPacketCollection.h"

namespace inet {
namespace queueing {

/**
 * This module implements a Deficit Round Robin (DRR) Scheduler.
 */
class INET_API DrrScheduler : public PacketSchedulerBase, public IPacketCollection
{
  protected:
    int *quantums = nullptr;  // array of quantum values in bytes (has numInputs elements)
    int *deficits = nullptr;  // array of deficit counters in bytes (has numInputs elements)
    int currentIndex = 0;      // current position in round-robin iteration

    std::vector<IPacketCollection *> collections;

  protected:
    virtual void initialize(int stage) override;
    virtual int schedulePacket() override;

  public:
    virtual ~DrrScheduler();

    virtual int getMaxNumPackets() const override { return -1; }
    virtual int getNumPackets() const override;

    virtual b getMaxTotalLength() const override { return b(-1); }
    virtual b getTotalLength() const override;

    virtual bool isEmpty() const override { return getNumPackets() == 0; }
    virtual Packet *getPacket(int index) const override { throw cRuntimeError("Invalid operation"); }
    virtual void removePacket(Packet *packet) override { throw cRuntimeError("Invalid operation"); }
};

} // namespace queueing
} // namespace inet

#endif // ifndef __INET_DRRSCHEDULER_H
