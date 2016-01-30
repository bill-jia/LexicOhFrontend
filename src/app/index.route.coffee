angular.module 'coolnameFrontend'
  .config ($stateProvider, $urlRouterProvider) ->
    'ngInject'
    $stateProvider
      .state 'home',
        url: '/'
        templateUrl: 'app/main/main.html'
        controller: 'MainController'
      .state 'learn',
        url: '/learn'
        templateUrl: 'app/components/learn/index.html'
        controller: 'LearnIndexController'
      .state 'login',
        url: '/login'
        templateUrl: 'app/components/login/login.html'
        controller: 'SessionController'
      .state 'signin',
        url: '/user/new'
        templateUrl: 'app/components/user/new.html'
        controller: 'UserNewController'


    $urlRouterProvider.otherwise '/'
