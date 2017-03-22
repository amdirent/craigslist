# coding: utf-8
require 'post_helpers'
class Craigslist < Sinatra::Base
  include PostHelpers

  set :views, File.join($root, 'views')

  get('/') { erb :index }

  get('/unprocessed') do
    @unprocessed = DB.pool do |c|
      c.exec_prepared 'get first unprocessed'
    end.first

    @default_from = "#{request.session['user']}@amdirent.com"

    erb :unprocessed
  end

  post('/process/:id') do
    if params['bad']

      entry = DB.pool do |c|
        c.exec_prepared('mark bad', [params['id']])
      end.first

    elsif params['good']

      email_from    = params['email_from']
      email_subject = params['email_subject']
      email_text    = params['email_body']
      email_html    = markdown(params['email_body'], autolink: true)

      mail = Mail.new do
        from email_from
        subject email_subject

        text_part do
          body email_text
        end

        html_part do
          content_type 'text/html; charset=UTF-8'
          body email_html
        end
      end

      entry = DB.pool do |c|
        c.exec_prepared('mark good', [params['id'], mail.to_s])
      end.first
    else
      return json_halt('{ "message" : "Invalid Status" }', 400)
    end

    return json_halt('{ "message" : "Invalid entry" }', 400) if entry.nil?

    redirect('/unprocessed')    
  end

  get('/unemailed') do
    @unemailed = DB.pool do |c|
      c.exec_prepared 'get first unemailed'
    end.first

    erb :unemailed
  end

  post('/send-mail/:id') do
    if params['invalid']
      entry = DB.pool do |c|
        c.exec_prepared('mark bad', [params['id']])
      end.first

      return json_halt('{ "message" : "Invalid entry" }', 400) if entry.nil?
    else
      return json_halt('{ "message": "No email given" }', 400) if params['email'].nil?

      entry = DB.pool do |c|
        c.exec_prepared('fetch post', [params['id']])
      end.first

      return json_halt('{ "message" : "Invalid entry" }', 400) if entry.nil?

      mail = Mail.new(entry['email'])

      mail.to = params['email']

      print mail.from

      Mailer.send_mail({ to: mail.to.map { |e| { email: e } },
                         from_email: mail.from.first,
                         subject: mail.subject,
                         text: mail.text_part.body.to_s.force_encoding('utf-8'),
                         html: mail.html_part.body.to_s.force_encoding('utf-8'),
                         metadata: { post_id: entry['id'] }
                       })

      DB.pool do |c|
        c.exec_prepared('update with mail', [params['id'], mail.to_s])
      end
    end

    redirect '/unemailed'
  end

  private

  def json_halt(message, status=500)
    halt status, { 'Content-Type' => 'application/json' }, message
  end

  EMAIL_TEMPLATE = <<EMAIL
Hello,

In response to your post on Craigslist, I’d like to help build your project.  My team and I have extensive experience in building production web and mobile applications as well as data warehousing platforms.

I’ve included my and my partner's LinedIn profiles below for your review. I’m sure we can develop a great product for you faster and with better performance than you’ll receive from most “Craigslist types”.

Please let me know when a good time to discuss your project will be. You can even get a free rough estimate for your project from our website. It’s not 100% accurate but if you request a proposal we can do a custom one for you.

Go to our site to get an instant estimate of your project: http://amdirent.com

Here are links to our LinkedIn profiles:

* https://www.linkedin.com/in/christopher-rankin-b7841155/
* https://www.linkedin.com/in/jordan-prince-20764220/

Thanks,

Chris
EMAIL
end
