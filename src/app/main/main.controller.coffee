app = angular.module 'coolnameFrontend'

app.controller('MainController', ["$scope", "$timeout", "Restangular", "$mdDialog", "$mdMedia", "$mdToast"
  ($scope, $timeout, Restangular, $mdDialog, $mdMedia, $mdToast) ->

    $scope.customFullscreen = $mdMedia('xs') || $mdMedia('sm')
    $scope.word = {name:"Potato", definition:"The best vegetable"}
    console.dir $scope.word
    console.log "Main controller engaged"
    recWordCount = 0
    user = {username: "TheUser", id: ""}
		
    Restangular.all("related").getList().then((words) ->
      $scope.words = words
      $scope.word = words[recWordCount]
    )

    $scope.addWord = (word) ->
      # POST word to words
      Restangular.all("words").post(word)
      Restangular.all("related").getList().then((words) ->
        $scope.words = words
        $scope.word = words[recWordCount]
      )     
    
    $scope.saveWord = () ->
      # POST word to words
      Restangular.all("words").post(word)
      recWordCount++
      $scope.word = $scope.words[recWordCount]
      if recWordCount == 49
        Restangular.all("related").getList().then((words) ->
          recWordcount = 0
          $scope.words = words
          $scope.word = words[recWordCount]
          $mdToast.show(
            $mdToast.simple()
              .textContent("Word added!")
              .position("top right")
              .hideDelay(2000)
          )
        )             

    $scope.removeWord = () ->
      recWordCount++
      $scope.word = $scope.words[recWordCount]
      if recWordCount == 49
        Restangular.all("related").getList().then((words) ->
          recWordcount = 0
          $scope.words = words
          $scope.word = words[recWordCount]
        )      

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

DialogController = ["$scope", "$mdDialog", "name", "definition",
  ($scope, $mdDialog, name, definition) ->
    $scope.name = name
    $scope.definition = definition

    $scope.hide = () ->
      $mdDialog.hide()

]