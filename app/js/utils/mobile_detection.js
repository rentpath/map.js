'use strict';
define(['flight/lib/component'], function(defineComponent) {
  var mobileDetection;
  mobileDetection = function() {
    this.isAndroid = function() {
      return navigator.userAgent.match(/Android/i);
    };
    this.isBlackBerry = function() {
      return navigator.userAgent.match(/BlackBerry/i);
    };
    this.isIOS = function() {
      return navigator.userAgent.match(/iPhone|iPad|iPod/i);
    };
    this.isOpera = function() {
      return navigator.userAgent.match(/Opera Mini/i);
    };
    this.isWindows = function() {
      return navigator.userAgent.match(/IEMobile/i);
    };
    return this.isMobile = function() {
      return this.isAndroid() || this.isBlackBerry() || this.isIOS() || this.isOpera() || this.isWindows();
    };
  };
  return mobileDetection;
});

//# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbInV0aWxzL21vYmlsZV9kZXRlY3Rpb24uY29mZmVlIl0sIm5hbWVzIjpbXSwibWFwcGluZ3MiOiJBQUFBLFlBQUEsQ0FBQTtBQUFBLE1BT0EsQ0FBTyxDQUNMLHNCQURLLENBQVAsRUFFRyxTQUNELGVBREMsR0FBQTtBQUlELE1BQUEsZUFBQTtBQUFBLEVBQUEsZUFBQSxHQUFrQixTQUFBLEdBQUE7QUFFaEIsSUFBQSxJQUFDLENBQUEsU0FBRCxHQUFhLFNBQUEsR0FBQTthQUNYLFNBQVMsQ0FBQyxTQUFTLENBQUMsS0FBcEIsQ0FBMEIsVUFBMUIsRUFEVztJQUFBLENBQWIsQ0FBQTtBQUFBLElBR0EsSUFBQyxDQUFBLFlBQUQsR0FBZ0IsU0FBQSxHQUFBO2FBQ2QsU0FBUyxDQUFDLFNBQVMsQ0FBQyxLQUFwQixDQUEwQixhQUExQixFQURjO0lBQUEsQ0FIaEIsQ0FBQTtBQUFBLElBTUEsSUFBQyxDQUFBLEtBQUQsR0FBUyxTQUFBLEdBQUE7YUFDUCxTQUFTLENBQUMsU0FBUyxDQUFDLEtBQXBCLENBQTBCLG1CQUExQixFQURPO0lBQUEsQ0FOVCxDQUFBO0FBQUEsSUFTQSxJQUFDLENBQUEsT0FBRCxHQUFXLFNBQUEsR0FBQTthQUNULFNBQVMsQ0FBQyxTQUFTLENBQUMsS0FBcEIsQ0FBMEIsYUFBMUIsRUFEUztJQUFBLENBVFgsQ0FBQTtBQUFBLElBWUEsSUFBQyxDQUFBLFNBQUQsR0FBYSxTQUFBLEdBQUE7YUFDWCxTQUFTLENBQUMsU0FBUyxDQUFDLEtBQXBCLENBQTBCLFdBQTFCLEVBRFc7SUFBQSxDQVpiLENBQUE7V0FlQSxJQUFDLENBQUEsUUFBRCxHQUFZLFNBQUEsR0FBQTthQUNWLElBQUMsQ0FBQSxTQUFELENBQUEsQ0FBQSxJQUFnQixJQUFDLENBQUEsWUFBRCxDQUFBLENBQWhCLElBQW1DLElBQUMsQ0FBQSxLQUFELENBQUEsQ0FBbkMsSUFBK0MsSUFBQyxDQUFBLE9BQUQsQ0FBQSxDQUEvQyxJQUE2RCxJQUFDLENBQUEsU0FBRCxDQUFBLEVBRG5EO0lBQUEsRUFqQkk7RUFBQSxDQUFsQixDQUFBO0FBb0JBLFNBQU8sZUFBUCxDQXhCQztBQUFBLENBRkgsQ0FQQSxDQUFBIiwiZmlsZSI6InV0aWxzL21vYmlsZV9kZXRlY3Rpb24uanMiLCJzb3VyY2VSb290IjoiL3NvdXJjZS8iLCJzb3VyY2VzQ29udGVudCI6WyIndXNlIHN0cmljdCdcblxuI1xuIyBCRVdBUkU6IFRoaXMgaXMgbm90IGZ1bGwgcHJvb2Ygc2luY2UgYWdlbnQgc3RyaW5ncyBjYW4gYmUgbWFzcXVlcmFkZWQuXG4jICBEZXBlbmRpbmcgb24geW91ciBuZWVkIHRoaXMgbWF5IG9yIG1heSBub3Qgd29ya1xuI1xuXG5kZWZpbmUgW1xuICAnZmxpZ2h0L2xpYi9jb21wb25lbnQnLFxuXSwgKFxuICBkZWZpbmVDb21wb25lbnQsXG4pIC0+XG5cbiAgbW9iaWxlRGV0ZWN0aW9uID0gLT5cblxuICAgIEBpc0FuZHJvaWQgPSAoKSAtPlxuICAgICAgbmF2aWdhdG9yLnVzZXJBZ2VudC5tYXRjaCgvQW5kcm9pZC9pKVxuICAgIFxuICAgIEBpc0JsYWNrQmVycnkgPSAtPlxuICAgICAgbmF2aWdhdG9yLnVzZXJBZ2VudC5tYXRjaCgvQmxhY2tCZXJyeS9pKVxuICAgIFxuICAgIEBpc0lPUyA9IC0+XG4gICAgICBuYXZpZ2F0b3IudXNlckFnZW50Lm1hdGNoKC9pUGhvbmV8aVBhZHxpUG9kL2kpXG5cbiAgICBAaXNPcGVyYSA9IC0+XG4gICAgICBuYXZpZ2F0b3IudXNlckFnZW50Lm1hdGNoKC9PcGVyYSBNaW5pL2kpXG5cbiAgICBAaXNXaW5kb3dzID0gLT5cbiAgICAgIG5hdmlnYXRvci51c2VyQWdlbnQubWF0Y2goL0lFTW9iaWxlL2kpXG4gICAgXG4gICAgQGlzTW9iaWxlID0gLT5cbiAgICAgIEBpc0FuZHJvaWQoKSB8fCBAaXNCbGFja0JlcnJ5KCkgfHwgQGlzSU9TKCkgfHwgQGlzT3BlcmEoKSB8fCBAaXNXaW5kb3dzKClcblxuICByZXR1cm4gbW9iaWxlRGV0ZWN0aW9uICAiXX0=