# Rails の ActiveRecord#order メソッドでSQL injectionを防ぐコードの検証

## 結論：どうすればいいか

```
Model.order(key => value)
```

と書けば良さそう
