#@+leo-ver=5
#@+node:@button pandoc_auto
#@@language python
import os
import re

def atoi(text):
    return int(text) if text.isdigit() else text

def natural_keys(text):
    '''
    alist.sort(key=natural_keys) sorts in human order
    http://nedbatchelder.com/blog/200712/human_sorting.html
    (See Toothy's implementation in the comments)
    '''
    return [ atoi(c) for c in re.split('(\d+)', text) ]
'''
c is the commander of the outline containing the script.
g is Leo's leo.core.leoGlobals module.
p is the presently selected position, the same as c.p.
'''
d = c.scanAllDirectives(p)
#g.es(d)
# d 為 commander 由目前所在目錄進行指令設定掃描
# d 資料格式為 dictionary
''' 
實際操作下, d 為 
{'tabwidth': -4, 'lineending': None, 'language': 'python', 'encoding': None, 'pluginsList': [], 'pagewidth': 70, 'wrap': True, 'path': 'D:\\github\\mdeCourse\\2013spring', 'delims': ('#', '', '')}
'''
# 在處理 pandoc 之前,  將協同人員上傳的 file1.txt 與 file2.txt 結合為 demo.txt
# 以下採用 os.walk 自動進入目錄取出目錄與檔案名稱後, 採自然排序
# 最後再利用 insert 將標題頁面放入數列最前頭
'''
# 這裡是原先使用的手動檔名排序數列, 好處為可以任意編排次序
filenames = ['title.txt', '2bg1/doc.txt', '2bg2/doc.txt', '2bg3/doc.txt', '2bg5/doc.txt', '2bg15/doc.txt', '2bg13/doc.txt', '2bg9/doc.txt']
'''
# 定義要合併檔案的共同目錄
directory = "V:/project/2014cda-W13/wsgi/doc/"
# 定義一個空數列
filenames = []
for (path, dirs, files) in os.walk(directory):
    for fname in files:
        # 利用 if 判斷式將外部的 title.txt 與其他檔案隔開不取
        if path != directory:
            filenames.append(path+"/"+fname)
# 依照 natural_keys 客製化排序, 使用上面的函式定義
filenames.sort(key=natural_keys)
# 利用 insert 以 0 為索引, 將 title.txt 放在數列最前頭
filenames.insert(0, directory+"title.txt")
# 以下將依據 filenames 數列中的檔案合併為 result.txt 之後再進行文書處理轉換
with open('V:/project/2014cda-W13/wsgi/pandoc/result.txt', 'w', encoding="utf-8") as outfile:
    for fname in filenames:
        #fname = directory+fname
        with open(fname, encoding="utf-8") as infile:
            for line in infile:
                outfile.write(line)
            outfile.write("\n\n")

# 將目錄指到 pandoc
mandir = d.get('path') + "/wsgi/pandoc"
g.es(mandir)
os.chdir(mandir)
# 先轉一份 html 
os.system("V:\\apps\\pandoc\\pandoc.exe -s result.txt -o result.html")
# 利用 pandoc 將 demo.txt 轉為 demo.tex, 在此決定是否要有 toc
os.system("V:\\apps\\pandoc\\pandoc.exe -s result.txt --toc -o result.tex")
# 中文設定必須要放在 begin document 之前
setup = ''' 
\\usepackage{xeCJK}    % 中英文字行分開設置 
\\usepackage[T1]{fontspec}    %設定字體用 
\\usepackage{graphicx} 
\\usepackage{fancyvrb} % for frame on Verbatim 
\\setCJKmainfont{新細明體}
'''
# 在 demo.tex 最前頭加上"中文設定"
file = open("result.tex", "r", encoding="utf-8")
lines = file.read().splitlines()
file.close()
file = open("result.tex", "w", encoding="utf-8")
for i in range(len(lines)):
    # 設法將中文設定放在文件開始之前, 以便蓋掉之前的設定
    if "\\begin{document}" in lines[i]:
        file.write(setup+lines[i]+"\n")
    else:
        file.write(lines[i]+"\n")
file.close()
target_name = "result"
filename = target_name+".tex"
os.system("V:\\apps\\miktex-portable\\miktex\\bin\\xelatex.exe -no-pdf -interaction=nonstopmode "+filename)
os.system("V:\\apps\\miktex-portable\\miktex\\bin\\xelatex.exe -no-pdf -interaction=nonstopmode "+filename)
filename = target_name+".xdv"
os.system("V:\\apps\\miktex-portable\\miktex\\bin\\xdvipdfmx.exe -vv -E "+filename)

filename = target_name+".pdf"
os.system(filename)
#@-leo

