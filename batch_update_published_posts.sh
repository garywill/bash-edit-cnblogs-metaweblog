#!/bin/bash

script=$(readlink -f "$0")
scriptpath=$(dirname "$script")

CNBLOG_BLOG=    # 博客园博客名
ACCOUNT=       # 博客园用户名
PASSWD=        # metaweblog令牌

APIURL=https://rpc.cnblogs.com/metaweblog/$CNBLOG_BLOG


# 格式： postID|本地.md文件
# 注意：文章标题从.md文件的头部（适合hugo的格式）取得，而非从.md文件名
LIST="
12345678|article-1.md
87654321|article-2.md
"

for line in $LIST  
do
    POST_ID=${line%|*}
    ARTI_FILE=${line#*|}
    
    cp $scriptpath/$ARTI_FILE /dev/shm/arti.esc.md

    # 取得头部hugo部分
    head_range="$(grep -E "^---[[:space:]]*$"  -n -h -m 2 /dev/shm/arti.esc.md | cut -d ':' -f 1)"
    head_1="$(echo $head_range | cut -d ' ' -f 1 )"
    head_2="$(echo $head_range | cut -d ' ' -f 2 )"
    
    # 从hugo头取得标题
    POST_TITLE="$(sed -n ${head_1},${head_2}p /dev/shm/arti.esc.md | grep -E "^[[:space:]]*title[[:space:]]*:[[:space:]]*" | cut -d ':' -f 2 | sed 's/^[[:space:]]*\"//g' | sed 's/\"[[:space:]]*$//g' )"
    
    # 去掉hugo头
    sed -i ${head_1},${head_2}d /dev/shm/arti.esc.md

    # 去掉hugo变量 （如 {{< after_article >}} )
    sed -i 's/^[[:space:]]*{{<.*>}}//g' /dev/shm/arti.esc.md 
    # 转换 & < > 换行 等XML需要转换的字符
    sed -i 's/&/\&amp;/g' /dev/shm/arti.esc.md
    sed -i 's/</\&lt;/g' /dev/shm/arti.esc.md
    sed -i 's/>/\&gt;/g' /dev/shm/arti.esc.md
    sed -i 's/$/\&#x000A;/g' /dev/shm/arti.esc.md

    
    ARTI="$(cat '/dev/shm/arti.esc.md')"

    cat > /dev/shm/edit_post.xml << EOF
<?xml version="1.0"?>
    <methodCall>
    <methodName>metaWeblog.editPost</methodName>
    <params>
        <param>
            <value><string>$POST_ID</string></value>
        </param>
        <param>
            <value><string>$ACCOUNT</string></value>
        </param>
        <param>
            <value><string>$PASSWD</string></value>
        </param>
        <param>
            <value>
                    <struct>
                        <member>
                            <name>description</name>
                            <value>
                                <string>$ARTI</string>
                            </value>
                        </member>
                        <member>
                            <name>title</name>
                            <value>
                                <string>$POST_TITLE</string>
                            </value>
                        </member>
                        <member>
                            <name>categories</name>
                            <value>
                                <array>
                                    <data>
                                        <value>
                                            <string>[Markdown]</string>
                                        </value>
                                    </data>
                                </array>
                            </value>
                        </member>
                    </struct>
                </value>
        </param>
        <param>
            <value><boolean>1</boolean></value>
        </param>
    </params>
    </methodCall> 
EOF

    curl  $APIURL  -H "Content-Type: text/xml" --data @/dev/shm/edit_post.xml 
    rm /dev/shm/edit_post.xml   # 里面含有令牌
done
