angular.module 'coolnameFrontend'
  .config ($logProvider, toastrConfig) ->
    'ngInject'
    # Enable log
    $logProvider.debugEnabled true
    # Set options third-party lib
    toastrConfig.allowHtml = true
    toastrConfig.timeOut = 3000
    toastrConfig.positionClass = 'toast-top-right'
    toastrConfig.preventDuplicates = true
    toastrConfig.progressBar = true
  .config (RestangularProvider) ->
    RestangularProvider.setBaseUrl("http://172.20.2.117:8080")
  .config ($mdThemingProvider) ->
    $mdThemingProvider.theme("default")
      .primaryPalette("lime", {'default': '600'})
      .accentPalette("pink", {'default' : '300'})
      .backgroundPalette('amber', {'default': '300'})
