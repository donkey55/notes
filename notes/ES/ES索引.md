反向索引Index

一个索引的内容被分片存储到多个服务器上

每一个分片是一个Lucene index

## Lucene

在lucene里面有很多小的segment，我们可以把他们看作lucene内部的mini-index

### segment内部

主要有以下几个部分：

- Inverted Index
- Stored Fields
- Document Values
- Cache

