# frozen_string_literal: true

require "bundler/inline"

# 引用元: https://raw.githubusercontent.com/rails/rails/main/guides/bug_report_templates/active_record_main.rb
# RailsリポジトリのLICENSE: https://github.com/rails/rails/blob/main/MIT-LICENSE

gemfile(true) do
  source "https://rubygems.org"

  git_source(:github) { |repo| "https://github.com/#{repo}.git" }

  gem "rails", github: "rails/rails", branch: "main"
  gem "sqlite3"
end

require "active_record"
require "minitest/autorun"
require "logger"

# This connection will do for database-independent bug reports.
ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
ActiveRecord::Base.logger = Logger.new(STDOUT)

ActiveRecord::Schema.define do
  create_table :users, force: true do |t|
    t.text :name
    t.text :email
  end
end

class User < ActiveRecord::Base
end

class BugTest < Minitest::Test
  def test_sql_injection
    User.create!(name: 'hoge', email: 'hoge@example.com')

    p User.all

    # 参考: https://rails-sqli.org/
    p User.order('email, 1').to_sql
    p User.order('email, 1')
    column = 'email'
    direction = ', 1'
    # orderなのに、Userのカラムを取得してしまう
    p User.order("#{column} #{direction}").to_sql
    p User.order("#{column} #{direction}")

    p '~' * 100
    # こうすればSQL injectionが無効化されて、埋め込まれたSQLが実行されなくなる
    p User.order(column => direction).to_sql
    p User.order(column => direction)
    # Error:
    # BugTest#test_sql_injection:
    # ArgumentError: Direction ", 1" is invalid. Valid directions are: [:asc, :desc, :ASC, :DESC, "asc", "desc", "ASC", "DESC"]
    #     /Users/nabetani.satoshi/.rbenv/versions/2.7.2/lib/ruby/gems/2.7.0/bundler/gems/rails-168ddaa08a63/activerecord/lib/active_record/relation/query_methods.rb:1475:in `block (2 levels) in validate_order_args'
    #     /Users/nabetani.satoshi/.rbenv/versions/2.7.2/lib/ruby/gems/2.7.0/bundler/gems/rails-168ddaa08a63/activerecord/lib/active_record/relation/query_methods.rb:1473:in `each'
    #     /Users/nabetani.satoshi/.rbenv/versions/2.7.2/lib/ruby/gems/2.7.0/bundler/gems/rails-168ddaa08a63/activerecord/lib/active_record/relation/query_methods.rb:1473:in `block in validate_order_args'
    #     /Users/nabetani.satoshi/.rbenv/versions/2.7.2/lib/ruby/gems/2.7.0/bundler/gems/rails-168ddaa08a63/activerecord/lib/active_record/relation/query_methods.rb:1471:in `each'
    #     /Users/nabetani.satoshi/.rbenv/versions/2.7.2/lib/ruby/gems/2.7.0/bundler/gems/rails-168ddaa08a63/activerecord/lib/active_record/relation/query_methods.rb:1471:in `validate_order_args'
    #     /Users/nabetani.satoshi/.rbenv/versions/2.7.2/lib/ruby/gems/2.7.0/bundler/gems/rails-168ddaa08a63/activerecord/lib/active_record/relation/query_methods.rb:1488:in `preprocess_order_args'
    #     /Users/nabetani.satoshi/.rbenv/versions/2.7.2/lib/ruby/gems/2.7.0/bundler/gems/rails-168ddaa08a63/activerecord/lib/active_record/relation/query_methods.rb:385:in `order!'
    #     /Users/nabetani.satoshi/.rbenv/versions/2.7.2/lib/ruby/gems/2.7.0/bundler/gems/rails-168ddaa08a63/activerecord/lib/active_record/relation/query_methods.rb:380:in `order'
    #     /Users/nabetani.satoshi/.rbenv/versions/2.7.2/lib/ruby/gems/2.7.0/bundler/gems/rails-168ddaa08a63/activerecord/lib/active_record/querying.rb:22:in `order'
    #     active_record_main.rb:65:in `test_sql_injection'
  end
end
