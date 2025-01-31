﻿
'use strict';

angular.module('gedApplication.datetimepicker', [])
        .provider('datetimepicker', function () {
            var default_options = {};

            this.setOptions = function (options) {
                default_options = options;
            };

            this.$get = function () {
                return {
                    getOptions: function () {
                        return default_options;
                    }
                };
            };
        })
        .directive('datetimepicker', [
            '$timeout',
            'datetimepicker',
            function ($timeout,
                datetimepicker) {

                var default_options = datetimepicker.getOptions();

                return {
                    require: '?ngModel',
                    restrict: 'AE',
                    scope: {
                        datetimepickerOptions: '@'
                    },
                    link: function ($scope, $element, $attrs, ngModelCtrl) {
                        var passed_in_options = $scope.$eval($attrs.datetimepickerOptions);
                        var options = jQuery.extend({}, default_options, passed_in_options);

                        $element
                            .on('dp.change', function (e) {
                                if (ngModelCtrl) {
                                    $timeout(function () {
                                        if (e) {
                                            var date = e.date;
                                            if (date) {
                                                ngModelCtrl.$setViewValue(date.format(options.format));
                                            }
                                        }
                                    });
                                }
                            })
                            .datetimepicker(options);

                        function setPickerValue() {
                            var date = options.defaultDate || null;

                            if (ngModelCtrl && ngModelCtrl.$viewValue) {
                                date = ngModelCtrl.$viewValue;
                            }

                            $element
                                .data('DateTimePicker')
                                .date(date);
                        }

                        if (ngModelCtrl) {
                            ngModelCtrl.$render = function () {
                                setPickerValue();
                            };
                        }

                        setPickerValue();
                    }
                };
            }
        ]);