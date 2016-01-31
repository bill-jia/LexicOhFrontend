app = angular.module 'coolnameFrontend'

app.controller('MainController', ["$scope", "$timeout", "Restangular", "$mdDialog", "$mdMedia", "$mdToast", "$mdBottomSheet", "$speechRecognition", "$cordovaCamera", "$rootScope"
    ($scope, $timeout, Restangular, $mdDialog, $mdMedia, $mdToast, $mdBottomSheet, $speechRecognition, $cordovaCamera, $rootScope) ->


      maxWords = 2
      leftWords = []
      rightWords = []


      $scope.listening = false
      $scope.speechInput = []
      $scope.ocrInput = []
      $scope.customFullscreen = $mdMedia('xs') || $mdMedia('sm')
      $scope.words = [{word: "Potato", definition: "The best vegetable"}, {word: "Broccoli", definition: "The worst vegetable"}]
      $scope.direction = "left"
      $scope.currIndex = 0
      $scope.word = $scope.words[$scope.currIndex]
  		
      Restangular.all("related").getList().then((words) ->
        $scope.currIndex = 0
        $scope.words = words
        maxWords = $scope.words.length
        $scope.word = words[$scope.currIndex]
      )

      Restangular.all("words").getList().then((words)->
        $scope.learnedWords = words
      )

      $scope.isCurrentIndex = (index) ->
        index is $scope.currIndex

      $scope.addWord = (word) ->
        # POST word to words
        Restangular.all("words").post(word)
        Restangular.all("related").post(word).then((words) ->
          $scope.currIndex = 0
          $scope.words = words
          maxWords = $scope.words.length
          $scope.word = words[$scope.currIndex]
        )
      
      $scope.saveWord = () ->
        # POST word to words
        # Restangular.all("words").post($scope.word)
        $scope.direction = "right"
        $scope.currIndex++
        console.log $scope.currIndex
        rightWords.push($scope.word.word)

        if $scope.currIndex > maxWords-1
          maxWords = $scope.words.length
          $scope.currIndex = 0
          Restangular.all("related").getList().then((words) ->
            console.log "Words reloaded"
            $scope.currIndex = 0
            $scope.words = words
            maxWords = $scope.words.length
            $scope.word = words[$scope.currIndex]
          )
        else        
          $scope.word = $scope.words[$scope.currIndex]
        console.log "Word saved"
        $mdToast.show({
          controller: ""
          templateUrl: "app/main/toast.html"
          template: "Word Added!"
          hideDelay: 2000
          position: "top right"          
        })

        console.dir rightWords
        if rightWords.length > 9
          console.log "Posting words"
          Restangular.all("words").all("acceptedWords").customPOST(rightWords).then(()->)
          rightWords = []
        


             

      $scope.removeWord = () ->
        $scope.direction = "left"
        $scope.currIndex++
        console.log $scope.currIndex
        leftWords.push($scope.word.word)
        
        if $scope.currIndex > maxWords-1
          maxWords = $scope.words.length
          $scope.currIndex = 0
          Restangular.all("related").getList().then((words) ->
            console.log "Words reloaded"
            maxWords = $scope.words.length            
            $scope.currIndex = 0
            $scope.words = words
            $scope.word = $scope.words[$scope.currIndex]
          )
        else      
          $scope.word = $scope.words[$scope.currIndex]
        console.log "Word rejected"

        console.dir leftWords
        if leftWords.length > 9
          console.log "Posting words"
          Restangular.all("words").all("discardedWords").customPOST(leftWords).then(()->)
          leftWords = []

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

      $scope.openInput = (ev) ->
        useFullScreen = ($mdMedia('sm') || $mdMedia('xs')) && $scope.customFullscreen
        
        $mdDialog.show({
          controller: InputDialogController
          templateUrl: "app/main/inputword.html"
          parent: angular.element(document.body)
          targetEvent: ev
          clickOutsideToClose: true
          fullscreen: useFullScreen
        }).then(
          (word) ->
            console.log word
            $scope.addWord(word)
          () ->
            console.log "dialog closed"
        )

      $scope.showBottomSheet = ($event) ->
        $mdBottomSheet.show({
          templateUrl: 'app/main/learnedwords.html'
          controller: BottomSheetController
          targetEvent: $event
          locals: {
            words: $scope.learnedWords
          }
        }).then(
          (word) ->
            $scope.words = []
            $scope.currIndex = 0
            $scope.words.push(word)
            maxWords = 1
        )

      $scope.toggleSpeechInput = () ->
        if $scope.listening
          $speechRecognition.stopListening()
          $scope.listening = false
          $rootScope.$on('finishedSpeechProcessing', ()->
            console.log "Begin POST"
            Restangular.all("related").all("multipleWords").customPOST($scope.speechInput).then((words) ->
                console.log "Words reloaded"
                maxWords = $scope.words.length            
                $scope.currIndex = 0
                $scope.words = words
                $scope.word = $scope.words[$scope.currIndex])
            )          
          )          
        else
          $speechRecognition.listen()
          $scope.listening = true

      $speechRecognition.onUtterance((utterance) ->
        tmpArray = utterance.split(" ")
        for word in tmpArray
          $scope.speechInput.push word

        console.dir $scope.speechInput
        $rootScope.$broadcast('finishedSpeechProcessing')
      )



      $scope.takePictureInput = () ->
        document.addEventListener "deviceready", () ->
          
          options =
            quality: 50,
            destinationType: Camera.DestinationType.DATA_URL,
            sourceType: Camera.PictureSourceType.CAMERA,
            allowEdit: true,
            encodingType: Camera.EncodingType.JPEG,
            targetWidth: 100,
            targetHeight: 100,
            popoverOptions: CameraPopoverOptions,
            saveToPhotoAlbum: false,
            correctOrientation:true

          $cordovaCamera.getPicture(options).then(
            (imageData) ->
              inputString = ocrad(imageData)
              inputString = inputString.replace(/[.,\/#!$%\^&\*;:{}=\-_`~()]/g,"")
              inputWords = inputString.split(" ")
              $scope.ocrInput = inputWords
              Restangular.all("related").all("multipleWords").customPOST($scope.ocrInput).then((words) ->
                console.log "Words reloaded"
                maxWords = $scope.words.length            
                $scope.currIndex = 0
                $scope.words = words
                $scope.word = $scope.words[$scope.currIndex])
            (err) ->
              console.log err
          )       


])

app.animation(".slide-animation", ["$window", ($window) ->
  load: (element, done) ->
    scope = element.scope()
    TweenMax.to(element, 1, {opacity:1})

  beforeAddClass: (element, className, done) ->
    scope = element.scope()

    if className == 'ng-hide'
      console.log scope.direction
      finishPoint = element.parent().width()
      if scope.direction is 'left'
        console.log "reverse finish"
        finishPoint = -finishPoint
      console.log finishPoint
      TweenMax.to(element, 1, {left: finishPoint, onComplete: done, opacity:0 })
    else
      done()
    return
  removeClass: (element, className, done) ->
    scope = element.scope()

    if className == 'ng-hide'
      element.removeClass 'ng-hide'
      console.log scope.direction
      startPoint = element.parent().width()
      if scope.direction is 'right'
        console.log "reverse start"
        startPoint = -startPoint
      console.log startPoint

      TweenMax.set(element, { left: startPoint })
      currAnimation = TweenMax.to(element, 1, {left: 0, onComplete: done, opacity:1})
      console.log currAnimation.delay()
    else
      done()
    return
])


DialogController = ["$scope", "$mdDialog", "name", "definition",
  ($scope, $mdDialog, name, definition) ->
    $scope.name = name
    $scope.definition = definition

    $scope.hide = () ->
      $mdDialog.hide()

]

InputDialogController = ["$scope", "$mdDialog",
  ($scope, $mdDialog) ->
    $scope.word =""
    $scope.cancel = () ->
      console.log "Cancel clicked"
      $mdDialog.cancel()
    $scope.answer = () ->
      $mdDialog.hide($scope.word)
    $scope.hide = () ->
      $mdDialog.hide()

]

BottomSheetController = ["$scope", "$mdBottomSheet", "words",
  ($scope, $mdBottomSheet, words) ->
    $scope.words = words
    $scope.select = ($index) ->
      $mdBottomSheet.hide($scope.words[$index])
]