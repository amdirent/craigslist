class Craigslist::Authorizer < Sinatra::Base
  set :views, Craigslist.views

  get('/login') do
    redirect '/' if session['user']

    erb :login
  end

  get('/logout') do
    session.delete('user')

    redirect('/login')
  end

  post('/login') do
    if params['password'] == ENV['PASSWD']
      session['user'] = params['user']
      redirect '/'
    else
      redirect '/login'
    end
  end

  get('*') do
    redirect '/login' unless session['user']

    pass
  end
end
