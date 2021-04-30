require 'sinatra'
require 'json'
require 'sinatra/reloader' #TODO: 後で消す


set :bind, '0.0.0.0'
#enable :method_override

class Memo

  def id_title_list
    #title 一覧を返す
    File.open("data.json") do |file|
      hash = JSON.load(file)
      hash.each.map do |id, value|
        [id, value["title"]]
      end
    end
  end

  def detail(id)
    #id を元にして、その id に対応するメモの詳細を返す
    File.open("data.json") do |file|
      hash = JSON.load(file)
      hash[id]
    end
  end

  def add(title, content)
    # title と content を file/DB に登録する
    hash = File.open("data.json") do |file|
      JSON.load(file)
    end

    hash[new_id] = {"title" => title, "content" => content}

    File.open("data.json", "w") do |f|
      f.write(JSON.dump(hash))
    end
  end

  def edit(id, title, content)
    hash = File.open("data.json") do |file|
      JSON.load(file)
    end

    hash[id] = {"title" => title, "content" => content}

    File.open("data.json", "w") do |f|
      f.write(JSON.dump(hash))
    end
  end

  def delete(id)
    # id で指定された項目を削除する
    hash = File.open("data.json") do |file|
      JSON.load(file)
    end

    hash.delete(id)

    File.open("data.json", "w") do |f|
      f.write(JSON.dump(hash))
    end
  end

  private

  def new_id
    hash = File.open("data.json") do |file|
      JSON.load(file)
    end
    ids = hash.each_key.map { |id| id.to_i }
    (ids.max + 1).to_s
  end
end

helpers do
    def h(text)
      Rack::Utils.escape_html(text)
    end
end

get "/" do
  @url = "#{request.scheme}://#{request.host}:#{request.port}"
  @id_title_list = Memo.new.id_title_list
  erb :index
end

get "/detail/:id" do
  @id = params[:id]
  detail = Memo.new.detail(@id)
  @title = detail["title"]
  @content = detail["content"]
  erb :detail
end

# 編集
get "/detail/:id/edit" do
  @id = params[:id]
  detail = Memo.new.detail(@id)
  @title = detail["title"]
  @content = detail["content"]
  erb :edit
end

put "/detail/:id/edit" do
  @id = params[:id]
  @title = params[:title] 
  @content = params[:content] 
  Memo.new.edit(@id, @title, @content)
  redirect '/'
  erb :index
end

# 削除
delete "/detail/:id" do
  @id = params[:id]
  Memo.new.delete(@id)
  redirect '/'
  erb :index
end

# 新規作成
get "/new" do 
  erb :new
end

post "/new" do 
  @title = params[:title] 
  @content = params[:content] 
  Memo.new.add(@title, @content)
  redirect '/'
  erb :index
end
