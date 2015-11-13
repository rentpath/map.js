define [], () ->
  describeComponent 'map/components/ui/neighborhoods', ->
    beforeEach ->
      @setupComponent()

    describe '#formatValue', ->
      it 'formats median_income', ->
        expect(@component.formatValue('median_income', 1000)).toEqual '$1,000.00'

      it 'formats average_income', ->
        expect(@component.formatValue('average_income', 1000)).toEqual '$1,000.00'

      it 'formats population', ->
        expect(@component.formatValue('population', 1000)).toEqual '1,000'

      it 'leaves everything else the same', ->
        expect(@component.formatValue('foo_bar', 1000)).toEqual 1000
