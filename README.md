# Rails の ActiveRecord#order メソッドでSQL injectionを防ぐコードの検証

## 結論：どうすればいいか

```
Model.order(key => value)
```

と書けば良さそう

## 実行環境

Ruby 2.7.2

## 実行方法

```
ruby active_record_main.rb
```
