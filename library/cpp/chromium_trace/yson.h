#pragma once

#include "consumer.h"

#include <library/cpp/yson/writer.h>

namespace NChromiumTrace {
    class TYsonTraceConsumer final: public ITraceConsumer {
        NYson::TYsonWriter Yson;
        TString JobId;

    public:
        TYsonTraceConsumer(IOutputStream* stream, NYson::EYsonFormat format = NYson::EYsonFormat::Binary);
        ~TYsonTraceConsumer() override;

        void AddEvent(const TDurationBeginEvent& event, const TEventArgs* args) override;
        void AddEvent(const TDurationEndEvent& event, const TEventArgs* args) override;
        void AddEvent(const TDurationCompleteEvent& event, const TEventArgs* arg) override;
        void AddEvent(const TCounterEvent& event, const TEventArgs* args) override;
        void AddEvent(const TMetadataEvent& event, const TEventArgs* args) override;

    private:
        void BeginEvent(char type, const TEventOrigin& origin);
        void EndEvent(const TEventArgs* args);
        void WriteArgs(const TEventArgs& args);
        void WriteFlow(const TEventFlow& flow);

        static TString GetCurrentJobId();
    };

}
