app = angular.module 'coolnameFrontend'

app.controller('MainController', ["$scope", "$timeout", "WordService", "UserService", "$mdDialog", "$mdMedia"
  ($scope, $timeout, WordService, UserService, $mdDialog, $mdMedia) ->

    $scope.customFullscreen = $mdMedia('xs') || $mdMedia('sm')
    $scope.word = {name:"Potato", definition:"The best vegetable"}
    console.dir $scope.word
    console.log "Main controller engaged"

			
		# UserService.getUser(1).then((user) ->
		# 	$scope.user = user
		# 	wordId = user.words[0]
		# 	WordService.getWord(1).then((word) ->
		# 		$scope.word = word
		# 	)
    # )
    
    $scope.saveWord = () ->
      $scope.word.name = $scope.word.name + "s"

    $scope.removeWord = () ->
      $scope.word.name = $scope.word.name.slice(0,$scope.word.name.length-1)

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