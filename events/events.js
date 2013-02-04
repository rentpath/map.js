define(function () {
    var eventsObject = $({});
    var trigger = function () {
        eventsObject.trigger.apply(eventsObject, arguments)
    };
    var one = function () {
        eventsObject.one.apply(eventsObject, arguments)
    };
    var bind = function () {
        eventsObject.on.apply(eventsObject, arguments)
    };
    var unbind = function () {
        eventsObject.off.apply(eventsObject, arguments)
    };
    return{trigger:trigger, bind:bind, unbind:unbind, one:one}
});