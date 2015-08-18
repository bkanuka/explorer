import interactor from '../lib/job/interactor.js'
import util from 'util'

let debug = require('debug')('explorer:middlewares:notify')

function notify(req, res, next) {
    
  if(!interactor.ipc) {
    debug('No interactor')
    res.locals.notifications = {num: 0}
    return next()
  }

  interactor.ipc.once('info', function(data) {

    debug('Notifications %o', data)

    let num = 0
    let user_data = {}

    if(!req.user) {
      res.locals.notifications = {num: num}
      return next()
    }

    let notifications = {}
    let username = req.user.username

    for(var plugin in data) {
      if(typeof data[plugin] == 'object') {
        if(username in data[plugin]) {
          num += Object.keys(data[plugin][username]).length
          user_data[plugin] = data[plugin][username]
        } else {
          user_data[plugin] = {} 
        }
      }
    }

    debug('User notifications %o', user_data)

    res.locals.notifications = util._extend({num: num}, user_data)

    return next()
  })

  interactor.ipc.send('info')
}

export default notify