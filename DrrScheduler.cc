#include "inet/common/INETUtils.h"
#include "inet/queueing/scheduler/DrrScheduler.h"

namespace inet {
namespace queueing {

Define_Module(DrrScheduler);

DrrScheduler::~DrrScheduler()
{
    delete[] quantums;
    delete[] deficits;
}

void DrrScheduler::initialize(int stage)
{
    PacketSchedulerBase::initialize(stage);
    if (stage == INITSTAGE_LOCAL) {
        int numInputs = providers.size();
        quantums = new int[numInputs];
        deficits = new int[numInputs];

        // Parse quantum values from parameter
        cStringTokenizer tokenizer(par("quantums"));
        int i;
        for (i = 0; i < numInputs && tokenizer.hasMoreTokens(); ++i) {
            quantums[i] = (int)utils::atoul(tokenizer.nextToken());
            deficits[i] = 0; // Initialize deficit counters to 0
        }

        if (i < numInputs)
            throw cRuntimeError("Too few values given in the quantums parameter.");
        if (tokenizer.hasMoreTokens())
            throw cRuntimeError("Too many values given in the quantums parameter.");

        for (auto provider : providers)
            collections.push_back(dynamic_cast<IPacketCollection *>(provider));

        currentIndex = 0;
    }
}

int DrrScheduler::getNumPackets() const
{
    int size = 0;
    for (auto collection : collections)
        size += collection->getNumPackets();
    return size;
}

b DrrScheduler::getTotalLength() const
{
    b totalLength(0);
    for (auto collection : collections)
        totalLength += collection->getTotalLength();
    return totalLength;
}

// Schedules one packet per function call
int DrrScheduler::schedulePacket()
{
    int numInputs = providers.size();
    
    // Check if all queues are empty
    bool allEmpty = true;
    for (int i = 0; i < numInputs; ++i) {
        if (providers[i]->canPopSomePacket(inputGates[i]->getPathStartGate())) {
            allEmpty = false;
            break;
        }
    }
    
    if (allEmpty)
        return -1;

    for (int i = 0; i < (int)providers.size(); ++i) {
        int idx = currentIndex;
        
        // Check if current stream has packets
        if (providers[idx]->canPopSomePacket(inputGates[idx]->getPathStartGate())) {
            // Add quantum to deficit counter
            deficits[idx] += quantums[idx];
            
            // Try to schedule a packet from this stream
            auto packet = providers[idx]->canPopSomePacket(inputGates[idx]->getPathStartGate());
            if (packet) {
                int packetSize = packet->getByteLength();
                if (deficits[idx] >= packetSize) {
                    deficits[idx] -= packetSize;
                    return idx;
                }
            }
        }
        
        // Move to next stream
        currentIndex = (currentIndex + 1) % numInputs;
    }
    
    // If we've gone through all streams and couldn't schedule anything, add a round of quantum
    for (int i = 0; i < numInputs; ++i) {
        deficits[i] += quantums[i];
    }
    
    // Attempt again
    for (int i = 0; i < numInputs; ++i) {
        int idx = (currentIndex + i) % numInputs;
        
        if (providers[idx]->canPopSomePacket(inputGates[idx]->getPathStartGate())) {
            auto packet = providers[idx]->canPopSomePacket(inputGates[idx]->getPathStartGate());
            if (packet) {
                int packetSize = packet->getByteLength();
                
                if (deficits[idx] >= packetSize) {
                    deficits[idx] -= packetSize;
                    currentIndex = (idx + 1) % numInputs;
                    return idx;
                }
            }
        }
    }
    
    // No packet could be scheduled
    return -1;
}

} // namespace queueing
} // namespace inet
