app = angular.module 'coolnameFrontend'

app.controller('MainController', ["$scope", "$timeout", "Restangular", "$mdDialog", "$mdMedia", "$mdToast"
    ($scope, $timeout, Restangular, $mdDialog, $mdMedia, $mdToast) ->

      $scope.customFullscreen = $mdMedia('xs') || $mdMedia('sm')
      $scope.words = [{word: "Potato", definition: "The best vegetable"}, {word: "Broccoli", definition: "The worst vegetable"}]
      console.log "Main controller engaged"
      recWordCount = 0
      maxWords = 0
      user = {username: "TheUser", id: ""}
      $scope.word = $scope.words[recWordCount]
  		
      Restangular.all("related").all("all").getList().then((words) ->
        $scope.words = words
        maxWords = $scope.words.length
        console.log maxWords
        console.dir $scope.words
        $scope.word = words[recWordCount]
      )

      $scope.addWord = (word) ->
        # POST word to words
        Restangular.all("words").post(word)
        Restangular.all("related").all("all").getList().then((words) ->
          $scope.words = words
          $scope.word = words[recWordCount]
        )
      
      $scope.saveWord = () ->
        # POST word to words
        # Restangular.all("words").post($scope.word)
        recWordCount++
        console.log recWordCount
        if recWordCount > maxWords-1
          Restangular.all("related").all("all").getList().then((words) ->
            console.log "Words reloaded"
            recWordCount = 0
            $scope.words = words
            $scope.word = words[recWordCount]
          )
        else        
          $scope.word = $scope.words[recWordCount]
        console.log "Word saved"
        $mdToast.show({
          controller: ""
          templateUrl: "app/main/toast.html"
          template: "Word Added!"
          hideDelay: 2000
          position: "top right"          
        })
             

      $scope.removeWord = () ->
        recWordCount++
        console.log recWordCount
        if recWordCount > maxWords-1
          Restangular.all("related").all("all").getList().then((words) ->
            console.log "Words reloaded"
            recWordCount = 0
            $scope.words = words
            $scope.word = $scope.words[recWordCount]
          )
        else      
          $scope.word = $scope.words[recWordCount]
        console.log "Word rejected"

      $scope.openDef = (ev) ->
        useFullScreen = ($mdMedia('sm') || $mdMedia('xs')) && $scope.customFullscreen

        $mdDialog.show({
          controller: DialogController
          templateUrl: "app/main/definition.html"
          parent: angular.element(document.body)
          targetEvent: ev
          clickOutsideToClose: true
          fullscreen: useFullScreen
          locals: {
            name: $scope.word.name
            definition: $scope.word.definition
          }
        })
])

app.animation(".slide", () ->
  addClass: (element, className, done) ->
    scope = element.scope()

    if className == 'ng-hide'
      finishPoint = element.parent().width()
      if scope.direction is 'left'
        finishPoint = -finishPoint

    else
      done()
    return
  removeClass: (element, className, done) ->
    scope = element.scope()

    if className == 'ng-hide'
      element.removeClass 'ng-hide'

      startPoint = element.parent().width()
      if scope.direction is 'right'
        startPoint = -startPoint

    else
      done()
    return
)


DialogController = ["$scope", "$mdDialog", "name", "definition",
  ($scope, $mdDialog, name, definition) ->
    $scope.name = name
    $scope.definition = definition

    $scope.hide = () ->
      $mdDialog.hide()

]