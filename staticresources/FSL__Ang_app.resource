'use strict';

(function () {

    // creating the angular app hi
    var app = angular.module('serviceExpert', ['uiGmapgoogle-maps', 'angularMoment', 'ui.bootstrap', 'chart.js', 'MstResolver']);

    app.run(['amMoment', function (amMoment) {
        amMoment.changeLocale(userLocale);
    }]);

    app.config(['$sceDelegateProvider', '$compileProvider', 'MstResolverProvider', function ($sceDelegateProvider, $compileProvider, MstResolverProvider) {

        //
        // scheduler.attachEvent("onSchedulerReady", function(){
        //
        //     let timesDebounces = 0;
        //
        //     scheduler.config.delay_render = 50;
        //
        //     window.uv = scheduler.updateView;
        //     window.scheduler.updateView = function() {
        //         timesDebounces = 0;
        //         //console.count('updateView');
        //         window.uv.apply(scheduler, arguments);
        //     };


        var updateViewIntervalForConsole = null;

        var debouncedUpdateView = _.debounce(window.scheduler.updateView, 100).bind(window.scheduler);

        window.updateViewDebounced = function () {

            // nothing is running + tab hidden
            if (!updateViewIntervalForConsole && document.body.clientWidth === 0) {

                updateViewIntervalForConsole = setInterval(window.updateViewDebounced, 1000);
                return;
            }

            // visible, if running cancel
            if (document.body.clientWidth !== 0) {

                if (updateViewIntervalForConsole) {
                    clearInterval(updateViewIntervalForConsole);
                    updateViewIntervalForConsole = null;
                }

                debouncedUpdateView();
            }
        };
        //});


        // production
        if (!debugMode) {
            $compileProvider.debugInfoEnabled(false);
        }

        // set MST configs
        MstResolverProvider.setConfig({
            fslOperationRemoteAction: RemoteActions.getFslOperation,
            getAsyncApexJobRemoteAction: RemoteActions.getAsyncApexJob,
            apiVersion: '41.0',
            fieldNames: fieldNames.FslOperation,
            autoConnect: false
        });

        // Allow same origin resource loads.
        $sceDelegateProvider.resourceUrlWhitelist(['self', 'https://**.force.com']);
    }]);
})();