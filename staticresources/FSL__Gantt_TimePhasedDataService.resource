'use strict';

/*

 TimePhasedDataService
 This will hold all time phased data - services, absences, service resource resource territory, operating hours

 */

(function () {

    TimePhasedDataService.$inject = ['$q', '$rootScope', 'sfdcService', 'utils', '$injector'];

    angular.module('serviceExpert').factory('TimePhasedDataService', TimePhasedDataService);

    function TimePhasedDataService($q, $rootScope, sfdcService, utils, $injector) {

        var defferedObjects = {
            initialPhasedData: $q.defer()
        },
            _resourcesAndTerritories = {},
            _resourcesByPrimariesAndRelocations = {},
            _serviceAppointments = {},
            _resourceAbsences = {},
            _resourceCapacities = {},
            _serviceCrewMembers = {},
            _resourceToServiceCrewMembers = {},
            _crewToServiceCrewMembers = {},
            currentCrewToShow = {},
            isCrewViewActive = false,
            _visitedDates = {};

        function didVisitDay(date) {
            return _visitedDates[utils.formatDayToString(date)];
        }

        function isTimephaseAvailable(id, date) {

            var found = false;

            for (var key in _resourcesAndTerritories[id]) {
                var timephase = _resourcesAndTerritories[id][key];
                if (isIntersect(date, date, timephase.effectiveStartDate, timephase.effectiveEndDate)) {
                    found = true;
                }
            }

            return found;
        }

        function getTimePhasedObjects(start, finish) {

            var deffered = $q.defer();

            start.setDate(start.getDate() - window.daysToLoadOnGanttInit);
            finish.setDate(finish.getDate() + window.daysToLoadOnGanttInit);

            // align dates - from list date is 30/1/2016 23:59:00
            if (start.getMinutes() !== 0 || start.getHours() !== 0) {
                start.setHours(0);
                start.setMinutes(0);
            }
            if (finish.getMinutes() !== 0 || finish.getHours() !== 0) {
                finish.setHours(0);
                finish.setMinutes(0);

                finish.setDate(finish.getDate() + 1);
            }

            var needToBringData = false;

            for (var day = new Date(start); day < finish; day.setDate(day.getDate() + 1)) {
                if (typeof _visitedDates[utils.formatDayToString(day)] === 'undefined') {
                    needToBringData = true;
                    break;
                }
            }

            if (!needToBringData) {
                deffered.resolve();
                return deffered.promise;
            }

            var ultimateServicesPromise = $q.defer(),
                ultimateAbsencesPromise = $q.defer(),
                servicesIdsRetrivedFromServer = [];

            getRealTimePhasedObjects(ultimateServicesPromise, start, finish, true, null, null, servicesIdsRetrivedFromServer);
            getRealTimePhasedObjects(ultimateAbsencesPromise, start, finish, false, null, null);

            $q.all([ultimateAbsencesPromise.promise, ultimateServicesPromise.promise]).then(function (timephasedObjects) {

                if (Object.keys(servicesIdsRetrivedFromServer).length > 0) {
                    $rootScope.$broadcast('timePhasedObjectsCheckRules', servicesIdsRetrivedFromServer);
                }

                deffered.resolve(timephasedObjects);
            });

            return deffered.promise;
        }

        function getRealTimePhasedObjects(ultimateDeffered, start, finish, onlyServices, serviceOffset, absenceOffset, servicesIdsRetrivedFromServer) {

            // load time phased object when initialized
            sfdcService.GetTimePhasedObjects(start, finish, onlyServices, serviceOffset, absenceOffset).then(function (data) {

                handleGetTimePhasedObjectResult(ultimateDeffered, onlyServices, start, finish, data, servicesIdsRetrivedFromServer);
            }).catch(function (error) {
                defferedObjects.initialPhasedData.promise.$$state.status === 0 && defferedObjects.initialPhasedData.reject(error);
                console.warn('GetTimePhasedObjects: something went wrong ' + error.message);
                utils.addNotification(customLabels.Action_Could_Not_Be_Performed, error.message || customLabels.user_is_not_allowed_to_perform_action);

                if (numberOfAllowedRecoveries === 0) {
                    console.log('maximum allowed times to recover reached');
                    return;
                }

                numberOfAllowedRecoveries--;

                if (onlyServices) {
                    maxServicesToLoadEachBulkInGantt = Math.round(maxServicesToLoadEachBulkInGantt / 2);
                    console.log('%c getTimePhasedObjects - ENTERING RECOVERY MODE - NOW LOADING: ' + maxServicesToLoadEachBulkInGantt + ' SERVICES', 'background: #222; color: #bada55');
                } else {
                    maxAbsencesToLoadEachBulkInGantt = Math.round(maxAbsencesToLoadEachBulkInGantt / 2);
                    console.log('%c getTimePhasedObjects - ENTERING RECOVERY MODE - NOW LOADING: ' + maxAbsencesToLoadEachBulkInGantt + ' ABSENCES', 'background: #222; color: #bada55');
                }

                getTimePhasedObjects(start, finish);
            });
        }

        function handleGetTimePhasedObjectResult(ultimateDeffered, onlyServices, start, finish, data, servicesIdsRetrivedFromServer) {

            var monthlyViewHelperService = $injector.get('monthlyViewHelperService');

            var objectsToBroadcast = {
                resourcesAndTerritories: {},
                resourcesByPrimariesAndRelocations: {},
                resourceOperatingHours: {},
                serviceAppointments: {},
                resourceAbsences: {},
                resourceCapacities: {},
                serviceCrewMembers: {},
                start: start,
                finish: finish
            };

            // set visited dates
            for (var day = new Date(start); day < finish; day.setDate(day.getDate() + 1)) {
                _visitedDates[utils.formatDayToString(day)] = true;
            }

            // resolve only if it's the first call
            defferedObjects.initialPhasedData.promise.$$state.status === 0 && defferedObjects.initialPhasedData.resolve();

            data.resourcesAndTerritories.forEach(function (value) {
                var srrt = new ResourcesAndTerritories(value);

                _resourcesAndTerritories[srrt.serviceResource] = _resourcesAndTerritories[srrt.serviceResource] || {};
                _resourcesAndTerritories[srrt.serviceResource][srrt.id] = srrt;

                objectsToBroadcast.resourcesAndTerritories[srrt.serviceResource] = objectsToBroadcast.resourcesAndTerritories[srrt.serviceResource] || {};
                objectsToBroadcast.resourcesAndTerritories[srrt.serviceResource][srrt.id] = srrt;

                if (srrt.serviceTerritoryType !== 'S') {
                    _resourcesByPrimariesAndRelocations[srrt.serviceResource] = _resourcesByPrimariesAndRelocations[srrt.serviceResource] || {};
                    _resourcesByPrimariesAndRelocations[srrt.serviceResource][srrt.id] = srrt;

                    objectsToBroadcast.resourcesByPrimariesAndRelocations[srrt.serviceResource] = objectsToBroadcast.resourcesByPrimariesAndRelocations[srrt.serviceResource] || {};
                    objectsToBroadcast.resourcesByPrimariesAndRelocations[srrt.serviceResource][srrt.id] = srrt;
                }
            });

            data.services.forEach(function (value) {

                // object not modified
                var ganttService = new GanttService(value);

                if (!_serviceAppointments[ganttService.id] || _serviceAppointments[ganttService.id].isChanged(ganttService) || _serviceAppointments[ganttService.id].isChainChanged(ganttService)) {

                    _serviceAppointments[value.Id] = ganttService;
                    objectsToBroadcast.serviceAppointments[value.Id] = ganttService;

                    // add to check rules list only if service is scheduled
                    servicesIdsRetrivedFromServer.push(ganttService.id);

                    if (monthlyViewSettings.isMonthlyAvailable && !scheduler._events[ganttService.id] || scheduler._events[value.Id]) {
                        monthlyViewHelperService.updateMonthlyCapacity(ganttService);
                    }
                }
            });

            data.resourceAbsences.forEach(function (value) {

                // object not modified
                if (_resourceAbsences[value.Id] && value.LastModifiedDate === _resourceAbsences[value.Id].lastModifiedDate) {
                    return;
                }

                _resourceAbsences[value.Id] = new ResourceAbsence(value);
                objectsToBroadcast.resourceAbsences[value.Id] = _resourceAbsences[value.Id];

                monthlyViewHelperService.updateMonthlyCapacity(_resourceAbsences[value.Id]);
            });

            data.resourceCapacities.forEach(function (value) {

                // object not modified
                if (_resourceCapacities[value.Id] && value.LastModifiedDate === _resourceCapacities[value.Id].lastModifiedDate) {
                    return;
                }

                _resourceCapacities[value.Id] = new ResourceCapacity(value);

                //set capacity times according to user tz
                if (!useLocationTimezone) setResourceCapacityOffset(_resourceCapacities[value.Id]);

                objectsToBroadcast.resourceCapacities[value.Id] = _resourceCapacities[value.Id];
            });

            data.serviceCrewMembers.forEach(function (value) {

                //     // object not modified // TODO OMRI CREWS - add last modified field
                //     // if (serviceCrewMembers[value.Id] && value.LastModifiedDate === serviceCrewMembers[value.Id].lastModifiedDate) {
                //     //     return;
                //     // }

                _serviceCrewMembers[value.Id] = new ServiceCrewMember(value);

                if (!_resourceToServiceCrewMembers[_serviceCrewMembers[value.Id].serviceResource]) {
                    _resourceToServiceCrewMembers[_serviceCrewMembers[value.Id].serviceResource] = {};
                }

                if (!_crewToServiceCrewMembers[_serviceCrewMembers[value.Id].serviceCrew]) {
                    _crewToServiceCrewMembers[_serviceCrewMembers[value.Id].serviceCrew] = {};
                }

                _crewToServiceCrewMembers[_serviceCrewMembers[value.Id].serviceCrew][value.Id] = _serviceCrewMembers[value.Id];
                _resourceToServiceCrewMembers[_serviceCrewMembers[value.Id].serviceResource][value.Id] = _serviceCrewMembers[value.Id];
                objectsToBroadcast.serviceCrewMembers[value.Id] = _serviceCrewMembers[value.Id];
            });

            $rootScope.$broadcast('gotNewTimePhasedObjects', objectsToBroadcast);

            if (onlyServices && data.services.length === maxServicesToLoadEachBulkInGantt) {

                var offsetId = data.services[data.services.length - 1].Id;
                getRealTimePhasedObjects(ultimateDeffered, start, finish, onlyServices, offsetId, null, servicesIdsRetrivedFromServer);
            } else if (!onlyServices && data.resourceAbsences.length === maxAbsencesToLoadEachBulkInGantt) {

                var _offsetId = data.resourceAbsences[data.resourceAbsences.length - 1].Id;
                getRealTimePhasedObjects(ultimateDeffered, start, finish, onlyServices, null, _offsetId);
            } else {
                ultimateDeffered.resolve();
            }
        }

        function setResourceCapacityOffset(resourceCapacity) {
            var userStartOffset = utils.getUserOffset(resourceCapacity.start_date);
            var userEndOffset = utils.getUserOffset(resourceCapacity.end_date);
            var offsetInMinutes = getIntersectingSrstOffset(resourceCapacity, resourceCapacity.resource);
            resourceCapacity.start_date = resourceCapacity.start_date.setMinutes(resourceCapacity.start_date.getMinutes() + userStartOffset - offsetInMinutes);
            resourceCapacity.end_date = resourceCapacity.end_date.setMinutes(resourceCapacity.end_date.getMinutes() + userEndOffset - offsetInMinutes);
        }

        // get 1 or array of SObjects, updates if needed and return array of parsed objects as saved on the factory
        function updateTimePhaseData(objects, type) {
            var force = arguments.length > 2 && arguments[2] !== undefined ? arguments[2] : false;


            var monthlyViewHelperService = $injector.get('monthlyViewHelperService');
            var GanttPalettesService = $injector.get('GanttPalettesService');

            var updatedObjects = {
                absences: [],
                services: [],
                capacities: []
            };

            if (!Array.isArray(objects)) {
                objects = [objects];
            }

            objects.forEach(function (object) {
                if (type === 'na') {
                    if (force || _resourceAbsences[object.Id] && object.LastModifiedDate === _resourceAbsences[object.Id].lastModifiedDate) {
                        return;
                    } else {
                        _resourceAbsences[object.Id] = new ResourceAbsence(object);
                        updatedObjects.absences.push(_resourceAbsences[object.Id]);

                        monthlyViewHelperService.updateMonthlyCapacity(_resourceAbsences[object.Id]);
                    }
                }

                if (type === 'service') {

                    var ganttService = new GanttService(object);

                    GanttPalettesService.updateGanttServicePaletteColor(ganttService);

                    if (force || !_serviceAppointments[ganttService.id] || _serviceAppointments[ganttService.id].isChanged(ganttService) || _serviceAppointments[ganttService.id].isChainChanged(ganttService)) {

                        _serviceAppointments[object.Id] = ganttService;
                        updatedObjects.services.push(ganttService);

                        if (scheduler._events[ganttService.id] && scheduler._events[ganttService.id].violations && ganttService.isScheduled()) {
                            ganttService.violations = scheduler._events[ganttService.id].violations;
                        }

                        if (monthlyViewSettings.isMonthlyAvailable && !scheduler._events[ganttService.id] || scheduler._events[object.Id]) {
                            monthlyViewHelperService.updateMonthlyCapacity(ganttService);
                        }
                    }
                }

                if (type === 'capacity') {
                    if (_resourceCapacities[object.Id] && object.LastModifiedDate === _resourceCapacities[object.Id].lastModifiedDate) {
                        return;
                    } else {
                        _resourceCapacities[object.Id] = new ResourceCapacity(object);

                        //set capacity times according to user tz
                        if (!useLocationTimezone) setResourceCapacityOffset(_resourceCapacities[object.Id]);

                        updatedObjects.capacities.push(_resourceCapacities[object.Id]);
                    }
                }

                if (type === 'stm') {
                    var srrt = new ResourcesAndTerritories(object);

                    _resourcesAndTerritories[srrt.serviceResource] = _resourcesAndTerritories[srrt.serviceResource] || {};
                    _resourcesAndTerritories[srrt.serviceResource][srrt.id] = srrt;

                    if (srrt.serviceTerritoryType !== 'S') {
                        _resourcesByPrimariesAndRelocations[srrt.serviceResource] = _resourcesByPrimariesAndRelocations[srrt.serviceResource] || {};
                        _resourcesByPrimariesAndRelocations[srrt.serviceResource][srrt.id] = srrt;
                    }
                }
            });

            return updatedObjects;
        }

        // delete objects
        function deleteTimePhaseData(objects, type) {

            var monthlyViewHelperService = $injector.get('monthlyViewHelperService'),
                deletedObjectsIds = {
                absences: [],
                services: [],
                capacities: []
            };

            if (!Array.isArray(objects)) {
                objects = [objects];
            }

            objects.forEach(function (object) {
                if (type === 'na') {
                    if (_resourceAbsences[object.Id]) {
                        _resourceAbsences[object.Id].isDeleted = true;
                    }

                    if (_resourceAbsences[object.Id]) {
                        monthlyViewHelperService.updateMonthlyCapacity(_resourceAbsences[object.Id]);
                    }

                    delete _resourceAbsences[object.Id];
                    deletedObjectsIds.absences.push(object.Id);
                } else if (type === 'service') {
                    if (_serviceAppointments[object.Id]) {
                        _serviceAppointments[object.Id].isDeleted = true;
                    }
                    monthlyViewHelperService.updateMonthlyCapacity(_serviceAppointments[object.Id]);
                    delete _serviceAppointments[object.Id];
                    deletedObjectsIds.services.push(object.Id);
                } else if (type === 'capacity') {
                    delete _resourceCapacities[object.Id];
                    deletedObjectsIds.capacities.push(object.Id);
                }
            });

            return deletedObjectsIds;
        }

        function reset() {
            _resourcesAndTerritories = {}, _resourcesByPrimariesAndRelocations = {}, _serviceAppointments = {}, _resourceAbsences = {}, _resourceCapacities = {}, _serviceCrewMembers = {}, currentCrewToShow = {}, _resourceToServiceCrewMembers = {}, _crewToServiceCrewMembers = {}, _visitedDates = {};
        }

        function getResoruceGanttIdByDate(resourceId, date) {

            // checking for relocation first
            for (var timephaseId in _resourcesAndTerritories[resourceId]) {

                var rsrt = _resourcesAndTerritories[resourceId][timephaseId];

                if (rsrt.effectiveStartDate <= date && date <= rsrt.effectiveEndDate && rsrt.serviceTerritoryType === 'R') {
                    return utils.generateResourceId(resourceId, rsrt.serviceTerritory);
                }
            }

            // and now primary
            var srsts = [];
            for (var _timephaseId in _resourcesAndTerritories[resourceId]) {

                var _rsrt = _resourcesAndTerritories[resourceId][_timephaseId];

                if (!showSecondarySTMs) {
                    if (_rsrt.effectiveStartDate <= date && date <= _rsrt.effectiveEndDate && _rsrt.serviceTerritoryType === 'P') {
                        return utils.generateResourceId(resourceId, _rsrt.serviceTerritory);
                    }
                }

                if (_rsrt.effectiveStartDate <= date && date <= _rsrt.effectiveEndDate) {
                    srsts.push(_rsrt.serviceTerritory);
                }
            }
            if (srsts.length > 0) return utils.generateResourceId(resourceId, srsts);

            // not found, resource isn't available in this date
            return null;
        }

        function getResoruceGanttIdByDateAndTerritory(resourceId, date, territory) {

            // checking for relocation first
            for (var timephaseId in _resourcesAndTerritories[resourceId]) {

                var rsrt = _resourcesAndTerritories[resourceId][timephaseId];

                if (rsrt.effectiveStartDate <= date && date <= rsrt.effectiveEndDate && rsrt.serviceTerritoryType === 'R') {
                    return utils.generateResourceId(resourceId, rsrt.serviceTerritory);
                }
            }

            // and now primary
            var foundTerritory = null,
                primaryTer = null;
            for (var _timephaseId2 in _resourcesAndTerritories[resourceId]) {

                var _rsrt2 = _resourcesAndTerritories[resourceId][_timephaseId2];
                if (_rsrt2.effectiveStartDate <= date && date <= _rsrt2.effectiveEndDate && _rsrt2.serviceTerritoryType === 'P') primaryTer = _rsrt2.serviceTerritory;

                if (_rsrt2.effectiveStartDate <= date && date <= _rsrt2.effectiveEndDate && _rsrt2.serviceTerritory === territory) {
                    foundTerritory = _rsrt2.serviceTerritory;
                }
            }

            if (foundTerritory) return utils.generateResourceId(resourceId, foundTerritory);else primaryTer;
            return utils.generateResourceId(resourceId, primaryTer);
        }

        function getIntersectingSrstOffset(changedObj, resourceId) {
            //1 - get correct srst and Tz
            var resourceTimePhases = _resourcesAndTerritories[resourceId],
                effectiveSRST = null;

            // go over all time phases of the specific resource
            for (var tpKey in resourceTimePhases) {
                var timephase = resourceTimePhases[tpKey];

                if (isIntersect(timephase.effectiveStartDate, timephase.effectiveEndDate, changedObj.start_date, changedObj.end_date)) {
                    effectiveSRST = timephase;

                    if (timephase.serviceTerritoryType === 'R') break;
                }
            }

            var timezone = effectiveSRST && effectiveSRST.timezone ? effectiveSRST.timezone : 'GMT';

            //2 - return territory offset by SRST
            return -moment.tz.zone(timezone).offset(utils.convertDtToMomentDt(changedObj.start_date, timezone).valueOf());
        }

        function getRelevantSTMToGanttService(ganttService) {

            if (ganttService.resourceId) {
                var resourceId = ganttService.resourceId.split('_')[0];
                var territoryId = ganttService.resourceId.split('_')[1];

                var resourceTimePhases = _resourcesAndTerritories[resourceId];

                // go over all time phases of the specific resource
                for (var tpKey in resourceTimePhases) {
                    var timephase = resourceTimePhases[tpKey];

                    if (isIntersect(timephase.effectiveStartDate, timephase.effectiveEndDate, ganttService.start_date, ganttService.end_date)) {
                        return timephase;
                    }
                }
            }

            return null;
        }

        function isResourceRelocated(resourceIdOnGantt, date) {

            var resourceId = resourceIdOnGantt.split('_')[0],
                territory = resourceIdOnGantt.split('_')[1],
                resourceMembers = _resourcesAndTerritories[resourceId] || {};

            for (var memberId in resourceMembers) {

                var resourceMember = resourceMembers[memberId];

                //resourceMember.serviceTerritory === territory

                if (resourceMember.serviceTerritory !== territory && resourceMember.serviceTerritoryType === 'R' && isIntersect(resourceMember.effectiveStartDate, resourceMember.effectiveEndDate, date, date)) {
                    return true;
                }
            }

            return false;
        }

        function isResourceSecondary(resourceIdOnGantt, date) {

            var resourceId = resourceIdOnGantt.split('_')[0],
                territory = resourceIdOnGantt.split('_')[1],
                resourceMembers = _resourcesAndTerritories[resourceId] || {};

            for (var memberId in resourceMembers) {

                var resourceMember = resourceMembers[memberId];
                if (resourceMember.serviceTerritory === territory && resourceMember.serviceTerritoryType === 'S' && isIntersect(resourceMember.effectiveStartDate, resourceMember.effectiveEndDate, date, date)) {
                    return true;
                }
            }

            return false;
        }

        function isResourceCrewMembers(resourceIdOnGantt, date) {

            var resourceId = resourceIdOnGantt.split('_')[0],
                territory = resourceIdOnGantt.split('_')[1],
                resourceCrewMembers = _resourceToServiceCrewMembers[resourceId] || {};

            for (var memberId in resourceCrewMembers) {

                var resourceMember = resourceCrewMembers[memberId];
                if (isIntersect(resourceMember.startDate, resourceMember.endDate, date, date)) {
                    return true;
                }
            }

            return false;
        }

        // This will be our factory
        return {
            resourcesAndTerritories: function resourcesAndTerritories() {
                return _resourcesAndTerritories;
            },
            resourcesByPrimariesAndRelocations: function resourcesByPrimariesAndRelocations() {
                return _resourcesByPrimariesAndRelocations;
            },
            serviceAppointments: function serviceAppointments() {
                return _serviceAppointments;
            },
            resourceAbsences: function resourceAbsences() {
                return _resourceAbsences;
            },
            resourceCapacities: function resourceCapacities() {
                return _resourceCapacities;
            },
            resourceToServiceCrewMembers: function resourceToServiceCrewMembers() {
                return _resourceToServiceCrewMembers;
            },
            crewToServiceCrewMembers: function crewToServiceCrewMembers() {
                return _crewToServiceCrewMembers;
            },
            serviceCrewMembers: function serviceCrewMembers() {
                return _serviceCrewMembers;
            },
            visitedDates: function visitedDates() {
                return _visitedDates;
            },
            getRelevantSTMToGanttService: getRelevantSTMToGanttService,
            getTimePhasedObjects: getTimePhasedObjects,
            updateTimePhaseData: updateTimePhaseData,
            deleteTimePhaseData: deleteTimePhaseData,
            reset: reset,
            getResoruceGanttIdByDate: getResoruceGanttIdByDate,
            getResoruceGanttIdByDateAndTerritory: getResoruceGanttIdByDateAndTerritory,
            getIntersectingSrstOffset: getIntersectingSrstOffset,
            didVisitDay: didVisitDay,
            isTimephaseAvailable: isTimephaseAvailable,
            isResourceRelocated: isResourceRelocated,
            isResourceSecondary: isResourceSecondary,
            isResourceCrewMembers: isResourceCrewMembers,
            isCrewViewActive: isCrewViewActive,
            currentCrewToShow: currentCrewToShow,
            promises: {
                initialPhasedData: defferedObjects.initialPhasedData.promise
            }
        };
    }
})();