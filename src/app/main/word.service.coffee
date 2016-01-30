angular.module "coolnameFrontend"
  .factory("WordService", ["Restangular",
    (Retangular) ->
      model = "words"

      listWords: (userId) -> Restangular.one("users", userId).getList(model)
      getWord: (wordId) -> Restangular.one(model, wordId).get()
      updateWord: (word) -> word.put()
])