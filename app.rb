require 'bundler'
Bundler.require
require 'tilt/erb'
require_relative 'lib/models'
require_relative 'lib/query'

class Actress < Sinatra::Base
  use Rack::Cors do
    allow do
      origins '*'
      resource '/api/*', headers: :any, methods: :get
    end
  end
  register Sinatra::ActiveRecordExtension

  configure :production do
    #set :dump_errors, false
  end

  helpers do
    def json(obj, options = {})
      content_type :json
      body obj.to_json(options)
    end

    def page
      [1, params[:page].to_i].max
    end
  end

  error ActiveRecord::RecordNotFound do
    e = env['sinatra.error']
    status 404
    json({message: e.to_s})
  end

  get '/api/encounters' do
    scope = Encounter.all
    scope = Query.build(scope, params[:q]) if params[:q].present?
    scope = scope.order('starttime DESC').paginate(page, 50)
    json({data: scope, next: scope.next_page, prev: scope.prev_page})
  end

  get '/api/encounters/:encid' do |encid|
    encounter = Encounter.find encid
    json({data: encounter})
  end

  get '/api/names' do
    names = Combatant.friendly.by_name(params[:q]).select(:name).uniq.limit(200).pluck(:name)
    json({data: names})
  end

  get '/api/encounters/:encid/combatants' do |encid|
    encounter = Encounter.find encid
    json({data: encounter.combatants})
  end

  get '/api/encounters/:encid/swings' do |encid|
    encounter = Encounter.find encid
    scope = encounter.swings.order('stime ASC')
    scope = scope.where(attacker: params[:name]) if params[:name].present?
    scope = scope.order('stime ASC')
    json({data: scope})
  end

  get '/api/*' do
    status 404
    json({data: 'Not found'})
  end

  get '*' do
    erb :index
  end
end
