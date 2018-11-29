'use strict';

function _toConsumableArray(arr) { if (Array.isArray(arr)) { for (var i = 0, arr2 = Array(arr.length); i < arr.length; i++) { arr2[i] = arr[i]; } return arr2; } else { return Array.from(arr); } }

(function () {

    angular.module('serviceExpert').directive('bulkActionsButton', BulkActionsButton);

    BulkActionsButton.$inject = [];

    function BulkActionsButton() {

        controllerFunction.$inject = ['$scope', 'servicesService', 'utils', 'bulkDispatchService', 'bulkUnscheduleService', 'ServiceSelectorService', 'optimizeLightboxService', 'bulkScheduleService', 'rdOptimizeLightboxService', 'sfdcService', 'GeneralLightbox', 'TimePhasedDataService'];

        function controllerFunction($scope, servicesService, utils, bulkDispatchService, bulkUnscheduleService, ServiceSelectorService, optimizeLightboxService, bulkScheduleService, rdOptimizeLightboxService, sfdcService, GeneralLightbox, TimePhasedDataService) {
            $scope.bulkActionsOrder = bulkActionsOrder;
            $scope.customActions = [];

            $scope.actionNames = {
                'Schedule': { name: customLabels.Schedule, icon: lsdIcons.calendar },
                'Dispatch': { name: customLabels.Dispatch, icon: lsdIcons.dispatch },
                'Optimize': { name: customLabels.Optimize, icon: lsdIcons.magicwand },
                'Flag-Unflag': { name: customLabels.Flag_Unflag, icon: lsdIcons.flag },
                'Unschedule': { name: customLabels.Unschedule, icon: lsdIcons.na }
            };

            // custom actions
            utils.customActionsPromise.then(function () {
                var _$scope$customActions;

                var customServiceActions = utils.getCustomActions('bulk');
                (_$scope$customActions = $scope.customActions).push.apply(_$scope$customActions, _toConsumableArray(customServiceActions));
            });

            $scope.runCustomServiceAction = function (action) {

                var servicesIds = ServiceSelectorService.getSelected();

                if (action.visualforce) {

                    var startDateStr = scheduler._min_date.getMonth() + 1 + "-" + scheduler._min_date.getDate() + "-" + scheduler._min_date.getFullYear(),
                        endDateStr = scheduler._max_date.getMonth() + 1 + "-" + scheduler._max_date.getDate() + "-" + scheduler._max_date.getFullYear();

                    //GeneralLightbox.open(action.name, action.visualforce + '?services=' + servicesIds.join(',') + '&id=' + servicesIds.join(',') + '&start=' + startDateStr + '&end=' + endDateStr);

                    if (servicesIds.length === 1) {
                        GeneralLightbox.open(action.name, action.visualforce + '?id=' + servicesIds[0] + '&start=' + startDateStr + '&end=' + endDateStr);
                    } else {
                        GeneralLightbox.open(action.name, action.visualforce + '?services=' + servicesIds.join(',') + '&start=' + startDateStr + '&end=' + endDateStr);
                    }
                } else {

                    if (servicesIds.length === 0) {
                        return;
                    }

                    sfdcService.runCustomServiceAction(action.className, servicesIds, scheduler._min_date, scheduler._max_date).then(function (res) {
                        sfdcService.getServicesById(servicesIds).then(function (fetchedServcices) {
                            var updatesServices = TimePhasedDataService.updateTimePhaseData(fetchedServcices, 'service').services;
                            servicesService.drawServicesAndAbsences(updatesServices, [], [], []);

                            if (res) {
                                utils.addNotification(action.name, res, null, null);
                            }
                        });
                    }).catch(function (ev) {
                        return utils.addNotification(action.name, ev.message, null, null);
                    });
                }
            };

            $scope.checkHasCustomPermission = function (actionName) {
                if (utils.hasCustomPermission('Bulk_' + actionName) == undefined) return true;

                return utils.hasCustomPermission('Bulk_' + actionName);
            };

            $scope.openBulkAction = function (title) {
                switch (title) {
                    case 'Schedule':
                        bulkScheduleService.schedule(ServiceSelectorService.getSelected());
                        break;

                    case 'Dispatch':
                        bulkDispatchService.open();
                        break;

                    case 'Unschedule':
                        bulkUnscheduleService.open();
                        break;

                    case 'Optimize':
                        optimizeLightboxService.open();
                        break;

                    case 'Flag-Unflag':

                        var selected = ServiceSelectorService.getSelected();

                        for (var i = 0; i < selected.length; i++) {
                            servicesService.flagged[selected[i]] = !servicesService.flagged[selected[i]];
                        }

                        updateViewDebounced();

                        break;
                }
            };
        }

        var template = '<div id="quickActionsButtons">\n\t\t\t                    <div id="actionQuickFirst" class="truncate quickActionBtn" ng-show="bulkActionsOrder.first.length && checkHasCustomPermission(actionNames[bulkActionsOrder.first[0].title].name)" ng-click="openBulkAction(bulkActionsOrder.first[0].title)" title="{{actionNames[bulkActionsOrder.first[0].title].name}}">\n\t\t\t\t\t\t\t\t\t{{actionNames[bulkActionsOrder.first[0].title].name}}\n\t\t\t\t\t\t\t\t</div>\n\t                        \t<div id="actionQuickSecond"\n\t\t\t\t\t\t\t\t\t class="truncate quickActionBtn"\n\t\t\t\t\t\t\t\t\t ng-show="bulkActionsOrder.second.length && checkHasCustomPermission(actionNames[bulkActionsOrder.second[0].title].name)"\n\t\t\t\t\t\t\t\t\t ng-click="openBulkAction(bulkActionsOrder.second[0].title)"\n\t\t\t\t\t\t\t\t\t title="{{actionNames[bulkActionsOrder.second[0].title].name}}">{{actionNames[bulkActionsOrder.second[0].title].name}}</div>\n\t\t                    \t<div class="truncate" id="ActionButton" ng-show="bulkActionsOrder.dropdown.length" cs-toggle="MainActionContainer">\n                                    <span ng-show="(!bulkActionsOrder.first.length &&\n                                                   !bulkActionsOrder.second.length) ||\n                                                   (!checkHasCustomPermission(actionNames[bulkActionsOrder.first[0].title].name) &&\n                                                   !checkHasCustomPermission(actionNames[bulkActionsOrder.second[0].title].name))">\n                                           ' + customLabels.Actions + '\n                                    </span>\n                                    <i class="fa fa-caret-down"></i>\n\t\t                    \t</div>\n\t                    \t</div>\n\t                    \t\n\t                        <div id="MainActionContainer">\n\t\t\t                    <div class="truncate BulkActionMenuItem" ng-repeat="action in bulkActionsOrder.dropdown" ng-show="checkHasCustomPermission(actionNames[action.title].name)" ng-click="openBulkAction(action.title)">\n\t\t\t\t\t\t\t\t\t<svg aria-hidden="true" class="slds-icon mainActionIcon">\n\t\t\t\t\t\t\t\t\t\t\u2028<use xlink:href="{{actionNames[action.title].icon}}"></use>\n\t\t\t\t\t\t\t\t\t\u2028</svg>\n\t\t\t\t\t\t\t\t\t{{actionNames[action.title].name}}\n                                </div>\n                                \n                                \n                                <div class="truncate BulkActionMenuItem" ng-repeat="action in customActions" ng-click="runCustomServiceAction(action)">\n                                \n                                    <svg aria-hidden="true" class="slds-icon mainCustomActionIcon">\n\t\t\t\t\t\t\t\t\t\t\u2028<use xlink:href="{{action.icon}}"></use>\n\t\t\t\t\t\t\t\t\t\u2028</svg>\n                                \n\t\t\t\t\t\t\t\t\t{{action.name}}\n                                </div>\n                                                               \n                                \n\t                        </div>';

        return {
            restrict: 'E',
            template: template,
            scope: {},
            controller: controllerFunction
        };
    }
})();