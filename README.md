# 博客园已发文章批量编辑更新

This is a Bash script to use MetaWeblog API (sometimes called XML-RPC, a kind of old-school-designed API) to batch update a blog website's posts with local `.md` files.

Uses **`editPost`** method <<--- **Just this one**! No `newPost` or other features implimented.

我有一个水出来的IT博客，早已基本不发新文（我不是码农，年纪也大了），偶尔编辑一下旧文。这个bash脚本批量将 **博客园（cnblogs.com）** 内容与本地`.md`文件同步。

（请打开`.sh`文件自行编辑） 

## Dependencies

A simple Unix-like enviroment （模拟出来的也可以）及里面有：

- bash
- curl
