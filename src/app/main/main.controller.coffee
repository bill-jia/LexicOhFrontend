app = angular.module 'coolnameFrontend'

app.controller('MainController', ["$scope", "$timeout", "Restangular", "$mdDialog", "$mdMedia", "$mdToast", "$mdBottomSheet", "$speechRecognition", "$cordovaCamera", "$rootScope",
    ($scope, $timeout, Restangular, $mdDialog, $mdMedia, $mdToast, $mdBottomSheet, $speechRecognition, $cordovaCamera, $rootScope) ->


      maxWords = 2
      leftWords = []
      rightWords = []

      $scope.direction = "left"
      $scope.listening = false
      $scope.speechInput = []
      $scope.ocrInput = []
      $scope.customFullscreen = $mdMedia('xs') || $mdMedia('sm')
      $scope.words = [{word: "Potato", definition: "The best vegetable"}, {word: "Broccoli", definition: "The worst vegetable"}]
      $scope.currIndex = 0
      $scope.word = $scope.words[$scope.currIndex]
  		
      Restangular.all("related").getList().then((words) ->
        $scope.currIndex = 0
        maxWords = words.length
        $scope.words = words
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
          maxWords = words.length
          $scope.words = words
          $scope.word = words[$scope.currIndex]       
        )
      
      $scope.saveWord = () ->
        # POST word to words
        $scope.direction = "right"
        $scope.currIndex++
        console.log "Current index: " +$scope.currIndex
        console.log "Max words: " + maxWords
        rightWords.push($scope.word.word)

        if $scope.currIndex > maxWords-1
          Restangular.all("related").getList().then((words) ->
            console.log "Words reloaded"
            maxWords = words.length
            $scope.currIndex = 0
            $scope.words = words
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
          Restangular.all("words").customPOST(rightWords).then(Restangular.all("words").getList().then((words)->
            $scope.learnedWords = words
          ))
          rightWords = []
                     

      $scope.removeWord = () ->
        $scope.direction = "left"
        $scope.currIndex++
        console.log "Current index: " +$scope.currIndex
        console.log "Max words: " + maxWords
        leftWords.push($scope.word.word)
        
        if $scope.currIndex > maxWords-1
          Restangular.all("related").getList().then((words) ->
            console.log "Words reloaded"
            maxWords = words.length            
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

        Restangular.all("words").all("translation").customPOST({"destLang":"es", "word": $scope.word.word}).then(
          (translation) ->
            $scope.word.definition = translation
            $mdDialog.show({
              controller: DialogController
              templateUrl: "app/main/definition.html"
              parent: angular.element(document.body)
              targetEvent: ev
              clickOutsideToClose: true
              fullscreen: useFullScreen
              locals: {
                name: $scope.word.word
                definition: $scope.word.definition
              }
            })
        )



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
            maxWords = 1
            $scope.currIndex = 0
            $scope.words.push(word)
            $scope.word = $scope.words[currIndex]
        )

      document.addEventListener('deviceready', ()->
        console.log "Device ready", false)

      resetSpeechInput = () ->
        $scope.listening = false


      $scope.toggleSpeechInput = () ->
        if $scope.listening
          # $scope.recognition.stop()
          $scope.listening = false
          # console.log "Begin POST"
          console.log $scope.speechInput
          if $scope.speechInput.length > 0
            Restangular.all("related").all("multipleWords").customPOST($scope.speechInput).then((words) ->
              console.log "Words reloaded"
              maxWords = words.length            
              $scope.currIndex = 0
              $scope.words = words
              $scope.word = $scope.words[$scope.currIndex]
              $scope.speechInput = []
            )                    
        else
          $scope.listening = true
          window.plugins.speechrecognizer.startRecognize(
              ((result) ->
                $scope.listening = false
                tmpArray = result[0].split(" ")
                for word in tmpArray
                  $scope.speechInput.push word
                if $scope.speechInput.length > 0                  
                  Restangular.all("related").all("multipleWords").customPOST($scope.speechInput).then((words) ->
                    console.log "Words reloaded"
                    maxWords = words.length    
                    $scope.currIndex = 0
                    $scope.words = words
                    $scope.word = $scope.words[$scope.currIndex]
                    $scope.speechInput = []
                  )
              )
              ,((err) ->
                $scope.listening = false
                resetSpeechInput()
                console.log err)
            ,5) 



      $speechRecognition.onUtterance((utterance) ->
        tmpArray = utterance.split(" ")
        for word in tmpArray
          $scope.speechInput.push word

        console.dir $scope.speechInput
        $rootScope.$broadcast('finishedSpeechProcessing')
      )



      $scope.takePictureInput = () ->
        console.log "Taking photo"
        document.addEventListener "deviceready", () ->
          console.log "Device ready"
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
              # c = document.getElementById("placeholder")
              # ctx = c.getContext("2d")
              # image = document.getElementById('hiddenimage')
              # image.src = "data:image/jpeg;base64," + imageData
              # ctx.drawImage(image, 30, 30)
              inputString = OCRAD(c)
              inputString = inputString.replace(/[.,\/#!$%\^&\*;:{}=\-_`~()]/g,"")
              inputWords = inputString.split(" ")
              $scope.ocrInput = inputWords
              console.dir $scope.ocrInput
              Restangular.all("related").all("multipleWords").customPOST($scope.ocrInput).then((words) ->
                console.log "Words reloaded"
                maxWords = words.length            
                $scope.currIndex = 0
                $scope.words = words
                $scope.word = $scope.words[$scope.currIndex]
                Restangular.all("words").all("translation").customPOST({"destLang":"es", "word": $scope.word.word}).then((translation) -> $scope.word.definition = translation)  
                $scope.ocrInput = []
              )

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