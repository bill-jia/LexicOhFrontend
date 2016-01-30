angular.module "coolnameFrontend"
  .factory("RecommendService", ["Restangular",
    (Retangular) ->
      model = "recommends"

      listWords: (userId) -> Restangular.one("users", userId).getList(model)
      getWord: (userId, wordId) -> Restangular.one("users", userId).one(model, wordId)
      updateWord: (word) -> word.put()
])