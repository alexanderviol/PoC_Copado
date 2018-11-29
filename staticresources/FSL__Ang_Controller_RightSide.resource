'use strict';

(function () {

    angular.module('serviceExpert').controller('ctrlRightSide', ['$q', '$scope', '$rootScope', '$filter', '$sce', 'sfdcService', 'utils', 'servicesService', 'kpiCalculationsService', 'StateService', 'DeltaService', 'TimePhasedDataService', 'StreamingAPIService', 'RegisterService', function ($q, $scope, $rootScope, $filter, $sce, sfdcService, utils, servicesService, kpiCalculationsService, StateService, DeltaService, TimePhasedDataService, StreamingAPIService, RegisterService) {

        $scope.isMapEnabled = StateService.isMapEnabled();
        $scope.servicesObjects = servicesService.servicesObjects;
        $scope.servicesScheduledToCapacity = {};
        $scope.notifications = utils.butlerNotifications;
        $scope.unreadNotifications = 0;
        $scope.showServiceList = utils.showServiceList;
        $scope.optimizationRequests = {};
        $scope.workingState = 'gantt';
        $scope.openConsoleTab = utils.openConsoleTab;
        $scope.openSObjectLink = utils.openSObjectLink;
        $scope.activeRequests = sfdcService.activeRequests;
        $scope.activeRuleCheckRequests = sfdcService.activeRuleCheckRequests;
        $scope.kpi = kpiCalculationsService.kpis;
        $scope.optimizationRequsts = {};
        $scope.marginLeftForBox = 0;
        $scope.mapAvailable = mapMode;

        $scope.$watch('workingState', function (newValue) {
            if (newValue === 'gantt') {
                setTimeout(function () {
                    scheduler._is_initialized() && updateViewDebounced();
                }, 0);
            }
        });

        sfdcService.getServiceMapInfoWindowFields().then(function (fieldsList) {
            $scope.serviceFields = fieldsList;
        });

        $scope.getServiceInfoRowClass = utils.getServiceInfoRowClass;
        $scope.openLink = utils.openLink;

        $scope.order = function (predicate, reverse) {
            $scope.orderByField = predicate;
            $scope.reverse = reverse;
        };

        $scope.$on('changeWorkingState', function (event, workingState) {

            $scope.workingState = workingState;

            if (workingState === 'gantt') {
                setTimeout(function () {
                    updateViewDebounced();
                }, 100);
            } else {
                $('.dhtmlXTooltip').remove();
            }
        });

        $scope.showNotifications = function () {
            $scope.unreadNotifications = 0;
            utils.butlerNotifications().forEach(function (notification) {
                return notification.unread = false;
            });
        };

        $scope.calcUnreadNotifications = function () {

            $scope.unreadNotifications = 0;

            utils.butlerNotifications().forEach(function (notification) {
                notification.unread && $scope.unreadNotifications++;
            });

            return $scope.unreadNotifications;
        };

        $scope.numOfNotifications = function () {

            var s = 0;

            utils.butlerNotifications().forEach(function (n) {
                if (n.show) {
                    s++;
                }
            });

            return s;
        };

        $scope.formatTravel = function (time) {
            var travelH = Math.floor(time / 60 / 60),
                travelM = Math.floor(time / 60 % 60);

            return travelH + customLabels.kpi_h + ' ' + travelM + customLabels.kpi_m;
        };

        $scope.toggleServiceList = function () {
            $scope.showServiceList.show = true;

            setTimeout(function () {
                updateViewDebounced();
                $rootScope.$broadcast('resizeMap', {});
            }, 830);
        };

        $scope.isEmpty = function (o) {
            return Object.keys(o).length;
        };

        // get optimization requests
        $q.all([TimePhasedDataService.promises.initialPhasedData, sfdcService.getOptimizationRequests()]).then(function (requests) {
            requests[1].forEach(function (req) {

                $scope.optimizationRequsts[req.Id] = new OptimizationRequest(req);
                addSmartActionTimespan($scope.optimizationRequsts[req.Id]);
            });
        });

        $scope.getRequestCss = function (status) {
            switch (status) {
                case 'In Progress':
                    return 'smart_in_progress';
                case 'Completed':
                    return 'smart_completed';
                case 'Failed':
                    return 'smart_failed';
                case 'Open':
                    return 'smart_open';
                case 'Queued':
                    return 'smart_queued';
            }
        };

        // register to delta - optimization requests
        RegisterService.register('optimizationRequests', function (requests) {
            requests.forEach(function (req) {

                var newRequest = new OptimizationRequest(req);

                // check if exist
                if ($scope.optimizationRequsts[req.Id] && $scope.optimizationRequsts[req.Id].timespan) {
                    scheduler.deleteMarkedTimespan($scope.optimizationRequsts[req.Id].timespan);
                }

                $scope.optimizationRequsts[req.Id] = newRequest;
                addSmartActionTimespan(newRequest);
            });

            updateViewDebounced();
        });

        // add timespan for smart action
        function addSmartActionTimespan(request) {

            if (request.status !== 'Failed' && request.status !== 'Completed' && request.type !== 'Global Optimization' && request.start && request.finish) {

                request.timespan = markSmartActionOnResource(request);
            }
        }

        // put running effect on gantt
        function markSmartActionOnResource(request) {
            if (!request.resource) return new Date().getTime();

            var resourceId = void 0,
                resourceByDate = TimePhasedDataService.getResoruceGanttIdByDate(request.resource, request.start),
                cssType = 'reshufle-on-gantt',
                actionLabel = '';

            if (resourceByDate) resourceId = resourceByDate.split(',');else return new Date().getTime();

            switch (request.type) {
                case 'Fix Overlaps':
                    cssType = 'fix-overlaps-on-gantt';
                    actionLabel = customLabels.FixOverlaps;
                    break;
                case 'SA Reshuffle':
                    cssType = 'reshufle-on-gantt';
                    actionLabel = customLabels.Reshuffle;
                    break;
                case 'Fill-In Schedule':
                    cssType = 'fillin-on-gantt';
                    actionLabel = customLabels.Fill_in_Schedule;
                    break;
                case 'Group Nearby SAs':
                    cssType = 'group-near-on-gantt';
                    actionLabel = customLabels.GroupNearby;
                    break;
                case 'Resource Schedule Optimization':
                    cssType = 'resource-day-on-gantt';
                    actionLabel = customLabels.RDOptimize;
                    break;
                default:
                    cssType = 'reshufle-on-gantt';
            }

            return scheduler.addMarkedTimespan({

                start_date: request.start,

                end_date: request.finish,

                sections: { ZoomLevel2: resourceId, ZoomLevel3: resourceId, ZoomLevel4: resourceId, ZoomLevel5: resourceId, ZoomLevel6: resourceId },
                css: 'smart-on-gantt ' + cssType,
                html: '<div><span>' + actionLabel + '</span></div>'
            });
        }

        $scope.getNumOfRunningRequests = function () {

            var sum = 0;

            for (var key in $scope.optimizationRequsts) {
                if ($scope.optimizationRequsts[key].status !== 'Completed' && $scope.optimizationRequsts[key].status !== 'Failed') {
                    sum++;
                }
            }

            return sum;
        };

        $scope.openSomethingBox = function ($event, whatBox) {
            if (whatBox === 'smart') $scope.marginLeftForBox = $event.target.offsetLeft - 227;else $scope.marginLeftForBox = $event.target.offsetLeft - 200;
        };
    }]);
})();