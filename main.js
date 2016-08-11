Parse.Cloud.define('push', function (request, response) {

    console.log("============== START");
    var targetUser = new Parse.User();
    targetUser.id = request.params.recipientId;

    var query = new Parse.Query(Parse.Installation);
    query.equalTo('user', targetUser);

    console.log("============== recipientId:");
    console.log(request.params.recipientId);
    try {
      Parse.Push.send({
        where: query,
        data: {
          alert: request.params.message,
          badge: 1,
          sound: "Default"
        }
      }, {
        useMasterKey: true,
        success: function() {
          // Push was successful
          response.success('Success! ' + request.params.message);
        },
        error: function(error) {
          // Handle error
          response.error('Error hier?!' +error.code+":"+error.message);
        }
      });
    } catch(error)
    {
      console.log("error while send pn:"+error.code+":"+error.message);
    }

    console.log("============== END");
});

Parse.Cloud.define('testPush', function (request, response) {

    console.log("============== START");
    var targetUser = new Parse.User();
    targetUser.id = request.params.data["recipientId"];

    console.log("============== recipientId:");
    console.log(targetUser.id);

    var query = new Parse.Query(Parse.Installation);
    query.equalTo('user', targetUser);

    console.log("============== DATA:");
    console.log(request.params.data);

    try {
      Parse.Push.send({
        where: query,
        data: request.params.data
      }, {
        useMasterKey: true,
        success: function() {
          // Push was successful
          response.success('Success! ' + request.params.data);
        },
        error: function(error) {
          // Handle error
          response.error('Error hier?!' +error.code+":"+error.message);
        }
      });
    } catch(error)
    {
      console.log("error while send pn:"+error.code+":"+error.message);
    }

    console.log("============== END");
});
