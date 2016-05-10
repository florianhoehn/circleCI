(function () {
    'use strict';
    angular.module('main',
                  ['ui.router',
                  'ngRemote',
                  'accounts']);
})();
(function () {
    'use strict';
    angular.module('accounts',
                  ['ui.router',
                  'contacts']);
})();
(function () {
    'use strict';
    angular.module('contacts',
                  ['ui.router']);
})();
(function () {
    'use strict';
    angular
    .module('main')
    .config(function($stateProvider, $urlRouterProvider) {
        $stateProvider
        .state('root', {
            url: '',
            abstract: true,
            views: {
                'header': {
                    templateUrl: 'header'
                },
                'footer': {
                    templateUrl: 'footer'
                }
            }
        })
        .state('root.ooops', {
            url: '/ooops',
            views: {
                'mainSection@': {
                    templateUrl: 'ooops'
                }
            }
        });
        $urlRouterProvider.otherwise('/accounts');
    });
})();
(function () {
    'use strict';
    angular
    .module('main')
    .run(['$rootScope',
          '$state',
          '$location',
          '$window',
          function ($rootScope, $state, $location, $window) {
        $rootScope.$on('$stateChangeStart', function() {
            $rootScope.stateIsLoading = true;
        });

        $rootScope.$on('$stateChangeSuccess', function() {
            $rootScope.stateIsLoading = false;
        });

        $rootScope.$on('$stateChangeError', function(event, toState, toParams, fromState, fromParams, error) {
            $state.go('root.ooops');
        });
    }]);
})();
(function () {
    'use strict';
    angular
    .module('accounts')
    .controller('accountListController',
                ['accountService',
                'massAccountService',
                function(accountService, massAccountService) {
        var vm = this;
        vm.accounts = [];
        vm.massAccounts = [];

        activate();
        
        function activate() {
            accountService.retrieveRecentItems(5)
                          .then(function(result) {
                if(result) {
                    vm.accounts = result;
                }
            }, function(error) {
                console.log('accountListController:accountService:retrieveRecentItems:error:', error);
            });

            massAccountService.getAll()
                              .then(function(result) {
                if(result) {
                    vm.massAccounts = result;
                }
            }, function(error) {
                console.log('accountListController:massAccountService:getAll:error:', error);
            });
        }
    }]);
})();
(function () {
    'use strict';
    angular
    .module('accounts')
    .config(function($stateProvider) {
        $stateProvider
        .state('root.accounts',{
            url: '/accounts',
            views: {
                'mainSection@': {
                    templateUrl: 'accounts',
                    controller: 'accountListController',
                    controllerAs: 'vm'
                }
            }
        });
    });
})();
(function () {
    'use strict';
    angular
    .module('contacts')
    .controller('contactListController',
                ['$stateParams',
                'contactService',
                function($stateParams, contactService) {
        var vm = this;
        vm.contacts = [];

        activate();
        
        function activate() {
            // still going through ngRemote -> only gets the result array
            contactService.retrieveByParentId('AccountId', $stateParams.accountId, 5)
                          .then(function(result) {
                if(result) {
                    console.log('You got some extra?', result); // NO!
                    vm.contacts = result;
                }
            }, function(error) {
                console.log('contactListController:contactService:retrieveRecentItems:error:', error);
            });
        }
    }]);
})();
(function () {
    'use strict';
    angular
    .module('contacts')
    .config(function($stateProvider) {
        $stateProvider
        .state('root.accounts.contacts',{
            url: '/contacts/{accountId}',
            views: {
                'contacts@root.accounts': {
                    templateUrl: 'contacts',
                    controller: 'contactListController',
                    controllerAs: 'vm'
                }
            }
        });
    });
})();
(function () {
    'use strict';
    angular
    .module('accounts')
    .factory('massAccountService',
            ['$q',
            function ($q) {
        var service = {
            getAll : getAll
        };

        return service;

        function getAll() {
            var deferred = $q.defer();
            
            Visualforce.remoting.Manager.invokeAction(
                'DemoController.getAll',
                function(result,
                         event) {
                    if(event.status && result) {
                        deferred.resolve(result);
                    } else {
                        deferred.reject(event);
                    }
                }, {
                    buffer: true,
                    escape: false,
                    timeout: 30000
                }
            );

            return deferred.promise;
        }
    }]);
})();