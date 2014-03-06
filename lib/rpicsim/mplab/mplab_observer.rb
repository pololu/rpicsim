module RPicSim::Mplab
  # This class implements the com.microchip.mplab.util.observers.Observer
  # interface, so we can easily receive events from objects that support
  # sending updates to observers.
  class MplabObserver
    include Java::comMicrochipMplabUtilObservers::Observer

    def initialize(subject, &callback)
      @callback = callback
      subject.Attach(self, nil)
    end

    def Update(event)
      @callback.call(event)
    end
  end
end