angular.module "coolnameFrontend"
  .factory("UserService", ["Restangular",
    (Restangular) ->

      model = "users"

      getUser: (userId) -> Restangular.one(model, userId).get()
      updateUser: (user) -> user.put()
])