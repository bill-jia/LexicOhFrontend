app = angular.module 'coolnameFrontend'

app.controller('MainController', ["$scope", "$timeout", "WordService", "UserService", "RecommendService", "$mdDialog", "$mdMedia"
  ($scope, $timeout, WordService, UserService, RecommendService, $mdDialog, $mdMedia) ->

    $scope.customFullscreen = $mdMedia('xs') || $mdMedia('sm')
    $scope.word = {name:"Potato", definition:"The best vegetable"}
    console.dir $scope.word
    console.log "Main controller engaged"
    recWordCount = 0
			
    UserService.getUser(1).then((user) ->
      $scope.user = user
      wordId = user.recWords[recWordcount]
      RecommendService.getWord(user.id, wordId).then((word) ->
        $scope.word = word
      )
    )
    
    $scope.saveWord = () ->
      recWordCount++
      wordId = $scope.user.recWords[recWordCount]
      RecommendService.getWord($scope.user.id, wordId).then((word) ->
        $scope.word = word
      )

    $scope.removeWord = () ->
      recWordCount++
      wordId = $scope.user.words[recWordCount]
      RecommendService.getWord(wordId).then((word) ->
        $scope.word = word
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