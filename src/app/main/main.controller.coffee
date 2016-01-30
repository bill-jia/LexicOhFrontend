app = angular.module 'coolnameFrontend'

app.controller('MainController', ["$scope", "$timeout", "Restangular", "$mdDialog", "$mdMedia", "$mdToast"
    ($scope, $timeout, Restangular, $mdDialog, $mdMedia, $mdToast) ->

      $scope.customFullscreen = $mdMedia('xs') || $mdMedia('sm')
      $scope.words = [{name: "Potato", definition: "The best vegetable"}, {name: "Broccoli", definition: "The worst vegetable"}]
      console.log "Main controller engaged"
      recWordCount = 0
      user = {username: "TheUser", id: ""}
      $scope.word = $scope.words[recWordCount]
  		
      Restangular.all("related").getList().then((words) ->
        $scope.words = words
        console.dir $scope.words
        # $scope.word = words[recWordCount]
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
        # Restangular.all("words").post(word)
        recWordCount++
        console.log recWordCount
        if recWordCount > 1
        #   Restangular.all("related").getList().then((words) ->
        #   console.log "Greater than 1"
          recWordCount = 0
        #     $scope.words = words
          $scope.word = words[recWordCount]
        #     $mdToast.show(
        #       $mdToast.simple()
        #         .textContent("Word added!")
        #         .position("top right")
        #         .hideDelay(2000)
        #     )
        #   )
        else        
          $scope.word = $scope.words[recWordCount]
             

      $scope.removeWord = () ->
        recWordCount++
        console.log recWordCount
        if recWordCount > 1
        #   Restangular.all("related").getList().then((words) ->
          console.log "Greater than 1"
          recWordCount = 0
            # $scope.words = words
          $scope.word = $scope.words[recWordCount]
        #   )
        else      
          $scope.word = $scope.words[recWordCount]


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

app.animation

DialogController = ["$scope", "$mdDialog", "name", "definition",
  ($scope, $mdDialog, name, definition) ->
    $scope.name = name
    $scope.definition = definition

    $scope.hide = () ->
      $mdDialog.hide()

]