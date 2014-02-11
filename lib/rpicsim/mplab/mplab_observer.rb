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