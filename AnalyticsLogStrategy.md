        0 判断是否达到写入上限值，未达到，执行1 达到，上限值置0，workpath置nil 
        1 判断write path是否存在
        2 write path不存在 创建 write path 执行4
        3 write path存在  执行4
        4 判断path下是否存在文件
        5 不存在，在path下创建文件 执行7
        6 存在 执行 7
        7 获取Filehandle  [NSFileHandl fileHandleForUpdatingAtPath:self.filePath]; 写入数据
        8 判断数据条目是否达到指定值比如1000
        9 达到指定值 执行11
        10 未达到指定值 执行1 
        11 文件移动到指定upload目录 write path 置nil
        12 给并行队列添加barrier block ,上传upload目录下的文件

